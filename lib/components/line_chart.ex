defmodule HomeGateway.Components.LineChart do
  use Scenic.Component, has_children: false

  alias Scenic.Graph
  alias Scenic.Primitive.Style.Theme
  import Scenic.Primitives

  alias MySensors.{Broadcast, SensorValue}

  @default_font :roboto
  @default_font_size 20
  @default_chart_dimensions {340, 260}

  # --------------------------------------------------------
  @doc false
  def info(data) do
    """
    #{IO.ANSI.red()}Sensor data must be a tuple: {sensor_id, text_label}
    #{IO.ANSI.yellow()}Received: #{inspect(data)}
    #{IO.ANSI.default_color()}
    """
  end

  # --------------------------------------------------------
  @doc false
  def verify(data) when is_tuple(data), do: {:ok, data}
  def verify(_), do: :invalid_data

  # --------------------------------------------------------
  @doc false
  def init({sensor_id, label, values}, opts) when is_bitstring(label) and is_list(opts) do
    id = opts[:id]
    styles = opts[:styles]

    # theme is passed in as an inherited style
    theme =
      (styles[:theme] || Theme.preset(:primary))
      |> Theme.normalize()

    background_color = 
      case theme do
         :dark -> :dim_gray
         :light -> :light_gray
         _ -> :gray
      end

    # build the graph
    graph = chart(background_color, values)
      #|> do_aligned_text(:label, :center, text, theme.text, label_width, label_vpos+value_vpos, font_size)

    :ok = Broadcast.subscribe()

    state = %{
      graph: graph,
      theme: theme,
      pressed: false,
      contained: false,
      sensor_id: sensor_id,
      styles: styles,
      opts: opts,
      id: id,
      background_color: background_color,
      values: values
    }

    {:ok, state, push: graph}
  end

  defp chart(background_color, values) do
    value_items = Enum.reduce(values, 0, fn line, value_count ->
      max(value_count, length(line))
    end)

    value_top = Enum.reduce(values, 0, fn line, value_top ->
      Enum.reduce(line, value_top, &max/2)
    end)
    
    value_bottom = Enum.reduce(values, value_top, fn line, value_bottom ->
      Enum.reduce(line, value_bottom, &min/2)
    end)

    graph =
      Graph.build(font: @default_font, font_size: @default_font_size)
      |> rectangle(@default_chart_dimensions, fill: background_color)

    {width, height} = @default_chart_dimensions
    if value_items > 0 do
      line_length = width/value_items
      value_range = value_top-value_bottom
      value_range = case value_range do
        0.0 -> 1.0
        _ -> value_range
      end
      line_multiplier = height/(value_range)

      path_commands = Enum.reduce(values, [], fn dataset, commands ->
        {command_list, _} = Enum.reduce(dataset, {[:begin], nil}, fn value, {command_list, last_pos} ->
          target_y = height-(((value-value_bottom)*line_multiplier))  # Reverse y coordinates and start at the bottom
           {last_pos, command_list} = case last_pos do
            nil -> 
              {{0, target_y}, [{:move_to, 0, target_y} | command_list]}
            _ -> {last_pos, command_list}
          end

          {last_x, _last_y} = last_pos

          target_x = last_x+line_length
          {[{:line_to, target_x, target_y} | command_list], {target_x, target_y}}
        end)
        [command_list | commands]
      end)

      Enum.reduce(path_commands, graph, fn command_list, graph ->
        command_list = Enum.reverse(command_list)
        graph
        |> path(command_list, stroke: {3, :green}, join: :round)
      end)
    else
      graph
    end
  end

  def handle_info({:my_sensors, {:insert_or_update, %SensorValue{sensor_id: sensor_id} = sv}}, %{sensor_id: sensor_id2} = state) when sensor_id == sensor_id2 do
    values = state.values
    first_line = List.first(values)
    values = case first_line do
      nil -> [[sv.value]]
      _ -> [first_line ++ [sv.value]]
    end
    
    graph = chart(state.background_color, values)
    state = state
    |> Map.put(:graph, graph)
    |> Map.put(:values, values)
    {:noreply, state, push: graph}
  end

  def handle_info({:my_sensors, _}, graph) do
    {:noreply, graph}
  end
end