local function Secret(v) -- chat hidden by the game (or faked by /cc secret)
  if CopyCatFakeSecret and CopyCatFakeSecret > GetTime() then return true end
  return issecretvalue ~= nil and issecretvalue(v) == true
end
-- Rally Point: LFG whisper window.
-- While you're listed in LFG, have applied to a group, or whispered a leader from Rally Point
-- (last 30 min), incoming whispers open a small window showing who is talking:
-- class, level, role, Familiar Faces history, with Invite / Decline buttons.
local ADDON, ns = ...

local CLASS_TEX = "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES"
local DECLINE_MSG = "Sorry, we're full for now. Good luck!"
local MAX_CONTACTS = 8
local MAX_LINES = 100

local contacts = {}   -- ordered list of contact tables
local byName = {}     -- short lowercased name -> contact
local current         -- selected contact
local win

local function Short(name) return (Ambiguate and Ambiguate(name, "none") or name):match("^[^-]+") or name end
local function Key(name) return Short(name):lower() end

------------------------------------------------------------------------
-- Am I "queued"?
------------------------------------------------------------------------
local function IsQueued()
  if C_LFGList then
    if C_LFGList.HasActiveEntryInfo and C_LFGList.HasActiveEntryInfo() then return true end
    if C_LFGList.GetApplications and C_LFGList.GetApplicationInfo then
      for _, id in ipairs(C_LFGList.GetApplications() or {}) do
        local r = { pcall(C_LFGList.GetApplicationInfo, id) }
        for i = 2, #r do
          if r[i] == "applied" or r[i] == "invited" then return true end
        end
      end
    end
  end
  for _, w in pairs(ns.whispered or {}) do
    if time() - (w.time or 0) < 1800 then return true end
  end
  return false
end

------------------------------------------------------------------------
-- Finding class / level / role for a name
------------------------------------------------------------------------
local ROLE_WORDS = {
  { "tank", "TANK" }, { "prot", "TANK" },
  { "heal", "HEALER" }, { "resto", "HEALER" }, { "holy", "HEALER" },
  { "dps", "DAMAGER" }, { "dd", "DAMAGER" },
}

local function Fill(c, class, level, role)
  if class and class ~= "" then c.class = class end
  if level and level > 0 then c.level = level end
  if role and ns.ROLE_ICON[role] then c.role = role end
end

