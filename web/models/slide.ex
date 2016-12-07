defmodule PingalServer.Slide do
  use PingalServer.Web, :model
  alias PingalServer.Slide
  alias PingalServer.User 
  alias PingalServer.Room  

  schema "slides" do
    field :body, :string
    field :display_start_time, Ecto.DateTime
    field :display_end_time, Ecto.DateTime
    field :public, :boolean, default: false
    field :sponsored, :boolean, default: false
    belongs_to :user, PingalServer.User
    belongs_to :room, PingalServer.Room

    has_many :events, PingalServer.Event

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:body, :display_start_time, :display_end_time, :public, :sponsored, :user_id, :room_id])
    |> validate_required([:body])
  end

  @doc """
  Insert a slide based on the `slide` struct.
  """
  def insert_slide(%{} = slide) do
    %Slide{}
    |> changeset(slide)
    |> Repo.insert!
  end

  def get_slides do
    query = from s in Slide,
      select: %{id: s.id, body: s.body, public: s.public, sponsored: s.sponsored, user_id: s.user_id, room_id: s.room_id}

    query
    |> Repo.all
  end

  def get_slides(:room, room_id) do
         #preload: [user: from(u in User, select: %{_id: u.id, name: u.hash, avatar: u.avatar}), 
         #       room: from(r in Room, select: %{id: r.id, name: r.name})]

    query = from s in Slide,
      select: %{id: s.id, body: s.body, public: s.public, sponsored: s.sponsored},
      where: s.room_id == ^room_id,
 
    query
    |> Repo.all
  end

  def get_slides(:user, user_id) do
    query = from s in Slide,
      select: %{id: s.id, body: s.body, public: s.public, sponsored: s.sponsored, user_id: s.user_id, room_id: s.room_id},
      where: s.user_id == ^user_id

    query
    |> Repo.all
  end

  def get_slide(slide_id) do
    Repo.get!(Slide, slide_id)
  end

  def update_slide(%{"id" => slide_id} = slide_changes) do
    Repo.get!(Slide, slide_id)
    |> changeset(slide_changes)
    |> Repo.update!
  end

  def delete_slide(slide_id) do
    Repo.get!(Slide, slide_id)
    |> Repo.delete
  end
end
