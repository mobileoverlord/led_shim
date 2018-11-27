defmodule LEDShimTest do
  use ExUnit.Case
  use PropCheck
  doctest LEDShim

  property "errors when LED pixel is out of bounds" do
    LEDShim.start_link
    forall {pixel, red, green, blue, brightness} <- {range(28, 1_000_000_000), color(), color(), color(), brightness()} do
      {:error, "Pixel out of LED Shim range of 0..27"} == LEDShim.set_pixel(pixel, {red, green, blue}, brightness)
    end
  end

  property "accepts pixels between 0 and 27" do
    LEDShim.start_link
    forall {pixel, red, green, blue, brightness} <- {range(0, 27), color(), color(), color(), brightness()} do
      :ok == LEDShim.set_pixel(pixel, {red, green, blue}, brightness)
    end
  end

  defp color() do
    range(0, 255)
  end

  defp brightness() do
    oneof([0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0])
  end
end
