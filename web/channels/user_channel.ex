defmodule PingalServer.UserChannel do
  use PingalServer.Web, :channel
 # alias PingalServer.Presence
  alias PingalServer.User
  alias PingalServer.Room
  alias PingalServer.Slide
  # alias PingalServer.UserLocation
  # alias PingalServer.Device
  alias PingalServer.Thought
  require Logger

  @moduledoc """
   
    We should be able to notify users privately along this channel (e.g. 1-1 messaging).
       
    Feature(s): User Inbox
      - private channel
      - a database of thoughts
      - notify if new comment on a previous thought
      - watch similar thoughts                
 
    Queries:
      - Insert a slide (or data) in the channel
      - Find thoughts by user (history)
      - Find thoughts by similarity
      
    Events:
        - add:slide 
        - update:user,
        - find:thoughts,
        - find:similar_thoughts
        - notify:user (other channels can also notify a user)
   
    Model: user: User.schema

    Future: Private Board 
      - Write any thought on the slide (e.g. Blog, Story, Billboard, Survey, Campaign, Promotion)
      - Create your own room (e.g. organization, shop, club, mailing_list)
      - Room and Slide Properties (e.g. Timestamped Query: expiry date), 
      - Network: Find nearby people interested in the thought (On-looker's network)

  """

  def join("user:" <> user_id, payload, socket) do
    Logger.debug "user #{inspect(user_id)} payload: #{inspect(payload)}"

    if authorized?(payload) do
      socket = assign(socket, :userid, user_id)
      #send(self(),:after_join)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end

  end

  def handle_info("after_join", socket) do  
    {:noreply, socket}
  end


  # add a room
  def handle_in("add:room" = event, message, socket) do
    Logger.debug "message: #{inspect(message)}"
 
    # room data to insert (get everything from message)
    room = insert_room(socket, message)

    # broadcast added room to subscribers
    broadcast! socket, event, %{
      user: socket.assigns.user,
      body: Map.get(message, "text"),
      room: %{id: room.id, name: room.name},
      timestamp: :os.system_time(:milli_seconds)
    }

    {:noreply, socket}

  end

  # add a slide
  def handle_in("add:slide" = event, message, socket) do

    slide = insert_slide(socket, message)

    broadcast! socket, event, %{
      user: socket.assigns.user,
      body: Map.get(message, "text"),
      room: socket.topic,
      params: %{slide_id: slide.id},
      timestamp: :os.system_time(:milli_seconds)
    }

    {:noreply, socket}

  end

   # update user data
  def handle_in("update:user" = event, message, socket) do
    # user data to update (get everything from message)
    Logger.debug "#{inspect(event)} message: #{inspect(message)}"
    params = Map.get(message, "user")
    user = update_user(params)
    # send a confirmation back to user on user channel
    {:reply, user, socket}
  end

  # list users around me
  def handle_in("find:users_location" = event, message, socket) do
    # location query on users
    Logger.debug "#{inspect(event)} message: #{inspect(message)}"
 
    {:noreply, socket}
  end

  # list rooms around me 
  def handle_in("find:rooms_location" = event, message, socket) do
    Logger.debug "#{inspect(event)} message: #{inspect(message)}"
    # location query on pages
    {:noreply, socket}
  end

  # list networks around me
  def handle_in("find:networks_location" = event, message, socket) do
    Logger.debug "#{inspect(event)} message: #{inspect(message)}"
    # location query on network
    {:noreply, socket}
  end

  # find room by room name
    def handle_in("find:room" = event, message, socket) do
      Logger.debug "#{inspect(event)} message: #{inspect(message)}"
      {:noreply, socket}
    end

  # find rooms in networks by name
  def handle_in("find:network" = event, message, socket) do
    Logger.debug "#{inspect(event)} message: #{inspect(message)}"
    {:noreply, socket}
  end

  # find rooms by history
  def handle_in("find:interest", socket) do
    {:noreply, socket}
	end

  # load more
  def handle_in("load:more", socket) do
    {:noreply, socket}
	end

  #  list thoughts by user
  def find_user_thoughts(socket) do
    Thought.get_thoughts(socket.assigns.userid)
  end

   #  list slides by user
  def find_user_slides(socket) do
    Slide.get_slides(:user, socket.assigns.userid)
  end

   #  list rooms by user
  def find_user_rooms(socket) do
    Room.get_rooms(:user, socket.assigns.userid)
  end
 
  def insert_room(socket, message) do
    params = %{
      name: socket.topic,
      body: Map.get(message, "text"),
      public: true,
      sponsored: false,
      host_id: socket.assigns.params.user_id,
      network_id: 1
    }

    case Room.get_room(socket.topic) do
      nil -> Room.insert_room(params)
      room -> room
    end
  end

   def insert_slide(socket, message) do
    params = %{
      body: Map.get(message, "text"),
      public: true,
      sponsored: false,
      user_id: socket.assigns.params.user_id,
      room_id: socket.assigns.params.room_id,
      }
     Slide.insert_slide(params)
  end

   def update_user(message) do
    device_name = message["deviceid"]
    # find user based on name: id, phone, email, key or device_id
    name = device_name
    user = User.get_user(name)
    params = %{ phone: message["phone"],
                name: message["name"],
                email: message["email"],
                avatar: message["avatar"],
                hash: message["name_hash"]
              }

    cond do
      user == nil -> User.insert_user(params)
      true -> user
    end
  end

  # Add authorization logic later
  defp authorized?(_message) do
    true
  end

end