defmodule BounceBackTest do
  use ExUnit.Case
  doctest BounceBack

  test "greets the world" do
    assert BounceBack.hello() == :world
  end
end
