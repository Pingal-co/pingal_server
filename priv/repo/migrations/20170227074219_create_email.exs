defmodule PingalServer.Repo.Migrations.CreateEmail do
  use Ecto.Migration

  def change do
    create table(:emails) do
      add :text, :string
      add :ip, :string

      timestamps()
    end

  end
end
