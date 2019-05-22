defmodule HomeGateway.Scene.Main do
  use Scenic.Scene
  alias Scenic.Graph

  alias HomeGateway.Components.{Sensor, LineChart}

  @graph Graph.build(font_size: 22, font: :roboto_mono, theme: :light)
  |> Sensor.add_to_graph({nil, "Temperature"})
  |> LineChart.add_to_graph({nil, "Temperature", []}, t: {128, 128})

         # |> group(
         #   fn g ->
         #     g
             
         #     |> text(" ", translate: {10, 20}, font_size: 18)
         #   end,
         #   t: {10, 30}
         # )
         # |> group(
         #   fn g ->
         #     g
         #     |> text("ViewPort")
         #     |> text("", translate: {10, 20}, font_size: 18, id: :vp_info)
         #   end,
         #   t: {10, 110}
         # )
         # |> group(
         #   fn g ->
         #     g
         #     |> text("Input Devices")
         #     |> text("Devices are being loaded...",
         #       translate: {10, 20},
         #       font_size: 18,
         #       id: :devices
         #     )
         #   end,
         #   t: {280, 30},
         #   id: :device_list
         # )

  # --------------------------------------------------------
  def init(_, _) do
    #:ok = Broadcast.subscribe()
    
    {:ok, @graph, push: @graph}
  end

  # unless @target == "host" do
  #   # --------------------------------------------------------
  #   # Not a fan of this being polling. Would rather have InputEvent send me
  #   # an occasional event when something changes.
  #   def handle_info(:update_devices, graph) do
  #     Process.send_after(self(), :update_devices, 1000)

  #     devices =
  #       InputEvent.enumerate()
  #       |> Enum.reduce("", fn {_, device}, acc ->
  #         Enum.join([acc, inspect(device), "\r\n"])
  #       end)

  #     # update the graph
  #     graph = Graph.modify(graph, :devices, &text(&1, devices))

  #     {:noreply, graph, push: graph}
  #   end
  # end

end
