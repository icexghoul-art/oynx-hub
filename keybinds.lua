return function(KeybindTab, player, UserInputService, Library, Window)
-- ==================================================================================================== SYSTÈME DE KEYBIND ====================================================================================================

-- ============================================
-- VARIABLES POUR LES KEYBINDS
-- ============================================
local Keybinds = {}

-- Table pour stocker les références aux toggles UI
_G.OYNX_Toggles = _G.OYNX_Toggles or {}

-- Système de callbacks qui utilise les toggles UI directement
local function CreateKeybindToggle(displayName, toggleKey)
    return function()
        local toggle = _G.OYNX_Toggles[toggleKey]
        
        if toggle then
            -- Récupérer la valeur actuelle
            local currentValue = toggle.CurrentValue or false
            local newValue = not currentValue
            
            -- Mettre à jour la valeur du toggle
            toggle.CurrentValue = newValue
            
            -- Appeler le callback original du toggle pour exécuter la logique
            if toggle.Callback and type(toggle.Callback) == "function" then
                local success, err = pcall(function()
                    toggle.Callback(newValue)
                end)
                
                if not success then
                    warn("[Keybind] Erreur callback " .. toggleKey .. ": " .. tostring(err))
                end
            end
            
            -- Mettre à jour l'UI du toggle si possible
            if toggle.Set and type(toggle.Set) == "function" then
                pcall(function()
                    toggle:Set(newValue)
                end)
            end
            
            -- Notification
            Library:Notify(displayName, newValue and "Activé" or "Désactivé", 2)
        else
            Library:Notify("Erreur", displayName .. " non disponible", 2)
            print("[Keybind Debug] Toggle non trouvé: " .. toggleKey)
            print("[Keybind Debug] Toggles disponibles:")
            for k, v in pairs(_G.OYNX_Toggles) do
                print("  - " .. k)
            end
        end
    end
end

-- ============================================
-- LABELS ET SECTIONS
-- ============================================
KeybindTab:CreateLabel({
    Text = "Configuration des raccourcis clavier",
    TextSize = 15,
    Color = Color3.fromRGB(130, 90, 255),
    Glow = true,
    Column = 'Left'
})

-- ===== MOVEMENT KEYBINDS ===== --
KeybindTab:CreateSection("Movement")

Keybinds.Speed = KeybindTab:CreateKeybind({
    Name = "Speed Hack",
    Column = "Left",
    CurrentKey = Enum.KeyCode.V,
    Flag = true,
    Callback = CreateKeybindToggle("Speed", "SpeedToggle")
})

Keybinds.Fly = KeybindTab:CreateKeybind({
    Name = "Fly Mode",
    Column = "Left",
    CurrentKey = Enum.KeyCode.X,
    Flag = true,
    Callback = CreateKeybindToggle("Fly", "FlyToggle")
})

Keybinds.NoClip = KeybindTab:CreateKeybind({
    Name = "No Clip",
    Column = "Left",
    CurrentKey = Enum.KeyCode.B,
    Flag = true,
    Callback = CreateKeybindToggle("No Clip", "NoClipToggle")
})

Keybinds.Teleport = KeybindTab:CreateKeybind({
    Name = "Teleport to Mouse",
    Column = "Left",
    CurrentKey = Enum.KeyCode.T,
    Flag = true,
    Callback = CreateKeybindToggle("TP to Mouse", "TpMouseToggle")
})

-- ===== COMBAT KEYBINDS ===== --
KeybindTab:CreateSection("Combat")

Keybinds.FastAttack = KeybindTab:CreateKeybind({
    Name = "Fast Attack",
    Column = "Right",
    CurrentKey = Enum.KeyCode.C,
    Flag = true,
    Callback = CreateKeybindToggle("Fast Attack", "FastAttackToggle")
})

Keybinds.Aimlock = KeybindTab:CreateKeybind({
    Name = "Aimlock",
    Column = "Right",
    CurrentKey = Enum.KeyCode.Q,
    Flag = true,
    Callback = CreateKeybindToggle("Aimlock", "AimlockToggle")
})

