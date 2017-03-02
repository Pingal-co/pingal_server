defmodule PingalServer.Message do
  use PingalServer.Web, :model

  schema "messages" do
    field :text, :string
    field :ip, :string
    field :user, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:text, :ip, :user])
    |> validate_required([:text, :ip, :user])
  end
end
