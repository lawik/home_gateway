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
    graph = chart(background_color)
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
      values: []
    }

    {:ok, state, push: graph}
  end

  defp chart(background_color, values \\ []) do
    value_items = Enum.reduce(values, 0, fn line, value_count ->
      max(value_count, length(line))
    end)

    value_top = Enum.reduce(values, 0, fn line, value_top ->
      Enum.reduce(line, 0, &max/2)
    end)

    value_bottom = Enum.reduce(values, 0, fn line, value_bottom ->
      Enum.reduce(line, 0, &min/2)
    end)

    graph =
      Graph.build(font: @default_font, font_size: @default_font_size)
      #|> rectangle(@default_chart_dimensions, fill: background_color)

    IO.puts("Items:")
    IO.inspect(value_items)
    {width, height} = @default_chart_dimensions
    graph = if value_items > 0 do
      line_length = width/value_items
      IO.puts("Length:")
      IO.inspect(line_length)
      value_range = value_top-value_bottom
      line_multiplier = height/(value_range)
      IO.puts("Multiplier:")
      IO.inspect(line_multiplier)
      
      graph = Enum.reduce(values, graph, fn dataset, graph ->
        {graph, _} = Enum.reduce(dataset, {graph, nil}, fn value, {graph, last_pos} ->
          target_y = (value-value_bottom)*line_multiplier
          {last_x, _last_y} = last_pos = case last_pos do
            nil -> {0, target_y}
            _ -> last_pos
          end

          target_pos = {last_x+line_length, target_y}
          line_data = {last_pos, target_pos}
          IO.inspect(line_data)
          graph = graph
          |> line(line_data, fill: :green, stroke: {3, :green})
          {graph, target_pos}
        end)
        graph
      end)

      IO.inspect(graph)

      graph
    else
      graph
    end
  end

  def handle_info({:my_sensors, {:insert_or_update, %SensorValue{sensor_id: sensor_id} = sv}}, %{sensor_id: sensor_id2} = state) when sensor_id == sensor_id2 do
    values = state.values
    IO.inspect(values)
    first_line = List.first(values)
    values = case first_line do
      nil -> [[sv.value]]
      _ -> [first_line ++ [sv.value]]
    end

    IO.inspect(values)
    
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