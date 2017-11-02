require("scripts/globals/TextIDs")

local MaxAreas =
{
    -- temenos
    {Max = 8, Zones = {37}},

    -- apollyon
    {Max = 6, Zones = {38}},

    -- dynamis
    {Max = 1, Zones = {39, 40, 41, 42, 134, 135, 185, 186, 187, 188,
                                140}}, -- ghelsba
}

function onBattlefieldHandlerInitialise(zone)
    local id = zone:getID()
    local default = 3
    for _, battlefield in pairs(MaxAreas) do
        for _, zoneid in pairs(battlefield.Zones) do
            if id == zoneid then
                return battlefield.Max
             end
        end
    end
    return default
end



g_Battlefield = {}

g_Battlefield.STATUS =
{
    OPEN     = 0,
    LOCKED   = 1,
    WON      = 2,
    LOST     = 3,
}

g_Battlefield.RETURNCODE =
{
    WAIT              = 1,
    CUTSCENE          = 2,
    INCREMENT_REQUEST = 3,
    LOCKED            = 4,
    REQS_NOT_MET      = 5,
    BATTLEFIELD_FULL  = 6
}

g_Battlefield.LEAVECODE =
{
    EXIT = 1,
    WON = 2,
    WARPDC = 3,
    LOST = 4
}

function g_Battlefield.onInit(battlefield, class)
    if (type(class) ~= "string") then
        class = "";
    end
    if ((class == "bcnm") or (class == "mission") or (class == "quest") or (class == "enm")) then
        -- This can be overwritten by a specific bcnm script after calling g_Battlefield.onInit()
        -- It's just a default value.
        battlefield:setLocalVar("AllowedWipeTime", 180);
    end
    -- To document and enumarate the other options available...
    if (class == "dynamis") then
    end
    if (class == "temenos") then
    end
    if (class == "apollyon") then
    end
end

function g_Battlefield.onBattlefieldTick(battlefield, timeinside, players)
    local killedallmobs = true
    local mobs = battlefield:getMobs(true, true)
    local status = battlefield:getStatus()
    local leavecode = -1
    local players = battlefield:getPlayers()
    print("fuck")
    local cutsceneTimer = battlefield:getLocalVar("cutsceneTimer")

    if status == g_Battlefield.STATUS.LOST then
        leavecode = 4
    elseif status == g_Battlefield.STATUS.WON then
        leavecode = 2
    end

    if leavecode ~= -1 then
        battlefield:setLocalVar("cutsceneTimer", cutsceneTimer + 1)

        local canLeave = true
        if status == g_Battlefield.STATUS.WON then
            if battlefield:getLocalVar("loot") ~= 0 then
                if canLeave and battlefield:getLocalVar("lootSpawned") == 0 and battlefield:spawnLoot() then
                    canLeave = false
                elseif battlefield:getLocalVar("lootSeen") == 1 then
                    canLeave = true
                end
            end
        end
        if canLeave and cutsceneTimer >= 15 then
            battlefield:cleanup(true)
        end
    end

    for _, mob in pairs(mobs) do
        if mob:getHP() > 0 then
            killedallmobs = false
            break
        end
    end

    g_Battlefield.HandleWipe(battlefield, players)

    -- if we cant send anymore time prompts theyre out of time
    if not g_Battlefield.SendTimePrompts(battlefield, players) then
        battlefield:cleanup(true)
    end

    if killedallmobs then
        battlefield:setStatus(g_Battlefield.STATUS.WON)
    end
end

-- returns false if out of time
function g_Battlefield.SendTimePrompts(battlefield, players)
    local tick = battlefield:getTimeInside()
    local status = battlefield:getStatus()
    local remainingTime = battlefield:getRemainingTime()
    local message = 0
    local lastTimeUpdate = battlefield:getLastTimeUpdate()

    players = players or battlefield:getPlayers()

    if lastTimeUpdate == 0 and remainingTime < 600 then
        message = 600;
    elseif lastTimeUpdate == 600 and remainingTime < 300 then
        message = 300;
    elseif lastTimeUpdate == 300 and remainingTime < 60 then
        message = 60;
    elseif lastTimeUpdate == 60 and remainingTime < 30 then
        message = 30;
    elseif lastTimeUpdate == 30 and remainingTime < 10 then
        message = 10;
    end

    if message ~= 0 then
        for i, player in pairs(players) do
            player:messageBasic(202, remainingTime)
        end
        battlefield:setLastTimeUpdate(message)
    end

    return remainingTime >= 0
