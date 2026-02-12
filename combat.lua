return function(CombatTab, player, Camera, Mouse, RunService, UserInputService, VirtualInputManager, ReplicatedStorage)
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

-- Bypass Private Server Owner
task.spawn(function()
    pcall(function()
        game:GetService("ReplicatedStorage").PrivateServerOwnerId.Value = player.UserId
    end)
end)

-- Variables globales pour whitelist
local whitelist = {}
local playerDropdown = nil
local whitelistDropdown = nil

-- Variables pour les jumps
local currentJumps = 0
local maxJumps = 10
local multiJumpEnabled = false
local humanoid = nil

-- Variables pour la taille
local sizeMultiplierEnabled = false
local originalSizes = {}
local sizeMultiplier = 10
local originalMaxZoomDistance = nil

-- Variables pour la taille d'arme
local weaponSizeEnabled = false
local weaponSizeMultiplier = 5
local originalWeaponSizes = {}
local weaponSizeConnection = nil

-- Variables SpeedHack
local speedEnabled = false
local speedValue = 16
local speedConnection = nil
local clickConnection = nil

-- Variables Fly
local flyEnabled = false
local flySpeed = 50
local flyConnection = nil

-- Variables Aimlock
local aimlockEnabled = false
local aimlockConnection = nil
local toggleEnabled = false
local smoothness = 0.2
local isLocked = false

-- Variables Mouselock
local mouselockEnabled = false
local mouselockConnection = nil
local mouselockToggleEnabled = false
local mouselockSmoothness = 0.2
local mouselockTargetPart = "UpperTorso"
local mouselockRadius = 150
local showCircle = false
local circleDrawing = nil

-- Variables Auto Escape
local autoEscapeEnabled = false
local healthThreshold = 40
local tpHeightIncrement = 500
local tpInterval = 0.1
local escapeDuration = 15
local isEscaping = false
local lastHealth = 100
local lastHealthCheckTime = tick()
local rapidDamageThreshold = 10

-- Variables Teleport
local isTpEnabled = false
local tpInputConnection = nil

-- Variables Desync
local desyncEnabled = false
local desyncConnection = nil
local frozenCFrame = nil

-- Variables NPC Blocker
local NPCBlockerEnabled = false
local scriptBackup = {}

-- Variables Anti Lava
local AntiLavaEnabled = false
local processed = {}

-- Variables Anti Water
local AntiWaterEnabled = false

-- Variables No Clip
local NoClipEnabled = false

-- Variables Invisible
local InvisibleEnabled = false
local savedTransparency = {}

-- Variables No Jump
local NoJumpEnabled = false

-- Variables Config
local SelectedConfigName = ""

-- Variables Fast Attack Logic
local FastAttackEnabled = false
local FastAttackConnection = nil
local FastAttackRange = 50000
local FastAttackIntensity = 10

-- Variables Dash Length
local DashEnabled = false
local DashConnection = nil
local DashLengthValue = 5

-- Variables Raid
local AutoRaidEnabled = false
local AutoBuyChip = false
local AutoStartRaid = false
local SelectedRaid = "Flame"
local RaidList = {"Flame", "Ice", "Quake", "Light", "Dark", "Spider", "Rumble", "Magma", "Buddha", "Sand", "Phoenix", "Dough"}

local function GetTargetForTrigger()
    local target = Mouse.Target
    if not target then return nil end
    
    -- Recherche récursive du joueur (gère les Accessoires, Tools, etc.)
    local current = target
    while current and current ~= workspace do
        local plr = Players:GetPlayerFromCharacter(current)
        if plr then
            if plr ~= player and not table.find(whitelist, plr.Name) then
                local char = current
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChild("Humanoid")
                if hrp and hum and hum.Health > 0 and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (player.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                    if dist <= TriggerBotDistance then
                        return plr
                    end
                end
            end
            return nil
        end
        current = current.Parent
    end
    return nil
end

RunService.RenderStepped:Connect(function()
    if not TriggerBotEnabled then return end
    if tick() - LastTriggerTime < TriggerBotDelay then return end
    
    local target = GetTargetForTrigger()
    if target then
        LastTriggerTime = tick()
        
        local k = string.lower(TriggerBotKey)
        if k == "mousebutton1" or k == "mb1" then
            VirtualInputManager:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true, game, 1)
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game, 1)
        elseif k == "mousebutton2" or k == "mb2" then
            VirtualInputManager:SendMouseButtonEvent(Mouse.X, Mouse.Y, 1, true, game, 1)
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(Mouse.X, Mouse.Y, 1, false, game, 1)
        else
            local key = nil
            pcall(function() key = Enum.KeyCode[TriggerBotKey] end)
            if not key then pcall(function() key = Enum.KeyCode[string.upper(TriggerBotKey)] end) end
            
            if key then
                VirtualInputManager:SendKeyEvent(true, key, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, key, false, game)
            end
        end
    end
