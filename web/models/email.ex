defmodule PingalServer.Email do
  use PingalServer.Web, :model

  schema "emails" do
    field :text, :string
    field :ip, :string
    field :name, :string
    field :interests, :string
    field :session, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:text, :ip, :name, :interests, :session])
    |> validate_required([:text, :ip])
  end
end
