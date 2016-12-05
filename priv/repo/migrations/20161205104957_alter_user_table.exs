defmodule PingalServer.Repo.Migrations.AlterUserTables do
  use Ecto.Migration

  def change do

    alter table(:users) do
      remove :code
      add :encrypted_passcode, :string
    end

  end
end
