defmodule PingalServer.DeviceTest do
  use PingalServer.ModelCase

  alias PingalServer.Device

  @valid_attrs %{brand: "some content", country: "some content", device: "some content", locale: "some content", name: "some content", user_agent: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Device.changeset(%Device{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Device.changeset(%Device{}, @invalid_attrs)
    refute changeset.valid?
  end
end