end)

CombatTab:CreateSection({Name = "TriggerBot Settings", Column = "Left"})
CombatTab:CreateToggle({
    Name = "TriggerBot",
    Column = "Left",
    CurrentValue = false,
    Callback = function(Value) TriggerBotEnabled = Value end,
})

CombatTab:CreateSlider({
    Name = "Trigger Distance",
    Column = "Left",
    Min = 10, Max = 1000, Suffix = " studs", CurrentValue = 150,
    Callback = function(Value) TriggerBotDistance = Value end,
})

CombatTab:CreateInput({
    Name = "Trigger Key (ex: MouseButton1, Z)", PlaceholderText = "MouseButton1",
    Column = "Left",
    Callback = function(Text) TriggerBotKey = Text end,
})

local function GetClosestToMouse()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and not table.find(whitelist, plr.Name) and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local dist = (mousePos - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    closestPlayer = plr
                end
            end
        end
    end
    return closestPlayer
end

CombatTab:CreateSection({Name = "Aimlock Settings", Column = "Right"})
local AimlockSmoothnessSlider = CombatTab:CreateSlider({
    Name = "Aimlock Smoothness",
    Column = 'Rights',
    Min = 5,
    Max = 100,
    Suffix = "Speed",
    CurrentValue = 5,
    Callback = function(Value)
        smoothness = Value/100
    end,
})

local AimlockToggle = CombatTab:CreateToggle({
    Name = "Aimlock (Touche B)",
    Column = 'Rights',
    CurrentValue = false,
    Callback = function(Value)
        toggleEnabled = Value
    end,
})

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.B and toggleEnabled then
        aimlockEnabled = not aimlockEnabled
        if aimlockEnabled then
            isLocked = false
            aimlockConnection = RunService.RenderStepped:Connect(function()
                local target = GetClosestToMouse()
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    local targetPos = target.Character.HumanoidRootPart.Position
                    local lookCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
                    
                    if not isLocked then
                        Camera.CFrame = Camera.CFrame:Lerp(lookCFrame, smoothness)
                        local angle = math.acos(Camera.CFrame.LookVector:Dot((targetPos - Camera.CFrame.Position).Unit))
                        if angle < 0.01 then
                            isLocked = true
                        end
                    else
                        Camera.CFrame = lookCFrame
                    end
                end
            end)
        else
            isLocked = false
            if aimlockConnection then
                aimlockConnection:Disconnect()
                aimlockConnection = nil
            end
        end
    end
end)

-- MOUSELOCK
local function CreateCircle()
    if circleDrawing then
        circleDrawing:Remove()
    end
    
    circleDrawing = Drawing.new("Circle")
    circleDrawing.Thickness = 2
    circleDrawing.NumSides = 64
    circleDrawing.Radius = mouselockRadius
    circleDrawing.Color = Color3.fromRGB(255, 255, 255)
    circleDrawing.Transparency = 0.8
    circleDrawing.Visible = showCircle
    circleDrawing.Filled = false
    
    return circleDrawing
end

