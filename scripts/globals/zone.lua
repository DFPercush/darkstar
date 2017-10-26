------------------------------------
--
-- Contains global functions and variables
-- related to area specific things
--
------------------------------------


------------------------------------
-- zone related IDs
------------------------------------

    -- Zone Types
    ZONETYPE_NONE           = 0
    ZONETYPE_CITY           = 1
    ZONETYPE_OUTDOORS       = 2
    ZONETYPE_DUNGEON        = 3
    ZONETYPE_BATTLEFIELD    = 4
    ZONETYPE_DYNAMIS        = 5
    ZONETYPE_INSTANCED      = 6

    -- Continent Type
    THE_MIDDLE_LANDS        = 1
    THE_ARADJIAH_CONTINENT  = 2
    THE_SHADOWREIGN_ERA     = 3
    OTHER_AREAS             = 4

    -- Region Types
    REGION_RONFAURE         = 0
    REGION_ZULKHEIM         = 1
    REGION_NORVALLEN        = 2
    REGION_GUSTABERG        = 3
    REGION_DERFLAND         = 4
    REGION_SARUTABARUTA     = 5
    REGION_KOLSHUSHU        = 6
    REGION_ARAGONEU         = 7
    REGION_FAUREGANDI       = 8
    REGION_VALDEAUNIA       = 9
    REGION_QUFIMISLAND      = 10
    REGION_LITELOR          = 11
    REGION_KUZOTZ           = 12
    REGION_VOLLBOW          = 13
    REGION_ELSHIMOLOWLANDS  = 14
    REGION_ELSHIMOUPLANDS   = 15
    REGION_TULIA            = 16
    REGION_MOVALPOLOS       = 17
    REGION_TAVNAZIA         = 18
    REGION_SANDORIA         = 19
    REGION_BASTOK           = 20
    REGION_WINDURST         = 21
    REGION_JEUNO            = 22
    REGION_DYNAMIS          = 23
    REGION_TAVNAZIAN_MARQ   = 24
    REGION_PROMYVION        = 25
    REGION_LUMORIA          = 26
    REGION_LIMBUS           = 27
    REGION_WEST_AHT_URHGAN  = 28
    REGION_MAMOOL_JA_SAVAGE = 29
    REGION_HALVUNG          = 30
    REGION_ARRAPAGO         = 31
    REGION_ALZADAAL         = 32
    REGION_RONFAURE_FRONT   = 33
    REGION_NORVALLEN_FRONT  = 34
    REGION_GUSTABERG_FRONT  = 35
    REGION_DERFLAND_FRONT   = 36
    REGION_SARUTA_FRONT     = 37
    REGION_ARAGONEAU_FRONT  = 38
    REGION_FAUREGANDI_FRONT = 39
    REGION_VALDEAUNIA_FRONT = 40
    REGION_ABYSSEA          = 41
    REGION_THE_THRESHOLD    = 42
    REGION_ABDHALJS         = 43
    REGION_ADOULIN_ISLANDS  = 44
    REGION_EAST_ULBUKA      = 45

    REGION_UNKNOWN          = 255

-----------------------------------
-- SetExplorerMoogles
----------------------------------

function SetExplorerMoogles(moogle)
    if (EXPLORER_MOOGLE == 1) then
        local npc = GetNPCByID(moogle);
        if (npc == nil) then
            printf("'SetExplorerMoogles' Error trying to load undefined npc (%d)", moogle);
        else
            npc:setStatus(0);
        end
    end
end;

-----------------------------------
-- SetRespawnTime
----------------------------------

function SetRespawnTime(id, minTime, maxTime)
    -- This function is redundant should place the mob:setRespawnTime() and UpdateNMSpawnPoint back in the individual zones.
    -- Having this global just uses 3 functions where only 2 were needed.
    local mob = GetMobByID(id);
    if (mob == nil) then
        printf("'SetTimedSpawns' Error trying to load undefined mob (%d)", id);
    else
        UpdateNMSpawnPoint(id);
        mob:setRespawnTime(math.random((minTime),(maxTime)));
    end
end

ZONE_MESSAGES = {};
function FormatSpecialMessage(player, msg, args, showname)
    -- Sends a "special message" stored in the current zone's string table to a specific player.
    -- player: A C-bound player object, usually passed to you from the core as the first parameter to your function.
    -- msg: (string) The message to send. Not an ID number, but a table index defined in the zone's TextIDs.lua (ZONE_MESSAGES)
    -- args: A table which will be parsed according to the parameter names in ZONE_MESSAGES
    --     Example: {["time_remaining_seconds"]=30, ["time_remaining_minutes"]=2}
    -- showname: boolean, passes through to the message system. Shows the character's name as the speaker?
    if (type(ZONE_MESSAGES) == nil) then return false; end
    if (type(msg) ~= "string") then return false; end

    local msgDesc = ZONE_MESSAGES[msg];
    if (msgDesc == nil) then return false; end
    if (type(msgDesc.id) ~= "number") then return false; end
    if (type(msgDesc.params) ~= "table") then return false; end

    local resolvedArgs = {}
    if (type(args) == "table") then
        for x = 0, 3 do
            if (type(msgDesc.params[x]) == "string") then
                if (args[msgDesc.params[x]] ~= nil) then
                    resolvedArgs[x] = tonumber(args[msgDesc.params[x]]);
                end
            end
        end
    end
    
    player:messageSpecial(msgDesc.id, resolvedArgs[0], resolvedArgs[1], resolvedArgs[2], resolvedArgs[3], showname)
    return true
end
