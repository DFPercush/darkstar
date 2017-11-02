-- Balgas_Dais
function eject(player, win)
	--player:setPos(x, y, z, player:getRotPos(), zoneID)
	player:release();
	if (win == nil or win == 0) then
		-- Lose, return to entrance
		player:setPos(300, -123, 348, 196, 146);
	else
		-- Win, come out the other side
		player:setPos(-299, 116, -339, 1, 146);
	end
end