local function GetClosestToMouseForMouselock()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and not table.find(whitelist, plr.Name) and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local dist = (mousePos - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                if dist < mouselockRadius and dist < shortestDistance then
                    shortestDistance = dist
                    closestPlayer = plr
                end
            end
        end
    end
    return closestPlayer
end

CreateCircle()

RunService.RenderStepped:Connect(function()
    if circleDrawing then
        if showCircle then
            local mouseLocation = UserInputService:GetMouseLocation()
            circleDrawing.Position = mouseLocation
            circleDrawing.Radius = mouselockRadius
            circleDrawing.Visible = true
        else
            circleDrawing.Visible = false
        end
    end
end)

local ShowCircleToggle = CombatTab:CreateToggle({
    Name = "Show Circle",
    Column = 'Left',
    CurrentValue = false,
    Callback = function(Value)
        showCircle = Value
    end,
})

CombatTab:CreateSection({Name = "Mouselock Settings", Column = "Left"})
local MouselockRadiusSlider = CombatTab:CreateSlider({
    Name = "Mouselock Radius",
    Column = 'Left',
    Min = 50,
    Max = 300,
    Suffix = "px",
    CurrentValue = 150,
    Callback = function(Value)
        mouselockRadius = Value
    end,
})

CombatTab:CreateDropdown({
    Name = "Mouselock Target",
    Column = 'Left',
    Options = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"},
    CurrentOption = {"UpperTorso"},
    Callback = function(Option)
        mouselockTargetPart = Option[1]
    end,
})

local MouselockSmoothnessSlider = CombatTab:CreateSlider({
    Name = "Mouselock Smoothness",
    Column = 'Left',
    Min = 5,
    Max = 100,
    Suffix = "Speed",
    CurrentValue = 5,
    Callback = function(Value)
        mouselockSmoothness = Value/100
    end,
})

local MouseLockToggle = CombatTab:CreateToggle({
    Name = "Mouselock (Touche N)",
    Column = 'Left',
    CurrentValue = false,
    Callback = function(Value)
        mouselockToggleEnabled = Value
    end,
})

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.N and mouselockToggleEnabled then
        mouselockEnabled = not mouselockEnabled
        if mouselockEnabled then
            mouselockConnection = RunService.RenderStepped:Connect(function()
                local target = GetClosestToMouseForMouselock()
                if target and target.Character then
                    local targetPart = target.Character:FindFirstChild(mouselockTargetPart)
                    
                    if not targetPart then
                        targetPart = target.Character:FindFirstChild("HumanoidRootPart")
                    end
                    
                    if targetPart then
                        local screenPos = Camera:WorldToScreenPoint(targetPart.Position)
                        
                        if screenPos.Z > 0 then
                            local targetMousePos = Vector2.new(screenPos.X, screenPos.Y)
                            local currentMousePos = Vector2.new(Mouse.X, Mouse.Y)
                            local newMousePos = currentMousePos:Lerp(targetMousePos, mouselockSmoothness)
                            local deltaX = newMousePos.X - currentMousePos.X
                            local deltaY = newMousePos.Y - currentMousePos.Y
                            
                            mousemoverel(deltaX, deltaY)
                        end
                    end
                end
            end)
        else
            if mouselockConnection then
                mouselockConnection:Disconnect()
                mouselockConnection = nil
            end
        end
    end
end)

-- Hitbox Modifier - Track slider value changes
local CurrentHitboxValue = 300
local PreviousHitboxValue = 300  -- Value BEFORE slider change

local function UpdateHitboxConstant(newValue)
    print("[HITBOX] Hitbox range changé de " .. PreviousHitboxValue .. " à: " .. newValue)
    
    local gc = getgc(true) or getgc() or {}
    local patchedConst = 0
    local patchedUpval = 0
    local foundFunctions = 0
    
    -- Search for the PREVIOUS slider value and replace it with new value
    local searchValues = {PreviousHitboxValue}
    -- Also search nearby values (in case of rounding or caching)
    for i = PreviousHitboxValue - 5, PreviousHitboxValue + 5 do
        if i ~= PreviousHitboxValue and i >= 280 and i <= 2000 then
            table.insert(searchValues, i)
        end
    end
    
    for _, obj in ipairs(gc) do
        if type(obj) == "function" then
            foundFunctions = foundFunctions + 1
            
            -- Patcher les constantes embarquées
            local s1, constants = pcall(debug.getconstants, obj)
            if s1 and type(constants) == "table" then
                for i, v in ipairs(constants) do
                    if type(v) == "number" then
                        for _, targetVal in ipairs(searchValues) do
                            if v == targetVal then
                                pcall(debug.setconstant, obj, i, newValue)
                                patchedConst = patchedConst + 1
                                break
                            end
                        end
                    end
                end
            end
            
            -- Patcher les upvalues
            local s2, upvalues = pcall(debug.getupvalues, obj)
            if s2 and type(upvalues) == "table" then
                for i, uv in ipairs(upvalues) do
                    if type(uv) == "number" then
                        for _, targetVal in ipairs(searchValues) do
                            if uv == targetVal then
                                pcall(debug.setupvalue, obj, i, newValue)
                                patchedUpval = patchedUpval + 1
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    
    local totalPatched = patchedConst + patchedUpval
    
    if totalPatched > 0 then
        PreviousHitboxValue = newValue  -- Remember this as the new "previous" value
        CurrentHitboxValue = newValue
        print("[HITBOX] Patché " .. totalPatched .. " valeurs (const: " .. patchedConst .. " + upval: " .. patchedUpval .. ")!")
        Library:Notify("Succès", "Hitbox: " .. newValue .. " studs ✓ (" .. totalPatched .. " patches)", 3)
    else
        print("[HITBOX] Aucune valeur trouvée (searched: " .. table.concat(searchValues, ", ") .. ", fonctions: " .. foundFunctions .. ")")
        Library:Notify("Info", "Hitbox range: " .. newValue .. " studs (0 patches)", 2)
    end
