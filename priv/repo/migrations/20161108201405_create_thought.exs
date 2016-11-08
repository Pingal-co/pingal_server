defmodule PingalServer.Repo.Migrations.CreateThought do
  use Ecto.Migration

  def change do
    create table(:thoughts) do
      add :thought, :string
      add :category, :string
      add :channel, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end
    create index(:thoughts, [:user_id])

  end
end
