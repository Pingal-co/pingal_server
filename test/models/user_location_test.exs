defmodule PingalServer.UserLocationTest do
  use PingalServer.ModelCase

  alias PingalServer.UserLocation

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = UserLocation.changeset(%UserLocation{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = UserLocation.changeset(%UserLocation{}, @invalid_attrs)
    refute changeset.valid?
  end
end
