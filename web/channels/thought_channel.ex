defmodule PingalServer.ThoughtChannel do
  use PingalServer.Web, :channel
  alias PingalServer.Presence
  alias PingalServer.User
  alias PingalServer.Room
  alias PingalServer.UserLocation
  alias PingalServer.Device
  alias PingalServer.Thought
  alias PingalServer.Elasticsearch
  import Tirexs.HTTP
  require Logger

  @moduledoc """
      We should be able to suggest users along this channel.
  
      Feature(s): 
        - User Thought Input 
        - Thought Recommendations 
     
      Queries:
        - Insert a thought
        - Insert user, location, device, any other info from the client
        - Find room by thought
        - Find users by thought
        
      Events:
          - add:thought  

      To do:
         - recall: find people and bots interested in category;
         - precision: rank them by location distance, filter by presence
         - broadcast to a list of people and bots
         - build user interest index:
         - given a thought, predict a sub:class(es) or sub:tag(s) in the category and update the user interest index
         - given the slides, update the user index

    """

  def join("thought:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # join the room, record the event
  def join("thought:" <> category, payload, socket) do
     Logger.debug "#{inspect(payload)}"

    if authorized?(payload) do
      socket = assign(socket, :params, %{category: category})
      #room_user = Event.insert_event(%{name: "view", user_id: payload.user_id, room_id: payload.room_id})
      send(self(),:after_join)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # track and add presence based on category and location
  def handle_info(:after_join, socket) do
   
    Presence.track(socket, socket.assigns.user, %{
      online_at: :os.system_time(:milli_seconds),
      category: socket.assigns.params.category
      })
    push socket, "presence:category", Presence.list(socket)

    {:noreply, socket}
  end


# add a thought
  def handle_in("add:thought" = event, message, socket) do
    Logger.debug "event: #{inspect(event)}"
    Logger.debug "message: #{inspect message}"
   
    # get user from user_hash or device_info 
    user = insert_user(message)

    # insert thought and index it in elastic search
    thought = insert_thought(message, user)

    # search the thought and get the list of users with similar thoughts
    temporary_friends = find_users(thought)
    Logger.debug "temporary friends: #{inspect(temporary_friends)}"
    
    # get or create a room
    %{id: room_id, name: room_name} = get_room(thought)   
  
    # assign user and room id to socket
    socket = assign(socket, :user, %{_id: user.id, avatar: user.avatar, name: user.name})
    socket = assign(socket, :params, %{room_id: room_id, room_name: room_name})
    Logger.debug "params for #{inspect socket.assigns.user} : #{inspect socket.assigns.params}"
    socket = socket |> assign(:rooms, []) |> watch_new_rooms(temporary_friends)

    # push to socket
    broadcast! socket, event, %{
      user: socket.assigns.user,
      body: message["thought"],
      params: socket.assigns.params,
      timestamp: :os.system_time(:milli_seconds)
    }

     # We should do these steps in a async way!!
    # insert location
    insert_location(message, user)

    # insert device info
    insert_device(message, user)

    {:noreply, socket}

  end
  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (thought:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  def insert_user(message) do
    device_info = message["device_info"]
    device_name = device_info["unique_id"] ,
    user_hash =  message["user_hash"]
    Logger.debug "name: #{inspect(device_name)}"
    # user name : can be device_name | email | phone
    # only using device name for testing
    name = device_name
    user = User.get_user(name)
    cond do
      user == nil -> User.insert_user(%{name: name, hash: user_hash})
      true -> user
    end
  end

  def insert_location(message, user) do
    location = message["location"]
    latitude = location["latitude"]
    longitude = location["longitude"]
    params = %{
          user_id: user.id,
          geom: %Geo.Point{ coordinates: {latitude, longitude}, srid: 4326}
    }
    Logger.debug "params: #{inspect(params)}"
    # need to be in a Geo Structure
    UserLocation.insert_location(params)
  end

  def insert_thought(message, user) do
    location = message["location"]
    latitude = location["latitude"]
    longitude = location["longitude"]
    params = %{
          thought: String.downcase(message["thought"]),
          category: message["category"],
          channel: "thought:lobby",
          count: 1,
          user_id: user.id,
          geom: %Geo.Point{ coordinates: {latitude, longitude}, srid: 4326}
          }

    case Thought.get_thought(params) do
      nil -> 
            Thought.insert_thought(params)
            # index in elasticsearch too
            # put("/thoughts/thought/" <> thought.id, [thought: thought.thought, category: thought.category])
      thought -> Thought.update_thought(%{id: thought.id, count: thought.count + 1, most_recent: Ecto.DateTime.utc})
    end 

  end

  def insert_device(message, user) do
    device_info = message["device_info"]
    params = %{
          user_id: user.id,
          device: device_info["unique_id"],
          brand: device_info["brand"],
           name: device_info["name"],
           user_agent: device_info["user_agent"],
           locale: device_info["locale"],
           country: device_info["country"],

    }
    Logger.debug "device params: #{inspect(params)}"

    user_device = Device.get_device(params.device)
    cond do
      user_device == nil -> Device.insert_device(params)
      true -> user_device
    end
  end

  def find_users(thought) do
   # recall: find people and bots interested in category;
    # precision: rank them by distance
    # find users in thoughts_table who had thoughts in a category and in a given radius and order_by timestamp and distance
    ids = Thought.get_users(:location,thought)
    # fetch from elastic search
    # elastic_ids = get("/thoughts/thought/_search?q=thought:" <> thought.thought)
    rooms = for id <- ids, do: "room:#{id}"
    rooms
  end

  def notify_users(thought) do

    users = Thought.get_users(:location, thought)
      # push to all these users
    for user <- users do
       # broadcast to an external topic: user channel
        PingalServer.Endpoint.broadcast! "user:" <> user.id, "add:thought", %{
          user: thought.user_id,
          body: thought,
          timestamp: :os.system_time(:milli_seconds)
        }
    end
  end

  def get_room(thought) do
    # check if the room of same name or similar rooms exists

    Logger.debug "thought: #{inspect(thought)}"
    thought_body = String.trim(thought.thought)
    Logger.debug "thought_body: #{thought_body}"
    name = "room:#{thought.user_id}:#{thought.id}"
     Logger.debug "room_name: #{name}"
    # netword_id : I must use machine learning service to assign sub_category_id
    params = %{
      name: name,
      body: thought_body,
      category: thought.category,
      public: true,
      sponsored: false,
      host_id: thought.user_id,
      network_id: 1,
    }
    Logger.debug "device params: #{inspect(params)}"
    room = Room.get_room(:similar, thought_body)
    cond do
      room == nil or room == [] -> 
        Logger.debug "no similar room, creating a new room"
        %{id: room_id, name: room_name} = Room.insert_room(params)
      true -> 
        Logger.debug "found room"
        %{id: room_id, name: room_name} = room
      # false: insert and return a new room id with the thoguht
    end
  end

  def watch_new_rooms(socket, rooms) do
      Enum.reduce(rooms, socket, 
        fn room, acc ->
          rooms = acc.assigns.rooms
          if room in rooms do
            acc
          else
            :ok = PingalServer.Endpoint.subscribe(room)
            assign(acc, :rooms, [room | rooms])
          end
        end
      )
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
