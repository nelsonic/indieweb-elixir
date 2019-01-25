defmodule IndieWebTest do
  use ExUnit.Case
  doctest IndieWeb

  test "greets the world" do
    assert IndieWeb.hello() == :world
  end
end
