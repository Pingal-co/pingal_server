defmodule PingalServer.Repo.Migrations.CreateSlide do
  use Ecto.Migration

  def change do
    create table(:slides) do
      add :body, :string
      add :display_start_time, :datetime
      add :display_end_time, :datetime
      add :public, :boolean, default: false, null: false
      add :sponsored, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :nothing)
      add :room_id, references(:rooms, on_delete: :nothing)

      timestamps()
    end
    create index(:slides, [:user_id])
    create index(:slides, [:room_id])

  end
end
