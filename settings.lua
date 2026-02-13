return function(SettingsTab, player, Players, Library, HttpService, Keybinds)
    local whitelist = {}
    local playerDropdown = nil
    local whitelistDropdown = nil
    local SelectedConfigName = ""
    
-- ==================================================================================================== ONGLET WHITELIST ====================================================================================================

local function GetAvailablePlayers()
    local playerList = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and not table.find(whitelist, plr.Name) then
            table.insert(playerList, plr.Name)
        end
    end
    return playerList
end

local function RefreshDropdowns()
    if playerDropdown then
        playerDropdown:Refresh(GetAvailablePlayers(), true)
    end
    if whitelistDropdown then
        whitelistDropdown:Refresh(whitelist, true)
    end
end

SettingsTab:CreateSection("Whitelist Management")
playerDropdown = SettingsTab:CreateDropdown({
    Name = "Ajouter à Whitelist",
    Column = "Left",
    Options = GetAvailablePlayers(),
    CurrentOption = {"Aucun"},
    Callback = function(Option)
        if Option[1] and Option[1] ~= "Aucun" then
            local playerName = Option[1]
            if not table.find(whitelist, playerName) then
                table.insert(whitelist, playerName)
                print("[Whitelist] Ajouté: " .. playerName)
                RefreshDropdowns()
            end
        end
    end,
})

whitelistDropdown = SettingsTab:CreateDropdown({
    Name = "Retirer de Whitelist",
    Column = "Left",
    Options = whitelist,
    CurrentOption = {"Aucun"},
    Callback = function(Option)
        if Option[1] and Option[1] ~= "Aucun" then
            local playerName = Option[1]
            for i, name in ipairs(whitelist) do
                if name == playerName then
                    table.remove(whitelist, i)
                    print("[Whitelist] Retiré: " .. playerName)
                    RefreshDropdowns()
                    break
                end
            end
        end
    end,
})

task.spawn(function()
    while true do
        task.wait(10)
        RefreshDropdowns()
    end
end)

-- ==================================================================================================== SYSTÈME DE CONFIG ====================================================================================================

local CONFIG_ROOT = "OYNX"
local CONFIG_FOLDER = CONFIG_ROOT .. "/Configs/"

if not isfolder(CONFIG_ROOT) then
    makefolder(CONFIG_ROOT)
end

if not isfolder(CONFIG_FOLDER) then
    makefolder(CONFIG_FOLDER)
end

local function CollectConfig()
    local keybindData = {}
    
    if Keybinds then
        for name, keybind in pairs(Keybinds) do
            if keybind and keybind.GetKey then
                keybindData[name] = keybind.GetKey()
            end
        end
    end
    
    return {
        -- MOVEMENT
        SpeedEnabled = speedEnabled,
        SpeedValue = speedValue,
        MultiJump = multiJumpEnabled,
        NoJump = NoJumpEnabled,
        TPEnabled = isTpEnabled,
        FlyEnabled = flyEnabled,
        FlySpeed = flySpeed,
        
        -- SIZE
        SizeEnabled = sizeMultiplierEnabled,
        SizeValue = sizeMultiplier,
        WeaponSizeEnabled = weaponSizeEnabled,
        WeaponSizeValue = weaponSizeMultiplier,
        
        -- DESYNC / WORLD
        Desync = desyncEnabled,
        NPCBlocker = npcBlockerEnabled,
        AntiLava = antiLavaEnabled,
        AntiWater = antiWaterEnabled,
        NoClip = noclipEnabled,
        Invisible = InvisibleEnabled,
        
        -- AIM
        AimlockToggle = toggleEnabled,
        AimSmoothness = smoothness,
        MouselockToggle = mouselockToggleEnabled,
        MouselockSmoothness = mouselockSmoothness,
        MouselockRadius = mouselockRadius,
        ShowCircle = showCircle,
        MouselockTarget = mouselockTargetPart,
        
        -- PVP
        AutoEscape = autoEscapeEnabled,
        AutoEscapeHP = healthThreshold,
        TPHeight = tpHeightIncrement,
        TPInterval = tpInterval,
        EscapeDuration = escapeDuration,
        RapidDamage = rapidDamageThreshold,
        
        -- FAST ATTACK
        FastAttack = FastAttackEnabled,
        FastAttackIntensity = FastAttackIntensity,
        FastAttackRange = 5000,
        
        -- PVP EXTRAS
        AntiStun = antiStunEnabled,
        DashLength = DashEnabled,
        DashLengthVal = DashLengthValue,

        -- RAID
        AutoRaid = AutoRaidEnabled,
        AutoBuyChip = AutoBuyChip,
        AutoStartRaid = AutoStartRaid,
        SelectedRaid = SelectedRaid,
        
        Keybinds = keybindData
    }
