defmodule SextoElugRj.GameState do

	def start_link do
		Agent.start_link(fn -> %{} end, name: __MODULE__)
	end

	def put_player(player) do
		put_player(player, 0, 0, 0)
	end

	def put_player(player, x, y, r) do
		player = player		
		|> Map.put(:type, 0)		
		|> Map.put(:kills, 0)
		|> Map.put(:x, x)
		|> Map.put(:y, y)
		|> Map.put(:r, r)

		Agent.update(__MODULE__, &Map.put_new(&1, player.id, player))
		player
	end

	def get_player(player_id) do
		Agent.get(__MODULE__, &Map.get(&1, player_id))
	end

	def update_player(player) do
		Agent.update(__MODULE__, &Map.put(&1, player.id, player))
		player
	end

	def fire_from_player(bullet) do
		bullet = bullet				
		|> Map.put(:type, 1)

		if(!get_player(bullet.id)) do
			put_player(bullet, bullet.x, bullet.y, bullet.r)
		end

		Agent.update(__MODULE__, &Map.put(&1, bullet.id, bullet))
		bullet	
	end

	def get_state do
		Agent.get(__MODULE__, &(&1))
	end

	def update_player_position(player, x, y, r) do
		player
		|> Map.update!(:x, x)
		|> Map.update!(:y, y)
		|> Map.update!(:rotation, r)
		|> update_player
	end

	def kill_player(id) do
		Agent.update(__MODULE__, &Map.drop(&1, get_player(id)))
	end

	def increment_kill_count(player) do
		player 
		|> Map.update!(:kills, &(&1 + 1)) 
		|> update_player
	end

end