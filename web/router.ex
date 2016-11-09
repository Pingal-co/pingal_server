defmodule PingalServer.Router do
  use PingalServer.Web, :router
  use Coherence.Router      

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session
  end

  pipeline :protected do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session, protected: true  
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :apiprotected do
    plug :accepts, ["json"]
    plug Coherence.Authentication.Session, protected: true 
  end

  scope "/" do
    pipe_through :browser
    coherence_routes
  end

  scope "/" do
    pipe_through :protected
    coherence_routes :protected
  end


  scope "/", PingalServer do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/", PingalServer do
    pipe_through :protected
    resources "/users", UserController
  end

  # Other scopes may use custom stacks.
  scope "/api", PingalServer do
     pipe_through :apiprotected
     resources "/networks", NetworkController, except: [:new, :edit]
     resources "/rooms", RoomController, except: [:new, :edit]
     resources "/thoughts", ThoughtController, except: [:new, :edit]
     resources "/apps", AppController, except: [:new, :edit]
     resources "/slides", SlideController, except: [:new, :edit]
   end
end


