defmodule PingalServer.AppView do
  use PingalServer.Web, :view

  def render("index.json", %{apps: apps}) do
    %{data: render_many(apps, PingalServer.AppView, "app.json")}
  end

  def render("show.json", %{app: app}) do
    %{data: render_one(app, PingalServer.AppView, "app.json")}
  end

  def render("app.json", %{app: app}) do
    %{id: app.id,
      name: app.name,
      body: app.body,
      display_start_time: app.display_start_time,
      display_end_time: app.display_end_time,
      public: app.public,
      sponsored: app.sponsored,
      user_id: app.user_id,
      room_id: app.room_id}
  end
end
