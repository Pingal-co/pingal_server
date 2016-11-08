defmodule PingalServer.ThoughtTest do
  use PingalServer.ModelCase

  alias PingalServer.Thought

  @valid_attrs %{category: "some content", channel: "some content", thought: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Thought.changeset(%Thought{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Thought.changeset(%Thought{}, @invalid_attrs)
    refute changeset.valid?
  end
end
