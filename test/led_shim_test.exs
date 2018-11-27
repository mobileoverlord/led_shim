defmodule LEDShimTest do
  use ExUnit.Case
  doctest LEDShim

  test "errors when LED pixel is out of bounds" do
    LEDShim.start_link
    assert {:error, _message} = LEDShim.set_pixel(28, {255, 255, 255}, 0.2)
  end

  test "accepts pixels between 0 and 27" do
    LEDShim.start_link
    for i <- 0..27, do: assert :ok = LEDShim.set_pixel(i, {255, 255, 255}, 0.2)
  end
end
