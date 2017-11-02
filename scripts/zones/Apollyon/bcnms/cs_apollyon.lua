-----------------------------------
-- Area: Appolyon
-- Name: 
-----------------------------------
require("scripts/globals/limbus");
require("scripts/globals/keyitems");


-- After registering the BCNM via bcnmRegister(bcnmid)
function onBattlefieldRegister(player,battlefield)
    SetServerVariable("[CS_Apollyon]UniqueID",os.time());
    HideArmouryCrates(CS_Apollyon,APOLLYON_SE_NE);    
    SetServerVariable("[CS_Apollyon]Already_Received",0);
    GetNPCByID(16933245):setAnimation(8);
    GetNPCByID(16933246):setAnimation(8);
    GetNPCByID(16933247):setAnimation(8);
    despawnLimbusCS();
end;

-- Physically entering the BCNM via bcnmEnter(bcnmid)
function onBattlefieldEnter(player,battlefield)
    player:setVar("characterLimbusKey",GetServerVariable("[CS_Apollyon]UniqueID"));
    player:delKeyItem(COSMOCLEANSE);
end;

-- Leaving the by every mean possible, given by the LeaveCode
-- 3=Disconnected or warped out (if dyna is empty: launch 4 after 3)
-- 4=Finish
function onBattlefieldLeave(player,battlefield,leavecode)
    --print("leave code "..leavecode);
    if (leavecode == 4) then
        SetServerVariable("[CS_Apollyon]UniqueID",0);
        player:setPos(-668,0.1,-666);
    end
end;
require("scripts/globals/battlefield")

function onBattlefieldInitialise(battlefield)
    g_Battlefield.onInit(battlefield, "apollyon");
end

function onBattlefieldTick(battlefield, tick)
    g_Battlefield.onBattlefieldTick(battlefield, tick)
end
