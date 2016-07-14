defmodule SextoElugRj.GameState do
	require Logger
	require IEx

	def start_link do
		Agent.start_link(fn -> %{} end, name: __MODULE__)
	end

	def get_state do
		Agent.get(__MODULE__, &(&1))
	end

	def put_player(player) do
		put_player(player, 0, 0, 0, 0)
	end

	def update_player_position(player, x, y, r) do
		player
		|> Map.update!(:x, x)
		|> Map.update!(:y, y)
		|> Map.update!(:rotation, r)
		|> update_player
	end

	def update_player_position(player) do	
		player
		|> check_colision
		|> update_player		
	end

	def get_player(player_id) do
		Agent.get(__MODULE__, &Map.get(&1, player_id))
	end

	defp update_player(player) do			
		Agent.update(__MODULE__, &Map.put(&1, player.id, player))
		player
	end

	def fire_from_player(bullet) do
		bullet = bullet				
		|> Map.put(:type, 1)

		if(!get_player(bullet.id)) do
			put_player(bullet, bullet.x, bullet.y, bullet.r, bullet.player)
		end
		
		update_player(bullet)		
	end

	def kill_player(id) do
		Logger.debug "KILL!"
		Agent.update(__MODULE__, &Map.drop(&1, get_player(id)))
	end

	defp put_player(player, x, y, r, pl) do
		player = player		
		|> Map.put(:type, 0)		
		|> Map.put(:kills, 0)
		|> Map.put(:x, x)
		|> Map.put(:y, y)
		|> Map.put(:r, r)
		|> Map.put(:player, pl)

		Agent.update(__MODULE__, &Map.put_new(&1, player.id, player))
		player
	end

	defp distance_from(playerX, playerY, x, y) do
		:math.sqrt(:math.pow((playerX - x), 2) + :math.pow((playerY - y),2) )
	end

	defp distance_from(player, other_player) do
		distance_from(player.x, player.y, other_player.x, other_player.y)
	end

	defp check_colision(player) do		
		get_state()
		|> Map.to_list
		|> Enum.filter(fn {id, _} -> id != player.id end)
		|> Enum.filter(fn { _, p} -> distance_from(p, player) < 50 end)					
		|> Enum.each(fn { _, p } -> increment_kill_count(p) end)

		player
	end

	defp increment_kill_count(player) do
		Logger.debug "KILLING"
		IO.inspect player
		Logger.debug "KILLING!!!!!!"

		player 
		|> Map.update!(:kills, &(&1 + 1)) 
		|> update_player
	end

end