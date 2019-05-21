defmodule HomeGateway.Components.Sensor do
  use Scenic.Component, has_children: false

  alias Scenic.Graph
  alias Scenic.Primitive
  alias Scenic.ViewPort
  alias Scenic.Primitive.Style.Theme
  import Scenic.Primitives

  alias MySensors.{Broadcast, SensorValue}

  @default_font :roboto
  @default_font_size 20
  @default_alignment :center

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
  def init({sensor_id, text}, opts) when is_bitstring(text) and is_list(opts) do
    id = opts[:id]
    styles = opts[:styles]

    # theme is passed in as an inherited style
    theme =
      (styles[:theme] || Theme.preset(:primary))
      |> Theme.normalize()

    # font related info
    font = @default_font
    font_size = @default_font_size
    #value_font_size = @default_font_size + 8
    fm = Scenic.Cache.Static.FontMetrics.get!(font)
    ascent = FontMetrics.ascent(font_size, fm)
    descent = FontMetrics.descent(font_size, fm)
    fm_width = FontMetrics.width(text, font_size, fm)

    width =
      case styles[:width] || opts[:w] do
        nil -> fm_width + ascent + ascent
        :auto -> fm_width + ascent + ascent
        width when is_number(width) and width > 0 -> width
      end

    height =
      case styles[:height] || opts[:h] do
        nil -> font_size + ascent
        :auto -> font_size + ascent
        height when is_number(height) and height > 0 -> height
      end

    alignment = styles[:alignment] || @default_alignment

    vpos = height / 2 + ascent / 2 + descent / 3

    # build the graph
    graph =
      Graph.build(font: font, font_size: font_size)
      |> do_aligned_text(:value, :center, "?", theme.text, width, vpos)
      |> do_aligned_text(:label, :center, text, theme.text, width, vpos)

    :ok = Broadcast.subscribe()

    state = %{
      vpos: vpos,
      graph: graph,
      theme: theme,
      pressed: false,
      contained: false,
      align: alignment,
      sensor_id: sensor_id,
      id: id
    }

    {:ok, state, push: graph}
  end

  defp do_aligned_text(graph, id, :center, text, fill, width, vpos) do
    text(graph, text,
      fill: fill,
      translate: {width / 2, vpos},
      text_align: :center,
      id: id
    )
  end

  defp do_aligned_text(graph, id, :left, text, fill, _width, vpos) do
    text(graph, text,
      fill: fill,
      translate: {8, vpos},
      text_align: :left,
      id: id
    )
  end

  defp do_aligned_text(graph, id, :right, text, fill, width, vpos) do
    text(graph, text,
      fill: fill,
      translate: {width - 8, vpos},
      text_align: :right,
      id: id
    )
  end

  def handle_info({:my_sensors, {:insert_or_update, %SensorValue{sensor_id: sensor_id} = sv}}, %{sensor_id: sensor_id2} = state) when sensor_id == sensor_id2 do
    display_value = Float.to_string(Float.round(sv.value, 2))
    graph = state.graph
    |> Graph.modify(:value, &text(&1, display_value))

    Map.put(state, :graph, graph) 

    {:noreply, state, push: graph}
  end

  def handle_info({:my_sensors, _}, graph) do
    {:noreply, graph}
  end
end