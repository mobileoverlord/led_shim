defmodule LEDShim do
  use GenServer

  @pixels_rgb [
    [118, 69, 85],
    [117, 68, 101],
    [116, 84, 100],
    [115, 83, 99],
    [114, 82, 98],
    [113, 81, 97],
    [112, 80, 96],
    [134, 21, 37],
    [133, 20, 36],
    [132, 19, 35],
    [131, 18, 34],
    [130, 17, 50],
    [129, 33, 49],
    [128, 32, 48],
    [127, 47, 63],
    [121, 41, 57],
    [122, 25, 58],
    [123, 26, 42],
    [124, 27, 43],
    [125, 28, 44],
    [126, 29, 45],
    [15, 95, 111],
    [8, 89, 105],
    [9, 90, 106],
    [10, 91, 107],
    [11, 92, 108],
    [12, 76, 109],
    [13, 77, 93],
  ]

  @enable_leds <<
    0b00000000, 0b10111111,
    0b00111110, 0b00111110,
    0b00111111, 0b10111110,
    0b00000111, 0b10000110,
    0b00110000, 0b00110000,
    0b00111111, 0b10111110,
    0b00111111, 0b10111110,
    0b01111111, 0b11111110,
    0b01111111, 0b00000000,
  >>

  def set_pixel(pixel, color, brightness \\ 1.0) do
    GenServer.call(__MODULE__, {:set_pixel, pixel, color, brightness})
  end

  def set_all(color, brightness \\ 1.0) do
    GenServer.call(__MODULE__, {:set_all, color, brightness})
  end

  def clear() do
    GenServer.call(__MODULE__, {:set_all, {0, 0, 0}, 1.0})
  end

  def show() do
    GenServer.call(__MODULE__, :show)
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    {:ok, led_shim} = IS31FL3731.start_link(opts)

    {:ok, %{
      led_shim: led_shim,
      buffer: List.duplicate(0, 144),
      frame: 0
    }, {:continue, nil}}
  end

  def handle_continue(nil, %{led_shim: led_shim} = s) do
    IS31FL3731.reset(led_shim)
    do_show(s)
    # Switch to the configuration page
    IS31FL3731.page(led_shim, :config)

    # Set mode and disable audiosync
    IS31FL3731.mode(led_shim, :picture)
    IS31FL3731.audiosync(led_shim, false)

    # Switch to Page 1 and enable LEDs
    IS31FL3731.page(led_shim, 1)
    IS31FL3731.led_control(led_shim, @enable_leds)

    # Switch to Page 2 and enable LEDs
    IS31FL3731.page(led_shim, 0)
    IS31FL3731.led_control(led_shim, @enable_leds)

    {:noreply, s}
  end

  def handle_call({:set_pixel, pixel, color, brightness}, _from, s) do
    {:reply, :ok, do_set_pixel(pixel, color, brightness, s)}
  end

  def handle_call({:set_all, color, brightness}, _from, s) do
    {:reply, :ok, Enum.reduce(0..27, s, &do_set_pixel(&1, color, brightness, &2))}
  end

  def handle_call(:show, _from, s) do
    {:reply, :ok, do_show(s)}
  end

  defp do_set_pixel(pixel, {r, g, b}, brightness, %{buffer: buffer} = s) do
    colors = Enum.map([r, g, b], & trunc(&1 * brightness))
    pixels = Enum.map(0..2, & Enum.at(@pixels_rgb, pixel) |> Enum.at(&1))

    buffer =
      Enum.zip(pixels, colors)
      |> Enum.reduce(buffer, fn({pixel, value}, buffer) ->
        List.update_at(buffer, pixel, fn(_) -> value end)
      end)
    %{s | buffer: buffer}
  end

  defp do_show(%{led_shim: led_shim, frame: frame, buffer: buffer} = s) do
    frame = if frame == 1, do: 0, else: 1
    IS31FL3731.page(led_shim, frame)

    binary = :binary.list_to_bin(buffer)
    IS31FL3731.pwm_control(led_shim, binary)

    IS31FL3731.page(led_shim, :config)
    IS31FL3731.frame(led_shim, frame)
    %{s | frame: frame}
  end
end