local function LookupFromLFG(c)
  local k = c.key
  -- people in listings I can see (Rally Point's filtered results)
  for _, e in ipairs(ns.results or {}) do
    for _, m in ipairs(e.members) do
      if m.name and Key(m.name) == k then Fill(c, m.class, m.level, m.role); return end
    end
  end
  -- people applying to my own listing
  if C_LFGList and C_LFGList.GetApplicants and C_LFGList.GetApplicantMemberInfo then
    for _, aid in ipairs(C_LFGList.GetApplicants() or {}) do
      local info = C_LFGList.GetApplicantInfo and C_LFGList.GetApplicantInfo(aid)
      for i = 1, (info and info.numMembers) or 1 do
        local ok, name, class, _, level, _, _, tank, healer, damage, assigned =
          pcall(C_LFGList.GetApplicantMemberInfo, aid, i)
        if ok and name and Key(name) == k then
          local role = assigned
          if not ns.ROLE_ICON[role or ""] then
            role = tank and "TANK" or healer and "HEALER" or damage and "DAMAGER" or nil
          end
          Fill(c, class, level, role)
          c.applicantID = aid
          return
        end
      end
    end
  end
end

local function LookupFromUnits(c)
  for _, u in ipairs({ "target", "mouseover", "focus", "party1", "party2", "party3", "party4" }) do
    if UnitExists(u) and UnitIsPlayer(u) then
      local n = UnitName(u)
      if n and n:lower() == c.key then
        local _, class = UnitClass(u)
        Fill(c, class, UnitLevel(u))
        return
      end
    end
  end
end

local function GuessRole(c, text)
  if c.role or not text then return end
  local t = " " .. text:lower():gsub("[^%a]", " ") .. " "
  for _, w in ipairs(ROLE_WORDS) do
    if t:find("%f[%a]" .. w[1]) then c.role = w[2]; return end
  end
end

local function Refresh(c)
  LookupFromLFG(c)
  if not c.level then LookupFromUnits(c) end
end

------------------------------------------------------------------------
-- Window
------------------------------------------------------------------------
local UpdateWindow, AddLine, Show, ZoneLine

local function ClassName(class)
  return (LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[class or ""]) or ""
end

local function FamiliarLine(c)
  if c.demo then return c.demoFF or "|cff888888Haven't played with them before|r" end
  local n, rate = ns.FamiliarInfo(c.name)
  if not n then return "|cff888888Haven't played with them before|r" end
  local line = ("|cff66ccffPlayed with them %d time%s|r %s"):format(n, n == 1 and "" or "s", rate or "")
  -- last session details, if Familiar Faces stored them
  local ff = _G.FamiliarFacesDB
  local key = c.name:find("-") and c.name or (c.name .. "-" .. GetRealmName())
  local p = ff and ff.players and ff.players[key]
  local last = p and p.sessions and p.sessions[#p.sessions]
  if type(last) == "table" then
    local where = last.zone or last.instance
    local when = type(last.time) == "number" and date("%d %b", last.time) or last.date
    if where or when then
      line = line .. "|cff888888 - last: " .. table.concat({ when, where }, ", ") .. "|r"
    end
  end
  return line
end

------------------------------------------------------------------------
-- Zone and rough distance. Exact yards to a player outside your group can't be read
-- by addons, so this measures from you to the middle of their zone.
------------------------------------------------------------------------
local zoneMaps -- zone name -> uiMapID
local function ZoneMapID(name)
  if not (C_Map and C_Map.GetMapInfo) or not name then return nil end
  if not zoneMaps then
    zoneMaps = {}
    for id = 1, 2000 do
      local m = C_Map.GetMapInfo(id)
      if m and m.name and (m.mapType == 3 or m.mapType == 4) and not zoneMaps[m.name] then
        zoneMaps[m.name] = id
      end
    end
  end
  return zoneMaps[name]
end

local function WorldPos(mapID, x, y)
  if not (C_Map.GetWorldPosFromMapPos and CreateVector2D) then return nil end
  local inst, v = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(x, y))
  if not v then return nil end
  local a, b = v:GetXY()
  return inst, a, b
end

local function YardsToZone(zone)
  local theirMap = ZoneMapID(zone)
  local myMap = C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
  if not (theirMap and myMap) then return nil end
  if theirMap == myMap then return 0 end
  local p = C_Map.GetPlayerMapPosition and C_Map.GetPlayerMapPosition(myMap, "player")
  if not p then return nil end
  local i1, x1, y1 = WorldPos(myMap, p:GetXY())
  local i2, x2, y2 = WorldPos(theirMap, 0.5, 0.5)
  if not (i1 and i2) or i1 ~= i2 then return nil, true end -- other continent
  return math.floor(math.sqrt((x1 - x2) ^ 2 + (y1 - y2) ^ 2) / 10 + 0.5) * 10
end

function ZoneLine(c)
  if not c.zone then return "|cff888888Zone ?  (press Look up)|r" end
  local yards, otherCont
  if c.demo then yards = c.demoYards else yards, otherCont = YardsToZone(c.zone) end
  local dist
  if yards == 0 then dist = "|cff00ff00in your zone|r"
  elseif yards then
    local col = yards < 1000 and "|cff00ff00" or yards < 3000 and "|cffffd100" or "|cffff6060"
    dist = ("%s~%d yd away|r"):format(col, yards)
  elseif otherCont then dist = "|cffff6060other continent|r"
  else dist = "" end
  return ("|cffffd100Zone:|r %s   %s"):format(c.zone, dist)
end

local function Select(c)
  current = c
  if c then c.unread = false end
  UpdateWindow()
end

local function Remove(c)
  for i, x in ipairs(contacts) do if x == c then table.remove(contacts, i) break end end
  byName[c.key] = nil
  if current == c then current = contacts[1] end
  if #contacts == 0 then win:Hide() else UpdateWindow() end
end

local function Button(parent, text, w)
  local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
  b:SetSize(w, 22); b:SetText(text)
  return b
end

local function BuildWindow()
  win = CreateFrame("Frame", "RallyPointWhisperFrame", UIParent, "BackdropTemplate")
  win:SetSize(500, 300)
  local DB = RallyPointDB or {}
  if DB.imPos then
    win:SetPoint(DB.imPos[1], UIParent, DB.imPos[1], DB.imPos[2], DB.imPos[3])
  else
    win:SetPoint("CENTER", 0, -150)
  end
  win:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 14,
    insets = { left = 3, right = 3, top = 3, bottom = 3 } })
  win:SetBackdropColor(0.05, 0.05, 0.08, 0.95)
  win:SetMovable(true); win:EnableMouse(true); win:RegisterForDrag("LeftButton")
  win:SetClampedToScreen(true); win:SetFrameStrata("HIGH")
  win:SetScript("OnDragStart", win.StartMoving)
  win:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local p, _, _, x, y = self:GetPoint()
    if RallyPointDB then RallyPointDB.imPos = { p, x, y } end
  end)

  local title = win:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  title:SetPoint("TOPLEFT", 10, -9); title:SetText("Rally Point - Whispers")
  local close = CreateFrame("Button", nil, win, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", 0, 0)

  -- contact list (left)
  win.list = {}
  for i = 1, MAX_CONTACTS do
    local b = CreateFrame("Button", nil, win)
    b:SetSize(120, 26); b:SetPoint("TOPLEFT", 8, -28 - (i - 1) * 28)
    local bg = b:CreateTexture(nil, "BACKGROUND"); bg:SetAllPoints(); b.bg = bg
    local hl = b:CreateTexture(nil, "HIGHLIGHT"); hl:SetAllPoints(); hl:SetColorTexture(1, 1, 1, 0.08)
    b.text = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    b.text:SetPoint("LEFT", 4, 0); b.text:SetWidth(112); b.text:SetJustifyH("LEFT"); b.text:SetWordWrap(false)
    b:SetScript("OnClick", function(self) Select(self.contact) end)
    win.list[i] = b
  end

  -- header (right)
  local x = 136
  win.icon = win:CreateTexture(nil, "ARTWORK")
  win.icon:SetSize(36, 36); win.icon:SetPoint("TOPLEFT", x, -28); win.icon:SetTexture(CLASS_TEX)
  win.name = win:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  win.name:SetPoint("TOPLEFT", x + 42, -28)
  win.info = win:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  win.info:SetPoint("TOPLEFT", x + 42, -48)
  win.ff = win:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  win.zone = win:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  win.zone:SetPoint("TOPLEFT", x, -70); win.zone:SetWidth(280); win.zone:SetJustifyH("LEFT")
  win.ff:SetPoint("TOPLEFT", x, -84); win.ff:SetWidth(350); win.ff:SetJustifyH("LEFT")

  win.invite = Button(win, "Invite", 70)
  win.invite:SetPoint("TOPRIGHT", -12, -28)
  win.invite:SetScript("OnClick", function()
    if not current then return end
    if current.demo then ns.Print("Demo: would invite " .. current.name); return end
    local fn =(C_PartyInfo and C_PartyInfo.InviteUnit) or InviteUnit
    fn(current.name)
  end)
  win.decline = Button(win, "Decline", 70)
  win.decline:SetPoint("TOPRIGHT", -12, -50)
  win.decline:SetScript("OnClick", function()
    local c = current
    if not c then return end
    if c.demo then ns.Print("Demo: would decline " .. c.name); Remove(c); return end
    if c.applicantID and C_LFGList.DeclineApplicant then pcall(C_LFGList.DeclineApplicant, c.applicantID) end
    SendChatMessage((RallyPointDB and RallyPointDB.declineMsg) or DECLINE_MSG, "WHISPER", nil, c.name)
    Remove(c)
  end)
  win.decline:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Decline")
    GameTooltip:AddLine("Whispers: " .. ((RallyPointDB and RallyPointDB.declineMsg) or DECLINE_MSG), 1, 1, 1, true)
    GameTooltip:AddLine("Also declines their application to your listing, if they applied.", 0.8, 0.8, 0.8, true)
    GameTooltip:AddLine("Change it: /rally decline <text>", 0.5, 0.5, 0.5)
    GameTooltip:Show()
  end)
  win.decline:SetScript("OnLeave", GameTooltip_Hide)
  win.who = Button(win, "Look up", 70)
  win.who:SetPoint("RIGHT", win.invite, "LEFT", -4, 0)
  win.who:SetScript("OnClick", function()
    if not current or not C_FriendList then return end
    if current.demo then
      current.level = 40; current.zone = "Stranglethorn Vale"
      ns.Print("Demo: /who found " .. current.name .. " (level 40, Stranglethorn Vale)")
      UpdateWindow(); return
    end
    current.whoPending = true
    C_FriendList.SendWho('n-"' .. current.name .. '"')
  end)
  win.who:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Look up level and zone with /who")
    GameTooltip:Show()
  end)
  win.who:SetScript("OnLeave", GameTooltip_Hide)

  -- messages
  local log = CreateFrame("ScrollingMessageFrame", nil, win)
  log:SetPoint("TOPLEFT", x, -100); log:SetPoint("BOTTOMRIGHT", -12, 36)
  log:SetFontObject(ChatFontNormal); log:SetJustifyH("LEFT")
  log:SetFading(false); log:SetMaxLines(MAX_LINES); log:SetHyperlinksEnabled(true)
  log:EnableMouseWheel(true)
  log:SetScript("OnMouseWheel", function(self, d) if d > 0 then self:ScrollUp() else self:ScrollDown() end end)
  log:SetScript("OnHyperlinkClick", function(_, link, text, button) SetItemRef(link, text, button) end)
  win.log = log

  local eb = CreateFrame("EditBox", nil, win, "InputBoxTemplate")
  eb:SetPoint("BOTTOMLEFT", x + 6, 10); eb:SetPoint("BOTTOMRIGHT", -14, 10); eb:SetHeight(20)
  eb:SetAutoFocus(false)
  eb:SetScript("OnEnterPressed", function(self)
    local t = self:GetText()
    if current and t ~= "" then
      if current.demo then AddLine(current, "You", t, true); UpdateWindow()
      else SendChatMessage(t, "WHISPER", nil, current.name) end
    end
    self:SetText(""); self:ClearFocus()
  end)
  eb:SetScript("OnEscapePressed", eb.ClearFocus)
  win.edit = eb

  tinsert(UISpecialFrames, "RallyPointWhisperFrame")
