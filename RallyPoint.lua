local function Secret(v) -- chat hidden by the game (or faked by /cc secret)
  if CopyCatFakeSecret and CopyCatFakeSecret > GetTime() then return true end
  return issecretvalue ~= nil and issecretvalue(v) == true
end
-- Rally Point: filters on top of Blizzard's Looking For Group browser (WoW Forever).
-- Reads the results Blizzard's LFG tool already fetched; it never forms groups itself.
local ADDON, ns = ...
local DB
local f = CreateFrame("Frame")
local rebuildPending = false

local CLASSES = { "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" }
local ROLES = { "TANK", "HEALER", "DAMAGER" }
local ROLE_NAME = { TANK = "Tank", HEALER = "Healer", DAMAGER = "DPS" }
local QUOTA = { TANK = 1, HEALER = 1, DAMAGER = 3 } -- 5-player dungeon
local ROLE_ICON = {
  TANK = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:14:14:0:0:64:64:0:19:22:41|t",
  HEALER = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:14:14:0:0:64:64:20:39:1:20|t",
  DAMAGER = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:14:14:0:0:64:64:20:39:22:41|t",
}
local CLASS_TEX = "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES"

local DEFAULTS = {
  role = nil,            -- "TANK"/"HEALER"/"DAMAGER" or nil = any
  fitLevel = true,       -- hide dungeons outside my level
  classes = {},          -- class -> false hides listings containing none of the shown classes
  alert = true,
  msg = "Hi! %role% lvl %level% %class% here, can I join for %dungeon%?",
  pos = nil,
}

local results = {}       -- built list for display
local seen = {}          -- resultID -> true, so alerts fire once per listing
local whispered = {}     -- lowercased leader name -> { time, replied }
local firstScan = true
local offset = 0
local NUM_ROWS = 10
local window

local function Print(msg) DEFAULT_CHAT_FRAME:AddMessage("|cffff9933Rally Point|r: " .. msg) end

local function ClassColor(class)
  local c = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class or ""]
  return c and c.colorStr or "ffffffff"
end

local function ClassIcon(class, size)
  local t = CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[class or ""]
  if not t then return "" end
  return ("|T%s:%d:%d:0:0:256:256:%d:%d:%d:%d|t"):format(CLASS_TEX, size, size,
    t[1] * 256, t[2] * 256, t[3] * 256, t[4] * 256)
end

------------------------------------------------------------------------
-- Optional tie-ins. Each one is checked at use time and silently skipped
-- if the other addon isn't loaded or doesn't offer the function.
------------------------------------------------------------------------
local function FamiliarInfo(name)
  local ff = _G.FamiliarFacesDB
  if not (ff and ff.players and name) then return nil end
  local key = name:find("-") and name or (name .. "-" .. GetRealmName())
  local p = ff.players[key]
  if not p then return nil end
  local n = p.sessions and #p.sessions or 0
  local rate = p.rating == 1 and "|TInterface\\RaidFrame\\ReadyCheck-Ready:0|t"
    or p.rating == -1 and "|TInterface\\RaidFrame\\ReadyCheck-NotReady:0|t" or ""
  return n, rate
end

local function TrekText(dungeonName)
  local fn = _G.TrekTime_DistanceText
  if type(fn) ~= "function" or not dungeonName then return nil end
  local ok, txt = pcall(fn, dungeonName)
  return ok and type(txt) == "string" and txt or nil
end

local function Translate(text)
  local fn = _G.Lingua_Translate
  if type(fn) ~= "function" or not text or text == "" then return nil end
  local ok, out = pcall(fn, text)
  if ok and type(out) == "string" and out ~= "" and out ~= text then return out end
end

------------------------------------------------------------------------
-- Dungeon quests
------------------------------------------------------------------------
local function Norm(n)
  n = (n or ""):lower():gsub("^the ", ""):gsub("[^%w ]", ""):gsub("%s+", " ")
  return n
end

local questCache -- normalized quest log header -> { "[lvl] title", ... }
local function ScanQuestLog()
  questCache = {}
  if not GetNumQuestLogEntries then return end
  local header
  for i = 1, GetNumQuestLogEntries() do
    local title, level, _, isHeader, _, isComplete = GetQuestLogTitle(i)
    if isHeader then
      header = Norm(title)
    elseif title and header then
      local done = (isComplete == 1 or isComplete == true) and " |cff00ff00(done)|r" or ""
      questCache[header] = questCache[header] or {}
      table.insert(questCache[header], ("[%d] %s%s"):format(level or 0, title, done))
    end
  end
