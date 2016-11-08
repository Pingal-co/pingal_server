defmodule PingalServer.Thought do
  use PingalServer.Web, :model

  schema "thoughts" do
    field :thought, :string
    field :category, :string
    field :channel, :string
    belongs_to :user, PingalServer.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:thought, :category, :channel])
    |> validate_required([:thought, :category, :channel])
  end
end
