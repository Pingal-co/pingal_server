defmodule PingalServer.SlideView do
  use PingalServer.Web, :view

  def render("index.json", %{slides: slides}) do
    %{data: render_many(slides, PingalServer.SlideView, "slide.json")}
  end

  def render("show.json", %{slide: slide}) do
    %{data: render_one(slide, PingalServer.SlideView, "slide.json")}
  end

  def render("slide.json", %{slide: slide}) do
    %{id: slide.id,
      body: slide.body,
      display_start_time: slide.display_start_time,
      display_end_time: slide.display_end_time,
      public: slide.public,
      sponsored: slide.sponsored,
      user_id: slide.user_id,
      room_id: slide.room_id}
  end
end
