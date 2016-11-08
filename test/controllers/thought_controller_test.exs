defmodule PingalServer.ThoughtControllerTest do
  use PingalServer.ConnCase

  alias PingalServer.Thought
  @valid_attrs %{category: "some content", channel: "some content", thought: "some content"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, thought_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    thought = Repo.insert! %Thought{}
    conn = get conn, thought_path(conn, :show, thought)
    assert json_response(conn, 200)["data"] == %{"id" => thought.id,
      "thought" => thought.thought,
      "category" => thought.category,
      "channel" => thought.channel,
      "user_id" => thought.user_id}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, thought_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, thought_path(conn, :create), thought: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Thought, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, thought_path(conn, :create), thought: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    thought = Repo.insert! %Thought{}
    conn = put conn, thought_path(conn, :update, thought), thought: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Thought, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    thought = Repo.insert! %Thought{}
    conn = put conn, thought_path(conn, :update, thought), thought: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    thought = Repo.insert! %Thought{}
    conn = delete conn, thought_path(conn, :delete, thought)
    assert response(conn, 204)
    refute Repo.get(Thought, thought.id)
  end
end
