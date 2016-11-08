defmodule PingalServer.Event do
  use PingalServer.Web, :model

  schema "events" do
    field :event, :string
    belongs_to :user, PingalServer.User
    belongs_to :room, PingalServer.Room
    belongs_to :slide, PingalServer.Slide

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:event])
    |> validate_required([:event])
  end
end
