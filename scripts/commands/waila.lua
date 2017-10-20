---------------------------------------------------------------------------------------------------
-- func: waila (What Am I Looking At?)
-- desc: Yields the ID and info about your target.
---------------------------------------------------------------------------------------------------

cmdprops =
{
    permission = 1,
    parameters = ""
};

function error(player, msg)
    player:PrintToPlayer(msg);
end;

function onTrigger(player)

    -- validate target
    local targ = player:getCursorTarget();
    if (targ == nil) then
        error(player, "Error: No target selected. Use !waila to find the ID of your cursor target.");
		return;
    end

	local targetType = "(unknown)";
	if (targ:isPC()) then
		targetType = "PC";
		if (targ:isAlly()) then
			targetType = targetType .. " (ally)";
		end
	elseif (targ:isNPC()) then
		targetType = "NPC";
	elseif (targ:isPet()) then
		targetType = "Pet";
	elseif (targ:isMob()) then
		targetType = "Mob";
	end
    player:PrintToPlayer(string.format("%s %i %s", targetType, targ:getID(), targ:getName()));
    
end;
