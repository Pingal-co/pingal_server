defmodule PingalServer.Repo.Migrations.AlterAllTables do
  use Ecto.Migration

  def change do

    alter table(:thoughts) do
      add :geom, :geometry
    end

    # index for group by / order by clauses other than primary key
    create index(:users, [:name])
    create index(:rooms, [:name])
    create index(:apps, [:name])
    create index(:networks, [:name])  
    create index(:events, [:event])
   
   # sorted index in descending
    create index(:rooms, ["display_start_time DESC NULLS LAST"])
    create index(:slides, ["display_start_time DESC NULLS LAST"])

    # partial index
    execute("CREATE INDEX sponsored_rooms ON rooms(sponsored) WHERE sponsored = true")
    execute("CREATE INDEX sponsored_slides ON slides(sponsored) WHERE sponsored = true")



  end
end
