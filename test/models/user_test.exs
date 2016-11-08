defmodule PingalServer.UserTest do
  use PingalServer.ModelCase

  alias PingalServer.User

  @valid_attrs %{avatar: "some content", code: 42, email: "some content", hash: "some content", name: "some content", phone: "some content", verified: true}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
