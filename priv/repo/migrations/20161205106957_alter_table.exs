defmodule PingalServer.Repo.Migrations.AlterTables do
  use Ecto.Migration

  def change do

    alter table(:thoughts) do
      add :most_recent, :datetime
    end

    alter table(:users) do
      add :login_count, :integer
      add :login_most_recent, :datetime
    end

  end
end
