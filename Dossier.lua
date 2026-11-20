-- Dungeon Dossier: shows the quests for a dungeon, both the ones in your log
-- and the ones you could still pick up.
local ADDON, ns = ...
-- Dungeon Dossier, now part of Rally Point.
-- If the old standalone Dungeon Dossier is still enabled, let it do the job
-- so you don't get two "?" buttons and two /dq commands.
do
    local loaded = (C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("DungeonDossier"))
        or (IsAddOnLoaded and IsAddOnLoaded("DungeonDossier"))
    if loaded then
        DEFAULT_CHAT_FRAME:AddMessage("|cffff9933Rally Point|r: Dungeon Dossier is now built in. You can delete the old DungeonDossier addon folder.")
        return
    end
end

local band, lshift = bit.band, bit.lshift
local floor, format, tinsert, wipe = math.floor, string.format, table.insert, wipe

local DEFAULTS = { enter = true, entrance = true, group = true, point = nil }
local DB

local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffDungeon Dossier:|r " .. msg)
end

---------------------------------------------------------------------------
-- Player state
---------------------------------------------------------------------------
local SKILL_NAMES = {
    [129] = "First Aid", [164] = "Blacksmithing", [165] = "Leatherworking", [171] = "Alchemy",
    [182] = "Herbalism", [185] = "Cooking", [186] = "Mining", [197] = "Tailoring",
    [202] = "Engineering", [333] = "Enchanting", [356] = "Fishing", [393] = "Skinning",
    [633] = "Lockpicking",
}

local player = {}
local function UpdatePlayer()
    player.level = UnitLevel("player") or 1
    local _, _, raceID = UnitRace("player")
    local _, _, classID = UnitClass("player")
    player.raceMask = raceID and lshift(1, raceID - 1) or 0
    player.classMask = classID and lshift(1, classID - 1) or 0
    local fac = UnitFactionGroup("player")
    player.faction = (fac == "Horde") and "H" or "A"
    player.skills = {}
    if GetNumSkillLines and GetSkillLineInfo then
        for i = 1, GetNumSkillLines() do
            local name, isHeader, _, rank = GetSkillLineInfo(i)
            if name and not isHeader then player.skills[name] = rank or 0 end
        end
    end
end

local function IsDone(id)
    if C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted then
        return C_QuestLog.IsQuestFlaggedCompleted(id) and true or false
    elseif IsQuestFlaggedCompleted then
        return IsQuestFlaggedCompleted(id) and true or false
    end
    return false
end

---------------------------------------------------------------------------
-- Quest log scan (expands collapsed headers so nothing is missed, then puts
-- them back the way they were)
---------------------------------------------------------------------------
local questLog, logHeaders = {}, {}

local function ScanQuestLog()
    wipe(questLog); wipe(logHeaders)
    if GetQuestLogTitle and GetNumQuestLogEntries then
        local selected = GetQuestLogSelection and GetQuestLogSelection() or 0
        local expanded = {}
        local i, header = 1, nil
        while i <= (GetNumQuestLogEntries()) do
            local title, level, _, isHeader, isCollapsed, isComplete, _, questID = GetQuestLogTitle(i)
            if isHeader then
                header = title
                if isCollapsed and ExpandQuestHeader then
                    expanded[title] = true
                    ExpandQuestHeader(i)
                end
            elseif title then
                local entry = {
                    title = title, level = level, id = questID, header = header,
                    complete = (isComplete == 1 or isComplete == true), failed = (isComplete == -1),
                }
                if questID then questLog[questID] = entry end
                if header then
                    logHeaders[header] = logHeaders[header] or {}
                    tinsert(logHeaders[header], entry)
                end
            end
            i = i + 1
        end
        if next(expanded) and CollapseQuestHeader then
            for j = GetNumQuestLogEntries(), 1, -1 do
                local title, _, _, isHeader = GetQuestLogTitle(j)
                if isHeader and expanded[title] then CollapseQuestHeader(j) end
            end
        end
        if SelectQuestLogEntry and selected and selected > 0 then SelectQuestLogEntry(selected) end
    elseif C_QuestLog and C_QuestLog.GetNumQuestLogEntries then
        local header
        for i = 1, C_QuestLog.GetNumQuestLogEntries() do
            local info = C_QuestLog.GetInfo(i)
            if info then
                if info.isHeader then
                    header = info.title
                elseif info.questID then
                    local entry = {
                        title = info.title, level = info.level, id = info.questID, header = header,
                        complete = C_QuestLog.IsComplete and C_QuestLog.IsComplete(info.questID) or false,
                        failed = C_QuestLog.IsFailed and C_QuestLog.IsFailed(info.questID) or false,
                    }
                    questLog[info.questID] = entry
                    if header then
                        logHeaders[header] = logHeaders[header] or {}
                        tinsert(logHeaders[header], entry)
                    end
                end
            end
        end
    end
end

---------------------------------------------------------------------------
-- Names / locations
---------------------------------------------------------------------------
local function ZoneName(areaID)
    if not areaID then return nil end
    if C_Map and C_Map.GetAreaInfo then
        local n = C_Map.GetAreaInfo(areaID)
        if n and n ~= "" then return n end
    end
    return ns.ZoneNames[areaID]
end

local function QuestName(id)
    local q = ns.Quests[id]
    if q then return q.n end
    if questLog[id] then return questLog[id].title end
    return ns.OtherQuestNames[id] or ("quest #" .. id)
end

