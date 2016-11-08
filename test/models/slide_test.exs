defmodule PingalServer.SlideTest do
  use PingalServer.ModelCase

  alias PingalServer.Slide

  @valid_attrs %{body: "some content", display_end_time: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, display_start_time: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, public: true, sponsored: true}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Slide.changeset(%Slide{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Slide.changeset(%Slide{}, @invalid_attrs)
    refute changeset.valid?
  end
end
