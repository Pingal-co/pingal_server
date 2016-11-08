defmodule PingalServer.Room do
  use PingalServer.Web, :model

  schema "rooms" do
    field :name, :string
    field :body, :string
    field :display_start_time, Ecto.DateTime
    field :display_end_time, Ecto.DateTime
    field :public, :boolean, default: false
    field :sponsored, :boolean, default: false
    belongs_to :host, PingalServer.Host
    belongs_to :network, PingalServer.Network

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :body, :display_start_time, :display_end_time, :public, :sponsored])
    |> validate_required([:name, :body, :display_start_time, :display_end_time, :public, :sponsored])
  end
end
