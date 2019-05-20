defmodule HomeGateway.MixProject do
  use Mix.Project

  @all_targets [:rpi, :rpi0, :rpi2, :rpi3, :rpi3a, :bbb, :x86_64]
  @target System.get_env("MIX_TARGET") || "host"

  def project do
    [
      app: :home_gateway,
      version: "0.1.0",
      elixir: "~> 1.8",
      archives: [nerves_bootstrap: "~> 1.5"],
      start_permanent: Mix.env() == :prod,
      build_embedded: true,
      aliases: [loadconfig: [&bootstrap/1]],
      deps: deps(@target)
    ] ++ my_sensors_mysgw_config(@target)
  end

  # Starting nerves_bootstrap adds the required aliases to Mix.Project.config()
  # Aliases are only added if MIX_TARGET is set.
  def bootstrap(args) do
    Application.start(:nerves_bootstrap)
    Mix.Task.run("loadconfig", args)
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {HomeGateway.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp deps("host") do
    deps(nil) ++ [
      {:scenic_driver_glfw, "~> 0.10"}
    ]
  end

  defp deps(target) when target in @all_targets do
    deps(nil) ++
      [
        # Dependencies for all targets except :host
        {:nerves_runtime, "~> 0.6", targets: @all_targets},
        {:nerves_init_gadget, "~> 0.4", targets: @all_targets},

        # Dependencies for specific targets
        {:scenic_driver_nerves_rpi, "~> 0.10", target: @all_targets},
        {:scenic_driver_nerves_touch, "~> 0.9", targets: @all_targets},
        {:my_sensors, path: "../my_sensors", targets: @all_targets},
        {:my_sensors_mysgw, path: "../my_sensors_mysgw", targets: @all_targets},
        {:nerves_system_rpi, "~> 1.6", runtime: false, targets: :rpi},
        {:nerves_system_rpi0, "~> 1.6", runtime: false, targets: :rpi0},
        {:nerves_system_rpi2, "~> 1.6", runtime: false, targets: :rpi2},
        {:nerves_system_rpi3, "~> 1.6", runtime: false, targets: :rpi3},
        {:nerves_system_rpi3a, "~> 1.6", runtime: false, targets: :rpi3a},
        {:nerves_system_bbb, "~> 2.0", runtime: false, targets: :bbb},
        {:nerves_system_x86_64, "~> 1.6", runtime: false, targets: :x86_64}
      ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps(_) do
    [
      # Dependencies for all targets
      {:nerves, "~> 1.4", runtime: false},
      {:shoehorn, "~> 0.4"},
      {:ring_logger, "~> 0.6"},
      {:toolshed, "~> 0.2"},
      {:scenic, "~> 0.10.0"}
    ]
  end

  defp my_sensors_mysgw_config("rpi0"),
    do: [
      my_sensors_transport: "rfm69",
      my_sensors_irq_pin: "22",
      my_sensors_cs_pin: "24",
      my_sensors_leds: "true",
      my_sensors_leds_inverse: "true",
      my_sensors_err_led_pin: "33",
      my_sensors_rx_led_pin: "29",
      my_sensors_tx_led_pin: "31",
      my_sensors_mysgw_spi_dev: "/dev/spidev0.0",
      my_sensors_rfm69hw: "true"
    ]

  defp my_sensors_mysgw_config("rpi3"),
    do: [
      my_sensors_transport: "rfm69",
      my_sensors_irq_pin: "22",
      my_sensors_cs_pin: "24",
      my_sensors_leds: "true",
      my_sensors_leds_inverse: "true",
      my_sensors_err_led_pin: "33",
      my_sensors_rx_led_pin: "29",
      my_sensors_tx_led_pin: "31",
      my_sensors_mysgw_spi_dev: "/dev/spidev0.0",
      my_sensors_rfm69hw: "true"
    ]

  defp my_sensors_mysgw_config(_), do: []
end