Keybinds.Mouselock = KeybindTab:CreateKeybind({
    Name = "Mouselock",
    Column = "Right",
    CurrentKey = Enum.KeyCode.E,
    Flag = true,
    Callback = CreateKeybindToggle("Mouselock", "MouselockToggle")
})

-- ===== MISC KEYBINDS ===== --
KeybindTab:CreateSection("Misc")

Keybinds.AutoEscape = KeybindTab:CreateKeybind({
    Name = "Auto Escape",
    Column = "Left",
    CurrentKey = Enum.KeyCode.F,
    Flag = true,
    Callback = CreateKeybindToggle("Auto Escape", "AutoEscapeToggle")
})

Keybinds.Invisible = KeybindTab:CreateKeybind({
    Name = "Invisible",
    Column = "Left",
    CurrentKey = Enum.KeyCode.G,
    Flag = true,
    Callback = CreateKeybindToggle("Invisible", "InvisibleToggle")
})

Keybinds.NPCBlocker = KeybindTab:CreateKeybind({
    Name = "NPC Blocker",
    Column = "Right",
    CurrentKey = Enum.KeyCode.N,
    Flag = true,
    Callback = CreateKeybindToggle("NPC Blocker", "NPCBlockerToggle")
})

-- ============================================
-- INDICATEUR VISUEL DES KEYBINDS ACTIFS
-- ============================================
KeybindTab:CreateLabel({
    Text = "Indicateur de statut",
    TextSize = 15,
    Color = Color3.fromRGB(130, 90, 255),
    Glow = true,
    Column = 'Left'
})

KeybindTab:CreateLabel({
    Text = "Les fonctions actives s'affichent dans les notifications",
    TextSize = 12,
    Color = Color3.fromRGB(130, 90, 255),
    Column = 'Left'
})

-- ============================================
-- BOUTONS UTILITAIRES POUR KEYBINDS
-- ============================================
KeybindTab:CreateButton({
    Name = "🔄 Reset tous les Keybinds",
    Column = "Left",
    Callback = function()
        for name, keybind in pairs(Keybinds) do
            if keybind and keybind.SetKey then
                keybind.SetKey(Enum.KeyCode.Unknown)
            end
        end
        Library:Notify("Keybinds", "Tous les keybinds ont été réinitialisés", 3)
    end
})

KeybindTab:CreateButton({
    Name = "📋 Afficher les Keybinds (Console)",
    Column = "Right",
    Callback = function()
        print("=== KEYBINDS ACTIFS ===")
        for name, keybind in pairs(Keybinds) do
            if keybind and keybind.GetKey then
                local key = keybind.GetKey()
                local keyName = tostring(key):match("Enum%.KeyCode%.(.+)") or "None"
                print(name .. ": " .. keyName)
            end
        end
        print("========================")
    end
})

KeybindTab:CreateButton({
    Name = "🔍 Debug - Liste des Toggles",
    Column = "Right",
    Callback = function()
        print("=== TOGGLES ENREGISTRÉS ===")
        for key, toggle in pairs(_G.OYNX_Toggles) do
            local value = toggle.CurrentValue or false
            print(key .. ": " .. tostring(value))
        end
        print("===========================")
    end
})

return {
    Keybinds = Keybinds,
    GetKeybind = function(name) return Keybinds[name] end,
    SetKeybind = function(name, keyCode)
        if Keybinds[name] and Keybinds[name].SetKey then
            Keybinds[name].SetKey(keyCode)
        end
    end,
    GetAllKeybinds = function()
        local result = {}
        for name, keybind in pairs(Keybinds) do
            if keybind and keybind.GetKey then
                result[name] = keybind.GetKey()
            end
        end
        return result
    end,
    ResetAllKeybinds = function()
        for name, keybind in pairs(Keybinds) do
            if keybind and keybind.SetKey then
                keybind.SetKey(Enum.KeyCode.Unknown)
            end
        end
    end
}
end
