defmodule PingalServer.Repo.Migrations.AddFieldsToEmails do
  use Ecto.Migration

  def change do
  	alter table(:emails) do
  		add :name, :string, default: ""
  		add :interests, :text, default: ""
  		add :session, :string, default: ""
  	end
  end
end