local function StarterText(s, area)
    if s.k == 3 then
        local where = ""
        if s.dd then
            local inHere = false
            for _, d in ipairs(s.dd) do if d == area then inHere = true end end
            if inHere then
                where = " (drops in here)"
            elseif ns.Dungeons[s.dd[1]] then
                where = " (drops in " .. ns.Dungeons[s.dd[1]].name .. ")"
            end
        end
        return "Starts from item: " .. s.n .. where
    end
    local zone = ZoneName(s.z)
    local loc = ""
    if zone and s.x then
        loc = format(" - %s (%.1f, %.1f)", zone, s.x, s.y)
    elseif zone then
        loc = " - " .. zone
    end
    return (s.k == 2 and "Starts at " or "From ") .. s.n .. loc
end

-- starters the player's faction can use
local function UsableStarters(q)
    if not q.s then return {} end
    local out = {}
    for _, s in ipairs(q.s) do
        if s.k ~= 1 or not s.f or s.f:find(player.faction, 1, true) then tinsert(out, s) end
    end
    return out
end

---------------------------------------------------------------------------
-- Availability
---------------------------------------------------------------------------
local function InLogOrDone(id) return questLog[id] ~= nil or IsDone(id) end

-- returns "log", "avail", "locked" (+ reason) or nil (not for you / already done)
local function QuestStatus(id, q)
    if questLog[id] then return "log" end
    if IsDone(id) then return nil end
    if q.ra and band(q.ra, player.raceMask) == 0 then return nil end
    if q.c and band(q.c, player.classMask) == 0 then return nil end
    if q.s and #UsableStarters(q) == 0 then return nil end
    if q.sp and band(q.sp, 1) == 1 then return nil end            -- repeatable turn-ins
    if q.pa and not questLog[q.pa] then return nil end             -- needs a parent quest active
    if q.mx and player.level > q.mx then return nil end
    if q.ex then for _, e in ipairs(q.ex) do if InLogOrDone(e) then return nil end end end
    if q.nx and InLogOrDone(q.nx) then return nil end

    if q.sk then
        local name = SKILL_NAMES[q.sk[1]]
        local have = name and player.skills[name]
        if not have or have < q.sk[2] then
            return "locked", "needs " .. (name or "a profession") .. (q.sk[2] > 0 and (" " .. q.sk[2]) or "")
        end
    end
    if q.pg then
        for _, p in ipairs(q.pg) do
            if not IsDone(p) then return "locked", "first do: " .. QuestName(p) end
        end
    end
    if q.ps and #q.ps > 0 then
        local ok = false
        for _, p in ipairs(q.ps) do if IsDone(p) then ok = true; break end end
        if not ok then return "locked", "first do: " .. QuestName(q.ps[1]) end
    end
    if q.r > player.level then return "locked", "needs level " .. q.r end
    return "avail"
end

local function Collect(area)
    local res = { log = {}, avail = {}, locked = {} }
    local seen = {}
    for id, q in pairs(ns.Quests) do
        local forThis = false
        for _, d in ipairs(q.d) do if d == area then forThis = true; break end end
        if forThis then
            local st, why = QuestStatus(id, q)
            if st == "log" then
                tinsert(res.log, { id = id, q = q, e = questLog[id] }); seen[id] = true
            elseif st == "avail" then
                tinsert(res.avail, { id = id, q = q })
            elseif st == "locked" and q.r <= player.level + 5 then
                tinsert(res.locked, { id = id, q = q, why = why })
            end
        end
    end
    -- anything filed under this dungeon's header in the quest log that the
    -- database doesn't know about
    for header, entries in pairs(logHeaders) do
        if header == ns.Dungeons[area].name or ns.DetectDungeon(header) == area then
            for _, e in ipairs(entries) do
                if not (e.id and seen[e.id]) then
                    seen[e.id or e.title] = true
                    tinsert(res.log, { id = e.id, e = e })
                end
            end
        end
    end
    local byLevel = function(a, b)
        local la = (a.q and a.q.l) or (a.e and a.e.level) or 0
        local lb = (b.q and b.q.l) or (b.e and b.e.level) or 0
        if la ~= lb then return la < lb end
        return (a.id or 0) < (b.id or 0)
    end
    table.sort(res.log, byLevel); table.sort(res.avail, byLevel); table.sort(res.locked, byLevel)
    return res
end

---------------------------------------------------------------------------
-- Quest chains and waypoints
---------------------------------------------------------------------------
local function AnyQuest(id) return ns.Quests[id] or (ns.ChainQuests and ns.ChainQuests[id]) end

local function ForMe(q)
    if not q then return false end
    if q.ra and band(q.ra, player.raceMask) == 0 then return false end
    if q.c and band(q.c, player.classMask) == 0 then return false end
    return true
end

-- Follows the prerequisites back to the first quest in the chain you still need to do.
local function ChainStart(id, depth)
    depth = depth or 0
    local q = AnyQuest(id)
    if not q or depth > 25 then return id end
    if q.pg then                                   -- every one of these must be done
        for _, p in ipairs(q.pg) do
            if not IsDone(p) and AnyQuest(p) and ForMe(AnyQuest(p)) then
                if questLog[p] then return p end
                return ChainStart(p, depth + 1)
            end
        end
    end
    if q.ps and #q.ps > 0 then                     -- any one of these is enough
        local ok = false
        for _, p in ipairs(q.ps) do if IsDone(p) then ok = true; break end end
        if not ok then
            for _, p in ipairs(q.ps) do
                if questLog[p] then return p end
            end
            for _, p in ipairs(q.ps) do
                if AnyQuest(p) and ForMe(AnyQuest(p)) then return ChainStart(p, depth + 1) end
            end
        end
    end
    return id