end

function UpdateWindow()
  if not win then return end
  for i, b in ipairs(win.list) do
    local c = contacts[i]
    b.contact = c
    if c then
      b.text:SetText(ns.ClassIcon(c.class, 14) .. " |c" .. ns.ClassColor(c.class) .. Short(c.name) .. "|r"
        .. (c.unread and " |cffffd100*|r" or ""))
      b.bg:SetColorTexture(1, 1, 1, c == current and 0.15 or 0.03)
      b:Show()
    else
      b:Hide()
    end
  end
  local c = current
  if not c then return end
  local t = CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[c.class or ""]
  if t then win.icon:SetTexCoord(t[1], t[2], t[3], t[4]); win.icon:Show() else win.icon:Hide() end
  win.name:SetText("|c" .. ns.ClassColor(c.class) .. Short(c.name) .. "|r")
  local lvl = c.level and ("Level " .. c.level) or "Level |cff888888?|r"
  local role = c.role and (ns.ROLE_ICON[c.role] .. " " .. ns.ROLE_NAME[c.role]) or "|cff888888role ?|r"
  win.info:SetText(("%s %s   %s"):format(lvl, ClassName(c.class), role))
  win.ff:SetText(FamiliarLine(c))
  win.zone:SetText(ZoneLine(c))
  win.who:SetShown(not c.demo or not c.zone)
  win.log:Clear()
  for _, line in ipairs(c.lines) do win.log:AddMessage(line) end
