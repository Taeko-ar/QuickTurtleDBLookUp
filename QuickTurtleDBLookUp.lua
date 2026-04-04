QuickTurtleDBLookUpDB = QuickTurtleDBLookUpDB or { enabled = true, debug = false }
QuickTurtleDBLookUp_CurrentType = "npc"
QuickTurtleDBLookUp_CurrentID = nil
QuickTurtleDBLookUp_CurrentName = nil

local L = {
    ["DB_LOOKUP"] = "Turtle DB Lookup",
    ["CANCEL"] = "Cancel",
    ["NPC_NO_ID"] = "NPC: %s",
    ["NPC_WITH_ID"] = "NPC: %s (ID: %s)",
    ["ITEM_NO_ID"] = "Item: %s",
    ["ITEM_WITH_ID"] = "Item: %s (ID: %s)",
    ["QUEST_NO_ID"] = "Quest: %s",
    ["QUEST_WITH_ID"] = "Quest: %s (ID: %s)",
    ["CLOSE"] = "Close",
    ["ENABLED"] = "Enabled.",
    ["DISABLED"] = "Disabled.",
    ["NO_TARGET"] = "You don't have a target to look up! (Type /qdb help for commands)",
    ["DEBUG_ON"] = "Debug mode Enabled. Use /qdb to see extraction details.",
    ["DEBUG_OFF"] = "Debug mode Disabled.",
    ["HELP_BASE"] = "/qdb - Attempt lookup on your current target",
    ["HELP_TOGGLE"] = "/qdb toggle - Enable / Disable",
    ["HELP_DEBUG"] = "/qdb debug - Toggle debug mode",
    ["LOADED"] = "v1.0 loaded. /qdb for options.",
    ["OPENED_LINK"] = "Opened database link for: ",
}

if GetLocale() == "esES" or GetLocale() == "esMX" then
    L["DB_LOOKUP"] = "Buscar en TurtleDB"
    L["CANCEL"] = "Cancelar"
    L["NPC_NO_ID"] = "PNJ: %s"
    L["NPC_WITH_ID"] = "PNJ: %s (ID: %s)"
    L["ITEM_NO_ID"] = "Objeto: %s"
    L["ITEM_WITH_ID"] = "Objeto: %s (ID: %s)"
    L["QUEST_NO_ID"] = "Misión: %s"
    L["QUEST_WITH_ID"] = "Misión: %s (ID: %s)"
    L["CLOSE"] = "Cerrar"
    L["ENABLED"] = "Activado."
    L["DISABLED"] = "Desactivado."
    L["NO_TARGET"] = "¡No tienes un objetivo! (Usa /qdb help para comandos)"
    L["DEBUG_ON"] = "Modo de depuración Activado. Usa /qdb para ver detalles."
    L["DEBUG_OFF"] = "Modo de depuración Desactivado."
    L["HELP_BASE"] = "/qdb - Buscar tu objetivo actual"
    L["HELP_TOGGLE"] = "/qdb toggle - Activar / Desactivar addon"
    L["HELP_DEBUG"] = "/qdb debug - Alternar modo de depuración"
    L["LOADED"] = "v1.0 cargado. Usa /qdb para opciones."
    L["OPENED_LINK"] = "Enlace de la base de datos abierto para: "
elseif GetLocale() == "ptBR" or GetLocale() == "ptPT" then
    L["DB_LOOKUP"] = "Buscar no TurtleDB"
    L["CANCEL"] = "Cancelar"
    L["NPC_NO_ID"] = "NPC: %s"
    L["NPC_WITH_ID"] = "NPC: %s (ID: %s)"
    L["ITEM_NO_ID"] = "Item: %s"
    L["ITEM_WITH_ID"] = "Item: %s (ID: %s)"
    L["QUEST_NO_ID"] = "Missão: %s"
    L["QUEST_WITH_ID"] = "Missão: %s (ID: %s)"
    L["CLOSE"] = "Fechar"
    L["ENABLED"] = "Ativado."
    L["DISABLED"] = "Desativado."
    L["NO_TARGET"] = "Você não tem um alvo válido! (Use /qdb help para os comandos)"
    L["DEBUG_ON"] = "Modo de depuração Ativado. Use /qdb para ver detalhes."
    L["DEBUG_OFF"] = "Modo de depuração Desativado."
    L["HELP_BASE"] = "/qdb - Buscar o seu alvo atual"
    L["HELP_TOGGLE"] = "/qdb toggle - Ativar / Desativar o addon"
    L["HELP_DEBUG"] = "/qdb debug - Alternar modo de depuração"
    L["LOADED"] = "v1.0 carregado. Use /qdb para opções."
    L["OPENED_LINK"] = "Link do banco de dados aberto para: "
