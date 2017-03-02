defmodule PingalServer.Repo.Migrations.CreateMessage do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :text, :string
      add :ip, :string
      add :user, :string

      timestamps()
    end

  end
end
