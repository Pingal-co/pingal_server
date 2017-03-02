defmodule PingalServer.MessageTest do
  use PingalServer.ModelCase

  alias PingalServer.Message

  @valid_attrs %{ip: "some content", text: "some content", user: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Message.changeset(%Message{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Message.changeset(%Message{}, @invalid_attrs)
    refute changeset.valid?
  end
end