end

local function PrintMsg(msg)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff96QuickTurtleDBLookUp:|r " .. tostring(msg))
    end
end

local function DebugMsg(msg)
    if QuickTurtleDBLookUpDB.debug then
        PrintMsg("|cffaaaaaa[DEBUG]|r " .. tostring(msg))
    end
end

StaticPopupDialogs["QUICK_TURTLE_DB_LOOKUP"] = {
    text = L["NPC_NO_ID"],
    button1 = L["CLOSE"],
    hasEditBox = 1,
    OnShow = function()
        local editBox = getglobal(this:GetName().."EditBox")
        if editBox then
            local url
            local lookupType = QuickTurtleDBLookUp_CurrentType or "npc"
            local currentID = QuickTurtleDBLookUp_CurrentID
            
            if currentID and currentID ~= "Unknown" then
                if lookupType == "item" then
                    url = "https://database.turtlecraft.gg/?item=" .. tostring(currentID)
                elseif lookupType == "quest" then
                    url = "https://database.turtlecraft.gg/?quest=" .. tostring(currentID)
                else
                    url = "https://database.turtlecraft.gg/?npc=" .. tostring(currentID)
                end
            else
                local nameForUrl = string.gsub(QuickTurtleDBLookUp_CurrentName or "", " ", "+")
                url = "https://database.turtlecraft.gg/?search=" .. nameForUrl
            end
            editBox:SetText(url)
            editBox:HighlightText()
            editBox:SetFocus()
        end
    end,
    EditBoxOnEnterPressed = function()
        local editBox = getglobal(this:GetParent():GetName().."EditBox") or this
        editBox:ClearFocus()
        this:GetParent():Hide()
    end,
    EditBoxOnEscapePressed = function()
        this:GetParent():Hide()
    end,
    OnAccept = function()
    end,
    timeout = 0,
    exclusive = 1,
    hideOnEscape = 1,
    whileDead = 1,
}

local function ExtractNPCID(guid)
    if type(guid) ~= "string" then return "Unknown" end
    
    if string.find(guid, "-") then
        local parts = {}
        for part in string.gfind(guid, "([^-]+)") do
            table.insert(parts, part)
        end
        if table.getn(parts) >= 6 then
            return tonumber(parts[6]) or "Unknown"
        end
    end

    if string.sub(guid, 1, 2) == "0x" then
        local val_end = tonumber(string.sub(guid, -10, -7), 16)
        local val_front = tonumber(string.sub(guid, 7, 10), 16)
        local val_mid = tonumber(string.sub(guid, 9, 12), 16)
        local val_nine_fourteen = tonumber(string.sub(guid, 9, 14), 16)
        local val_seven_twelve = tonumber(string.sub(guid, 7, 12), 16)
        
        DebugMsg("Extraction candidates:")
        DebugMsg("(-10 to -7) -> " .. tostring(string.sub(guid, -10, -7)) .. " = " .. tostring(val_end))
        DebugMsg("(7 to 10) -> " .. tostring(string.sub(guid, 7, 10)) .. " = " .. tostring(val_front))
        DebugMsg("(9 to 12) -> " .. tostring(string.sub(guid, 9, 12)) .. " = " .. tostring(val_mid))
        DebugMsg("(9 to 14) -> " .. tostring(string.sub(guid, 9, 14)) .. " = " .. tostring(val_nine_fourteen))
        DebugMsg("(7 to 12) -> " .. tostring(string.sub(guid, 7, 12)) .. " = " .. tostring(val_seven_twelve))

        if tonumber(string.sub(guid, -10, -7), 16) ~= 0 then
            return tonumber(string.sub(guid, -10, -7), 16)
        end
        return tonumber(string.sub(guid, 7, 10), 16) or "Unknown"
    end

    return "Unknown"
