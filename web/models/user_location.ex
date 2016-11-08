defmodule PingalServer.UserLocation do
  use PingalServer.Web, :model

  schema "userlocations" do
    belongs_to :user, PingalServer.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
    |> validate_required([])
  end
end
