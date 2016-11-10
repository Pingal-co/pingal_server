defmodule PingalServer.User do
  use PingalServer.Web, :model
  alias PingalServer.{Repo, User}

  schema "users" do
    field :name, :string
    field :email, :string
    field :avatar, :string
    field :hash, :string
    field :phone, :string
    field :passcode, :string, virtual: true
    field :encrypted_passcode, :string
    field :verified, :boolean, default: false

    has_many :slides, PingalServer.Slide
    has_many :rooms, PingalServer.Room
    has_many :networks, PingalServer.Network
    has_many :locations, PingalServer.UserLocation
    has_many :events, PingalServer.Event

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email, :avatar, :hash, :phone, :code, :verified])
    |> validate_required([])

  end

  @doc """
  Insert a user based on the `slide` struct.
  """
  def insert_user(user \\ %{}) do
    %User{}
    |> changeset(user)
    |> Repo.insert!
  end

  def get_users do
    query = from u in User,
      select: %{id: u.id, name: u.name, avatar: u.avatar}

    query
    |> Repo.all
  end

  def get_user(user) when is_number(user) do
    Repo.get!(User, user)
  end

  def get_user(user) do
      Repo.get_by(User, name: user)
  end

  def update_user(%{"id" => user_id} = user_changes) do
    Repo.get!(User, user_id)
    |> changeset(user_changes)
    |> Repo.update!
  end

  def delete_user(user_id) do
    Repo.get!(User, user_id)
    |> Repo.delete
  end

  def authenticate(%{"email" => email, "passcode" => passcode}) do
    user = Repo.get_by(User, email: String.downcase(email))

    case check_passcode(user, passcode) do
      true -> {:ok, user}
      _ -> :error
    end
  end

  defp check_passcode(user, passcode) do
    case user do
      nil -> false
      _ -> Comeonin.Bcrypt.checkpw(passcode, user.encrypted_passcode)
    end
  end

  defp generate_encrypted_passcode(current_changeset) do
    case current_changeset do
      %Ecto.Changeset{valid?: true, changes: %{passcode: passcode}} ->
        put_change(current_changeset, :encrypted_passcode, Comeonin.Bcrypt.hashpwsalt(passcode))
      _ ->
        current_changeset
    end
  end
  
end
