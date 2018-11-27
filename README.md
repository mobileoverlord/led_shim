# LEDShim

A [nerves](https://nerves-project.org) wrapper for the [RPi LED Shim](https://pinout.xyz/pinout/led_shim)

## Installation

```elixir
def deps do
  [
    {:led_shim, github: "mobileoverlord/led_shim"}
  ]
end
```

```sh
MIX_TARGET=rpi0 #replace rpi0 with your target device
mix deps.get
```

## Getting Started

After adding/installing the hex package:

1. Build and push firmware:

```sh
# if you haven't generated the upload script previously, run:
$ mix firmware.gen.script # and then
$ mix firmware && ./upload.sh
```

2. Attach to your nerves device:

```sh
$ ssh nerves.local
```

3. Start the LEDShim GenServer:

```elixir
iex> LEDShim.start_link
```

4. Set the color and brightness of the LEDs:

```elixir
# Set pixel 13 to red with 90% brightness
iex> red = 255
iex> green = 0
iex> blue = 0
iex> brightness = 0.9
iex> pixel = 12
iex> color = {red, green, blue}
iex> LEDShim.set_pixel(pixel, color, brightness)

# Set all pixels to red with 90% brightness
iex> LEDShim.set_all(color, brightness)
```

5. Tell the device to switch to the new configuration

```elixir
iex> LEDShim.show
```

6. To reset all LEDs:

```elixir
iex> LEDShim.clear
```