end

CombatTab:CreateSection({Name = "Hitbox Max Range Modifier", Column = "Right"})
CombatTab:CreateSlider({
    Name = "Hitbox Range (Modify 300)",
    Column = 'Right',
    Min = 300,
    Max = 2000,
    Suffix = " studs",
    CurrentValue = 300,
    Callback = function(Value)
        UpdateHitboxConstant(Value)
    end,
})

-- Click Reach (Bypass)
local clickReachEnabled = false
local clickReachRange = 50

CombatTab:CreateToggle({
    Name = "Click Reach (Bypass)",
    Column = 'Right',
    CurrentValue = false,
    Callback = function(Value)
        clickReachEnabled = Value
        Library:Notify("Click Reach", Value and "Activé" or "Désactivé", 2)
    end,
})

CombatTab:CreateSlider({
    Name = "Click Reach Range",
    Column = 'Right',
    Min = 10,
    Max = 2000,
    Suffix = " studs",
    CurrentValue = 50,
    Callback = function(Value)
        clickReachRange = Value
    end,
})

UserInputService.InputBegan:Connect(function(input, gp)
    if gp or not clickReachEnabled or input.UserInputType ~= Enum.UserInputType.MouseButton1 then
        return
    end

    local myChar = player.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    local closestTarget = nil
    local minDistance = clickReachRange + 1

    local function findTargets(folder)
        if not folder then return end
        for _, p in pairs(folder:GetChildren()) do
            local targetChar = (folder == Players) and p.Character or p
            if targetChar and targetChar ~= myChar then
                local humanoid = targetChar:FindFirstChild("Humanoid")
                local hrp = targetChar:FindFirstChild("HumanoidRootPart")
                if humanoid and hrp and humanoid.Health > 0 then
                    local dist = (hrp.Position - myHRP.Position).Magnitude
                    if dist <= clickReachRange and dist < minDistance then
                        minDistance = dist
                        closestTarget = targetChar
                    end
                end
            end
        end
    end

    findTargets(Players)
    findTargets(workspace:FindFirstChild("Enemies"))

    if closestTarget then
        local hitData = {}
        local head = closestTarget:FindFirstChild("Head")
        if head then table.insert(hitData, {closestTarget, head}) end
        
        if #hitData > 0 then
            pcall(function()
                RegisterAttack:FireServer(0)
                RegisterHit:FireServer(hitData[1][2], hitData)
            end)
        end
    end
end)

-- Hit & Run Sequence [U]
local HitAndRunEnabled = false
local HitAndRunExecuting = false
local HitAndRunTargetPos = Vector3.new(938.3403930664062, 246.8402862548828, 32893.390625)

CombatTab:CreateSection({Name = "Hit & Run Sequence", Column = "Right"})

CombatTab:CreateToggle({
    Name = "Instant kill [U] (need aimlock for best results)",
    Column = 'Right',
    CurrentValue = false,
    Callback = function(Value)
        HitAndRunEnabled = Value
    end,
})

UserInputService.InputBegan:Connect(function(input, gp)
    if gp or not HitAndRunEnabled or HitAndRunExecuting then return end
    if input.KeyCode == Enum.KeyCode.U then
        HitAndRunExecuting = true
        
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then HitAndRunExecuting = false return end
        
        -- 1. Sauvegarde Position
        local originalCFrame = hrp.CFrame
        
        -- 2. Trouver joueur le plus proche
        local closestPlr = nil
        local minDst = math.huge
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and not table.find(whitelist, p.Name) and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                if dist < minDst then
                    minDst = dist
                    closestPlr = p
                end
            end
        end
        
        if closestPlr and closestPlr.Character then
            local targetHRP = closestPlr.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                -- TP sur le joueur + Camlock + Shiftlock sim
                local attackPos = targetHRP.CFrame * CFrame.new(0, 0, 3)
                hrp.CFrame = attackPos
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
                
                -- Stabilisation (Anti-Rollback)
                task.wait(0.15)
                hrp.CFrame = attackPos
                
                -- Camlock
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHRP.Position)
                
                -- Shiftlock (Orientation du perso vers la cible)
                hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(targetHRP.Position.X, hrp.Position.Y, targetHRP.Position.Z))
                
                -- Attack Z (Durée augmentée pour validation)
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Z, false, game)
                task.wait(0.15) -- Maintenir la touche Z appuyée plus longtemps
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Z, false, game)
                task.wait(0.2)
            end
        end
        
        -- 3. TP Safe
        hrp.CFrame = CFrame.new(HitAndRunTargetPos)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        
        HitAndRunExecuting = false
    end
