defmodule PingalServer.RoomControllerTest do
  use PingalServer.ConnCase

  alias PingalServer.Room
  @valid_attrs %{body: "some content", display_end_time: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, display_start_time: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, name: "some content", public: true, sponsored: true}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, room_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    room = Repo.insert! %Room{}
    conn = get conn, room_path(conn, :show, room)
    assert json_response(conn, 200)["data"] == %{"id" => room.id,
      "name" => room.name,
      "body" => room.body,
      "display_start_time" => room.display_start_time,
      "display_end_time" => room.display_end_time,
      "public" => room.public,
      "sponsored" => room.sponsored,
      "host_id" => room.host_id,
      "network_id" => room.network_id}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, room_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, room_path(conn, :create), room: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Room, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, room_path(conn, :create), room: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    room = Repo.insert! %Room{}
    conn = put conn, room_path(conn, :update, room), room: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Room, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    room = Repo.insert! %Room{}
    conn = put conn, room_path(conn, :update, room), room: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    room = Repo.insert! %Room{}
    conn = delete conn, room_path(conn, :delete, room)
    assert response(conn, 204)
    refute Repo.get(Room, room.id)
  end
end
