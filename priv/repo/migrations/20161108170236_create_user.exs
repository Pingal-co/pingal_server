defmodule PingalServer.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string
      add :avatar, :string
      add :hash, :string
      add :phone, :string
      add :code, :integer
      add :verified, :boolean, default: false, null: false

      timestamps()
    end

  end
end
