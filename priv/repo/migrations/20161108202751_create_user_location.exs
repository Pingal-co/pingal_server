defmodule PingalServer.Repo.Migrations.CreateUserLocation do
  use Ecto.Migration

  def change do
    create table(:userlocations) do
      add :user_id, references(:users, on_delete: :nothing)
      add :geom, :geometry
      timestamps()
    end
    create index(:userlocations, [:user_id])

  end
end
