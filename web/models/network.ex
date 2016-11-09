defmodule PingalServer.Network do
  use PingalServer.Web, :model

  schema "networks" do
    field :name, :string
    has_many :rooms, PingalServer.Room

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
  end

  @doc """
  Insert a user based on the `slide` struct.
  """
  def insert_network(params) do
    %Network{}
    |> changeset(params)
    |> Repo.insert!
  end

  def get_networks do
    query = from n in Network,
      select: {n.id, n.name, }

    query
    |> Repo.all
  end

  def get_network(id) when is_number(id) do
    Repo.get!(Network, id)
  end

  def get_network(name) do
      Repo.get_by!(Network, name: name)
  end

  def update_network(%{"id" => network_id} = changes) do
    Repo.get!(Network, network_id)
    |> changeset(changes)
    |> Repo.update!
  end

  def delete_network(network_id) do
    Repo.get!(Network, network_id)
    |> Repo.delete
  end
end
