# Built with

- elixir 1.8.1-otp-21 (using asdf)
- erlang 21.2.2 (asdf)

# Setup: host development

```
export MIX_TARGET=host
mix deps.get
iex -S mix
```

This should open the scenic scene for you and an iex prompt.

# Setup: firmware and hardware

Assuming your device is a Raspberry Pi 3. Otherwise change the target accordingly and figure out if you need more changes to run the screen. Scenic has a driver for the official 7" display.

```
export MIX_TARGET=rpi3
mix deps.get
mix firmware

```

And if you need to burn an SD card:

```
mix firmware.burn
```

If you need to push to an existing Nerves device:

```
mix firmware.gen.script
./upload.sh
```
