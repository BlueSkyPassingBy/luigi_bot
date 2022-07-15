defmodule LuigiTest do
  use ExUnit.Case
  doctest Luigi

  test "greets the world" do
    assert Luigi.hello() == :world
  end
end
