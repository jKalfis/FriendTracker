local frame = CreateFrame("Frame", "FriendTrackerFrame", UIParent)

frame:SetWidth(320)
frame:SetHeight(250)
frame:SetPoint("CENTER", UIParent, "CENTER", 300, 0)

frame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})

frame:SetBackdropColor(0,0,0,0.85)

frame:EnableMouse(true)
frame:SetMovable(true)
frame:RegisterForDrag("LeftButton")

frame:SetScript("OnDragStart", function()
    this:StartMoving()
end)

frame:SetScript("OnDragStop", function()
    this:StopMovingOrSizing()
end)

local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -10)
title:SetText("Online Friends")

local rows = {}

for i = 1, 15 do
    local row = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")

    row:SetPoint(
        "TOPLEFT",
        10,
        -35 - ((i - 1) * 14)
    )

    row:SetWidth(300)
    row:SetJustifyH("LEFT")
    row:SetText("")

    rows[i] = row
end

local function UpdateFriends()

    ShowFriends()

    local total = GetNumFriends() or 0

    for i = 1, 15 do
        rowsSetText("")
    end

    local line = 1

    for i = 1, total do

        local name, level, class, zone, online =
            GetFriendInfo(i)

        if online and line <= 15 then

            rowsSetText(
                name ..
                " (" ..
                level ..
                " " ..
                class ..
                ") - " ..
                zone
            )

            line = line + 1
        end
    end

    if line == 1 then
        rowsSetText("No friends online")
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

frame:Hide()
