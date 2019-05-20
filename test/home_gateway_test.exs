defmodule HomeGatewayTest do
  use ExUnit.Case
  doctest HomeGateway

  test "greets the world" do
    assert HomeGateway.hello() == :world
  end
end
