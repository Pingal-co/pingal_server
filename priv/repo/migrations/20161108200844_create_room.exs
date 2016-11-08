defmodule PingalServer.Repo.Migrations.CreateRoom do
  use Ecto.Migration

  def change do
    create table(:rooms) do
      add :name, :string
      add :body, :string
      add :display_start_time, :datetime
      add :display_end_time, :datetime
      add :public, :boolean, default: false, null: false
      add :sponsored, :boolean, default: false, null: false
      add :host_id, references(:users, on_delete: :nothing)
      add :network_id, references(:networks, on_delete: :nothing)

      timestamps()
    end
    create index(:rooms, [:host_id])
    create index(:rooms, [:network_id])

  end
end
