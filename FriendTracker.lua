local frame = CreateFrame("Frame", "FriendTrackerFrame", UIParent)
frame:SetWidth(250)
frame:SetHeight(300)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

frame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})

frame:SetBackdropColor(0, 0, 0, 0.8)
frame:EnableMouse(true)
frame:SetMovable(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", 0, -10)
title:SetText("Online Friends")

local rows = {}

local function UpdateFriends()
    ShowFriends()

    local count = GetNumFriends()

    for i = 1, table.getn(rows) do
        rowsHide()
    end

    for i = 1, count do
        local name, level, class, area, connected =
            GetFriendInfo(i)

        if connected then
            if not rows[i] then
                rows[i] = frame:CreateFontString(nil,
                    "OVERLAY",
                    "GameFontHighlightSmall")
            end

            rowsSetPoint("TOPLEFT",
                10,
                -30 - ((i - 1) * 15))

            rowsSetText(
                name ..
                " | Lv" .. level ..
                " | " .. class ..
                " | " .. area
            )

            rowsShow()
        end
    end
end

frame:RegisterEvent("FRIENDLIST_UPDATE")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

frame:SetScript("OnEvent", function()
    UpdateFriends()
end)

local timer = 0
frame:SetScript("OnUpdate", function()
    timer = timer + arg1

    if timer > 30 then
        ShowFriends()
        timer = 0
    end
end)

SLASH_FRIENDTRACKER1 = "/ft"

SlashCmdList["FRIENDTRACKER"] = function()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
        UpdateFriends()
    end
end