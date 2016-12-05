defmodule PingalServer.RoomChannel do
  use PingalServer.Web, :channel
  alias PingalServer.Presence
  alias PingalServer.User
  alias PingalServer.Room
  # alias PingalServer.Network
  alias PingalServer.Slide
  alias PingalServer.Event
  require Logger

  @moduledoc """

   Feature(s): 
      - discussion group around a thought (query | question | book | audio | video | sport), 
     
      A room  (or a chat page) consists of multiple slides from multiple users
  
      Queries:
      - Insert a slide (or data) in the channel
      - Insert an app
      - Find users by thought
      - Find rooms by thought
      - Find networks by thought
      
       We should be able to notify users in chat room along this channel.
        Events:
        - add:slide 
        - add:app
        - broadcast: to:user, to:room [room_name == hash(slide)
        - find:slides,
        - find:users (presence)
        - find:rooms 
        - find:networks
        - forward:slide

      Model: slide message
      message : {
        user: {
          id: integer,
          name: string,
          ...
        },
        body: string,
        channels: list, #[users, pages, networks],
        buttons: list, #[buttons, responses, actions]
        location: {
          longitude: float,
          latitude: float
        },
        address: {
            page: {
              name: string,
              id: integer
            },
            network: {
              name: string,
              id: integer
            }
          }
        timestamp : datetime
      }

       Future: action evetents = [buttons, inputs, commands, ...]
        - forward:* (forward:user_channel), service:*, command:*

  """

  def join("room:" <> room_id, payload, socket) do
    if authorized?(payload) do
      socket = socket |> assign(:room, room_id)
      #%{"ids" => ids} = payload
      #rooms = for id <- ids, do: "room:#{id}"
      #socket = socket |> assign(:rooms, []) |> watch_new_rooms(rooms)
      
      Logger.debug "room:#{inspect(room_id)} message: #{inspect(payload)}"
      #Logger.debug "rooms:#{inspect(rooms)} ; socket:#{inspect(socket)}"

      send(self(),:after_join)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # load room and track and add presence
  def handle_info(:after_join, socket) do
    slides = find_room_slides(socket)   
    Logger.debug "all slides: #{inspect slides}"

    broadcast! socket, "get:slides_in_room", %{slides: slides}

    Presence.track(socket, socket.assigns.user, %{
      online_at: :os.system_time(:milli_seconds)
      })
    push socket, "presence_state", Presence.list(socket)

    {:noreply, socket}
  end

  def handle_in("watch", %{"room_id" => id}, socket) do
    {:reply, :ok, watch_new_rooms(socket, ["room:#{id}"])}
  end

  def handle_in("unwatch", %{"room_id" => id}, socket) do
    {:reply, :ok, PingalServer.Endpoint.unsubscribe("room:#{id}")}
  end

  

  # add a slide
  def handle_in("add:slide" = event, message, socket) do
    Logger.debug "event: #{inspect(event)}"

    Logger.debug "message: #{inspect message}"
    Logger.debug "params for #{inspect socket.assigns.user} : #{inspect socket.assigns.params}"
    slide_temp_id = message["_id"]
    edit = message["edit"]
    Logger.debug(" slide_id: #{slide_temp_id}")
    params = %{body: Map.get(message, "text"),
                public: true,
                sponsored: false,
                user_id: socket.assigns.params.user_id,
                room_id: socket.assigns.params.room_id,
                id: slide_temp_id,
              }

    Logger.debug "slide_params: #{inspect(params)}"

    # insert after broadcast in the background
    if (!edit) do
      slide = Slide.insert_slide(params)
      Map.put(params, :id, slide.id)
      Logger.debug "slide_params after insert: #{inspect params}"
    end

    broadcast! socket, event, %{
      user: socket.assigns.user,
      body: Map.get(message, "text"),
      room: socket.topic,
      timestamp: :os.system_time(:milli_seconds),
      params: params
    }

    {:noreply, socket}

  end

  def handle_in("update:page" = event, message, socket) do
    Logger.debug "#{inspect(event)} message: #{inspect(message)}"
    
    address = Map.get(message, "address")
    room_params = %{id: address.page.id,
                    name: address.page.name,
                    body: Map.get(message, "text"),
                    public: true,
                    sponsored: false,
                    host_id: socket.assigns.params.user_id,
                    network_id: 1
                  }

    room = Room.update_room(room_params)
    Logger.debug "#{inspect(room)}"
    
  end

  # add a room
  def handle_in("add:page" = event, message, socket) do
    Logger.debug "event: #{inspect(event)}"

    Logger.debug "message: #{inspect(message)}"
    Logger.debug "params for #{inspect socket.assigns.user} : #{inspect socket.assigns.params}"

    room_params = %{name: socket.topic,
                    body: Map.get(message, "text"),
                    public: true,
                    sponsored: false,
                    host_id: socket.assigns.params.user_id,
                    network_id: 1
                  }

    # insert after broadcast in the background

    room = insert_room(socket, room_params)


    # adding room id to socket params
    Logger.debug "room_id: #{inspect(room.id)}"
    room_params = Map.put(room_params, :id, room.id )
    Logger.debug "room_params: #{inspect(room_params)}"

    broadcast! socket, event, %{
      user: socket.assigns.user,
      body: Map.get(message, "text"),
      room: room_params,
      timestamp: :os.system_time(:milli_seconds)
    }

    {:noreply, socket}

  end

   # find apps around me in a category
  def handle_in("find:apps" = event, message, socket) do
    Logger.debug "#{inspect(event)} message: #{inspect(message)}"
    
    # location query on network
      {:noreply, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  def insert_user(socket) do
    user = User.get_user(socket.assigns.user)
    cond do
      user == nil -> User.insert_user(%{"name" => socket.assigns.user})
      true -> user
    end
  end

  def insert_room(socket, room_params) do
    case Room.get_room(socket.topic) do
      nil -> Room.insert_room(room_params)
      room -> room
    end
  end

  def find_room_slides(socket) do
    # get slides from all rooms subscribed by user
    Slide.get_slides(:room, socket.assigns.room)
  end


  def insert_event(event \\ "view",socket) do
    Event.insert_event(%{
      name: event, 
      user_id: socket.assigns.params.user_id, 
      room_id: socket.assigns.params.room_id
    })
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
