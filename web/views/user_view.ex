defmodule PingalServer.UserView do
  use PingalServer.Web, :view

  def render("index.json", %{users: users}) do
    %{data: render_many(users, PingalServer.UserView, "user.json")}
  end

  def render("show.json", %{user: user, jwt: jwt}) do
    user_map = %{
      id: user.id,
      name: user.name,
      email: user.email,
      avatar: user.avatar,
      hash: user.hash,
      phone: user.phone,
      code: user.code,
      verified: user.verified,
      jwt: jwt
    }
    %{data: user_map}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      name: user.name,
      email: user.email,
      avatar: user.avatar,
      hash: user.hash,
      phone: user.phone,
      code: user.code,
      verified: user.verified}
  end
end
