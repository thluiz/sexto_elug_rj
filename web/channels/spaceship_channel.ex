defmodule SextoElugRj.SpaceshipChannel do
  use SextoElugRj.Web, :channel
  alias SextoElugRj.GameState

  def join("spaceship:lobby", payload, socket) do
    state = GameState.get_state()
    send(self, {:after_join, payload})

    {:ok, state, socket}
  end

  def handle_info({:after_join, message}, socket) do
    player = %{id: message["id"] }
    player = GameState.put_player(player)
    broadcast! socket, "player:joined", %{player: player}
    {:noreply, socket}
  end

  def handle_in("update_player", payload, socket) do
    GameState.update_player %{
      id: payload["id"],
      x: payload["x"],
      y: payload["y"],
      r: payload["r"]      
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

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
