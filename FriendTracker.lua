-- Janela principal para Vanilla 1.12.1 (Lua 5.0)
local frame = CreateFrame("Frame", "FriendTrackerMainFrame", UIParent)
frame:SetWidth(300)
frame:SetHeight(380)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
frame:SetMovable(true)
frame:SetResizable(true)
frame:SetMinResize(200, 150)
frame:SetMaxResize(600, 800)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")

-- Arrastar janela
frame:SetScript("OnDragStart", function() this:StartMoving() end)
frame:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
frame:Hide()

-- Estilo pfUI: Fundo preto semi-translúcido com borda fina plana
frame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    tile = false, tileSize = 0, edgeSize = 1,
    insets = { left = 0, right = 0, top = 0, bottom = 0 }
})
frame:SetBackdropColor(0, 0, 0, 0.75)         -- Fundo preto com 75% de opacidade
frame:SetBackdropBorderColor(0.2, 0.2, 0.2, 1) -- Borda fina cinza escuro

-- Botão de Fechar estilo pfUI (Quadrado escuro com 'x' vermelho)
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
closeBtn:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)

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
    this:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
end)

-- Ícone/Pega para redimensionar (Canto inferior direito)
local resizeBtn = CreateFrame("Button", nil, frame)
resizeBtn:SetWidth(12)
resizeBtn:SetHeight(12)
resizeBtn:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
resizeBtn:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
resizeBtn:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
resizeBtn:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")

resizeBtn:SetScript("OnMouseDown", function()
    this:GetParent():StartSizing("BOTTOMRIGHT")
end)
resizeBtn:SetScript("OnMouseUp", function()
    this:GetParent():StopMovingOrSizing()
end)

-- Título em Dourado e maior
local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -8)
title:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
title:SetText("Online Friends")
title:SetTextColor(1, 0.82, 0, 1) -- Cor Dourada do WoW

-- ScrollFrame para suportar a lista
local scrollFrame = CreateFrame("ScrollFrame", "FriendTrackerScrollFrame", frame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -32)
scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -28, 10)

local content = CreateFrame("Frame", nil, scrollFrame)
content:SetWidth(240)
content:SetHeight(1)
scrollFrame:SetScrollChild(content)

-- Ajustar a largura do conteúdo ao redimensionar a janela
frame:SetScript("OnSizeChanged", function()
    if scrollFrame then
        content:SetWidth(scrollFrame:GetWidth() - 10)
    end
end)

-- Linhas da lista de amigos
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

-- Atualização da lista de amigos
local function UpdateFriendList()
    if not frame:IsShown() then return end

    ShowFriends()

    local numFriends = GetNumFriends()
    local onlineCount = 0

    -- Esconder linhas anteriores
    for _, row in ipairs(friendRows) do
        row:Hide()
    end

    for i = 1, numFriends do
        local name, level, class, area, connected, status = GetFriendInfo(i)

        if connected then
            onlineCount = onlineCount + 1
            local row = GetOrCreateRow(onlineCount)

            local nameStr = name or "Unknown"
            local areaStr = (area and area ~= "") and area or "Unknown Zone"
            local levelStr = level and ("[" .. level .. "]") or ""

            -- Formatação: [Nível] Nome - Zona
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

-- Registar eventos
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

-- Comandos no Chat (/ft ou /friendtracker)
SLASH_FRIENDTRACKER1 = "/ofriends"
SlashCmdList["FRIENDTRACKER"] = function()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end
