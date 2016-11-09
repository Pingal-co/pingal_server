defmodule PingalServer.UserLocation do
  use PingalServer.Web, :model
  alias PingalServer.UserLocation
  import Geo.PostGIS

  schema "userlocations" do
    belongs_to :user, PingalServer.User
    field :geom, Geo.Point
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :geom])
    |> validate_required([])
  end

  @doc """
  Insert a slide based on the `slide` struct.
  """
  def insert_location(location \\ %{}) do
    %UserLocation{}
    |> changeset(location)
    |> Repo.insert!
  end

  def get_locations do
    query = from l in UserLocation,
      select: {l.user_id, l.geom}

    query
    |> Repo.all
  end

  def get_location(location_id) do
    Repo.get!(UserLocation, location_id)
  end

  def get_users do
     query = from l in UserLocation,
        select: %{user_id: l.user_id, geom: l.geom}

      query |> Repo.all

  end
  def get_users(geom, radius \\ 5) do
     # joins can be really expensive, so manual filtering
     # 
     # 
     #order_by: distance
     query = from l in UserLocation,
        select: %{user_id: l.user_id, distance: st_distance(l.geom, ^geom)},
        where: st_distance(l.geom, ^geom) <= ^radius
       

      query |> Repo.all

  end

  def update_location(%{"id" => location_id} = location_changes) do
    Repo.get!(UserLocation, location_id)
    |> changeset(location_changes)
    |> Repo.update!
  end

  def delete_location(location_id) do
    Repo.get!(UserLocation, location_id)
    |> Repo.delete
  end
  
end
