defmodule PingalServer.Repo.Migrations.CreateNetwork do
  use Ecto.Migration

  def change do
    create table(:networks) do
      add :name, :string

      timestamps()
    end

  end
end
