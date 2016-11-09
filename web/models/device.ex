defmodule PingalServer.Device do
  use PingalServer.Web, :model

  schema "devices" do
    field :device, :string
    field :brand, :string
    field :name, :string
    field :user_agent, :string
    field :locale, :string
    field :country, :string
    belongs_to :user, PingalServer.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:device, :brand, :name, :user_agent, :locale, :country, :user_id])
    |> validate_required([:device])
  end

  @doc """
  Insert a device based on the `device` struct.
  """
  def insert_device(%{} = device) do
    %Device{}
    |> changeset(device)
    |> Repo.insert!
  end

  def get_devices do
    query = from d in Device,
      select: %{ id: d.id, device: d.device, user_id: d.user_id, brand: d.brand, name: d.name, user_agent: d.user_agent, locale: d.locale, country: d.country }

    query
    |> Repo.all
  end

  def get_devices(user_id) do
    query = from d in Device,
      select: %{ id: d.id, device: d.device, user_id: d.user_id, brand: d.brand, name: d.name, user_agent: d.user_agent, locale: d.locale, country: d.country },
      where: d.user_id == ^user_id

    query
    |> Repo.all
  end

  def get_device(device) do
    query = from d in Device,
      select: %{ id: d.id, device: d.device, user_id: d.user_id, brand: d.brand, name: d.name, user_agent: d.user_agent, locale: d.locale, country: d.country },
      where: d.device == ^device

    query
    |> Repo.all
  end

  def update_device(%{device: device} = device_changes) do
    Repo.get_by!(Device, device: device) 
    |> changeset(device_changes)
    |> Repo.update!
  end


  def delete_device(device) do
    Repo.get!(Device, device)
    |> Repo.delete
  end
end
