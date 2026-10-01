local frame = CreateFrame("Frame", "FriendTrackerFrame", UIParent")

frame:SetWidth(300)
frame:SetHeight(250)
frame:SetPoint("CENTER", UIParent, "CENTER", 300, 0)

frame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = 1,
    tileSize = 16,
    edgeSize = 16,
    insets = {
        left = 4,
        right = 4,
        top = 4,
        bottom = 4
    }
})

frame:SetBackdropColor(0,0,0,0.85)

local title = frame:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
title:SetPoint("TOP",0,-12)
title:SetText("Online Friends")

local rows = {}

for i = 1, 15 do
    rows[i] = frame:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    rows[i]:SetPoint("TOPLEFT",10,-35-((i-1)*14))
    rows[i]:SetWidth(280)
    rows[i]:SetJustifyH("LEFT")
    rows[i]:SetText("")
end

local function UpdateFriendList()

    if ShowFriends then
        ShowFriends()
    end

    local count = GetNumFriends() or 0

    for i = 1, 15 do
        rows[i]:SetText("")
    end

    rows[1]:SetText("Friends found: "..count)

    for i = 1, count do

        local a,b,c,d,e,f,g,h = GetFriendInfo(i)

        rows[i + 1]:SetText(
            tostring(a).." | "
            ..tostring(b).." | "
            ..tostring(c).." | "
            ..tostring(d)
        )

        DEFAULT_CHAT_FRAME:AddMessage(
            "Friend "..i..": "
            ..tostring(a).." | "
            ..tostring(b).." | "
            ..tostring(c).." | "
            ..tostring(d).." | "
            ..tostring(e).." | "
            ..tostring(f).." | "
            ..tostring(g).." | "
            ..tostring(h)
        )
    end
end

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("FRIENDLIST_UPDATE")

frame:SetScript("OnEvent", function()
    UpdateFriendList()
end)

SLASH_FRIENDTRACKER1 = "/ofriends"

SlashCmdList["FRIENDTRACKER"] = function()

    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
        UpdateFriendList()
    end

end

frame:Show()
UpdateFriendList()
