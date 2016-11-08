defmodule PingalServer.AppController do
  use PingalServer.Web, :controller

  alias PingalServer.App

  def index(conn, _params) do
    apps = Repo.all(App)
    render(conn, "index.json", apps: apps)
  end

  def create(conn, %{"app" => app_params}) do
    changeset = App.changeset(%App{}, app_params)

    case Repo.insert(changeset) do
      {:ok, app} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", app_path(conn, :show, app))
        |> render("show.json", app: app)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(PingalServer.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    app = Repo.get!(App, id)
    render(conn, "show.json", app: app)
  end

  def update(conn, %{"id" => id, "app" => app_params}) do
    app = Repo.get!(App, id)
    changeset = App.changeset(app, app_params)

    case Repo.update(changeset) do
      {:ok, app} ->
        render(conn, "show.json", app: app)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(PingalServer.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    app = Repo.get!(App, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(app)

    send_resp(conn, :no_content, "")
  end
end
