-- Rally Point waypoints: a pin on the world map, a line in chat, and a TomTom waypoint
-- if TomTom is installed. (The 3D arrow lives in Quest Ledger Forever.)
local _, ns = ...

local target          -- { uiMap, x, y (0-1), title }
local mapPin

local function Print(msg) DEFAULT_CHAT_FRAME:AddMessage("|cffff9933Rally Point|r: " .. msg) end

local function UpdateMapPin()
    if not (WorldMapFrame and WorldMapFrame.ScrollContainer and WorldMapFrame.ScrollContainer.Child) then return end
    local child = WorldMapFrame.ScrollContainer.Child
    if not mapPin then
        mapPin = CreateFrame("Button", nil, child)
        mapPin:SetSize(24, 24)
        mapPin.tex = mapPin:CreateTexture(nil, "OVERLAY")
        mapPin.tex:SetAllPoints()
        mapPin.tex:SetTexture("Interface\\GossipFrame\\AvailableQuestIcon")
        mapPin:RegisterForClicks("RightButtonUp")
        mapPin:SetScript("OnClick", function() ns.ClearWaypoint() end)
        mapPin:SetScript("OnEnter", function(self)
            if not target then return end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(target.title, 1, 0.82, 0)
            GameTooltip:AddLine("Rally Point waypoint - right-click to remove", 0.7, 0.7, 0.7)
            GameTooltip:Show()
        end)
        mapPin:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end
    local shownMap = WorldMapFrame.GetMapID and WorldMapFrame:GetMapID()
    if target and shownMap == target.uiMap then
        local w, h = child:GetWidth(), child:GetHeight()
        mapPin:SetFrameLevel(child:GetFrameLevel() + 50)
        mapPin:ClearAllPoints()
        mapPin:SetPoint("CENTER", child, "TOPLEFT", target.x * w, -target.y * h)
        mapPin:Show()
    else
        mapPin:Hide()
    end
end

function ns.ClearWaypoint(quiet)
    target = nil
    UpdateMapPin()
    if not quiet then Print("Waypoint cleared.") end
end

-- zone: area ID used by Dungeon Dossier, x/y: 0-100
function ns.SetWaypoint(zone, x, y, title)
    local uiMap = ns.AreaToUiMap and ns.AreaToUiMap[zone]
    if not uiMap or not x or not y then
        Print("No map position known for " .. (title or "that") .. ".")
        return false
    end
    local zoneName = (C_Map and C_Map.GetAreaInfo and C_Map.GetAreaInfo(zone)) or (ns.ZoneNames and ns.ZoneNames[zone]) or "?"
    target = { uiMap = uiMap, x = x / 100, y = y / 100, title = title or "Waypoint" }
    if TomTom and TomTom.AddWaypoint then
        pcall(TomTom.AddWaypoint, TomTom, uiMap, x / 100, y / 100,
            { title = target.title, persistent = false, minimap = true, world = true })
    end
    UpdateMapPin()
    Print(("Waypoint: %s - %s (%.1f, %.1f). Marked on your world map."):format(target.title, zoneName, x, y))
    return true
end

local watcher = CreateFrame("Frame")
watcher:RegisterEvent("PLAYER_LOGIN")
watcher:SetScript("OnEvent", function()
    if not WorldMapFrame then return end
    WorldMapFrame:HookScript("OnShow", UpdateMapPin)
    if WorldMapFrame.OnMapChanged then hooksecurefunc(WorldMapFrame, "OnMapChanged", UpdateMapPin) end
end)