end

local function NameMatches(a, b)
  if a == "" or b == "" then return false end
  return a == b or a:find(b, 1, true) or b:find(a, 1, true)
end

-- Quests in my log whose quest-log zone header is this dungeon
local function QuestsInLog(dungeonNames)
  if not questCache then ScanQuestLog() end
  local out, used = {}, {}
  for _, dn in ipairs(dungeonNames) do
    local n = Norm(dn)
    for header, list in pairs(questCache) do
      if not used[header] and NameMatches(n, header) then
        used[header] = true
        for _, q in ipairs(list) do out[#out + 1] = q end
      end
    end
  end
  return out
end

-- Quests I could still pick up: provided by Dungeon Dossier if it offers it
local function QuestsAvailable(dungeonNames)
  local fn = _G.DungeonDossier_AvailableQuests
  if type(fn) ~= "function" then return nil end
  local out, used = {}, {}
  for _, dn in ipairs(dungeonNames) do
    local ok, list = pcall(fn, dn)
    if ok and type(list) == "table" then
      for _, q in ipairs(list) do
        q = tostring(q)
        if not used[q] then used[q] = true; out[#out + 1] = q end
      end
    end
  end
  return out
end

------------------------------------------------------------------------
-- Reading Blizzard's LFG results (defensive: field names vary by client)
------------------------------------------------------------------------
local function ActivityInfo(info)
  local ids = info.activityIDs or (info.activityID and { info.activityID }) or {}
  local names, full, minL, maxL = {}, {}, nil, nil
  for _, id in ipairs(ids) do
    local a = C_LFGList.GetActivityInfoTable and C_LFGList.GetActivityInfoTable(id)
    if a then
      names[#names + 1] = (a.shortName and a.shortName ~= "") and a.shortName or a.fullName
      full[#full + 1] = a.fullName or names[#names]
      if a.minLevel and a.minLevel > 0 then minL = math.min(minL or 999, a.minLevel) end
      local top = a.maxLevelSuggestion or a.maxLevel
      if top and top > 0 then maxL = math.max(maxL or 0, top) end
    end
  end
  return names, minL, maxL, full
end

local function Members(id, num)
  local list = {}
  for i = 1, num or 0 do
    local m
    if C_LFGList.GetSearchResultPlayerInfo then
      local ok, p = pcall(C_LFGList.GetSearchResultPlayerInfo, id, i)
      if ok and type(p) == "table" then
        m = { name = p.name, class = p.classFilename, level = p.level,
              role = p.assignedRole, leader = p.isLeader }
      end
    end
    if not m and C_LFGList.GetSearchResultMemberInfo then
      local ok, role, class = pcall(C_LFGList.GetSearchResultMemberInfo, id, i)
      if ok then m = { role = role, class = class } end
    end
    if m then list[#list + 1] = m end
  end
  return list
end

local function RoleCounts(id, members)
  local c = { TANK = 0, HEALER = 0, DAMAGER = 0 }
  local ok, t = pcall(C_LFGList.GetSearchResultMemberCounts, id)
  if ok and type(t) == "table" and t.TANK then
    c.TANK, c.HEALER, c.DAMAGER = t.TANK or 0, t.HEALER or 0, t.DAMAGER or 0
  else
    for _, m in ipairs(members) do if c[m.role] then c[m.role] = c[m.role] + 1 end end
  end
  return c
end

local function Passes(e)
  local myLevel = UnitLevel("player")
  if DB.fitLevel and e.minL and myLevel < e.minL then return false end
  if DB.fitLevel and e.maxL and myLevel > e.maxL + 2 then return false end
  if DB.role and e.numMembers > 1 then
    -- a group: only show it if my role isn't filled yet
    if (e.counts[DB.role] or 0) >= QUOTA[DB.role] then return false end
  end
  local anyHidden = false
  for _, cl in ipairs(CLASSES) do if DB.classes[cl] == false then anyHidden = true end end
  if anyHidden then
    local hit = false
    for _, m in ipairs(e.members) do if m.class and DB.classes[m.class] ~= false then hit = true end end
    if not hit then return false end
  end
  return true
end

local Refresh -- forward

-- Quest lookups are only done for listings you can see, and only once per dungeon per rebuild.
local questsFor = {}
local function LoadQuests(e)
  if e.myQuests then return end
  local key = table.concat(e.qn, "|")
  local c = questsFor[key]
  if not c then
    c = { mine = QuestsInLog(e.qn), avail = QuestsAvailable(e.qn) }
    questsFor[key] = c
  end
  e.myQuests, e.availQuests = c.mine, c.avail
end

local function Rebuild()
  wipe(results)
  wipe(questsFor)
  if not (C_LFGList and C_LFGList.GetSearchResults) then return end
  local _, ids = C_LFGList.GetSearchResults()
  local newMatch
  for _, id in ipairs(ids or {}) do
    local info = C_LFGList.GetSearchResultInfo(id)
    if info and not info.isDelisted and not info.hasSelf then
      local num = info.numMembers or 1
      local members = Members(id, num)
      local names, minL, maxL, full = ActivityInfo(info)
      local leader = info.leaderName
      if not leader then for _, m in ipairs(members) do if m.leader then leader = m.name end end end
      local qn = {}
      for _, n in ipairs(full) do qn[#qn + 1] = n end
      for _, n in ipairs(names) do qn[#qn + 1] = n end
      local e = {
        id = id, leader = leader, numMembers = num, members = members,
        counts = RoleCounts(id, members), dungeons = names, fullNames = full, minL = minL, maxL = maxL,
        comment = info.comment or "", age = info.age,
      }
      e.qn = qn
      if Passes(e) then
        results[#results + 1] = e
        if not seen[id] then
          seen[id] = true
          if not firstScan then newMatch = e end
        end
      end
    end
  end
  firstScan = false
  -- forget listings that are gone, so this list doesn't grow all session
  local live = {}
  for _, id in ipairs(ids or {}) do live[id] = true end
  for id in pairs(seen) do if not live[id] then seen[id] = nil end end
  table.sort(results, function(a, b) return (a.age or 0) < (b.age or 0) end)
  if newMatch and DB.alert then
    PlaySound(SOUNDKIT and SOUNDKIT.READY_CHECK or 8960, "Master")
    if FlashClientIcon then FlashClientIcon() end
    Print(("New match: |cffffff00%s|r - %s"):format(newMatch.leader or "?",
      table.concat(newMatch.dungeons, ", ")))
  end
  if window and window:IsShown() then Refresh() end
end

------------------------------------------------------------------------
-- Whisper helper
------------------------------------------------------------------------
local function Whisper(e)
  if not e.leader then Print("No leader name for that listing yet. Try again in a second."); return end
  local _, class = UnitClass("player")
  local msg = DB.msg
    :gsub("%%role%%", DB.role and ROLE_NAME[DB.role] or "")
    :gsub("%%level%%", tostring(UnitLevel("player")))
    :gsub("%%class%%", (UnitClass("player")))
    :gsub("%%dungeon%%", e.dungeons[1] or "your group")
    :gsub("  +", " ")
  SendChatMessage(msg, "WHISPER", nil, e.leader)
  whispered[e.leader:lower()] = { time = time(), replied = false }
  if window and window:IsShown() then Refresh() end
end

local function OnWhisper(sender)
  if not sender or Secret(sender) then return end
  local short = Ambiguate and Ambiguate(sender, "none") or sender
  for _, n in ipairs({ sender:lower(), short:lower() }) do
    local w = whispered[n]
    if w and not w.replied then
      w.replied = true
      Print(("|cffffff00%s|r replied to your whisper."):format(short))
      PlaySound(SOUNDKIT and SOUNDKIT.TELL_MESSAGE or 3081, "Master")
      if window and window:IsShown() then Refresh() end
      return
    end
  end
end

------------------------------------------------------------------------
-- Window
------------------------------------------------------------------------
local function Tooltip(row)
  local e = row.entry
  if not e then return end
  LoadQuests(e)
  GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
  GameTooltip:AddLine(table.concat(e.dungeons, ", "), 1, 0.82, 0)
  if e.minL then GameTooltip:AddLine(("Level %d-%d"):format(e.minL, e.maxL or e.minL), 0.7, 0.7, 0.7) end
  local trek = TrekText(e.dungeons[1]); if trek then GameTooltip:AddLine(trek, 0.5, 0.8, 1) end
  if e.comment ~= "" then
    GameTooltip:AddLine(e.comment, 1, 1, 1, true)
    local tr = Translate(e.comment); if tr then GameTooltip:AddLine("-> " .. tr, 0.6, 1, 0.6, true) end
  end
  if #e.myQuests > 0 or (e.availQuests and #e.availQuests > 0) then
    GameTooltip:AddLine(" ")
    if #e.myQuests > 0 then
      GameTooltip:AddLine("Your quests here:", 1, 0.82, 0)
      for _, q in ipairs(e.myQuests) do GameTooltip:AddLine("  " .. q, 1, 1, 1) end
    end
    if e.availQuests and #e.availQuests > 0 then
      GameTooltip:AddLine("You can still pick up:", 0.4, 0.8, 1)
      for _, q in ipairs(e.availQuests) do GameTooltip:AddLine("  " .. q, 0.8, 0.8, 0.8) end
    end
  end
  GameTooltip:AddLine(" ")
  for _, m in ipairs(e.members) do
    local left = ("%s%s |c%s%s|r"):format(ROLE_ICON[m.role] or "", ClassIcon(m.class, 14),
      ClassColor(m.class), m.name or "?")
    local right = m.level and ("lvl " .. m.level) or ""
    local n, rate = FamiliarInfo(m.name)
    if n then left = left .. (" |cff66ccff(played with %dx)|r%s"):format(n, rate) end
    GameTooltip:AddDoubleLine(left, right, 1, 1, 1, 0.8, 0.8, 0.8)
  end
  GameTooltip:AddLine(" ")
  GameTooltip:AddLine("Click: whisper the leader", 0.5, 0.5, 0.5)
  GameTooltip:Show()
end

function Refresh()
  local maxOff = math.max(0, #results - NUM_ROWS)
  for i = 1, NUM_ROWS do local e = results[i + offset]; if e then LoadQuests(e) end end
  if offset > maxOff then offset = maxOff end
  for i, row in ipairs(window.rows) do
    local e = results[i + offset]
    row.entry = e
    if e then
      local icons = {}
      for _, m in ipairs(e.members) do
        icons[#icons + 1] = (ROLE_ICON[m.role] or "") .. ClassIcon(m.class, 16)
          .. (m.level and ("|cffaaaaaa" .. m.level .. "|r") or "")
      end
      local need = {}
      if e.numMembers > 1 then
        for _, r in ipairs(ROLES) do
          local left = QUOTA[r] - (e.counts[r] or 0)
          if left > 0 then need[#need + 1] = ROLE_ICON[r] .. (left > 1 and left or "") end
        end
      end
      local name = e.leader or "?"
      local famN = FamiliarInfo(name)
      local w = whispered[name:lower()]
      local status = w and (w.replied and " |cff00ff00replied|r" or " |cffaaaaaawhispered|r") or ""
      local q = ""
      if #e.myQuests > 0 then q = q .. (" |cffffd100[%d quest%s]|r"):format(#e.myQuests, #e.myQuests == 1 and "" or "s") end
      if e.availQuests and #e.availQuests > 0 then q = q .. (" |cff66ccff[+%d to get]|r"):format(#e.availQuests) end
      row.title:SetText(("|cffffd100%s|r%s  %s%s%s"):format(table.concat(e.dungeons, ", "), q,
        name, famN and " |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:0|t" or "", status))
      row.members:SetText(table.concat(icons, "  ")
        .. (#need > 0 and ("   |cff888888needs|r " .. table.concat(need, " ")) or ""))
      local c = e.comment
      local tr = Translate(c)
      row.comment:SetText(tr and ("|cff99ff99" .. tr .. "|r") or c)
      row:Show()
    else
      row:Hide()
    end
  end
  window.count:SetText(("%d shown"):format(#results))
  for _, b in ipairs(window.roleBtns) do
    b:SetAlpha(DB.role == b.role and 1 or 0.35)
  end
  for _, b in ipairs(window.classBtns) do
    b:SetAlpha(DB.classes[b.class] == false and 0.25 or 1)
  end
  window.fit:SetChecked(DB.fitLevel)
  window.alert:SetChecked(DB.alert)
end

local function Check(parent, label, x, y, get, set)
  local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
  cb:SetSize(22, 22)
  cb:SetPoint("TOPLEFT", x, y)
  local t = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  t:SetPoint("LEFT", cb, "RIGHT", 2, 0)
  t:SetText(label)
  cb:SetScript("OnClick", function(self) set(self:GetChecked() and true or false); Rebuild() end)
  return cb
end

local function BuildWindow()
  window = CreateFrame("Frame", "RallyPointFrame", UIParent, "BackdropTemplate")
  window:SetSize(560, 470)
  if DB.pos then
    window:SetPoint(DB.pos[1], UIParent, DB.pos[1], DB.pos[2], DB.pos[3])
  else
    window:SetPoint("CENTER")
  end
  window:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 14,
    insets = { left = 3, right = 3, top = 3, bottom = 3 } })
  window:SetBackdropColor(0.05, 0.05, 0.08, 0.95)
  window:SetMovable(true); window:EnableMouse(true); window:RegisterForDrag("LeftButton")
  window:SetClampedToScreen(true)
  window:SetScript("OnDragStart", window.StartMoving)
  window:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local p, _, _, x, y = self:GetPoint()
    DB.pos = { p, x, y }
  end)
  window:SetFrameStrata("HIGH")
  tinsert(UISpecialFrames, "RallyPointFrame")

  local title = window:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", 12, -10)
  title:SetText("Rally Point")
  local close = CreateFrame("Button", nil, window, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", 0, 0)

  window.count = window:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  window.count:SetPoint("LEFT", title, "RIGHT", 10, 0)

  -- My role
  local rl = window:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  rl:SetPoint("TOPLEFT", 12, -38); rl:SetText("I am:")
  window.roleBtns = {}
  for i, r in ipairs(ROLES) do
    local b = CreateFrame("Button", nil, window)
    b:SetSize(24, 24); b:SetPoint("TOPLEFT", 46 + (i - 1) * 28, -32)
    local fs = b:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    fs:SetPoint("CENTER"); fs:SetText((ROLE_ICON[r]:gsub(":14:14:", ":22:22:")))
    b.role = r
    b:SetScript("OnClick", function() DB.role = (DB.role ~= r) and r or nil; Rebuild(); Refresh() end)
    b:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_TOP")
      GameTooltip:SetText(ROLE_NAME[r] .. ": only show groups that still need one")
      GameTooltip:Show()
    end)
    b:SetScript("OnLeave", GameTooltip_Hide)
    window.roleBtns[i] = b
  end

  -- Classes
  local cl = window:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  cl:SetPoint("TOPLEFT", 150, -38); cl:SetText("Classes:")
  window.classBtns = {}
  for i, c in ipairs(CLASSES) do
    local b = CreateFrame("Button", nil, window)
    b:SetSize(22, 22); b:SetPoint("TOPLEFT", 200 + (i - 1) * 25, -33)
    local tx = b:CreateTexture(nil, "ARTWORK"); tx:SetAllPoints()
    tx:SetTexture(CLASS_TEX)
    local t = CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[c]
    if t then tx:SetTexCoord(t[1], t[2], t[3], t[4]) end
    b.class = c
    b:SetScript("OnClick", function()
      DB.classes[c] = (DB.classes[c] == false) and nil or false
      Rebuild(); Refresh()
    end)
    b:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_TOP")
      local name = (LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[c]) or c
      GameTooltip:SetText(name .. (DB.classes[c] == false and " (hidden)" or " (shown)"))
      GameTooltip:AddLine("Shows listings that include at least one shown class.", 0.8, 0.8, 0.8, true)
      GameTooltip:Show()
    end)
    b:SetScript("OnLeave", GameTooltip_Hide)
    window.classBtns[i] = b
  end

  window.fit = Check(window, "Fits my level", 10, -60, nil, function(v) DB.fitLevel = v end)
  window.alert = Check(window, "Alert on new match", 130, -60, nil, function(v) DB.alert = v end)

  local refresh = CreateFrame("Button", nil, window, "UIPanelButtonTemplate")
  refresh:SetSize(110, 22); refresh:SetPoint("TOPRIGHT", -12, -60)
  refresh:SetText("Search again")
  refresh:SetScript("OnClick", function()
    local b = _G.LFGBrowseFrameRefreshButton
    if b and b:IsVisible() then b:Click() else
      Print("Open Blizzard's Looking For Group window (Group Browser tab) and search there; Rally Point reads those results.")
    end
  end)

  -- Rows
  window.rows = {}
  for i = 1, NUM_ROWS do
    local row = CreateFrame("Button", nil, window)
    row:SetSize(536, 36)
    row:SetPoint("TOPLEFT", 12, -88 - (i - 1) * 37)
    local hl = row:CreateTexture(nil, "HIGHLIGHT"); hl:SetAllPoints()
    hl:SetColorTexture(1, 1, 1, 0.08)
    local bg = row:CreateTexture(nil, "BACKGROUND"); bg:SetAllPoints()
    bg:SetColorTexture(1, 1, 1, i % 2 == 0 and 0.03 or 0)
    row.title = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.title:SetPoint("TOPLEFT", 4, -2); row.title:SetJustifyH("LEFT")
    row.members = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.members:SetPoint("TOPLEFT", 4, -19); row.members:SetJustifyH("LEFT")
    row.comment = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    row.comment:SetPoint("TOPRIGHT", -4, -4); row.comment:SetWidth(220)
    row.comment:SetJustifyH("RIGHT"); row.comment:SetWordWrap(false)
    row:SetScript("OnClick", function(self) if self.entry then Whisper(self.entry) end end)
    row:SetScript("OnEnter", Tooltip)
    row:SetScript("OnLeave", GameTooltip_Hide)
    window.rows[i] = row
  end
  window:EnableMouseWheel(true)
  window:SetScript("OnMouseWheel", function(_, d)
    offset = math.max(0, offset - d * 2); Refresh()
  end)

  local hint = window:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  hint:SetPoint("BOTTOMLEFT", 12, 8)
  hint:SetText("Click a listing to whisper the leader | /rally msg <text> to change the message")
end

local function Toggle()
  if not window then BuildWindow() end
  if window:IsShown() then window:Hide() else Rebuild(); window:Show(); Refresh() end
end

-- shared with Messenger.lua
ns.results, ns.whispered = results, whispered
ns.FamiliarInfo, ns.ClassIcon, ns.ClassColor = FamiliarInfo, ClassIcon, ClassColor
ns.ROLE_ICON, ns.ROLE_NAME, ns.Print, ns.Translate = ROLE_ICON, ROLE_NAME, Print, Translate

------------------------------------------------------------------------
-- Events & slash
------------------------------------------------------------------------
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(_, event, a1, a2, a3, a4, a5)
  if event == "ADDON_LOADED" and a1 == ADDON then
    RallyPointDB = RallyPointDB or {}
    DB = RallyPointDB
    for k, v in pairs(DEFAULTS) do if DB[k] == nil then DB[k] = type(v) == "table" and {} or v end end
    f:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED")
    f:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED")
    f:RegisterEvent("CHAT_MSG_WHISPER")
    f:RegisterEvent("PLAYER_LEVEL_UP")
    f:RegisterEvent("QUEST_LOG_UPDATE")
  elseif event == "LFG_LIST_SEARCH_RESULTS_RECEIVED" or event == "LFG_LIST_SEARCH_RESULT_UPDATED"
      or event == "PLAYER_LEVEL_UP" then
    -- many updates can arrive at once: rebuild at most once a second
    if not rebuildPending then
      rebuildPending = true
      C_Timer.After(1, function() rebuildPending = false; Rebuild() end)
    end
  elseif event == "QUEST_LOG_UPDATE" then
    questCache = nil
  elseif event == "CHAT_MSG_WHISPER" then
    OnWhisper(a2)
  end
end)

SLASH_RALLYPOINT1 = "/rally"
SlashCmdList.RALLYPOINT = function(input)
  input = input or ""
  local cmd, rest = input:match("^(%S*)%s*(.-)$")
  cmd = (cmd or ""):lower()
  if cmd == "msg" then
    if rest ~= "" then DB.msg = rest; Print("Whisper message set to: " .. rest)
    else Print("Message: " .. DB.msg .. "  (placeholders: %role% %level% %class% %dungeon%)") end
  elseif cmd == "mem" then
    UpdateAddOnMemoryUsage()
    Print(("Memory: %.1f MB"):format(GetAddOnMemoryUsage(ADDON) / 1024))
  elseif cmd == "clear" then
    if ns.ClearWaypoint then ns.ClearWaypoint() end
  elseif cmd == "im" or cmd == "whispers" then
    if ns.ToggleMessenger then ns.ToggleMessenger() end
  elseif cmd == "reset" then
    wipe(DB); for k, v in pairs(DEFAULTS) do DB[k] = type(v) == "table" and {} or v end
    Print("Settings reset."); if window then Refresh() end
  elseif cmd == "help" then
    Print("/rally - open the window | /rally msg <text> - whisper message | /rally im - LFG whisper window | /rally demo - test it | /rally clear - remove the map waypoint | /rally reset | /dq - dungeon quests")
  else
    Toggle()
  end
end
