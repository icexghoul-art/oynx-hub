return function(WorldTab, player, RunService, UserInputService, ReplicatedStorage)

local Library = loadstring(game:HttpGet("https://pastebin.com/raw/YHaPCpCr"))()
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Mouse = player:GetMouse()
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")

-- Variables Fast Attack (Boosted)
local Net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
local RegisterHit = Net:WaitForChild("RE/RegisterHit")
local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local Modules = ReplicatedStorage:FindFirstChild("Modules")
local Net = Modules and Modules:FindFirstChild("Net")
local RegisterHit = Net and Net:FindFirstChild("RE/RegisterHit")
local RegisterAttack = Net and Net:FindFirstChild("RE/RegisterAttack")

    local npcBlockerEnabled = false
    local antiLavaEnabled = false
    local antiFogEnabled = false
    local serverHopEnabled = false
    local noclipEnabled = false
    local noclipConnection = nil

    -- NPC Blocker
local TARGET_SCRIPTS = {
    NPC = true,
    NPCStreaming = true
}

local function SetNPCScriptsState(state)
    local ps = player:WaitForChild("PlayerScripts")

    for _, obj in ipairs(ps:GetChildren()) do
        if obj:IsA("LocalScript") and TARGET_SCRIPTS[obj.Name] then
            if not scriptBackup[obj] then
                scriptBackup[obj] = obj.Disabled
            end
            pcall(function()
                obj.Disabled = state
            end)
        end
    end
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.B then
        NPCBlockerEnabled = not NPCBlockerEnabled

        if NPCBlockerEnabled then
            SetNPCScriptsState(true)
        else
            SetNPCScriptsState(false)
        end
    end
end)

WorldTab:CreateSection({Name = "NPC Blocker Settings", Column = "Left"})
local NPCBlockerToggle = WorldTab:CreateToggle({
    Name = "NPC Blocker (Real) [B]",
    Column = 'Left',
    CurrentValue = false,
    Callback = function(Value)
        NPCBlockerEnabled = Value
        SetNPCScriptsState(Value)
    end,
})

WorldTab:CreateSection({Name = "Fog Settings", Column = "Left"})
WorldTab:CreateToggle({
    Name = "Anti Fog",
    Column = 'Left',
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            Lighting.FogStart = 100000
            Lighting.FogEnd = 100000
        else
            Lighting.FogStart = 0
            Lighting.FogEnd = 100
        end
    end,
})

WorldTab:CreateSection({Name = "Server Management", Column = "Right"})
WorldTab:CreateButton({
    Name = "Server Hop (Changer de serveur)",
    Column = 'Right',
    Callback = function()
        local Http = game:GetService("HttpService")
        local TPS = game:GetService("TeleportService")
        local Api = "https://games.roblox.com/v1/games/"
        local _place = game.PlaceId
        local _servers = Api.._place.."/servers/Public?sortOrder=Asc&limit=100"
        
        local function ListServers(cursor)
            local Raw = game:HttpGet(_servers .. ((cursor and "&cursor="..cursor) or ""))
            return Http:JSONDecode(Raw)
        end
        
        local Server, Next; repeat
            local Servers = ListServers(Next)
            for _, v in ipairs(Servers.data) do
                if v.playing < v.maxPlayers and v.id ~= game.JobId then
                    Server = v
                    break
                end
            end
            Next = Servers.nextPageCursor
        until Server
        
        if Server then
            TPS:TeleportToPlaceInstance(_place, Server.id, player)
        else
            Library:Notify("Server Hop", "Aucun serveur trouvé", 3)
        end
    end,
})

local TargetJoinUser = ""
WorldTab:CreateInput({
    Name = "Rejoindre un joueur (Pseudo)",
    Column = 'Right',
    PlaceholderText = "Pseudo du joueur",
    Callback = function(text)
        TargetJoinUser = text
    end,
})

WorldTab:CreateButton({
    Name = "Rejoindre le serveur du joueur",
    Column = 'Right',
    Callback = function()
        if TargetJoinUser == "" then 
            Library:Notify("Erreur", "Pseudo vide", 3)
            return 
        end
        
        Library:Notify("Système", "Recherche du joueur...", 2)
        local success, userId = pcall(function() return Players:GetUserIdFromNameAsync(TargetJoinUser) end)
        if not success or not userId then Library:Notify("Erreur", "Joueur introuvable", 3) return end
        
        local TPS = game:GetService("TeleportService")
        local s, err = pcall(function()
            local placeId, jobId = TPS:GetPlayerPlaceInstanceAsync(userId)
            if placeId and jobId then TPS:TeleportToPlaceInstance(placeId, jobId, player)
            else Library:Notify("Erreur", "Serveur introuvable (Privé/Offline)", 3) end
        end)
        if not s then Library:Notify("Erreur", "Impossible de rejoindre", 3) end
    end,
})

WorldTab:CreateSection({Name = "Server Mode", Column = "Right"})
WorldTab:CreateDropdown({
    Name = "Set Server Mode",
    Column = 'Right',
    Options = {"Default", "Passive", "Friendly"},
    CurrentOption = {"Default"},
    Callback = function(Option)
        if Option[1] then
            pcall(function()
                game:GetService("ReplicatedStorage").ServerMode.Value = Option[1]
            end)
        end
    end,
})
    return {
        NPCBlockerEnabled = NPCBlockerEnabled,
        antiLavaEnabled = antiLavaEnabled,
        antiFogEnabled = antiFogEnabled,
        noclipEnabled = noclipEnabled,
        TargetJoinUser = TargetJoinUser,
        SetNPCScriptsState = SetNPCScriptsState,
        ServerHop = serverHopFunction,
        Rejoin = rejoinFunction
    }
end
