defmodule PingalServer.User do
  use PingalServer.Web, :model
  alias PingalServer.User
  use Coherence.Schema

  schema "users" do
    field :name, :string
    field :email, :string
    field :avatar, :string
    field :hash, :string
    field :phone, :string
    field :code, :integer
    field :verified, :boolean, default: false
    coherence_schema

    has_many :slides, PingalServer.Slide
    has_many :rooms, PingalServer.Room
    has_many :networks, PingalServer.Network
    has_many :locations, PingalServer.UserLocation
    has_many :events, PingalServer.Event

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email, :avatar, :hash, :phone, :code, :verified])
    |> validate_required([])

  end

  @doc """
  Insert a user based on the `slide` struct.
  """
  def insert_user(user \\ %{}) do
    %User{}
    |> changeset(user)
    |> Repo.insert!
  end

  def get_users do
    query = from u in User,
      select: %{id: u.id, name: u.name, avatar: u.avatar}

    query
    |> Repo.all
  end

  def get_user(user) when is_number(user) do
    Repo.get!(User, user)
  end

  def get_user(user) do
      Repo.get_by(User, name: user)
  end

  def update_user(%{"id" => user_id} = user_changes) do
    Repo.get!(User, user_id)
    |> changeset(user_changes)
    |> Repo.update!
  end

  def delete_user(user_id) do
    Repo.get!(User, user_id)
    |> Repo.delete
  end
  
end
