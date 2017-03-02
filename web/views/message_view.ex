defmodule PingalServer.MessageView do
  use PingalServer.Web, :view

  def render("index.json", %{messages: messages}) do
    %{data: render_many(messages, PingalServer.MessageView, "message.json")}
  end

  def render("show.json", %{message: message}) do
    %{data: render_one(message, PingalServer.MessageView, "message.json")}
  end

  def render("message.json", %{message: message}) do
    %{id: message.id,
      text: message.text,
      ip: message.ip,
      user: message.user}
  end
end