end

local function Open()
  if not win then BuildWindow() end
  if not win:IsShown() then win:Show() end
  UpdateWindow()
end

ns.ToggleMessenger = function()
  if win and win:IsShown() then win:Hide()
  elseif #contacts == 0 then ns.Print("No LFG whispers yet. The window opens by itself when someone whispers you while you're queued.")
  else Open() end
end

------------------------------------------------------------------------
-- Whispers in and out
------------------------------------------------------------------------
local function GetContact(name, guid, create)
  local k = Key(name)
  local c = byName[k]
  if not c and create then
    c = { name = name, key = k, lines = {} }
    if guid and GetPlayerInfoByGUID then
      local _, class = GetPlayerInfoByGUID(guid)
      c.class = class
    end
    byName[k] = c
    table.insert(contacts, 1, c)
    if #contacts > MAX_CONTACTS then
      local old = table.remove(contacts)
      byName[old.key] = nil
    end
  end
  return c
end

function AddLine(c, who, text, mine)
  local ts = date("%H:%M")
  local color = mine and "|cffaaaaaa" or ("|c" .. ns.ClassColor(c.class))
  table.insert(c.lines, ("|cff666666%s|r %s%s|r: |cffffc0ff%s|r"):format(ts, color, who, text))
  if not mine then
    local tr = ns.Translate and ns.Translate(text)
    if tr then table.insert(c.lines, "      |cff99ff99-> " .. tr .. "|r") end
  end
  while #c.lines > MAX_LINES do table.remove(c.lines, 1) end