end

function g_Battlefield.HandleWipe(battlefield, players)
    local rekt = true
    if (battlefield:getStatus() == g_Battlefield.STATUS.LOST) then
        return;
    end
    local elapsed = battlefield:getTimeInside()
    local allowedWipeDuration = battlefield:getLocalVar("AllowedWipeTime")
    if (allowedWipeDuration == 0) then
        return;  -- Battlefield does not have a wipe time limit. To insta-kick set a negative number.
    end
    local wiped = battlefield:getLocalVar("WipedAtTime")
    local lastWipeTimeNotice = battlefield:getLocalVar("LastWipeTimeNotice");
    local timeSinceWipe;
    if (wiped == 0) then
        timeSinceWipe = 0;
    else
        timeSinceWipe = elapsed - wiped;
    end
    local needWipeTimeNotice = false;
    
    players = players or battlefield:getPlayers()

    -- copied from instance.lua and modified from there
    if timeSinceWipe == 0 then
        for _, player in pairs(players) do
            if player:getHP() ~= 0 then
                rekt = false
                break
            end
        end
        if rekt then
            battlefield:setLocalVar("WipedAtTime", elapsed);
            if (elapsed - lastWipeTimeNotice > 0) then
                needWipeTimeNotice = true;
            end
        end
    else
        if ((timeSinceWipe > allowedWipeDuration) and (allowedWipeDuration ~= 0)) then
            battlefield:setStatus(g_Battlefield.STATUS.LOST);
        else
            for _, player in pairs(players) do
                if player:getHP() ~= 0 then
                    battlefield:setLocalVar("WipedAtTime", 0);
                    needWipeTimeNotice = false;
                    timeSinceWipe = 0;
                    wiped = 0
                    rekt = false;
                    break
                end
            end
        end
    end

    local wipeTimeRemaining = (allowedWipeDuration - timeSinceWipe);
    local lastNoticeDiff = elapsed - lastWipeTimeNotice;
    if ((not needWipeTimeNotice) and (rekt) and (lastWipeTimeNotice ~= 0) and (wiped ~= 0)) then
        if (wipeTimeRemaining <= 60 and lastNoticeDiff >= 15) then
            needWipeTimeNotice = true;
        elseif (wipeTimeRemaining <= 300 and lastNoticeDiff >= 30) then
            needWipeTimeNotice = true;
        elseif (wipeTimeRemaining <= 600 and lastNoticeDiff >= 60) then
            needWipeTimeNotice = true;
        elseif (wipeTimeRemaining <= 1800 and lastNoticeDiff >= 300) then
            needWipeTimeNotice = true;
        elseif (lastNoticeDiff >= 900) then
            needWipeTimeNotice = true;
        end
    end
    local msgId;
    if (needWipeTimeNotice == true and wipeTimeRemaining >= 5) then
        for _, player in pairs(players) do
            -- v:messageSpecial(ID, 3)
            msgId = msgSpecial[player:getZoneID()].BATTLEFIELD_WIPE_TIMER;
            if (msgId ~= nil) then
                player:messageSpecial(msgId, 0, 0, math.floor(wipeTimeRemaining % 60), math.floor(wipeTimeRemaining / 60));
            else
                player:messageSystem("If all party members' HP are still zero after " .. math.floor(wipeTimeRemaining / 60) .. " minutes and " .. math.floor(wipeTimeRemaining % 60) .. " seconds, the party will be removed from the battlefield.");
            end
            battlefield:setLocalVar("LastWipeTimeNotice", elapsed);
        end
    end
end


function g_Battlefield.onBattlefieldStatusChange(battlefield, players, status)

end

function g_Battlefield.HandleLootRolls(battlefield, lootTable, players, npc)
    players = players or battlefield:getPlayers()
    local lootGroup = lootTable[math.random(1, #lootTable)]

    if battlefield:getStatus() == g_Battlefield.STATUS.WON and battlefield:getLocalVar("lootSeen") == 0 then
        if npc then
            npc:setAnimation(8)
        end
        if lootGroup then
            for _, entry in pairs(lootGroup) do
                local chansu = entry.droprate / 1000
                local watashiNoChansu = math.random()

                if watashiNoChansu <= chansu then
                    players[1]:addTreasure(entry.itemid)
                end
            end
        else
            printf("fuckin loot groups")
        end
        battlefield:setLocalVar("cutsceneTimer", 10)
        battlefield:setLocalVar("lootSeen", 1)
    end
end