end

local function FirstPlace(list)
    for _, s in ipairs(list or {}) do
        if s.k ~= 3 and s.z and s.x and (not s.f or s.f:find(player.faction, 1, true)) then return s end
    end
end

-- What to point at for a quest row: { z, x, y, title, note }
local function WaypointFor(id, q, e, area)
    local dg = ns.Dungeons[area]
    if e then                                      -- already in your log
        if e.complete then
            local s = FirstPlace(ns.QuestEnds and ns.QuestEnds[id])
            if s then return { z = s.z, x = s.x, y = s.y, title = s.n, note = "Hand in: " .. s.n } end
        end
        local loc = dg and dg.locs and dg.locs[1]
        if loc then return { z = loc[1], x = loc[2], y = loc[3], title = dg.name .. " entrance", note = "Go to the " .. dg.name .. " entrance" } end
        return nil
    end
    if not q then return nil end
    local startId = ChainStart(id)
    local sq = AnyQuest(startId)
    if startId ~= id and questLog[startId] then
        local s = FirstPlace(ns.QuestEnds and ns.QuestEnds[startId])
        local name = (sq and sq.n) or QuestName(startId)
        if s then return { z = s.z, x = s.x, y = s.y, title = s.n, note = "Chain: hand in " .. name .. " to " .. s.n, chain = name } end
        return { note = "Chain: finish " .. name .. " (in your log) first", chain = name }
    end
    local s = sq and FirstPlace(sq.s)
    if s then
        local note = (startId ~= id) and ("Chain starts with: " .. sq.n .. " - from " .. s.n) or ("From " .. s.n)
        return { z = s.z, x = s.x, y = s.y, title = (startId ~= id) and (sq.n .. " (chain start)") or q.n, note = note,
                 chain = (startId ~= id) and sq.n or nil }
    end
    if sq and sq.s and sq.s[1] and sq.s[1].k == 3 then
        return { note = "Chain starts with: " .. sq.n .. " - starts from item: " .. sq.s[1].n, chain = sq.n }
    end
    return nil
end
ns.WaypointFor = WaypointFor

---------------------------------------------------------------------------
-- UI
---------------------------------------------------------------------------
local frame, scroll, content, titleText, subText
local rows = {}
local WIDTH = 330

local function LevelColor(level)
    if GetQuestDifficultyColor and level and level > 0 then
        local c = GetQuestDifficultyColor(level)
        if c then return format("|cff%02x%02x%02x", c.r * 255, c.g * 255, c.b * 255) end
    end
    return "|cffffffff"
end

local function RowEnter(self)
    local d = self.data
    if not d or not d.id then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    local q = d.q
    GameTooltip:AddLine((q and q.n) or (d.e and d.e.title) or "?", 1, 0.82, 0)
    if q then
        GameTooltip:AddLine(format("Quest level %d, requires level %d", q.l, q.r), 1, 1, 1)
        for _, s in ipairs(UsableStarters(q)) do
            GameTooltip:AddLine(StarterText(s, d.area), 0.8, 0.8, 0.8, true)
        end
        if d.why then GameTooltip:AddLine(d.why, 1, 0.3, 0.3, true) end
    end
    local w = WaypointFor(d.id, d.q, d.e, d.area)
    if w and w.note then GameTooltip:AddLine(w.note, 0.4, 1, 0.4, true) end
    if w and w.z then GameTooltip:AddLine("Click: set a waypoint", 0.4, 0.8, 1) end
    GameTooltip:Show()
end

local function RowClick(self)
    local d = self.data
    if not d then return end
    local w = WaypointFor(d.id, d.q, d.e, d.area)
    if w and w.z and ns.SetWaypoint then
        ns.SetWaypoint(w.z, w.x, w.y, w.title)
    elseif w and w.note then
        Print(w.note)
    end
end

local function GetRow(i)
    local r = rows[i]
    if not r then
        r = CreateFrame("Button", nil, content)
        r.text = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        r.text:SetPoint("TOPLEFT")
        r.text:SetJustifyH("LEFT")
        r.text:SetJustifyV("TOP")
        if r.text.SetWordWrap then r.text:SetWordWrap(true) end
        r:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
        r:RegisterForClicks("LeftButtonUp")
        r:SetScript("OnEnter", RowEnter)
        r:SetScript("OnLeave", function() GameTooltip:Hide() end)
        r:SetScript("OnClick", RowClick)
        rows[i] = r
    end
    return r
end

local function CreateUI()
    if frame then return end
    frame = CreateFrame("Frame", "DungeonDossierFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    frame:SetSize(WIDTH + 50, 420)
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local p, _, rp, x, y = self:GetPoint()
        DB.point = { p, rp, x, y }
    end)
    if frame.SetBackdrop then
        frame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true, tileSize = 32, edgeSize = 24,
            insets = { left = 6, right = 6, top = 6, bottom = 6 },
        })
    end
    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)

    titleText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleText:SetPoint("TOPLEFT", 16, -14)
    titleText:SetPoint("RIGHT", close, "LEFT", -4, 0)
    titleText:SetJustifyH("LEFT")
    subText = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    subText:SetPoint("TOPLEFT", titleText, "BOTTOMLEFT", 0, -3)
    subText:SetJustifyH("LEFT")

    scroll = CreateFrame("ScrollFrame", "DungeonDossierScroll", frame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 14, -48)
    scroll:SetPoint("BOTTOMRIGHT", -32, 14)
    content = CreateFrame("Frame", nil, scroll)
    content:SetSize(WIDTH, 10)
    scroll:SetScrollChild(content)

    tinsert(UISpecialFrames, "DungeonDossierFrame")
    frame:Hide()