end

function Show(c, sender, text)
  AddLine(c, Short(sender), text, false)
  if not current or not (win and win:IsShown()) then current = c end
  if c ~= current then c.unread = true end
  Open()
end

------------------------------------------------------------------------
-- Demo mode: /rally demo sends fake whispers so the window can be tested solo
------------------------------------------------------------------------
local DEMO = {
  { name = "Thrallbro", class = "WARRIOR", level = 34, role = "TANK", zone = "Tirisfal Glades", yards = 640,
    text = "Hey, tank here lvl 34, still need one for SM Armory?",
    ff = "|cff66ccffPlayed with them 3 times|r |TInterface\\RaidFrame\\ReadyCheck-Ready:0|t|cff888888 - last: 14 Nov, Razorfen Downs|r" },
  { name = "Leafwhisper", class = "DRUID", level = 33, role = "HEALER", zone = "The Barrens", yards = 4100,
    text = "resto druid, can heal if you want :)" },
  { name = "Pewpewmage", class = "MAGE", role = nil,
    text = "inv pls" },
}

local function RunDemo()
  ns.Print("Demo: 3 fake whispers coming. Nothing is really sent.")
  for i, d in ipairs(DEMO) do
    C_Timer.After((i - 1) * 3, function()
      local c = byName[d.name:lower()]
      if not c then
        c = { name = d.name, key = d.name:lower(), lines = {}, demo = true,
              class = d.class, level = d.level, role = d.role, demoFF = d.ff,
              zone = d.zone, demoYards = d.yards }
        byName[c.key] = c
        table.insert(contacts, 1, c)
      end
      PlaySound(SOUNDKIT and SOUNDKIT.TELL_MESSAGE or 3081, "Master")
      Show(c, d.name, d.text)
    end)
  end
end

local ev = CreateFrame("Frame")
ev:RegisterEvent("CHAT_MSG_WHISPER")
ev:RegisterEvent("CHAT_MSG_WHISPER_INFORM")
ev:RegisterEvent("WHO_LIST_UPDATE")
ev:RegisterEvent("LFG_LIST_APPLICANT_LIST_UPDATED")
ev:SetScript("OnEvent", function(_, event, text, sender, ...)
  if (event == "CHAT_MSG_WHISPER" or event == "CHAT_MSG_WHISPER_INFORM") and (Secret(text) or Secret(sender)) then return end
  if event == "CHAT_MSG_WHISPER" then
    local guid = select(10, ...)
    local c = GetContact(sender, guid, false)
    if not c then
      if not IsQueued() then return end
      c = GetContact(sender, guid, true)
    end
    Refresh(c)
    GuessRole(c, text)
    Show(c, sender, text)
  elseif event == "CHAT_MSG_WHISPER_INFORM" then
    local c = GetContact(sender, nil, false)
    if c then
      AddLine(c, "You", text, true)
      if win and win:IsShown() then UpdateWindow() end
    end
  elseif event == "WHO_LIST_UPDATE" then
    if not (C_FriendList and C_FriendList.GetNumWhoResults) then return end
    for i = 1, C_FriendList.GetNumWhoResults() do
      local w = C_FriendList.GetWhoInfo(i)
      local c = w and w.fullName and byName[Key(w.fullName)]
      if c and c.whoPending then
        c.whoPending = nil
        Fill(c, w.filename, w.level)
        c.zone = w.area
        if win and win:IsShown() then UpdateWindow() end
      end
    end
  elseif event == "LFG_LIST_APPLICANT_LIST_UPDATED" then
    for _, c in ipairs(contacts) do Refresh(c) end
    if win and win:IsShown() then UpdateWindow() end
  end
end)

-- /rally decline <text>
local orig = SlashCmdList.RALLYPOINT
SlashCmdList.RALLYPOINT = function(input)
  local cmd, rest = (input or ""):match("^(%S*)%s*(.-)$")
  if (cmd or ""):lower() == "demo" then RunDemo(); return end
  if (cmd or ""):lower() == "decline" then
    if rest ~= "" then RallyPointDB.declineMsg = rest; ns.Print("Decline message set to: " .. rest)
    else ns.Print("Decline message: " .. (RallyPointDB.declineMsg or DECLINE_MSG)) end
    return
  end
  orig(input)
end
