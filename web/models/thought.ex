defmodule PingalServer.Thought do
  use PingalServer.Web, :model
  import Geo.PostGIS

  schema "thoughts" do
    field :thought, :string
    field :category, :string
    field :channel, :string
    field :geom, Geo.Point
    belongs_to :user, PingalServer.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:thought, :category, :channel, :user_id, :geom])
    |> validate_required([:thought, :category])
  end

  @doc """
  Insert a thought based on the `thought` struct.
  """
  def insert_thought(%{} = thought) do
    %Thought{}
    |> changeset(thought)
    |> Repo.insert!
  end

  def get_thought(%{thought: name}) do
    Repo.get_by!(Thought, thought: name)
  end

  def get_thought(:id, thought_id) do
      Repo.get!(Thought, thought_id)
  end

  def get_thoughts do
    query = from t in Thought,
      select: %{ id: t.id, user_id: t.user_id, thought: t.thought, category: t.category, channel: t.channel }

    query
    |> Repo.all
  end

  def get_thoughts(user_id) do
    query = from t in Thought,
      select: %{ id: t.id, user_id: t.user_id, thought: t.thought, category: t.category, channel: t.channel },
      where: t.user_id == ^user_id

    query
    |> Repo.all
  end

  def get_users(thought) do
    category = thought.category
    id = thought.user_id
    query = from t in Thought,
      select: %{ id: t.id, user_id: t.user_id, thought: t.thought, category: t.category, channel: t.channel },
      distinct: t.user_id,
      where: t.category == ^category, 
      where: t.user_id != ^id,
      order_by: t.updated_at

    query |> Repo.all
  end

  def get_users(:location, thought, radius \\ 5) do
    # gets users by category and location radius
    geom = thought.geom
    category = thought.category
    id = thought.user_id
      
    query = from t in Thought,
     select: %{ id: t.id, user_id: t.user_id, thought: t.thought, category: t.category, distance: st_distance(t.geom, ^geom) },
     distinct: t.user_id, 
     where: t.category == ^category , 
     where: st_distance(t.geom, ^geom) <= ^radius,
     where: t.user_id != ^id,
     order_by: t.updated_at
 
    query |> Repo.all
  end

  

  def update_thought(%{id: thought_id} = thought_changes) do
    Repo.get!(Thought, thought_id)
    |> changeset(thought_changes)
    |> Repo.update!
  end

   def update_thought(%{thought: thought} = thought_changes) do
    Repo.get_by!(Thought, thought: thought)
    |> changeset(thought_changes)
    |> Repo.update!
  end

  def delete_thought(thought_id) do
    Repo.get!(Thought, thought_id)
    |> Repo.delete
  end

end
