local frame = CreateFrame("Frame", "FriendTrackerFrame", UIParent)

frame:SetWidth(280)
frame:SetHeight(220)
frame:SetPoint("CENTER", UIParent, "CENTER", 300, 0)

frame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = {
        left = 4,
        right = 4,
        top = 4,
        bottom = 4
    }
})

frame:SetBackdropColor(0, 0, 0, 0.85)

local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -12)
title:SetText("Online Friends")

local rows = {}

for i = 1, 15 do
    rows[i] = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    rowsSetPoint("TOPLEFT", 10, -35 - ((i - 1) * 14))
    rowsSetWidth(260)
    rowsSetJustifyH("LEFT")
    rowsSetText("")
end

local function UpdateFriends()

    if ShowFriends then
        ShowFriends()
    end

    local numFriends = GetNumFriends() or 0

    for i = 1, 15 do
        rowsSetText("")
    end

    if numFriends == 0 then
        rowsSetText("No friends found")
        return
    end

    for i = 1, numFriends do

        local friendData = { GetFriendInfo(i) }

        rowsSetText(
            tostring(friendData[1] or ("Friend "..i))
        )

    end
end

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("FRIENDLIST_UPDATE")

frame:SetScript("OnEvent", function()
    UpdateFriends()
end)

SLASH_FRIENDTRACKER1 = "/ofriends"

SlashCmdList["FRIENDTRACKER"] = function()

    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
        UpdateFriends()
    end

end

frame:Show()
UpdateFriends()
