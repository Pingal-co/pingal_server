defmodule PingalServer.NetworkControllerTest do
  use PingalServer.ConnCase

  alias PingalServer.Network
  @valid_attrs %{name: "some content"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, network_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    network = Repo.insert! %Network{}
    conn = get conn, network_path(conn, :show, network)
    assert json_response(conn, 200)["data"] == %{"id" => network.id,
      "name" => network.name}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, network_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, network_path(conn, :create), network: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Network, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, network_path(conn, :create), network: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    network = Repo.insert! %Network{}
    conn = put conn, network_path(conn, :update, network), network: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Network, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    network = Repo.insert! %Network{}
    conn = put conn, network_path(conn, :update, network), network: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    network = Repo.insert! %Network{}
    conn = delete conn, network_path(conn, :delete, network)
    assert response(conn, 204)
    refute Repo.get(Network, network.id)
  end
end
