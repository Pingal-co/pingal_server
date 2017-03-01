defmodule PingalServer.EmailView do
  use PingalServer.Web, :view

  def render("index.json", %{emails: emails}) do
    %{data: render_many(emails, PingalServer.EmailView, "email.json")}
  end

  def render("show.json", %{email: email}) do
    %{data: render_one(email, PingalServer.EmailView, "email.json")}
  end

  def render("email.json", %{email: email}) do
    %{id: email.id,
      text: email.text,
      ip: email.ip}
  end
end