end

local function ApplyConfig(data)
    if typeof(data) ~= "table" then return end

    -- MOVEMENT
    if data.SpeedValue then speedValue = data.SpeedValue end
    if data.SpeedEnabled ~= nil then speedEnabled = data.SpeedEnabled end
    if data.MultiJump ~= nil then multiJumpEnabled = data.MultiJump end
    if data.NoJump ~= nil then NoJumpEnabled = data.NoJump end
    if data.TPEnabled ~= nil then isTpEnabled = data.TPEnabled end
    if data.FlySpeed then flySpeed = data.FlySpeed end
    if data.FlyEnabled ~= nil then 
        flyEnabled = data.FlyEnabled
        if flyEnabled and StartFly then StartFly() 
        elseif StopFly then StopFly() end
    end
    
    -- SIZE
    if data.SizeValue then sizeMultiplier = data.SizeValue end
    if data.SizeEnabled ~= nil then 
        sizeMultiplierEnabled = data.SizeEnabled
        if sizeMultiplierEnabled and SetCharacterSize then
            SetCharacterSize(sizeMultiplier)
        elseif SetCharacterSize then
            SetCharacterSize(1)
        end
    end
    if data.WeaponSizeValue then weaponSizeMultiplier = data.WeaponSizeValue end
    if data.WeaponSizeEnabled ~= nil then 
        weaponSizeEnabled = data.WeaponSizeEnabled
        if weaponSizeEnabled and SetWeaponSize then
            SetWeaponSize(weaponSizeMultiplier)
        elseif SetWeaponSize then
            SetWeaponSize(1)
        end
    end
    
    -- DESYNC / WORLD
    if data.Desync ~= nil then desyncEnabled = data.Desync end
    if data.NPCBlocker ~= nil then 
        npcBlockerEnabled = data.NPCBlocker
        if SetNPCScriptsState then SetNPCScriptsState(npcBlockerEnabled) end
    end
    if data.AntiLava ~= nil and SetAntiLava then SetAntiLava(data.AntiLava) end
    if data.AntiWater ~= nil then antiWaterEnabled = data.AntiWater end
    if data.NoClip ~= nil then noclipEnabled = data.NoClip end
    if data.Invisible ~= nil then 
        InvisibleEnabled = data.Invisible
        if SetInvisible then SetInvisible(InvisibleEnabled) end
    end
    
    -- AIM
    if data.AimSmoothness then smoothness = data.AimSmoothness end
    if data.AimlockToggle ~= nil then toggleEnabled = data.AimlockToggle end
    if data.MouselockSmoothness then mouselockSmoothness = data.MouselockSmoothness end
    if data.MouselockRadius then mouselockRadius = data.MouselockRadius end
    if data.ShowCircle ~= nil then showCircle = data.ShowCircle end
    if data.MouselockToggle ~= nil then mouselockToggleEnabled = data.MouselockToggle end
    if data.MouselockTarget then mouselockTargetPart = data.MouselockTarget end
    
    -- PVP
    if data.AutoEscapeHP then healthThreshold = data.AutoEscapeHP end
    if data.TPHeight then tpHeightIncrement = data.TPHeight end
    if data.TPInterval then tpInterval = data.TPInterval end
    if data.EscapeDuration then escapeDuration = data.EscapeDuration end
    if data.AutoEscape ~= nil then autoEscapeEnabled = data.AutoEscape end
    if data.RapidDamage then rapidDamageThreshold = data.RapidDamage end
    
    -- FAST ATTACK
    if data.FastAttackIntensity then FastAttackIntensity = data.FastAttackIntensity end
    if data.FastAttackRange then FastAttackRange = data.FastAttackRange end
    if data.FastAttack ~= nil then 
        FastAttackEnabled = data.FastAttack
        if toggleFastAttack then toggleFastAttack(FastAttackEnabled) end
    end
    
    -- PVP EXTRAS
    if data.AntiStun ~= nil and ToggleAntiStun then 
        ToggleAntiStun(data.AntiStun)
    end
    if data.DashLengthVal then DashLengthValue = data.DashLengthVal end
    if data.DashLength ~= nil and ToggleDashLength then
        ToggleDashLength(data.DashLength)
    end

    -- RAID
    if data.SelectedRaid then SelectedRaid = data.SelectedRaid end
    if data.AutoBuyChip ~= nil then AutoBuyChip = data.AutoBuyChip end
    if data.AutoStartRaid ~= nil then AutoStartRaid = data.AutoStartRaid end
    if data.AutoRaid ~= nil then 
        AutoRaidEnabled = data.AutoRaid 
        if toggleFastAttack then toggleFastAttack(AutoRaidEnabled) end
    end

    -- KEYBINDS
    if data.Keybinds and Keybinds then
        for name, keyCode in pairs(data.Keybinds) do
            if Keybinds[name] and Keybinds[name].SetKey then
                Keybinds[name].SetKey(keyCode)
            end
        end
    end
    
    print("[CONFIG] ✓ Configuration appliquée avec succès")
