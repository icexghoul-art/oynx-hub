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
        speedEnabled = not speedEnabled
        ToggleSpeed(speedEnabled)
        Library:Notify("Speed", speedEnabled and "Activé" or "Désactivé", 2)
    end
})

Keybinds.Fly = KeybindTab:CreateKeybind({
    Name = "Fly Mode",
    Column = "Left",
    CurrentKey = Enum.KeyCode.X,
    Flag = true,
    Callback = function()
        flyEnabled = not flyEnabled
        ToggleFly(flyEnabled)
        Library:Notify("Fly", flyEnabled and "Activé" or "Désactivé", 2)
    end
})

Keybinds.NoClip = KeybindTab:CreateKeybind({
    Name = "No Clip",
    Column = "Left",
    CurrentKey = Enum.KeyCode.B,
    Flag = true,
    Callback = function()
        NoClipEnabled = not NoClipEnabled
        Library:Notify("No Clip", NoClipEnabled and "Activé" or "Désactivé", 2)
    end
})

Keybinds.Teleport = KeybindTab:CreateKeybind({
    Name = "Teleport to Mouse",
    Column = "Left",
    CurrentKey = Enum.KeyCode.T,
    Flag = true,
    Callback = function()
        isTpEnabled = not isTpEnabled
        Library:Notify("TP to Mouse", isTpEnabled and "Activé" or "Désactivé", 2)
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
        FastAttackEnabled = not FastAttackEnabled
        toggleFastAttack(FastAttackEnabled)
        Library:Notify("Fast Attack", FastAttackEnabled and "Activé" or "Désactivé", 2)
    end
})

Keybinds.Aimlock = KeybindTab:CreateKeybind({
    Name = "Aimlock",
    Column = "Right",
    CurrentKey = Enum.KeyCode.Q,
    Flag = true,
    Callback = function()
        aimlockEnabled = not aimlockEnabled
        Library:Notify("Aimlock", aimlockEnabled and "Activé" or "Désactivé", 2)
    end
})

Keybinds.Mouselock = KeybindTab:CreateKeybind({
    Name = "Mouselock",
    Column = "Right",
    CurrentKey = Enum.KeyCode.E,
    Flag = true,
    Callback = function()
        mouselockEnabled = not mouselockEnabled
        Library:Notify("Mouselock", mouselockEnabled and "Activé" or "Désactivé", 2)
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
        autoEscapeEnabled = not autoEscapeEnabled
        Library:Notify("Auto Escape", autoEscapeEnabled and "Activé" or "Désactivé", 2)
    end
})

Keybinds.Invisible = KeybindTab:CreateKeybind({
    Name = "Invisible",
    Column = "Left",
    CurrentKey = Enum.KeyCode.G,
    Flag = true,
    Callback = function()
        InvisibleEnabled = not InvisibleEnabled
        SetInvisible(InvisibleEnabled)
        Library:Notify("Invisible", InvisibleEnabled and "Activé" or "Désactivé", 2)
    end
})

Keybinds.NPCBlocker = KeybindTab:CreateKeybind({
    Name = "NPC Blocker",
    Column = "Right",
    CurrentKey = Enum.KeyCode.N,
    Flag = true,
    Callback = function()
        NPCBlockerEnabled = not NPCBlockerEnabled
        SetNPCScriptsState(NPCBlockerEnabled)
        Library:Notify("NPC Blocker", NPCBlockerEnabled and "Activé" or "Désactivé", 2)
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
