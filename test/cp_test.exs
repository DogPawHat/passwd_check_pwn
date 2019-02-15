defmodule CPTest do
  use ExUnit.Case
  doctest CP

  test "greets the world" do
    assert CP.hello() == :world
  end
end
