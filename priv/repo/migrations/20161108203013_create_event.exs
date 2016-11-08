defmodule PingalServer.Repo.Migrations.CreateEvent do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :event, :string
      add :user_id, references(:users, on_delete: :nothing)
      add :room_id, references(:rooms, on_delete: :nothing)
      add :slide_id, references(:slides, on_delete: :nothing)

      timestamps()
    end
    create index(:events, [:user_id])
    create index(:events, [:room_id])
    create index(:events, [:slide_id])

  end
end
