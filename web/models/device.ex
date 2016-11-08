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
    |> cast(params, [:device, :brand, :name, :user_agent, :locale, :country])
    |> validate_required([:device, :brand, :name, :user_agent, :locale, :country])
  end
end
