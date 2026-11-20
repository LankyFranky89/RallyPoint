-- Rally Point: the waypoint arrow follows the quest you focus.
-- Focus = the quest you click in the quest log, or the quest you super-track
-- (the "focused" quest) if the client has that. Not done yet -> nearest objective,
-- done -> the person (or object) you hand it in to.
local _, ns = ...

local followed            -- questID the arrow is following
local followedDone        -- was it complete when we pointed at it
local lastSel, lastSuper  -- last selection we saw
local logWasShown = false

local function Print(msg) DEFAULT_CHAT_FRAME:AddMessage("|cffff9933Rally Point|r: " .. msg) end
local function Enabled() return not RallyPointDB or RallyPointDB.followLog ~= false end

local function Faction()
    local f = UnitFactionGroup and UnitFactionGroup("player")
    return f == "Horde" and "H" or "A"
end

-- quest log index for a questID, plus title and whether it's complete
local function LogInfo(questID)
    -- newer quest API (some WoW Forever builds)
    if C_QuestLog and C_QuestLog.GetLogIndexForQuestID and C_QuestLog.GetInfo then
        local i = C_QuestLog.GetLogIndexForQuestID(questID)
        local info = i and C_QuestLog.GetInfo(i)
        if info and not info.isHeader then
            local done = C_QuestLog.IsComplete and C_QuestLog.IsComplete(questID)
            return i, info.title, done and true or false
        end
    end
    -- classic quest API
    if GetNumQuestLogEntries and GetQuestLogTitle then
        for i = 1, GetNumQuestLogEntries() do
            local title, _, _, isHeader, _, isComplete, _, id = GetQuestLogTitle(i)
            if not isHeader and id == questID then
                return i, title, (isComplete == 1 or isComplete == true)
            end
        end
    end
end

local function HandIn(questID)
    local fac = Faction()
    for _, e in ipairs((ns.AllEnds and ns.AllEnds[questID]) or {}) do
        if not e.f or e.f:find(fac, 1, true) then return e end
    end
end

local function NearestObjective(questID)
    local best, bestD
    for _, p in ipairs((ns.Objectives and ns.Objectives[questID]) or {}) do
        local d = ns.DistanceTo(p.z, p.x, p.y)
        if d and (not bestD or d < bestD) then best, bestD = p, d end
        if not best then best = p end                -- other continent: still better than nothing
    end
    return best
end

local origSet -- the real ns.SetWaypoint (set below)

local function Follow(questID, announce)
    if not questID or questID == 0 or not Enabled() then return end
    local _, title, done = LogInfo(questID)
    if not title then
        if announce then Print("Couldn't read that quest from your log (quest " .. tostring(questID) .. ").") end
        return
    end
    local p, label
    if not done then
        p = NearestObjective(questID)
        if p then label = title .. ": " .. p.n end
    end
    if not p then
        p = HandIn(questID)
        if p then label = title .. ": hand in to " .. p.n end
    end
    if not p then
        if announce then Print("No location known for " .. title .. " (it may be a new WoW Forever quest).") end
        return
    end
    if origSet(p.z, p.x, p.y, label, true) then
        followed, followedDone = questID, done
    end
end
ns.FollowQuest = Follow
-- used by Quest Ledger Forever: point the arrow at the quest selected there
function RallyPoint_FollowQuest(questID) Follow(questID, true) end

-- Any other waypoint (e.g. clicking a quest in /dq) stops the quest-log following.
local watcher = CreateFrame("Frame")
watcher:RegisterEvent("PLAYER_LOGIN")
watcher:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        origSet = ns.SetWaypoint
        ns.SetWaypoint = function(...)
            followed = nil
            return origSet(...)
        end
        ns.OnWaypointCleared = function() followed = nil end
        self:RegisterEvent("QUEST_LOG_UPDATE")
        return
    end
    -- QUEST_LOG_UPDATE: switch to the hand-in when the followed quest is done,
    -- stop when it has left the log
    if not followed then return end
    local idx, _, done = LogInfo(followed)
    if not idx then
        followed = nil
        if ns.ClearWaypoint then ns.ClearWaypoint(true) end
    elseif done and not followedDone then
        local q = followed
        Follow(q, false)
        Print("Quest done - the arrow now points to where you hand it in.")
    end
end)

-- Watch for the focused quest changing (cheap: twice a second).
local function SelectedQuestID()
    if C_QuestLog and C_QuestLog.GetSelectedQuest then
        local id = C_QuestLog.GetSelectedQuest()
        if id and id ~= 0 then return id end
    end
    if GetQuestLogSelection then
        local i = GetQuestLogSelection()
        if i and i > 0 then
            local _, _, _, isHeader, _, _, _, id = GetQuestLogTitle(i)
            if not isHeader then return id end
        end
    end
end

local function LogShown()
    return (QuestLogFrame and QuestLogFrame:IsShown()) or (WorldMapFrame and WorldMapFrame:IsShown())
end

local t = 0
watcher:SetScript("OnUpdate", function(_, dt)
    t = t + dt
    if t < 0.5 or not origSet then return end
    t = 0
    if not Enabled() then return end
    -- Quest Ledger Forever's "Arrow" checkbox is off: don't follow quest selections
    if QuestLedgerForever_ArrowOff and QuestLedgerForever_ArrowOff() then return end
    -- super-tracked ("focused") quest, if the client has it
    if C_SuperTrack and C_SuperTrack.GetSuperTrackedQuestID then
        local id = C_SuperTrack.GetSuperTrackedQuestID()
        if id and id ~= 0 and id ~= lastSuper then
            lastSuper = id
            Follow(id, true)
        elseif not id or id == 0 then
            lastSuper = nil
        end
    end
    -- clicking a quest in the quest log. The log picks a quest by itself when it
    -- opens, so only react to changes made while it's already open.
    local shown = LogShown()
    local sel = SelectedQuestID()
    if shown and logWasShown and sel and sel ~= lastSel then
        Follow(sel, true)
    end
    lastSel = sel
    logWasShown = shown
end)
