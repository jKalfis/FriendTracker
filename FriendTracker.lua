-- FriendTracker for Vanilla 1.12.1 (Lua 5.0)

-- Tabela de cores de classe do Vanilla 1.12.1
local CLASS_COLORS = {
    ["WARRIOR"] = "cffc79c6e",
    ["PALADIN"] = "cfff58cba",
    ["HUNTER"]  = "cffabd473",
    ["ROGUE"]   = "cfffff569",
    ["PRIEST"]  = "cffffffff",
    ["SHAMAN"]  = "cff0070de",
    ["MAGE"]    = "cff69ccf0",
    ["WARLOCK"] = "cff9482c9",
    ["DRUID"]   = "cffff7d0a"
}

-- Main Frame
local frame = CreateFrame("Frame", "FriendTrackerMainFrame", UIParent)
frame:SetWidth(300)
frame:SetHeight(380)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
frame:SetMovable(true)
frame:SetResizable(true)
frame:SetMinResize(180, 120)
frame:SetMaxResize(600, 800)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:Hide()

-- Guardar tamanho e posição da janela
local function SavePositionAndSize()
    if not FriendTrackerDB then FriendTrackerDB = {} end
    FriendTrackerDB.width = frame:GetWidth()
    FriendTrackerDB.height = frame:GetHeight()
    
    local cX, cY = frame:GetCenter()
    local uX, uY = UIParent:GetCenter()
    if cX and cY and uX and uY then
        FriendTrackerDB.x = cX - uX
        FriendTrackerDB.y = cY - uY
    end
end

-- Arrastar janela
frame:SetScript("OnDragStart", function()
    if not (FriendTrackerDB and FriendTrackerDB.locked) then
        this:StartMoving()
    end
end)
frame:SetScript("OnDragStop", function()
    this:StopMovingOrSizing()
    SavePositionAndSize()
end)

-- Estilo pfUI (Fundo escuro semi-translúcido com borda fina)
frame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    tile = false, tileSize = 0, edgeSize = 1,
    insets = { left = 0, right = 0, top = 0, bottom = 0 }
})
frame:SetBackdropColor(0, 0, 0, 0.75)
frame:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)

-- Botão fechar estilo pfUI (Borda preta pura)
local closeBtn = CreateFrame("Button", nil, frame)
closeBtn:SetWidth(16)
closeBtn:SetHeight(16)
closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
closeBtn:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    tile = false, tileSize = 0, edgeSize = 1,
    insets = { left = 0, right = 0, top = 0, bottom = 0 }
})
closeBtn:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
closeBtn:SetBackdropBorderColor(0, 0, 0, 1)

local closeText = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
closeText:SetPoint("CENTER", closeBtn, "CENTER", 0, 1)
closeText:SetText("x")
closeText:SetTextColor(0.8, 0.2, 0.2, 1)

closeBtn:SetScript("OnClick", function()
    this:GetParent():Hide()
end)
closeBtn:SetScript("OnEnter", function()
    this:SetBackdropBorderColor(0.8, 0.2, 0.2, 1)
end)
closeBtn:SetScript("OnLeave", function()
    this:SetBackdropBorderColor(0, 0, 0, 1)
end)

-- Menu de Contexto (Apenas Whisper e Invite)
local contextMenu = CreateFrame("Frame", "FriendTrackerContextMenu", UIParent)
contextMenu:SetWidth(120)
contextMenu:SetHeight(44)
contextMenu:SetFrameStrata("TOOLTIP")
contextMenu:Hide()
contextMenu:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    tile = false, tileSize = 0, edgeSize = 1,
    insets = { left = 0, right = 0, top = 0, bottom = 0 }
})
contextMenu:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
contextMenu:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)

local activeFriendName = nil

local function CreateMenuButton(parent, label, yOffset, onClickFunc)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetWidth(112)
    btn:SetHeight(18)
    btn:SetPoint("TOP", parent, "TOP", 0, yOffset)
    btn:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", tile = false, tileSize = 0, edgeSize = 0 })
    btn:SetBackdropColor(0, 0, 0, 0)

    local txt = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    txt:SetPoint("LEFT", btn, "LEFT", 8, 0)
    txt:SetText(label)

    btn:SetScript("OnEnter", function()
        this:SetBackdropColor(0.2, 0.2, 0.2, 0.8)
    end)
    btn:SetScript("OnLeave", function()
        this:SetBackdropColor(0, 0, 0, 0)
    end)
    btn:SetScript("OnClick", function()
        onClickFunc()
        contextMenu:Hide()
    end)
    return btn
end

CreateMenuButton(contextMenu, "Whisper", -4, function()
    if activeFriendName then ChatFrame_OpenChat("/w " .. activeFriendName .. " ") end
end)
CreateMenuButton(contextMenu, "Invite to Party", -23, function()
    if activeFriendName then InviteByName(activeFriendName) end
end)

local function ShowContextMenu(name)
    activeFriendName = name
    local x, y = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
    contextMenu:ClearAllPoints()
    contextMenu:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x / scale, y / scale)
    contextMenu:Show()
end

-- Pega para redimensionar
local resizeBtn = CreateFrame("Button", nil, frame)
resizeBtn:SetWidth(12)
resizeBtn:SetHeight(12)
resizeBtn:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
resizeBtn:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
resizeBtn:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
resizeBtn:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")

resizeBtn:SetScript("OnMouseDown", function()
    if not (FriendTrackerDB and FriendTrackerDB.locked) then
        this:GetParent():StartSizing("
