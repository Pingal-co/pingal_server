defmodule PingalServer.Event do
  use PingalServer.Web, :model
  alias PingalServer.Event

  schema "events" do
    field :event, :string
    belongs_to :user, PingalServer.User
    belongs_to :room, PingalServer.Room
    belongs_to :slide, PingalServer.Slide

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:event, :user_id, :room_id, :slide_id])
    |> validate_required([:event])
  end

  @doc """
  Insert a user based on the `slide` struct.
  """
  def insert_event(name) do
    %Event{}
    |> changeset(name)
    |> Repo.insert!
  end

  def get_events do
    query = from e in Event,
      select: {e.id, e.name}

    query
    |> Repo.all
  end

  def get_event(id) when is_number(id) do
    Repo.get!(Event, id)
  end

  def get_event(name) do
      Repo.get_by!(Event, name: name)
  end

  def update_event(%{"id" => event_id} = changes) do
    Repo.get!(Event, event_id)
    |> changeset(changes)
    |> Repo.update!
  end

  def delete_event(event_id) do
    Repo.get!(Event, event_id)
    |> Repo.delete
  end
end
