defmodule PingalServer.NetworkTest do
  use PingalServer.ModelCase

  alias PingalServer.Network

  @valid_attrs %{name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Network.changeset(%Network{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Network.changeset(%Network{}, @invalid_attrs)
    refute changeset.valid?
  end
end
