-----------------------------------
-- Area: Balgas_Dais
-- Name: early bird catches the wyrm
-----------------------------------
package.loaded["scripts/zones/Balgas_Dais/TextIDs"] = nil;
-------------------------------------

require("scripts/globals/titles");
require("scripts/globals/quests");
require("scripts/globals/battlefield")

require("scripts/zones/Balgas_Dais/bcnms/eject");

dofile("scripts/zones/Balgas_Dais/TextIDs.lua");

-----------------------------------
-- EXAMPLE SCRIPT
--
-- What should go here:
-- giving key items, playing ENDING cutscenes
--
-- What should NOT go here:
-- Handling of "battlefield" status, spawning of monsters,
-- putting loot into treasure pool,
-- enforcing ANY rules (SJ/number of people/etc), moving
-- chars around, playing entrance CSes (entrance CSes go in bcnm.lua)

-- After registering the BCNM via bcnmRegister(bcnmid)
function onBcnmRegister(player,instance)
end;

-- Physically entering the BCNM via bcnmEnter(bcnmid)
function onBcnmEnter(player,instance)
end;

function onBattlefieldInitialise(battlefield)
    g_Battlefield.onInit(battlefield, "bcnm");
end

function onBattlefieldTick(battlefield, timeinside)
    g_Battlefield.onBattlefieldTick(battlefield, timeinside)
end

-- Leaving the BCNM by every mean possible, given by the LeaveCode
-- 1=Select Exit on circle
-- 2=Winning the BC
-- 3=Disconnected or warped out
-- 4=Losing the BC
-- via bcnmLeave(1) or bcnmLeave(2). LeaveCodes 3 and 4 are called
-- from the core when a player disconnects or the time limit is up, etc

function onBattlefieldLeave(player,instance,leavecode)
-- print("leave code "..leavecode);


    if (leavecode == 2) then -- play end CS. Need time and battle id for record keeping + storage
        player:startEvent(0x7d01,1,1,1,instance:getTimeInside(),1,1,0);
    elseif (leavecode == 4) then
        --player:startEvent(0x7d02);
        eject(player);
        --player:startEvent(0x7d02, 0, 0, 0, 0, 0, instance:getEntryPos(), 180);    -- player lost
        --player:startEvent(0x7d02, 0, 0, 0, 0, 0, 300, -123, 348, 196, 146);
        --player:startEvent(0x7d02, 0, 0, 0, 0, 0, 300, -123, 348, 196, 180);
    end

end;

function onEventUpdate(player,csid,option)
-- print("bc update csid "..csid.." and option "..option);
end;

function onEventFinish(player,csid,option)
-- print("bc finish csid "..csid.." and option "..option);
end;
