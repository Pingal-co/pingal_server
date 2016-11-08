defmodule PingalServer.AppControllerTest do
  use PingalServer.ConnCase

  alias PingalServer.App
  @valid_attrs %{body: "some content", display_end_time: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, display_start_time: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, name: "some content", public: true, sponsored: true}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, app_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    app = Repo.insert! %App{}
    conn = get conn, app_path(conn, :show, app)
    assert json_response(conn, 200)["data"] == %{"id" => app.id,
      "name" => app.name,
      "body" => app.body,
      "display_start_time" => app.display_start_time,
      "display_end_time" => app.display_end_time,
      "public" => app.public,
      "sponsored" => app.sponsored,
      "user_id" => app.user_id,
      "room_id" => app.room_id}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, app_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, app_path(conn, :create), app: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(App, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, app_path(conn, :create), app: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    app = Repo.insert! %App{}
    conn = put conn, app_path(conn, :update, app), app: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(App, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    app = Repo.insert! %App{}
    conn = put conn, app_path(conn, :update, app), app: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    app = Repo.insert! %App{}
    conn = delete conn, app_path(conn, :delete, app)
    assert response(conn, 204)
    refute Repo.get(App, app.id)
  end
end
