defmodule SextoElugRj.GameBroadcaster do
	alias SextoElugRj.GameState
	alias SextoElugRj.Endpoint

	@timeout 100 
	@endpoint "spaceship:lobby"

	def start_link do
		GenServer.start_link(__MODULE__, %{})
	end

	def init(state) do
    	Process.send_after(self(), :work, @timeout)
    	{:ok, state}
	end

	def handle_info(:work, state) do
		Endpoint.broadcast @endpoint, 
							"update_state", 
							GameState.get_state

    	Process.send_after(self(), :work, @timeout)   
    	{:noreply, state}
	end
end