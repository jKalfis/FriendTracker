-- Create main frame for Vanilla 1.12.1 (Lua 5.0)
local frame = CreateFrame("Frame", "FriendTrackerMainFrame", UIParent)
frame:SetWidth(300)
frame:SetHeight(380)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")

-- 1.12.1 uses global "this" inside frame scripts
frame:SetScript("OnDragStart", function() this:StartMoving() end)
frame:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
frame:Hide()

-- Classic dialog backdrop style
frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})

-- Close Button
local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)

-- Title
local title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
title:SetPoint("TOP", frame, "TOP", 0, -15)
title:SetText("FriendTracker - Online Friends")

-- ScrollFrame for friends list
local scrollFrame = CreateFrame("ScrollFrame", "FriendTrackerScrollFrame", frame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -40)
scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -35, 15)

local content = CreateFrame("Frame", nil, scrollFrame)
content:SetWidth(240)
content:SetHeight(1)
scrollFrame:SetScrollChild(content)

-- Text row storage
local friendRows = {}

local function GetOrCreateRow(index)
    if not friendRows[index] then
        local row = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 5, -(index - 1) * 18)
        row:SetJustifyH("LEFT")
        friendRows[index] = row
    end
    return friendRows[index]
end

-- Main update function
local function UpdateFriendList()
    if not frame:IsShown() then return end

    ShowFriends() -- Request friend list update from 1.12.1 server

    local numFriends = GetNumFriends()
    local onlineCount = 0

    -- Hide existing rows
    for _, row in ipairs(friendRows) do
        row:Hide()
    end

    for i = 1, numFriends do
        -- 1.12.1 API returns: name, level, class, area, connected, status
        local name, level, class, area, connected, status = GetFriendInfo(i)

        if connected then
            onlineCount = onlineCount + 1
            local row = GetOrCreateRow(onlineCount)

            local nameStr = name or "Unknown"
            local areaStr = (area and area ~= "") and area or "Unknown Zone"
            local levelStr = level and ("[" .. level .. "]") or ""

            -- Format: [Level] Name - Zone
            row:SetText(string.format("%s |cffffffff%s|r - |cff00ff00%s|r", levelStr, nameStr, areaStr))
            row:Show()
        end
    end

    content:SetHeight(math.max(1, onlineCount * 18))

    if onlineCount == 0 then
        local row = GetOrCreateRow(1)
        row:SetText("|cff808080No friends online.|r")
        row:Show()
    end
end

-- Event registration (1.12.1 uses global "event")
frame:RegisterEvent("FRIENDLIST_UPDATE")
frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function()
    if event == "PLAYER_LOGIN" or event == "FRIENDLIST_UPDATE" then
        UpdateFriendList()
    end
end)

frame:SetScript("OnShow", function()
    ShowFriends()
    UpdateFriendList()
end)

-- Slash commands (/ft or /friendtracker)
SLASH_FRIENDTRACKER1 = "/ft"
SLASH_FRIENDTRACKER2 = "/friendtracker"
SlashCmdList["FRIENDTRACKER"] = function()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end
