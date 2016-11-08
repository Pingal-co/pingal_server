defmodule PingalServer.NetworkController do
  use PingalServer.Web, :controller

  alias PingalServer.Network

  def index(conn, _params) do
    networks = Repo.all(Network)
    render(conn, "index.json", networks: networks)
  end

  def create(conn, %{"network" => network_params}) do
    changeset = Network.changeset(%Network{}, network_params)

    case Repo.insert(changeset) do
      {:ok, network} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", network_path(conn, :show, network))
        |> render("show.json", network: network)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(PingalServer.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    network = Repo.get!(Network, id)
    render(conn, "show.json", network: network)
  end

  def update(conn, %{"id" => id, "network" => network_params}) do
    network = Repo.get!(Network, id)
    changeset = Network.changeset(network, network_params)

    case Repo.update(changeset) do
      {:ok, network} ->
        render(conn, "show.json", network: network)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(PingalServer.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    network = Repo.get!(Network, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(network)

    send_resp(conn, :no_content, "")
  end
end
