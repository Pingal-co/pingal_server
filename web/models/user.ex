defmodule PingalServer.User do
  use PingalServer.Web, :model

  schema "users" do
    field :name, :string
    field :email, :string
    field :avatar, :string
    field :hash, :string
    field :phone, :string
    field :code, :integer
    field :verified, :boolean, default: false

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email, :avatar, :hash, :phone, :code, :verified])
    |> validate_required([:name, :email, :avatar, :hash, :phone, :code, :verified])
  end
end
