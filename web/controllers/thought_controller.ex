defmodule PingalServer.ThoughtController do
  use PingalServer.Web, :controller

  alias PingalServer.Thought

  def index(conn, _params) do
    thoughts = Repo.all(Thought)
    render(conn, "index.json", thoughts: thoughts)
  end

  def create(conn, %{"thought" => thought_params}) do
    changeset = Thought.changeset(%Thought{}, thought_params)

    case Repo.insert(changeset) do
      {:ok, thought} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", thought_path(conn, :show, thought))
        |> render("show.json", thought: thought)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(PingalServer.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    thought = Repo.get!(Thought, id)
    render(conn, "show.json", thought: thought)
  end

  def update(conn, %{"id" => id, "thought" => thought_params}) do
    thought = Repo.get!(Thought, id)
    changeset = Thought.changeset(thought, thought_params)

    case Repo.update(changeset) do
      {:ok, thought} ->
        render(conn, "show.json", thought: thought)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(PingalServer.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    thought = Repo.get!(Thought, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(thought)

    send_resp(conn, :no_content, "")
  end
end
