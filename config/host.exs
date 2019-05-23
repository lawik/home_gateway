use Mix.Config

config :home_gateway, :viewport, %{
  name: :main_viewport,
  default_scene: {HomeGateway.Scene.Main, nil},
  size: {800, 480},
  opts: [scale: 1.0],
  drivers: [
    %{
      module: Scenic.Driver.Glfw,
      opts: [title: "MIX_TARGET=host, app = :example_scenic_nerves"]
    }
  ]
}

config :file_system, :fs_inotify, executable_file: "deps/file_system/priv/mac_listener"

# case :os.type() do
#   {:unix, :darwin} ->

#   _ ->
#     nil
# end

config :my_sensors, MySensors.Repo,
  adapter: Sqlite.Ecto2,
  database: "my_sensors_#{Mix.env()}.sqlite",
  loggers: []