end

function QuickTurtleDBLookUp_ShowPopup()
    DebugMsg("ShowPopup called")
    if not QuickTurtleDBLookUpDB.enabled then 
        DebugMsg("Addon disabled")
        return 
    end
    
    local lookupType = QuickTurtleDBLookUp_CurrentType or "npc"
    local id, name
    
    if lookupType == "item" then
        id = QuickTurtleDBLookUp_CurrentID or "Unknown"
        name = QuickTurtleDBLookUp_CurrentName or "Unknown Item"
    elseif lookupType == "quest" then
        id = QuickTurtleDBLookUp_CurrentID or "Unknown"
        name = QuickTurtleDBLookUp_CurrentName or "Unknown Quest"
    else
        if not UnitExists("target") then 
            DebugMsg("No target exists")
            return 
        end
        
        if UnitIsPlayer("target") then 
            DebugMsg("Target is player, ignoring")
            return 
        end

        local guid = nil
        if UnitGUID then
            guid = UnitGUID("target")
            DebugMsg("Raw GUID from UnitGUID: '" .. tostring(guid) .. "' (length: " .. tostring(guid and string.len(guid) or 0) .. ")")
        else
            local _, possibleGuid = UnitExists("target")
            if type(possibleGuid) == "string" then 
                guid = possibleGuid 
                DebugMsg("Raw GUID from UnitExists possibleGuid (SuperWoW): '" .. tostring(guid) .. "'")
            else
                DebugMsg("No GUID found.")
            end
        end
        
        id = ExtractNPCID(guid)
        DebugMsg("Final parsed npcID selected: " .. tostring(id))
        name = UnitName("target") or "Unknown"
        QuickTurtleDBLookUp_CurrentID = id
        QuickTurtleDBLookUp_CurrentName = name
    end
    
    if id ~= "Unknown" then
        if lookupType == "item" then
            StaticPopupDialogs["QUICK_TURTLE_DB_LOOKUP"].text = L["ITEM_WITH_ID"]
        elseif lookupType == "quest" then
            StaticPopupDialogs["QUICK_TURTLE_DB_LOOKUP"].text = L["QUEST_WITH_ID"]
        else
            StaticPopupDialogs["QUICK_TURTLE_DB_LOOKUP"].text = L["NPC_WITH_ID"]
        end
        StaticPopup_Show("QUICK_TURTLE_DB_LOOKUP", name, id)
    else
        if lookupType == "item" then
            StaticPopupDialogs["QUICK_TURTLE_DB_LOOKUP"].text = L["ITEM_NO_ID"]
        elseif lookupType == "quest" then
            StaticPopupDialogs["QUICK_TURTLE_DB_LOOKUP"].text = L["QUEST_NO_ID"]
        else
            StaticPopupDialogs["QUICK_TURTLE_DB_LOOKUP"].text = L["NPC_NO_ID"]
        end
        StaticPopup_Show("QUICK_TURTLE_DB_LOOKUP", name)
    end
    
    PrintMsg(L["OPENED_LINK"] .. tostring(name))
end

