defmodule PingalServer.EmailController do
  use PingalServer.Web, :controller

  alias PingalServer.Email

  def index(conn, _params) do
    emails = Repo.all(Email)
    render(conn, "index.json", emails: emails)
  end

  def create(conn, %{"email" => email_params}) do

    # Add IP to params
    ip = conn.remote_ip |> Tuple.to_list |> Enum.join(".")
    email_params = Map.put(email_params, "ip", ip)
    changeset = Email.changeset(%Email{}, email_params)

    case Repo.insert(changeset) do
      {:ok, email} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", email_path(conn, :show, email))
        |> render("show.json", email: email)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(PingalServer.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def apiai(conn, %{"sessionId" => session_id, "result" => result}) do
    # Add IP to params
    ip = conn.remote_ip |> Tuple.to_list |> Enum.join(".")
    email_params = %{ip: ip, text: result["parameters"]["email"], name: result["parameters"]["name"], session: session_id}
    changeset = Email.changeset(%Email{}, email_params)

    case Repo.insert(changeset) do
      {:ok, email} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", email_path(conn, :show, email))
        |> render("show.json", email: email)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(PingalServer.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    email = Repo.get!(Email, id)
    render(conn, "show.json", email: email)
  end

  def update(conn, %{"id" => id, "email" => email_params}) do
    email = Repo.get!(Email, id)
    changeset = Email.changeset(email, email_params)

    case Repo.update(changeset) do
      {:ok, email} ->
        render(conn, "show.json", email: email)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(PingalServer.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    email = Repo.get!(Email, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(email)

    send_resp(conn, :no_content, "")
  end
end
