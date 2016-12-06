defmodule PingalServer.Room do
  use PingalServer.Web, :model
  alias PingalServer.Room

  schema "rooms" do
    field :name, :string, null: false
    field :body, :string
    field :display_start_time, Ecto.DateTime
    field :display_end_time, Ecto.DateTime
    field :public, :boolean, default: true
    field :sponsored, :boolean, default: false
    belongs_to :host, PingalServer.User
    belongs_to :network, PingalServer.Network

    has_many :slides, PingalServer.Slide
    has_many :events, PingalServer.Event

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :body, :display_start_time, :display_end_time, :public, :sponsored, :host_id, :network_id])
    |> validate_required([:name])
  end

  @doc """
  Insert a room based on the `slide` struct.
  """
  def insert_room(room \\ %{}) do
    %Room{}
    |> changeset(room)
    |> Repo.insert!
  end

  def search(search_term) do
      from(r in Room,
      where: fragment("? % ?", r.body, ^search_term),
      order_by: fragment("similarity(?, ?) DESC", r.body, ^search_term))
  end

  def get_rooms do
    query = from r in Room,
      select: {r.id, r.name, r.body}

    query
    |> Repo.all
  end

  def get_rooms(:user, user_id) do
    query = from r in Room,
      select: %{id: r.id, name: r.name, body: r.body, public: r.public, sponsored: r.sponsored, host_id: r.host_id, network_id: r.network_id},
      where: r.user_id == ^user_id

    query
    |> Repo.all
  end

  def get_rooms(:network, network_id) do
    query = from r in Room,
      select: %{id: r.id, name: r.name, body: r.body, public: r.public, sponsored: r.sponsored, host_id: r.host_id, network_id: r.network_id},
      where: r.network_id == ^network_id

    query
    |> Repo.all
  end

  def get_rooms(:similar, name) do

      query = from r in Room,
        select: %{id: r.id, name: r.name, body: r.body, public: r.public, sponsored: r.sponsored, host_id: r.host_id, network_id: r.network_id},
        where: like(r.body, ^("%#{name}%"))
      
      query
      |> Repo.all
    end

  def get_rooms(:search, name) do
    search(name) |> Repo.all
  end

  def get_room(room) when is_number(room) do
    Repo.get!(Room, room)
  end

  def get_room(room) do
    Repo.get_by(Room, body: room)
  end

  def get_room(:name, room) do
    Repo.get_by(Room, name: room)
  end

  def get_room(:similar, name) do

    query = from r in Room,
      select: %{id: r.id, name: r.name, body: r.body, public: r.public, sponsored: r.sponsored, host_id: r.host_id, network_id: r.network_id},
      where: like(r.body, ^("%#{name}%"))
    
    query
    |> Repo.one
  end


  def update_room(%{"id" => room_id} = room_changes) do
    Repo.get!(Room, room_id)
    |> changeset(room_changes)
    |> Repo.update!
  end

  def delete_room(room_id) do
    Repo.get!(Room, room_id)
    |> Repo.delete
  end
end