end)

-- ================= FAST ATTACK CORE ================= --

local EnemiesFolder = workspace:WaitForChild("Enemies")

local function AttackMultipleTargets(targets)
    pcall(function()
        if not targets or #targets == 0 then return end
        local allTargets = {}
        for _, targetChar in pairs(targets) do
            local head = targetChar:FindFirstChild("Head")
            local torso = targetChar:FindFirstChild("Torso") or targetChar:FindFirstChild("UpperTorso")
            local hrp = targetChar:FindFirstChild("HumanoidRootPart")
            if head then table.insert(allTargets, {targetChar, head}) end
            if torso and torso ~= head then table.insert(allTargets, {targetChar, torso}) end
            if hrp and hrp ~= head and hrp ~= torso then table.insert(allTargets, {targetChar, hrp}) end
        end
        if #allTargets == 0 then return end
        for i = 1, FastAttackIntensity do
            RegisterAttack:FireServer(0)
            RegisterHit:FireServer(allTargets[1][2], allTargets)
        end
    end)
end

local function toggleFastAttack(value)
    FastAttackEnabled = value
    if FastAttackEnabled then
        FastAttackConnection = task.spawn(function()
            while FastAttackEnabled do
                task.wait(0.1)
                local myChar = player.Character
                local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if not myHRP then continue end
                local targetsInRange = {}
                local enemiesFolder = workspace:FindFirstChild("Enemies")
                if enemiesFolder then
                    for _, npc in pairs(enemiesFolder:GetChildren()) do
                        local humanoid = npc:FindFirstChild("Humanoid")
                        local hrp = npc:FindFirstChild("HumanoidRootPart")
                        if humanoid and hrp and humanoid.Health > 0 then
                            if (hrp.Position - myHRP.Position).Magnitude <= FastAttackRange then
                                table.insert(targetsInRange, npc)
                            end
                        end
                    end
                end
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= player and p.Character then
                        local humanoid = p.Character:FindFirstChild("Humanoid")
                        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                        if humanoid and hrp and humanoid.Health > 0 then
                            if (hrp.Position - myHRP.Position).Magnitude <= FastAttackRange then
                                table.insert(targetsInRange, p.Character)
                            end
                        end
                    end
                end
                if #targetsInRange > 0 then AttackMultipleTargets(targetsInRange) end
            end
        end)
    else
        if FastAttackConnection then task.cancel(FastAttackConnection); FastAttackConnection = nil end
    end
end

CombatTab:CreateSection({Name = "Fast Attack Settings", Column = "Right"})
CombatTab:CreateToggle({
    Name = "Fast Attack",
    Column = 'Right',
    CurrentValue = false,
    Callback = function(Value)
        toggleFastAttack(Value)
    end,
})

CombatTab:CreateSlider({
    Name = "Fast Attack Intensity",
    Column = 'Right',
    Min = 1,
    Max = 10,
    CurrentValue = 10,
    Callback = function(Value)
        FastAttackIntensity = Value
    end,
})


    return {
    TriggerBotEnabled = TriggerBotEnabled,
    TriggerBotDistance = TriggerBotDistance,
    TriggerBotKey = TriggerBotKey,
    TriggerBotDelay = TriggerBotDelay,
    
    aimlockEnabled = aimlockEnabled,
    toggleEnabled = toggleEnabled,
    smoothness = smoothness,
    
    mouselockEnabled = mouselockEnabled,
    mouselockToggleEnabled = mouselockToggleEnabled,
    mouselockSmoothness = mouselockSmoothness,
    mouselockRadius = mouselockRadius,
    mouselockTargetPart = mouselockTargetPart,
    showCircle = showCircle,
    
    CurrentHitboxValue = CurrentHitboxValue,
    clickReachEnabled = clickReachEnabled,
    clickReachRange = clickReachRange,
    
    HitAndRunEnabled = HitAndRunEnabled,
    HitAndRunTargetPos = HitAndRunTargetPos,
    
    FastAttackEnabled = FastAttackEnabled,
    FastAttackIntensity = FastAttackIntensity,
    FastAttackRange = FastAttackRange,
    
    ToggleFastAttack = toggleFastAttack  -- ✅ AJOUTEZ CETTE LIGNE
}
end
