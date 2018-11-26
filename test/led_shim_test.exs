defmodule LEDShimTest do
  use ExUnit.Case
  doctest LEDShim

  test "greets the world" do
    assert LEDShim.hello() == :world
  end
end
