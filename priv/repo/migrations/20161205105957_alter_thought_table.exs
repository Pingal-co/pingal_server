defmodule PingalServer.Repo.Migrations.AlterThoughtTables do
  use Ecto.Migration

  def change do

    alter table(:thoughts) do
      add :count, :integer
    end

  end
end