end

local function SaveConfig(name)
    if not name or name == "" then
        warn("[CONFIG] Nom de config invalide")
        return
    end

    local path = CONFIG_FOLDER .. name .. ".json"
    local data = CollectConfig()
    writefile(path, HttpService:JSONEncode(data))
    print("[CONFIG] ✓ Sauvegardé: " .. name)
end

local function LoadConfig(name)
    local path = CONFIG_FOLDER .. name .. ".json"
    if not isfile(path) then
        warn("[CONFIG] Config introuvable: " .. name)
        return
    end

    local raw = readfile(path)
    local data = HttpService:JSONDecode(raw)
    ApplyConfig(data)
    print("[CONFIG] ✓ Chargé: " .. name)
end

local function GetConfigs()
    local list = {}
    for _, file in ipairs(listfiles(CONFIG_FOLDER)) do
        local name = file:match("([^/\\]+)%.json$")
        if name then
            table.insert(list, name)
        end
    end
    return list
end

SettingsTab:CreateSection("Config Management")
SettingsTab:CreateInput({
    Name = "Nom de la Config",
    Column = 'Right',
    PlaceholderText = "MaConfig",
    Callback = function(text)
        SelectedConfigName = text
    end,
})

SettingsTab:CreateButton({
    Name = "💾 Sauvegarder Config",
    Column = 'Right',
    Callback = function()
        if SelectedConfigName ~= "" then
            SaveConfig(SelectedConfigName)
            Library:Notify("Config", "Sauvegardé: " .. SelectedConfigName, 3)
        else
            Library:Notify("Erreur", "Entre un nom de config d'abord", 3)
        end
    end,
})

SettingsTab:CreateButton({
    Name = "📂 Charger Config",
    Column = 'Right',
    Callback = function()
        if SelectedConfigName ~= "" then
            LoadConfig(SelectedConfigName)
            Library:Notify("Config", "Chargé: " .. SelectedConfigName, 3)
        else
            Library:Notify("Erreur", "Entre un nom de config d'abord", 3)
        end
    end,
})

SettingsTab:CreateButton({
    Name = "📋 Liste des Configs (Console)",
    Column = 'Right',
    Callback = function()
        print("=== LISTE DES CONFIGS ===")
        local configs = GetConfigs()
        if #configs == 0 then
            print("Aucune config trouvée")
        else
            for i, v in ipairs(configs) do
                print(i .. ". " .. v)
            end
        end
        print("========================")
    end,
})
    
return {
    whitelist = whitelist,
    
    -- Fonctions whitelist
    GetWhitelist = function() return whitelist end,
    AddToWhitelist = function(name)
        if not table.find(whitelist, name) then
            table.insert(whitelist, name)
            RefreshDropdowns()
            return true
        end
        return false
    end,
    RemoveFromWhitelist = function(name)
        for i, v in ipairs(whitelist) do
            if v == name then
                table.remove(whitelist, i)
                RefreshDropdowns()
                return true
            end
        end
        return false
    end,
    IsWhitelisted = function(name)
        return table.find(whitelist, name) ~= nil
    end,
    
    -- Fonctions de config
    SaveConfig = SaveConfig,
    LoadConfig = LoadConfig,
    GetConfigs = GetConfigs,
    CollectConfig = CollectConfig,
    ApplyConfig = ApplyConfig,
    
    -- Variables
    SelectedConfigName = function() return SelectedConfigName end
}
end
