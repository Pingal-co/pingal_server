defmodule PingalServer.Repo.Migrations.CreateDevice do
  use Ecto.Migration

  def change do
    create table(:devices) do
      add :device, :string
      add :brand, :string
      add :name, :string
      add :user_agent, :string
      add :locale, :string
      add :country, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end
    create index(:devices, [:user_id])

  end
end
