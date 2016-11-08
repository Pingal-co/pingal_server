defmodule PingalServer.Slide do
  use PingalServer.Web, :model

  schema "slides" do
    field :body, :string
    field :display_start_time, Ecto.DateTime
    field :display_end_time, Ecto.DateTime
    field :public, :boolean, default: false
    field :sponsored, :boolean, default: false
    belongs_to :user, PingalServer.User
    belongs_to :room, PingalServer.Room

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:body, :display_start_time, :display_end_time, :public, :sponsored])
    |> validate_required([:body, :display_start_time, :display_end_time, :public, :sponsored])
  end
end
