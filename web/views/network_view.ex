defmodule PingalServer.NetworkView do
  use PingalServer.Web, :view

  def render("index.json", %{networks: networks}) do
    %{data: render_many(networks, PingalServer.NetworkView, "network.json")}
  end

  def render("show.json", %{network: network}) do
    %{data: render_one(network, PingalServer.NetworkView, "network.json")}
  end

  def render("network.json", %{network: network}) do
    %{id: network.id,
      name: network.name}
  end
end
