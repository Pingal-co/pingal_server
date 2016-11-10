defmodule PingalServer.Router do
  use PingalServer.Web, :router     

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers

  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PingalServer do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/users", UserController
  end

  # Other scopes may use custom stacks.
  scope "/api", PingalServer do
     pipe_through :api
     resources "/users", UserController, except: [:new, :edit]
     resources "/networks", NetworkController, except: [:new, :edit]
     resources "/rooms", RoomController, except: [:new, :edit]
     resources "/thoughts", ThoughtController, except: [:new, :edit]
     resources "/apps", AppController, except: [:new, :edit]
     resources "/slides", SlideController, except: [:new, :edit]
   end
end


