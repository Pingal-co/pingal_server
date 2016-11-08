defmodule PingalServer.RoomView do
  use PingalServer.Web, :view

  def render("index.json", %{rooms: rooms}) do
    %{data: render_many(rooms, PingalServer.RoomView, "room.json")}
  end

  def render("show.json", %{room: room}) do
    %{data: render_one(room, PingalServer.RoomView, "room.json")}
  end

  def render("room.json", %{room: room}) do
    %{id: room.id,
      name: room.name,
      body: room.body,
      display_start_time: room.display_start_time,
      display_end_time: room.display_end_time,
      public: room.public,
      sponsored: room.sponsored,
      host_id: room.host_id,
      network_id: room.network_id}
  end
end