local QTD_DropDown = CreateFrame("Frame", "QuickTurtleDBLookUp_DropDown", UIParent, "UIDropDownMenuTemplate")
UIDropDownMenu_Initialize(QTD_DropDown, function()
    local info = {}
    if QuickTurtleDBLookUp_CurrentType == "item" or QuickTurtleDBLookUp_CurrentType == "quest" then
        info.text = QuickTurtleDBLookUp_CurrentName or "Unknown"
    else
        info.text = UnitName("target") or "Unknown"
    end
    info.isTitle = 1
    info.notCheckable = 1
    UIDropDownMenu_AddButton(info)

    info = {}
    info.text = "|cff00ff00" .. L["DB_LOOKUP"] .. "|r"
    info.notCheckable = 1
    info.func = QuickTurtleDBLookUp_ShowPopup
    UIDropDownMenu_AddButton(info)
    
    info = {}
    info.text = L["CANCEL"]
    info.notCheckable = 1
    info.func = function() end
    UIDropDownMenu_AddButton(info)
end, "MENU")

local function AttemptHookUIFrame(fNameOrObj, isExplicitTargetFrame)
    local f = fNameOrObj
    if type(f) == "string" then
        f = getglobal(f)
    end
    
    if f and type(f) == "table" and not f.QuickTurtleDBHooked then
        local function TriggerIfValid(frame, btn)
            if not QuickTurtleDBLookUpDB or not QuickTurtleDBLookUpDB.enabled then return end
            if btn ~= "RightButton" then return end
            if not UnitExists("target") or UnitIsPlayer("target") then return end

            local isValid = isExplicitTargetFrame
            if not isValid and frame then
                if frame.unit == "target" then
                    isValid = true
                elseif frame.unit == nil then
                    local name = frame.GetName and frame:GetName()
                    name = name and string.lower(name) or ""
                    if string.find(name, "target") then
                        isValid = true
                    end
                end
            end

            if isValid then
                QuickTurtleDBLookUp_CurrentType = "npc"
                ToggleDropDownMenu(1, nil, QuickTurtleDBLookUp_DropDown, "cursor", 0, 0)
            end
        end

        if f:HasScript("OnClick") then
            local oldClick = f:GetScript("OnClick")
            f:SetScript("OnClick", function(a1, a2, a3)
                if oldClick then oldClick(a1, a2, a3) end
                local btn = arg1 or a1
                TriggerIfValid(this, btn)
            end)
            f.QuickTurtleDBHooked = true
        elseif f:HasScript("OnMouseUp") then
            local oldMouseUp = f:GetScript("OnMouseUp")
            f:SetScript("OnMouseUp", function(a1, a2, a3)
                if oldMouseUp then oldMouseUp(a1, a2, a3) end
                local btn = arg1 or a1
                TriggerIfValid(this, btn)
            end)
            f.QuickTurtleDBHooked = true
        end
    end
end

local old_TargetFrame_OnClick = TargetFrame_OnClick
if TargetFrame_OnClick then
    function TargetFrame_OnClick(button)
        if old_TargetFrame_OnClick then
            old_TargetFrame_OnClick(button)
        end
        if QuickTurtleDBLookUpDB and QuickTurtleDBLookUpDB.enabled and button == "RightButton" and UnitExists("target") and not UnitIsPlayer("target") then
            QuickTurtleDBLookUp_CurrentType = "npc"
            ToggleDropDownMenu(1, nil, QuickTurtleDBLookUp_DropDown, "cursor", 0, 0)
        end
    end
end

local old_SetItemRef = SetItemRef
function SetItemRef(link, text, button)
    if QuickTurtleDBLookUpDB and QuickTurtleDBLookUpDB.enabled and button == "RightButton" then
        if string.sub(link, 1, 4) == "item" then
            local _, _, itemId = string.find(link, "^item:(%d+)")
            local _, _, itemName = string.find(text, "%[(.+)%]")
            QuickTurtleDBLookUp_CurrentType = "item"
            QuickTurtleDBLookUp_CurrentID = tonumber(itemId)
            QuickTurtleDBLookUp_CurrentName = itemName or "Unknown Item"
            ToggleDropDownMenu(1, nil, QuickTurtleDBLookUp_DropDown, "cursor", 0, 0)
            return
        elseif string.sub(link, 1, 5) == "quest" then
            local _, _, questId = string.find(link, "^quest:(%d+)")
            local _, _, questName = string.find(text, "%[(.+)%]")
            QuickTurtleDBLookUp_CurrentType = "quest"
            QuickTurtleDBLookUp_CurrentID = tonumber(questId)
            QuickTurtleDBLookUp_CurrentName = questName or "Unknown Quest"
            ToggleDropDownMenu(1, nil, QuickTurtleDBLookUp_DropDown, "cursor", 0, 0)
            return
        end
    end
    if old_SetItemRef then
        old_SetItemRef(link, text, button)
    end