end

local function PlaceFrame()
    frame:ClearAllPoints()
    if DB.point then
        frame:SetPoint(DB.point[1], UIParent, DB.point[2], DB.point[3], DB.point[4])
    else
        frame:SetPoint("RIGHT", UIParent, "RIGHT", -120, 40)
    end
end

-- lines: { text=, font=, indent=, data= }
local function Render(lines)
    local y = 0
    for i, l in ipairs(lines) do
        local r = GetRow(i)
        r:ClearAllPoints()
        r:SetPoint("TOPLEFT", content, "TOPLEFT", l.indent or 0, -y)
        r.text:SetFontObject(l.font or "GameFontHighlightSmall")
        r.text:SetWidth(WIDTH - (l.indent or 0))
        r.text:SetText(l.text)
        local h = floor(r.text:GetStringHeight() + 0.5) + (l.gap or 3)
        r:SetSize(WIDTH - (l.indent or 0), h)
        r.data = l.data
        r:EnableMouse(l.data ~= nil)
        r:Show()
        y = y + h
    end
    for i = #lines + 1, #rows do rows[i]:Hide(); rows[i].data = nil end
    content:SetHeight(math.max(y, 10))
    scroll:SetVerticalScroll(0)
end

local function BuildLines(areas)
    local lines, total = {}, 0
    for _, area in ipairs(areas) do
        local dg = ns.Dungeons[area]
        local res = Collect(area)
        local n = #res.log + #res.avail + #res.locked
        total = total + #res.log + #res.avail
        if #areas > 1 or n == 0 then
            tinsert(lines, { text = dg.name .. (dg.raid and " |cff999999(raid)|r" or ""), font = "GameFontNormal", gap = 4 })
        end
        if n == 0 then
            tinsert(lines, { text = "|cff999999No quests for you here right now.|r", indent = 6, gap = 10 })
        end
        if #res.log > 0 then
            tinsert(lines, { text = "|cff40ff40In your quest log (" .. #res.log .. ")|r", font = "GameFontNormalSmall", indent = 2 })
            for _, it in ipairs(res.log) do
                local e = it.e
                local lvl = (it.q and it.q.l) or (e and e.level) or 0
                local state = ""
                if e and e.complete then state = "  |cff40ff40- ready to turn in|r"
                elseif e and e.failed then state = "  |cffff4040- failed|r" end
                tinsert(lines, { text = format("%s[%d] %s|r%s", LevelColor(lvl), lvl, (e and e.title) or it.q.n, state),
                                 indent = 10, data = { id = it.id, q = it.q, e = e, area = area } })
            end
        end
        if #res.avail > 0 then
            tinsert(lines, { text = "|cffffd100Available to pick up (" .. #res.avail .. ")|r", font = "GameFontNormalSmall", indent = 2 })
            for _, it in ipairs(res.avail) do
                local q = it.q
                local starters = UsableStarters(q)
                local s = starters[1]
                local coords = (s and s.k ~= 3 and s.x and s.z) and { z = s.z, x = s.x, y = s.y, title = s.n } or nil
                local extra = (#starters > 1) and format(" |cff999999(+%d more)|r", #starters - 1) or ""
                tinsert(lines, { text = format("%s[%d] %s|r\n|cffbbbbbb%s%s|r", LevelColor(q.l), q.l, q.n,
                                 s and StarterText(s, area) or "Quest giver unknown", extra),
                                 indent = 10, data = { id = it.id, q = q, area = area, coords = coords } })
            end
        end
        if #res.locked > 0 then
            tinsert(lines, { text = "|cff999999Not available yet (" .. #res.locked .. ")|r", font = "GameFontNormalSmall", indent = 2 })
            for _, it in ipairs(res.locked) do
                local w = WaypointFor(it.id, it.q, nil, area)
                local chainTxt = (w and w.chain) and format("\n|cff66cc66Chain starts with: %s|r", w.chain) or ""
                tinsert(lines, { text = format("|cff888888[%d] %s - %s|r%s", it.q.l, it.q.n, it.why, chainTxt), indent = 10,
                                 data = { id = it.id, q = it.q, area = area, why = it.why } })
            end
        end
        tinsert(lines, { text = " ", gap = 4 })
    end
    return lines, total
end

-- areas: list of dungeon area IDs. force: show even if there is nothing to show.
local function ShowFor(areas, reason, force)
    if not areas or #areas == 0 then return false end
    UpdatePlayer()
    ScanQuestLog()
    local lines, total = BuildLines(areas)
    if total == 0 and not force then return false end
    CreateUI()
    PlaceFrame()
    titleText:SetText(#areas == 1 and ns.Dungeons[areas[1]].name or "Dungeon quests")
    subText:SetText(reason or "")
    frame:Show()
    Render(lines)
    return true
end

---------------------------------------------------------------------------
-- Dungeon name matching (slash command and group chat)
---------------------------------------------------------------------------
local KEYWORDS = {
    rfc = 2437, ragefire = 2437,
    wc = 718, wailing = 718,
    deadmines = 1581, vc = 1581,
    sfk = 209, shadowfang = 209,
    bfd = 719, blackfathom = 719,
    stocks = 717, stockade = 717, stockades = 717,
    gnomer = 721, gnomeregan = 721,
    rfk = 491, kraul = 491,
    sm = 796, smgy = 796, smlib = 796, smarm = 796, smcath = 796, scarlet = 796,
    rfd = 722,
    uld = 1337, ulda = 1337, uldaman = 1337,
    zf = 1176, zulfarrak = 1176, ["zul'farrak"] = 1176,
    mara = 2100, maraudon = 2100,
    st = 1477, sunken = 1477,
    brd = 1584,
    brs = 1583, lbrs = 1583, ubrs = 1583,
    dme = 2557, dmw = 2557, dmn = 2557, dmt = 2557, diremaul = 2557,
    scholo = 2057, scholomance = 2057,
    strat = 2017, strath = 2017, stratholme = 2017,
    mc = 2717,
    ony = 2159, onyxia = 2159,
    zg = 1977, ["zul'gurub"] = 1977, zulgurub = 1977,
    bwl = 2677,
    aq20 = 3429, aq40 = 3428,
    naxx = 3456, naxxramas = 3456,
}
local PHRASES = {
    { "ragefire chasm", 2437 }, { "wailing caverns", 718 }, { "shadowfang keep", 209 }, { "blackfathom deeps", 719 },
    { "razorfen kraul", 491 }, { "razorfen downs", 722 }, { "scarlet monastery", 796 }, { "zul'farrak", 1176 },
    { "zul farrak", 1176 }, { "sunken temple", 1477 }, { "temple of atal", 1477 }, { "blackrock depths", 1584 },
    { "blackrock spire", 1583 }, { "dire maul", 2557 }, { "molten core", 2717 }, { "blackwing lair", 2677 },
    { "zul gurub", 1977 }, { "onyxia's lair", 2159 }, { "ruins of ahn", 3429 }, { "temple of ahn", 3428 }, { "the stockade", 717 },
}

local function DetectDungeon(msg)
    if not msg or msg == "" then return nil end
    local low = msg:lower()
    for _, p in ipairs(PHRASES) do
        if low:find(p[1], 1, true) then return p[2] end
    end
    for word in low:gmatch("[%a%d']+") do
        if word == "dm" then
            -- Deadmines for low levels, Dire Maul for high levels
            return (UnitLevel("player") or 1) <= 30 and 1581 or 2557
        end
        if KEYWORDS[word] then return KEYWORDS[word] end
    end
    return nil
end
ns.DetectDungeon = DetectDungeon

local function FindByName(arg)
    local a = DetectDungeon(arg)
    if a then return a end
    local low = arg:lower()
    for _, id in ipairs(ns.Order) do
        if ns.Dungeons[id].name:lower():find(low, 1, true) then return id end
    end
    return nil
end

---------------------------------------------------------------------------
-- Trigger 1: entering a dungeon
---------------------------------------------------------------------------
local lastInstance

local function CurrentInstanceArea()
    local _, itype, _, _, _, _, _, instanceID = GetInstanceInfo()
    if itype == "party" or itype == "raid" then
        return ns.InstanceToArea[instanceID], instanceID
    end
    return nil, nil
end

local function CheckInstance()
    local area, instanceID = CurrentInstanceArea()
    if not area then lastInstance = nil; return end
    if instanceID == lastInstance then return end
    lastInstance = instanceID
    if not DB.enter then return end
    if not ShowFor({ area }, "You entered " .. ns.Dungeons[area].name) then
        Print("No quests for you in " .. ns.Dungeons[area].name .. ". Type /dq to check anyway.")
    end
end

---------------------------------------------------------------------------
-- Trigger 2: near the entrance
---------------------------------------------------------------------------
local NEAR, FAR = 3.5, 7      -- map percent; must move FAR away before it can pop again
local nearState = {}

local function CheckEntrance()
    if not DB or not DB.entrance then return end
    if IsInInstance() then return end
    if not (C_Map and C_Map.GetBestMapForUnit and C_Map.GetPlayerMapPosition) then return end
    local map = C_Map.GetBestMapForUnit("player")
    if not map then return end
    local pos = C_Map.GetPlayerMapPosition(map, "player")
    if not pos then return end
    local px, py = pos:GetXY()
    if not px or (px == 0 and py == 0) then return end
    px, py = px * 100, py * 100

    local newlyNear = {}
    for _, area in ipairs(ns.Order) do
        local best
        for _, loc in ipairs(ns.Dungeons[area].locs) do
            if ns.AreaToUiMap[loc[1]] == map then
                local dx, dy = px - loc[2], py - loc[3]
                local dist = math.sqrt(dx * dx + dy * dy)
                if not best or dist < best then best = dist end
            end
        end
        if best and best <= NEAR then
            if not nearState[area] then nearState[area] = true; tinsert(newlyNear, area) end
        elseif not best or best >= FAR then
            nearState[area] = nil
        end
    end
    if #newlyNear > 0 then
        ShowFor(newlyNear, "You're near the entrance")
    end
end

---------------------------------------------------------------------------
-- Trigger 3: joining a group that is heading to a dungeon
---------------------------------------------------------------------------
local chatLog = {}            -- recent chat: { t, sender, msg }
local CHAT_KEEP, LOOKBACK, AFTER_JOIN = 300, 180, 120
local wasGrouped, joinedAt = false, 0
local shownForGroup = {}

local function ShortName(n) return n and (Ambiguate and Ambiguate(n, "short") or n:match("^[^-]+")) or nil end

local function GroupMembers()
    local set = { [UnitName("player")] = true }
    local prefix, n = "party", GetNumSubgroupMembers and GetNumSubgroupMembers() or 0
    if IsInRaid and IsInRaid() then prefix, n = "raid", GetNumGroupMembers() end
    for i = 1, n do
        local name = UnitName(prefix .. i)
        if name then set[name] = true end
    end
    return set
end

local function ShowGroupDungeon(area, who)
    if not area or shownForGroup[area] then return end
    if CurrentInstanceArea() == area then return end
    shownForGroup[area] = true
    ShowFor({ area }, (who and (who .. " mentioned ") or "Your group mentioned ") .. ns.Dungeons[area].name)
end

local function OnGroupChanged()
    local grouped = IsInGroup and IsInGroup() or (GetNumGroupMembers and GetNumGroupMembers() > 0)
    if grouped and not wasGrouped then
        joinedAt = GetTime()
        wipe(shownForGroup)
        if DB.group then
            local members = GroupMembers()
            local now = GetTime()
            for i = #chatLog, 1, -1 do
                local c = chatLog[i]
                if now - c.t > LOOKBACK then break end
                if members[c.sender] or (c.to and members[c.to]) then
                    local area = DetectDungeon(c.msg)
                    if area then ShowGroupDungeon(area, c.sender ~= UnitName("player") and c.sender or nil); break end
                end
            end
        end
    elseif not grouped then
        wipe(shownForGroup)
    end
    wasGrouped = grouped
end

local GROUP_CHAT = {
    CHAT_MSG_PARTY = true, CHAT_MSG_PARTY_LEADER = true, CHAT_MSG_RAID = true, CHAT_MSG_RAID_LEADER = true,
}

local function OnChat(event, msg, sender)
    local s = ShortName(sender)
    local entry = { t = GetTime(), sender = s, msg = msg }
    if event == "CHAT_MSG_WHISPER_INFORM" then entry.sender = UnitName("player"); entry.to = s end
    tinsert(chatLog, entry)
    local now = GetTime()
    while chatLog[1] and now - chatLog[1].t > CHAT_KEEP do table.remove(chatLog, 1) end
    if #chatLog > 300 then table.remove(chatLog, 1) end

    -- shortly after joining, group chat naming a dungeon also counts
    if DB.group and GROUP_CHAT[event] and wasGrouped and now - joinedAt <= AFTER_JOIN then
        local area = DetectDungeon(msg)
        if area then ShowGroupDungeon(area, entry.sender ~= UnitName("player") and entry.sender or nil) end
    end
end

---------------------------------------------------------------------------
-- Slash command
---------------------------------------------------------------------------
local function OnOff(v) return v and "|cff40ff40on|r" or "|cffff4040off|r" end

local function Slash(msg)
    msg = (msg or ""):gsub("^%s+", ""):gsub("%s+$", "")
    local cmd, rest = msg:match("^(%S+)%s*(.-)$")
    cmd = cmd and cmd:lower()

    if cmd == "auto" then
        local key = rest:lower()
        if key == "enter" or key == "entrance" or key == "group" then
            DB[key] = not DB[key]
            Print("Auto popup '" .. key .. "' is now " .. OnOff(DB[key]) .. ".")
        else
            Print("Auto popups: enter " .. OnOff(DB.enter) .. ", entrance " .. OnOff(DB.entrance) .. ", group " .. OnOff(DB.group) .. ".")
            Print("Toggle with /dq auto enter | entrance | group")
        end
        return
    elseif cmd == "reset" then
        DB.point = nil
        if frame then PlaceFrame() end
        Print("Window position reset.")
        return
    elseif cmd == "help" or cmd == "?" then
        Print("/dq - quests for the dungeon you're in (or standing next to)")
        Print("/dq <dungeon> - e.g. /dq sfk, /dq deadmines, /dq brd")
        Print("/dq auto [enter|entrance|group] - turn auto popups on/off")
        Print("/dq reset - reset the window position")
        return
    end

    if msg == "" then
        local area = CurrentInstanceArea()
        if area then ShowFor({ area }, "You are in " .. ns.Dungeons[area].name, true); return end
        -- nearest entrance on the current map
        local map = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
        local pos = map and C_Map.GetPlayerMapPosition(map, "player")
        if pos then
            local px, py = pos:GetXY()
            px, py = px * 100, py * 100
            local near = {}
            for _, a in ipairs(ns.Order) do
                for _, loc in ipairs(ns.Dungeons[a].locs) do
                    if ns.AreaToUiMap[loc[1]] == map then
                        local dx, dy = px - loc[2], py - loc[3]
                        if dx * dx + dy * dy <= 15 * 15 then tinsert(near, a); break end
                    end
                end
            end
            if #near > 0 then ShowFor(near, "Dungeons near you", true); return end
        end
        Print("You're not in or near a dungeon. Try /dq <dungeon>, e.g. /dq sfk. (/dq help)")
        return
    end

    local area = FindByName(msg)
    if area then
        ShowFor({ area }, "Checked with /dq", true)
    else
        Print("Don't know the dungeon '" .. msg .. "'. Try an abbreviation like wc, sfk, sm, brd, strat.")
    end
end

SLASH_DUNGEONDOSSIER1 = "/dq"
SLASH_DUNGEONDOSSIER2 = "/dossier"
SlashCmdList.DUNGEONDOSSIER = Slash

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------
local ev = CreateFrame("Frame")
ev:RegisterEvent("ADDON_LOADED")
ev:RegisterEvent("PLAYER_LOGIN")
ev:RegisterEvent("PLAYER_ENTERING_WORLD")
ev:RegisterEvent("ZONE_CHANGED_NEW_AREA")
ev:RegisterEvent("GROUP_ROSTER_UPDATE")
for _, e in ipairs({ "CHAT_MSG_CHANNEL", "CHAT_MSG_WHISPER", "CHAT_MSG_WHISPER_INFORM", "CHAT_MSG_SAY",
                     "CHAT_MSG_YELL", "CHAT_MSG_GUILD", "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER",
                     "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER" }) do
    ev:RegisterEvent(e)
end

ev:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        if ... ~= ADDON then return end
        DungeonDossierDB = DungeonDossierDB or {}
        DB = DungeonDossierDB
        for k, v in pairs(DEFAULTS) do if DB[k] == nil then DB[k] = v end end
        self:UnregisterEvent("ADDON_LOADED")
    elseif not DB then
        return
    elseif event == "PLAYER_LOGIN" then
        wasGrouped = IsInGroup and IsInGroup() or false
        C_Timer.NewTicker(2, CheckEntrance)
    elseif event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
        -- small delay so the quest log and instance info are ready
        C_Timer.After(2, CheckInstance)
    elseif event == "GROUP_ROSTER_UPDATE" then
        OnGroupChanged()
    else
        OnChat(event, ...)
    end
end)

---------------------------------------------------------------------------
-- "?" buttons in the Looking For Group window
---------------------------------------------------------------------------
local ALIASES = {
    ["deadmines"] = 1581, ["stockade"] = 717, ["stockades"] = 717, ["sunken temple"] = 1477,
    ["temple of atal'hakkar"] = 1477, ["lower blackrock spire"] = 1583, ["upper blackrock spire"] = 1583,
    ["ahn'qiraj"] = 3428, ["ahn'qiraj temple"] = 3428,
}
local function Normalize(t)
    t = t:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("%b()", "")
    t = t:lower():gsub("^%s+", ""):gsub("%s+$", "")
    return t
end
local NAMEMAP
local function AreaForText(text)
    if not NAMEMAP then
        NAMEMAP = {}
        for _, a in ipairs(ns.Order) do
            local n = ns.Dungeons[a].name:lower()
            NAMEMAP[n] = a
            NAMEMAP[(n:gsub("^the ", ""))] = a
        end
        for k, v in pairs(ALIASES) do NAMEMAP[k] = v end
    end
    local n = Normalize(text)
    if NAMEMAP[n] then return NAMEMAP[n] end
    for name, a in pairs(NAMEMAP) do                 -- "Dire Maul - East", "Scarlet Monastery Armory"
        if #n > #name and n:sub(1, #name) == name and n:sub(#name + 1, #name + 1):match("[%s%-:]") then return a end
    end
    return nil
end

local function AddTooltipLines(area, rawName)
    UpdatePlayer(); ScanQuestLog()
    local MAX = 8
    if area then
        local res = Collect(area)
        GameTooltip:AddLine(ns.Dungeons[area].name, 1, 0.82, 0)
        if #res.log + #res.avail + #res.locked == 0 then
            GameTooltip:AddLine("No quests for you here right now.", 0.6, 0.6, 0.6)
        end
        if #res.log > 0 then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("In your quest log:", 0.25, 1, 0.25)
            for i, it in ipairs(res.log) do
                if i > MAX then GameTooltip:AddLine(format("  +%d more", #res.log - MAX), 0.6, 0.6, 0.6); break end
                local e = it.e
                GameTooltip:AddLine("  " .. ((e and e.title) or it.q.n) .. ((e and e.complete) and " |cff40ff40(ready to turn in)|r" or ""), 1, 1, 1)
            end
        end
        if #res.avail > 0 then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Pick up before you go:", 1, 0.82, 0)
            for i, it in ipairs(res.avail) do
                if i > MAX then GameTooltip:AddLine(format("  +%d more", #res.avail - MAX), 0.6, 0.6, 0.6); break end
                local s = UsableStarters(it.q)[1]
                GameTooltip:AddLine(format("  [%d] %s", it.q.l, it.q.n), 1, 1, 1)
                if s then GameTooltip:AddLine("      " .. StarterText(s, area), 0.7, 0.7, 0.7, true) end
            end
        end
        if #res.locked > 0 then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(format("%d more not available yet", #res.locked), 0.6, 0.6, 0.6)
        end
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Click for the full list", 0.4, 0.8, 1)
    else
        -- dungeon not in the database (WoW Forever custom dungeon): use quest log headers only
        GameTooltip:AddLine(rawName, 1, 0.82, 0)
        local hdr = logHeaders[rawName]
        if hdr and #hdr > 0 then
            GameTooltip:AddLine("In your quest log:", 0.25, 1, 0.25)
            for _, e in ipairs(hdr) do
                GameTooltip:AddLine("  " .. e.title .. (e.complete and " |cff40ff40(ready to turn in)|r" or ""), 1, 1, 1)
            end
        else
            GameTooltip:AddLine("No quest data for this dungeon yet.", 0.6, 0.6, 0.6, true)
        end
    end
end

local qButtons = {}            -- [fontString] = button
local function QButton(fs)
    local b = qButtons[fs]
    if b then return b end
    local parent = fs:GetParent()
    b = CreateFrame("Button", nil, parent)
    b:SetSize(14, 14)
    b:SetFrameLevel(parent:GetFrameLevel() + 5)
    -- Blizzard's gold quest "?" (the one quest givers show)
    b.icon = b:CreateTexture(nil, "ARTWORK")
    b.icon:SetAllPoints()
    b.icon:SetTexture("Interface\\GossipFrame\\ActiveQuestIcon")
    b:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
    b:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        AddTooltipLines(self.area, self.rawName)
        GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)
    b:SetScript("OnClick", function(self)
        GameTooltip:Hide()
        if self.area then
            ShowFor({ self.area }, "From the Looking For Group window", true)
        else
            Print("No quest data for " .. self.rawName .. " yet.")
        end
    end)
    qButtons[fs] = b
    return b
end

-- Remembers what each text line said last time, so unchanged lines cost nothing.
local textCache = setmetatable({}, { __mode = "k" })   -- fontstring -> { text = , info = }
local BRACKET = "^%(%d+%s*%-%s*%d+%)$"

local function Clean(t) return (t:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")) end

local function FindBracket(r, ...)
    for i = 1, select("#", ...) do
        local s = select(i, ...)
        if s ~= r and s.GetText and s:IsVisible() then
            local st = s:GetText()
            if st and st ~= "" and #st < 20 and Clean(st):match(BRACKET) then return s end
        end
    end
end

local function WalkRegions(frame, found, ...)
    for i = 1, select("#", ...) do
        local r = select(i, ...)
        if r.GetObjectType and r:GetObjectType() == "FontString" and r:IsVisible() then
            local t = r:GetText()
            if t and t ~= "" and #t < 60 then
                local c = textCache[r]
                if not c or c.text ~= t then
                    c = c or {}
                    c.text = t
                    c.info = nil
                    if not t:match("^%(") then
                        local area = AreaForText(t)
                        local bracket = FindBracket(r, frame:GetRegions())
                        if area or bracket then             -- custom dungeons: name next to "(13 - 20)"
                            c.info = { area = area, bracket = bracket, raw = Clean(t) }
                        end
                    end
                    textCache[r] = c
                elseif c.info and c.info.bracket and not c.info.bracket:IsVisible() then
                    c.info.bracket = FindBracket(r, frame:GetRegions())
                end
                if c.info then found[r] = c.info end
            end
        end
    end
end

local function WalkChildren(depth, found, ...)
    for i = 1, select("#", ...) do
        local c = select(i, ...)
        if c.IsVisible and c:IsVisible() then
            WalkRegions(c, found, c:GetRegions())
            if depth < 8 then WalkChildren(depth + 1, found, c:GetChildren()) end
        end
    end
end

local function Walk(frame, depth, found)
    if not frame or not frame.IsVisible or not frame:IsVisible() then return end
    WalkRegions(frame, found, frame:GetRegions())
    WalkChildren(depth + 1, found, frame:GetChildren())
end

local LFG_CANDIDATES = { "LFGParentFrame", "LFGListingFrame", "LFGBrowseFrame", "LFGFrame", "PVEFrame", "LFGListFrame" }
local lfgFrames = {}
local function FindLFGFrames()
    for _, n in ipairs(LFG_CANDIDATES) do
        local f = _G[n]
        if f and type(f) == "table" and f.IsVisible then lfgFrames[f] = true end
    end
end

local lfgElapsed = 0
local lfgFound = {}
local lfgWatcher = CreateFrame("Frame")
lfgWatcher:SetScript("OnUpdate", function(_, dt)
    lfgElapsed = lfgElapsed + dt
    if lfgElapsed < 0.5 then return end
    lfgElapsed = 0
    if not next(lfgFrames) then FindLFGFrames() end
    local found = wipe(lfgFound)
    local any = false
    for f in pairs(lfgFrames) do
        if f:IsVisible() then any = true; Walk(f, 0, found) end
    end
    for fs, b in pairs(qButtons) do
        if not found[fs] then b:Hide() end
    end
    if not any then return end
    for fs, info in pairs(found) do
        local b = QButton(fs)
        b.area, b.rawName = info.area, info.raw
        b:ClearAllPoints()
        local anchor = info.bracket or fs
        local just = anchor.GetJustifyH and anchor:GetJustifyH() or "LEFT"
        if just == "RIGHT" then
            b:SetPoint("LEFT", anchor, "RIGHT", 1, 0)
        elseif just == "CENTER" then
            b:SetPoint("LEFT", anchor, "CENTER", anchor:GetStringWidth() / 2 + 1, 0)
        else
            b:SetPoint("LEFT", anchor, "LEFT", anchor:GetStringWidth() + 1, 0)
        end
        b:Show()
    end
end)

---------------------------------------------------------------------------
-- Shared with Rally Point: quests you can still pick up for a dungeon name
---------------------------------------------------------------------------
function DungeonDossier_AvailableQuests(dungeonName)
    if type(dungeonName) ~= "string" then return nil end
    local area = AreaForText(dungeonName)
    if not area then return nil end
    -- one quest log scan per second at most, even when Rally Point asks for many listings
    local t = GetTime and GetTime() or 0
    if not ns.lastShareScan or t - ns.lastShareScan > 1 then
        ns.lastShareScan = t
        UpdatePlayer(); ScanQuestLog()
    end
    local out = {}
    for _, it in ipairs(Collect(area).avail) do
        out[#out + 1] = format("[%d] %s", it.q.l or 0, it.q.n or "?")
    end
    return out
end
