local addonName = "FriendTracker"

--------------------------------------------------
-- Main Frame
--------------------------------------------------

local frame = CreateFrame("Frame", "FriendTrackerFrame", UIParent)

frame:SetWidth(270)
frame:SetHeight(220)
frame:SetPoint("CENTER", UIParent, "CENTER", 300, 0)

frame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = {
        left = 5,
        right = 5,
        top = 5,
        bottom = 5
    }
})

frame:SetBackdropColor(0, 0, 0, 0.85)
frame:EnableMouse(true)
frame:SetMovable(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function()
    this:StartMoving()
end)

frame:SetScript("OnDragStop", function()
    this:StopMovingOrSizing()
end)

--------------------------------------------------
-- Title
--------------------------------------------------

local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -12)
title:SetText("Online Friends")

--------------------------------------------------
-- Friend Lines
--------------------------------------------------

local rows = {}

for i = 1, 20 do
    local row = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row:SetPoint("TOPLEFT", 10, -35 - ((i - 1) * 12))
    row:SetJustifyH("LEFT")
    row:SetWidth(245)
    row:SetText("")
    rows[i] = row
end

--------------------------------------------------
-- Update Function
--------------------------------------------------

local function UpdateFriendList()

    ShowFriends()

    local numFriends = GetNumFriends()

    for i = 1, 20 do
        rowsSetText("")
    end

    local line = 1

    for i = 1, numFriends do

        local name, level, class, zone, online = GetFriendInfo(i)

        if online and line <= 20 then

            name = name or "Unknown"
            level = level or "?"
            class = class or "?"
            zone = zone or "Unknown"

            rowsSetText(
                string.format(
                    "%s (%s %s) - %s",
                    name,
                    level,
                    class,
                    zone
                )
            )

            line = line + 1
        end
    end

    if line == 1 then
        rowsSetText("No friends online")
    end
end

--------------------------------------------------
-- Events
--------------------------------------------------

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("FRIENDLIST_UPDATE")

frame:SetScript("OnEvent", function()

    if event == "PLAYER_ENTERING_WORLD" then
        ShowFriends()
    end

    UpdateFriendList()

end)

--------------------------------------------------
-- Slash Commands
--------------------------------------------------

SLASH_FRIENDTRACKER1 = "/ofriends"

SlashCmdList["FRIENDTRACKER"] = function()

    if FriendTrackerFrame:IsShown() then
        FriendTrackerFrame:Hide()
    else
        FriendTrackerFrame:Show()
        UpdateFriendList()
    end

end

--------------------------------------------------
-- Initial Update
--------------------------------------------------

frame:Show()
UpdateFriendList()
