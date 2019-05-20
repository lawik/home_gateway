use Mix.Config

config :home_gateway, :viewport, %{
  name: :main_viewport,
  default_scene: {HomeGateway.Scene.SysInfo, nil},
  size: {800, 480},
  opts: [scale: 1.0],
  drivers: [
    %{
      module: Scenic.Driver.Glfw,
      opts: [title: "MIX_TARGET=host, app = :example_scenic_nerves"]
    }
  ]
}
