defmodule SextoElugRj.SpaceshipChannel do
  use SextoElugRj.Web, :channel
  alias SextoElugRj.GameState
  alias SextoElugRj.Presence

  intercept ["disconnect"]

  def join("spaceship:lobby", payload, socket) do
    send(self, {:after_join, payload})
    {:ok, assign(socket, :id, payload["id"]) }
  end

  def handle_info({:after_join, message}, socket) do
    player = %{id: message["id"] }
    player = GameState.put_player(player)

    push socket, "presence_state", Presence.list(socket)

    {:ok, _} = Presence.track(socket, socket.assigns.id, %{
      online_at: inspect(System.system_time(:seconds))
    })

    broadcast! socket, "player:joined", %{player: player}
    {:noreply, socket}
  end

  def terminate({:shutdown, _}, socket) do
    GameState.kill_player(socket.assigns.id)
    {:noreply, socket}
  end

  def handle_in("fire_from_player", payload, socket) do
    GameState.fire_from_player %{
      id: payload["id"],
      x: payload["x"],
      y: payload["y"],
      r: payload["r"], 
      player: payload["player"] 
    }

    {:noreply, socket} 
  end

  def handle_in("update_player", payload, socket) do
    GameState.update_player %{
      id: payload["id"],
      x: payload["x"],
      y: payload["y"],
      r: payload["r"],
      type: 0,
      player: 0      
    }
    {:noreply, socket} 
  end 

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (spaceship:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  def handle_in("disconnect", %{id: id}, socket) do
    GameState.kill_player(id)
    {:noreply, socket}
  end

  def handle_out("disconnect", _payload, socket) do
    push socket, "disconnect", %{
      id: socket.assigns.id, 
    }

    {:noreply, socket}
  end

  # Add authorization logic here as required.
  #defp authorized?(_payload) do
  #  true
  #end
end