end

local old_ContainerFrameItemButton_OnClick = ContainerFrameItemButton_OnClick
if ContainerFrameItemButton_OnClick then
    function ContainerFrameItemButton_OnClick(button, ignoreShift)
        if QuickTurtleDBLookUpDB and QuickTurtleDBLookUpDB.enabled and button == "RightButton" and IsControlKeyDown() then
            local bag = this:GetParent():GetID()
            local slot = this:GetID()
            local link = GetContainerItemLink(bag, slot)
            if link then
                local _, _, itemId = string.find(link, "item:(%d+)")
                local _, _, itemName = string.find(link, "%[(.+)%]")
                if itemId and itemName then
                    QuickTurtleDBLookUp_CurrentType = "item"
                    QuickTurtleDBLookUp_CurrentID = tonumber(itemId)
                    QuickTurtleDBLookUp_CurrentName = itemName
                    ToggleDropDownMenu(1, nil, QuickTurtleDBLookUp_DropDown, "cursor", 0, 0)
                end
            end
            return
        end
        if old_ContainerFrameItemButton_OnClick then
            old_ContainerFrameItemButton_OnClick(button, ignoreShift)
        end
    end
end

SLASH_QUICKTURTLEDBLOOKUP1 = "/qdb"
SLASH_QUICKTURTLEDBLOOKUP2 = "/turtledb"
SlashCmdList["QUICKTURTLEDBLOOKUP"] = function(msg)
    msg = string.lower(msg or "")
    if msg == "toggle" then
        QuickTurtleDBLookUpDB.enabled = not QuickTurtleDBLookUpDB.enabled
        if QuickTurtleDBLookUpDB.enabled then
            PrintMsg(L["ENABLED"])
        else
            PrintMsg(L["DISABLED"])
        end
    elseif msg == "debug" then
        QuickTurtleDBLookUpDB.debug = not QuickTurtleDBLookUpDB.debug
        if QuickTurtleDBLookUpDB.debug then
            PrintMsg(L["DEBUG_ON"])
        else
            PrintMsg(L["DEBUG_OFF"])
        end
    elseif msg == "help" then
        PrintMsg(L["HELP_BASE"])
        PrintMsg(L["HELP_TOGGLE"])
        PrintMsg(L["HELP_DEBUG"])
    else
        if UnitExists("target") then
            QuickTurtleDBLookUp_ShowPopup()
        else
            PrintMsg(L["NO_TARGET"])
        end
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("VARIABLES_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:SetScript("OnEvent", function()
    if event == "VARIABLES_LOADED" then
        if QuickTurtleDBLookUpDB == nil then
            QuickTurtleDBLookUpDB = { enabled = true, debug = false }
        end
        if type(QuickTurtleDBLookUpDB.debug) ~= "boolean" then
            QuickTurtleDBLookUpDB.debug = false
        end
        PrintMsg(L["LOADED"])
    elseif event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_TARGET_CHANGED" then
        local frames = {"pfTarget", "LunaTargetFrame", "XPerl_Target", "SUFUnittarget", "DUF_TargetFrame", "DiscordUnitFrame2", "TargetFrame"}
        for _, name in pairs(frames) do
            AttemptHookUIFrame(name, true)
        end
        
        -- Universal UI Hook: Dynamically catch any unknown custom frames that register via standard click-casting API
        if ClickCastFrames then
            for clickFrame, _ in pairs(ClickCastFrames) do
                if clickFrame and not clickFrame.QuickTurtleDBHooked then
                    AttemptHookUIFrame(clickFrame, false)
                end
            end
        end
    end
end)
