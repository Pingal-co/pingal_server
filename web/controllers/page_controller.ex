defmodule PingalServer.PageController do
  use PingalServer.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
