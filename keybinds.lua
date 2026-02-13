return function(KeybindTab, player, UserInputService, Library, Window)
-- ==================================================================================================== SYSTÈME DE KEYBIND ====================================================================================================

-- ============================================
-- VARIABLES POUR LES KEYBINDS
-- ============================================
local Keybinds = {}

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
    Callback = function()
        pcall(function()
            _G.speedEnabled = not _G.speedEnabled
            if _G.ToggleSpeed then _G.ToggleSpeed(_G.speedEnabled) end
            Library:Notify("Speed", _G.speedEnabled and "Activé" or "Désactivé", 2)
        end)
    end
})

Keybinds.Fly = KeybindTab:CreateKeybind({
    Name = "Fly Mode",
    Column = "Left",
    CurrentKey = Enum.KeyCode.X,
    Flag = true,
    Callback = function()
        pcall(function()
            _G.flyEnabled = not _G.flyEnabled
            if _G.ToggleFly then _G.ToggleFly(_G.flyEnabled) end
            Library:Notify("Fly", _G.flyEnabled and "Activé" or "Désactivé", 2)
        end)
    end
})

Keybinds.NoClip = KeybindTab:CreateKeybind({
    Name = "No Clip",
    Column = "Left",
    CurrentKey = Enum.KeyCode.B,
    Flag = true,
    Callback = function()
        pcall(function()
            _G.NoClipEnabled = not _G.NoClipEnabled
            Library:Notify("No Clip", _G.NoClipEnabled and "Activé" or "Désactivé", 2)
        end)
    end
})

Keybinds.Teleport = KeybindTab:CreateKeybind({
    Name = "Teleport to Mouse",
    Column = "Left",
    CurrentKey = Enum.KeyCode.T,
    Flag = true,
    Callback = function()
        pcall(function()
            _G.isTpEnabled = not _G.isTpEnabled
            Library:Notify("TP to Mouse", _G.isTpEnabled and "Activé" or "Désactivé", 2)
        end)
    end
})

-- ===== COMBAT KEYBINDS ===== --
KeybindTab:CreateSection("Combat")

Keybinds.FastAttack = KeybindTab:CreateKeybind({
    Name = "Fast Attack",
    Column = "Right",
    CurrentKey = Enum.KeyCode.C,
    Flag = true,
    Callback = function()
        pcall(function()
            _G.FastAttackEnabled = not _G.FastAttackEnabled
            if _G.toggleFastAttack then _G.toggleFastAttack(_G.FastAttackEnabled) end
            Library:Notify("Fast Attack", _G.FastAttackEnabled and "Activé" or "Désactivé", 2)
        end)
    end
})

Keybinds.Aimlock = KeybindTab:CreateKeybind({
    Name = "Aimlock",
    Column = "Right",
    CurrentKey = Enum.KeyCode.Q,
    Flag = true,
    Callback = function()
        pcall(function()
            _G.aimlockEnabled = not _G.aimlockEnabled
            Library:Notify("Aimlock", _G.aimlockEnabled and "Activé" or "Désactivé", 2)
        end)
    end
})

Keybinds.Mouselock = KeybindTab:CreateKeybind({
    Name = "Mouselock",
    Column = "Right",
    CurrentKey = Enum.KeyCode.E,
    Flag = true,
    Callback = function()
        pcall(function()
            _G.mouselockEnabled = not _G.mouselockEnabled
            Library:Notify("Mouselock", _G.mouselockEnabled and "Activé" or "Désactivé", 2)
        end)
    end
})

-- ===== MISC KEYBINDS ===== --
KeybindTab:CreateSection("Misc")

Keybinds.AutoEscape = KeybindTab:CreateKeybind({
    Name = "Auto Escape",
    Column = "Left",
    CurrentKey = Enum.KeyCode.F,
    Flag = true,
    Callback = function()
        pcall(function()
            _G.autoEscapeEnabled = not _G.autoEscapeEnabled
            Library:Notify("Auto Escape", _G.autoEscapeEnabled and "Activé" or "Désactivé", 2)
        end)
    end
})

Keybinds.Invisible = KeybindTab:CreateKeybind({
    Name = "Invisible",
    Column = "Left",
    CurrentKey = Enum.KeyCode.G,
    Flag = true,
    Callback = function()
        pcall(function()
            _G.InvisibleEnabled = not _G.InvisibleEnabled
            if _G.SetInvisible then _G.SetInvisible(_G.InvisibleEnabled) end
            Library:Notify("Invisible", _G.InvisibleEnabled and "Activé" or "Désactivé", 2)
        end)
    end
})

Keybinds.NPCBlocker = KeybindTab:CreateKeybind({
    Name = "NPC Blocker",
    Column = "Right",
    CurrentKey = Enum.KeyCode.N,
    Flag = true,
    Callback = function()
        pcall(function()
            _G.NPCBlockerEnabled = not _G.NPCBlockerEnabled
            if _G.SetNPCScriptsState then _G.SetNPCScriptsState(_G.NPCBlockerEnabled) end
            Library:Notify("NPC Blocker", _G.NPCBlockerEnabled and "Activé" or "Désactivé", 2)
        end)
    end
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
        -- Reset toutes les touches à Unknown
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

return {
    Keybinds = Keybinds,
    
    -- Fonctions utilitaires
    GetKeybind = function(name)
        return Keybinds[name]
    end,
    
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
