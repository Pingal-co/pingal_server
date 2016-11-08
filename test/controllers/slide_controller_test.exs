defmodule PingalServer.SlideControllerTest do
  use PingalServer.ConnCase

  alias PingalServer.Slide
  @valid_attrs %{body: "some content", display_end_time: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, display_start_time: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, public: true, sponsored: true}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, slide_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    slide = Repo.insert! %Slide{}
    conn = get conn, slide_path(conn, :show, slide)
    assert json_response(conn, 200)["data"] == %{"id" => slide.id,
      "body" => slide.body,
      "display_start_time" => slide.display_start_time,
      "display_end_time" => slide.display_end_time,
      "public" => slide.public,
      "sponsored" => slide.sponsored,
      "user_id" => slide.user_id,
      "room_id" => slide.room_id}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, slide_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, slide_path(conn, :create), slide: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Slide, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, slide_path(conn, :create), slide: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    slide = Repo.insert! %Slide{}
    conn = put conn, slide_path(conn, :update, slide), slide: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Slide, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    slide = Repo.insert! %Slide{}
    conn = put conn, slide_path(conn, :update, slide), slide: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    slide = Repo.insert! %Slide{}
    conn = delete conn, slide_path(conn, :delete, slide)
    assert response(conn, 204)
    refute Repo.get(Slide, slide.id)
  end
end
