---------------------------------------------------------------------------------------------------
-- func: !checkquest {player}
-- desc: Prints status of the quest to the in game chatlog
---------------------------------------------------------------------------------------------------

require("scripts/globals/quests");

cmdprops =
{
    permission = 1,
    parameters = "s"
};

function error(player, msg)
    player:PrintToPlayer(msg);
    player:PrintToPlayer("!checkquest <logID> <questID> {player}");
end;

function onTrigger(player,target)
    -- validate target
    local targ;
    if (target == nil) then
        targ = player:getCursorTarget();
        if (targ == nil or not targ:isPC()) then
            targ = player;
        end
    else
        targ = GetPlayerByName(target);
        if (targ == nil) then
            error(player, string.format("Player named '%s' not found!", target));
            return;
        end
    end

    -- get quest status
    local status;
    local iq, il;
	local curQuestCount = 0;
    local outstr = "";
    for il = 0, 10 do -- The binary blob in the database is 704 bytes, that's 64*11, Log IDs 4 and 11 are not used 2017-10-19.
        for iq = 0, 255 do
            status = targ:getQuestStatus(il,iq);
            if (status == 1) then
				curQuestCount = curQuestCount + 1;
                if (string.len(outstr) > 0) then
                    outstr = outstr + ",";
                end
                outstr = outstr .. il .. ":" .. iq;
            end
        end
    end
    -- show quest status
	if (string.len(outstr) == 0) then
		outstr = "(none)";
	end
    player:PrintToPlayer( string.format( "%s's %s current quests are %s", targ:getName(), curQuestCount, outstr ) );

end;
