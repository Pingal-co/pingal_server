defmodule PingalServer.ThoughtView do
  use PingalServer.Web, :view

  def render("index.json", %{thoughts: thoughts}) do
    %{data: render_many(thoughts, PingalServer.ThoughtView, "thought.json")}
  end

  def render("show.json", %{thought: thought}) do
    %{data: render_one(thought, PingalServer.ThoughtView, "thought.json")}
  end

  def render("thought.json", %{thought: thought}) do
    %{id: thought.id,
      thought: thought.thought,
      category: thought.category,
      channel: thought.channel,
      user_id: thought.user_id}
  end
end
