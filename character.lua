return function(CharacterTab, player, RunService, UserInputService)

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

local function SetWeaponSize(multiplier)
    local character = player.Character
    if not character then return end
    
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            local handle = tool:FindFirstChild("Handle")
            if handle and handle:IsA("BasePart") then
                local compensationMultiplier = multiplier
                if sizeMultiplierEnabled then
                    compensationMultiplier = multiplier * sizeMultiplier
                end
                
                if not originalWeaponSizes[tool.Name] then
                    originalWeaponSizes[tool.Name] = {}
                    originalWeaponSizes[tool.Name].HandleSize = handle.Size
                end
                
                handle.Size = originalWeaponSizes[tool.Name].HandleSize * compensationMultiplier
                handle.CanCollide = false
                handle.Massless = true
                handle.Transparency = 0.5
            end
            
            for _, part in pairs(tool:GetDescendants()) do
                if part:IsA("BasePart") and part ~= handle then
                    local compensationMultiplier = multiplier
                    if sizeMultiplierEnabled then
                        compensationMultiplier = multiplier * sizeMultiplier
                    end
                    
                    if not originalWeaponSizes[tool.Name][part.Name] then
                        originalWeaponSizes[tool.Name][part.Name] = part.Size
                    end
                    part.Size = originalWeaponSizes[tool.Name][part.Name] * compensationMultiplier
                    part.CanCollide = false
                    part.Massless = true
                    part.Transparency = 0.5
                    
                elseif part:IsA("Attachment") then
                    local compensationMultiplier = multiplier
                    if sizeMultiplierEnabled then
                        compensationMultiplier = multiplier * sizeMultiplier
                    end
                    
                    if not originalWeaponSizes[tool.Name][part.Name .. "_Pos"] then
                        originalWeaponSizes[tool.Name][part.Name .. "_Pos"] = part.Position
                    end
                    part.Position = originalWeaponSizes[tool.Name][part.Name .. "_Pos"] * compensationMultiplier
                    
                elseif part:IsA("SpecialMesh") then
                    local compensationMultiplier = multiplier
                    if sizeMultiplierEnabled then
                        compensationMultiplier = multiplier * sizeMultiplier
                    end
                    
                    if not originalWeaponSizes[tool.Name][part.Name .. "_Scale"] then
                        originalWeaponSizes[tool.Name][part.Name .. "_Scale"] = part.Scale
                    end
                    part.Scale = originalWeaponSizes[tool.Name][part.Name .. "_Scale"] * compensationMultiplier
                end
            end
        end
    end
end

local function WatchForNewTools()
    local character = player.Character
    if not character then return end
    
    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and weaponSizeEnabled then
            task.wait(0.2)
            SetWeaponSize(weaponSizeMultiplier)
        end
    end)
    
    player.Backpack.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and weaponSizeEnabled then
            task.wait(0.2)
            SetWeaponSize(weaponSizeMultiplier)
        end
    end)
end

WatchForNewTools()

player.CharacterAdded:Connect(function(character)
    originalWeaponSizes = {}
    task.wait(1)
    WatchForNewTools()
    if weaponSizeEnabled then
        SetWeaponSize(weaponSizeMultiplier)
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if weaponSizeEnabled then
            SetWeaponSize(weaponSizeMultiplier)
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if weaponSizeEnabled then
        local character = player.Character
        if character then
            for _, tool in pairs(character:GetChildren()) do
                if tool:IsA("Tool") then
                    local handle = tool:FindFirstChild("Handle")
                    if handle and handle:IsA("BasePart") then
                        local compensationMultiplier = weaponSizeMultiplier
                        if sizeMultiplierEnabled then
                            compensationMultiplier = weaponSizeMultiplier * sizeMultiplier
                        end
                        
                        if originalWeaponSizes[tool.Name] and originalWeaponSizes[tool.Name].HandleSize then
                            handle.Size = originalWeaponSizes[tool.Name].HandleSize * compensationMultiplier
                            handle.CanCollide = false
                        end
                    end
                end
            end
        end
    end
end)

CharacterTab:CreateSection({Name = "Weapon Multiplier Setting", Column = "Right"})
local WeaponSizeSlider = CharacterTab:CreateSlider({
    Name = "Weapon Size Multiplier",
    Column = "Right",
    Min = 1,
    Max = 50,
    Suffix = "x",
    CurrentValue = 5,
    Callback = function(Value)
        weaponSizeMultiplier = Value
        if weaponSizeEnabled then
            SetWeaponSize(weaponSizeMultiplier)
        end
    end,
})

local WeaponSizeToggle = CharacterTab:CreateToggle({
    Name = "Enable Weapon Size",
    Column = "Right",
    CurrentValue = false,
    Flag = "WeaponSizeToggle",
    Callback = function(Value)
        weaponSizeEnabled = Value
        
        if Value then
            SetWeaponSize(weaponSizeMultiplier)
        else
            SetWeaponSize(1)
            originalWeaponSizes = {}
        end
    end,
})

local function SetCharacterSize(multiplier)
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end
    
    if not originalSizes[character] then
        originalSizes[character] = {
            parts = {},
            motor6d = {},
            attachments = {},
            rootPartSize = rootPart.Size,
            hipHeight = humanoid.HipHeight
        }
        
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                originalSizes[character].parts[part] = part.Size
            elseif part:IsA("Motor6D") then
                originalSizes[character].motor6d[part] = {
                    C0 = part.C0,
                    C1 = part.C1
                }
            elseif part:IsA("Attachment") then
                originalSizes[character].attachments[part] = part.Position
            end
        end
    end
    
    if humanoid:FindFirstChild("BodyDepthScale") then
        humanoid.BodyDepthScale.Value = multiplier
    else
        local bodyDepth = Instance.new("NumberValue")
        bodyDepth.Name = "BodyDepthScale"
        bodyDepth.Value = multiplier
        bodyDepth.Parent = humanoid
    end
    
    if humanoid:FindFirstChild("BodyWidthScale") then
        humanoid.BodyWidthScale.Value = multiplier
    else
        local bodyWidth = Instance.new("NumberValue")
        bodyWidth.Name = "BodyWidthScale"
        bodyWidth.Value = multiplier
        bodyWidth.Parent = humanoid
    end
    
    if humanoid:FindFirstChild("BodyHeightScale") then
        humanoid.BodyHeightScale.Value = multiplier
    else
        local bodyHeight = Instance.new("NumberValue")
        bodyHeight.Name = "BodyHeightScale"
        bodyHeight.Value = multiplier
        bodyHeight.Parent = humanoid
    end
    
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            local originalSize = originalSizes[character].parts[part]
            if originalSize then
                pcall(function()
                    part:SetNetworkOwner(player)
                end)
                part.Size = originalSize * multiplier
            end
        end
    end
    
    pcall(function()
        rootPart:SetNetworkOwner(player)
    end)
    rootPart.Size = originalSizes[character].rootPartSize * multiplier
    
    if not originalSizes[character].lastMultiplier then
        originalSizes[character].lastMultiplier = 1
    end
    
    humanoid.HipHeight = originalSizes[character].hipHeight * multiplier / originalSizes[character].lastMultiplier
    originalSizes[character].lastMultiplier = multiplier
    
    if multiplier > 1 then
        if not originalMaxZoomDistance then
            originalMaxZoomDistance = player.CameraMaxZoomDistance
        end
        player.CameraMaxZoomDistance = originalMaxZoomDistance * multiplier
    else
        if originalMaxZoomDistance then
            player.CameraMaxZoomDistance = originalMaxZoomDistance
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if sizeMultiplierEnabled then
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    if humanoid:FindFirstChild("BodyDepthScale") then
                        humanoid.BodyDepthScale.Value = sizeMultiplier
                    end
                    if humanoid:FindFirstChild("BodyWidthScale") then
                        humanoid.BodyWidthScale.Value = sizeMultiplier
                    end
                    if humanoid:FindFirstChild("BodyHeightScale") then
                        humanoid.BodyHeightScale.Value = sizeMultiplier
                    end
                end
            end
        end
    end
end)

CharacterTab:CreateSection({Name = "Size Multiplier Setting", Column = "Right"})
local SizeSlider = CharacterTab:CreateSlider({
    Name = "Size Multiplier",
    Column = "Right",
    Min = 1,
    Max = 30,
    Suffix = "x",
    CurrentValue = 10,
    Callback = function(Value)
        sizeMultiplier = Value
        if sizeMultiplierEnabled then
            SetCharacterSize(sizeMultiplier)
        end
    end,
})

local SizeToggle = CharacterTab:CreateToggle({
    Name = "Enable Size Multiplier",
    Column = "Right",
    CurrentValue = false,
    Flag = "SizeMultiplier",
    Callback = function(Value)
        sizeMultiplierEnabled = Value
        
        if Value then
            SetCharacterSize(sizeMultiplier)
        else
            SetCharacterSize(1)
        end
    end,
})

player.CharacterAdded:Connect(function(character)
    originalSizes[character] = nil
    task.wait(0.5)
    if sizeMultiplierEnabled then
        SetCharacterSize(sizeMultiplier)
    end
end)

local function EscapeToSky()
    if isEscaping then return end
    isEscaping = true
    
    local startTime = tick()
    
    task.spawn(function()
        while isEscaping and (tick() - startTime) < escapeDuration do
            local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            
            if rootPart then
                local currentPos = rootPart.Position
                local newPosition = Vector3.new(
                    currentPos.X,
                    currentPos.Y + tpHeightIncrement,
                    currentPos.Z
                )
                
                rootPart.CFrame = CFrame.new(newPosition)
            end
            
            task.wait(tpInterval)
        end
        
        isEscaping = false
    end)
end

RunService.Heartbeat:Connect(function()
    if not autoEscapeEnabled then return end
    
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        
        if humanoid and humanoid.Health > 0 then
            local currentHealthPercent = (humanoid.Health / humanoid.MaxHealth) * 100
            local currentTime = tick()
            local timeDiff = currentTime - lastHealthCheckTime
            
            local healthLoss = lastHealth - currentHealthPercent
            
            if currentHealthPercent < healthThreshold and not isEscaping then
                EscapeToSky()
            end
            
            if not isEscaping and currentHealthPercent < healthThreshold then
                if timeDiff <= 2 and healthLoss >= rapidDamageThreshold then
                    EscapeToSky()
                    lastHealthCheckTime = currentTime
                    lastHealth = currentHealthPercent
                end
            end
            
            if timeDiff >= 2 then
                lastHealth = currentHealthPercent
                lastHealthCheckTime = currentTime
            end
        end
    end
end)

CharacterTab:CreateSection({Name = "Auto Escape Settings", Column = "Left"})
local AutoEscapeHPSlider = CharacterTab:CreateSlider({
    Name = "Auto Escape HP %",
    Column = "Left",
    Min = 10,
    Max = 80,
    Suffix = "%",
    CurrentValue = 40,
    Callback = function(Value)
        healthThreshold = Value
    end,
})

CharacterTab:CreateSlider({
    Name = "Rapid Damage Threshold",
    Column = "Left",
    Min = 5,
    Max = 30,
    Suffix = "%",
    CurrentValue = 10,
    Callback = function(Value)
        rapidDamageThreshold = Value
    end,
})

local TPHeightSlider = CharacterTab:CreateSlider({
    Name = "TP Height Increment",
    Column = "Left",
    Min = 50,
    Max = 1000,
    Suffix = "studs",
    CurrentValue = 500,
    Callback = function(Value)
        tpHeightIncrement = Value
    end,
})

local TPIntervalSlider = CharacterTab:CreateSlider({
    Name = "TP Interval",
    Column = "Left",
    Min = 0.05,
    Max = 0.5,
    Suffix = "sec",
    CurrentValue = 0.1,
    Callback = function(Value)
        tpInterval = Value
    end,
})

local EscapeDurationSlider = CharacterTab:CreateSlider({
    Name = "Escape Duration",
    Column = "Left",
    Min = 5,
    Max = 30,
    Suffix = "sec",
    CurrentValue = 15,
    Callback = function(Value)
        escapeDuration = Value
    end,
})

local AutoEscapeToggle = CharacterTab:CreateToggle({
    Name = "Auto Escape (Low HP)",
    Column = "Left",
    CurrentValue = false,
    Callback = function(Value)
        autoEscapeEnabled = Value
        if Value then
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    lastHealth = (humanoid.Health / humanoid.MaxHealth) * 100
                    lastHealthCheckTime = tick()
                end
            end
        else
            isEscaping = false
        end
    end,
})

local AntiLavaConnection = nil

local function SetAntiLava(state)
    AntiLavaEnabled = state
    
    -- Fix spécifique pour Circle Island (LavaParts)
    pcall(function()
        local lavaParts = game:GetService("Workspace").Map.CircleIsland.LavaParts
        local hauntedLavaParts = game:GetService("Workspace").Map.GhostShipInterior.LavaParts
        if lavaParts then
            for _, part in pairs(lavaParts:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanTouch = not state
                end
            end
        end
        if hauntedLavaParts then
            for _, part in pairs(hauntedLavaParts:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanTouch = not state
                end
            end
        end
    end)

    if state then
        for _, v in pairs(workspace:GetDescendants()) do
            ProcessLava(v)
        end
        if AntiLavaConnection then AntiLavaConnection:Disconnect() end
        AntiLavaConnection = workspace.DescendantAdded:Connect(ProcessLava)
    else
        if AntiLavaConnection then 
            AntiLavaConnection:Disconnect() 
            AntiLavaConnection = nil 
        end
    end
end

CharacterTab:CreateSection({Name = "Anti Lava / Haunted Settings", Column = "Right"})
local AntiLavaToggle = CharacterTab:CreateToggle({
    Name = "Anti Lava / Haunted (0 Damage)",
    Column = 'Right',
    CurrentValue = false,
    Callback = function(Value)
        AntiLavaEnabled = Value
        SetAntiLava(Value)
    end,
})

RunService.Stepped:Connect(function()
    if not AntiWaterEnabled then return end

    local char = player.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    if hum:GetState() == Enum.HumanoidStateType.Swimming then
        hrp.CFrame = hrp.CFrame + Vector3.new(0, 6, 0)
        hrp.Velocity = Vector3.new(0, 60, 0)
    end
end)

CharacterTab:CreateSection({Name = "Anti Water Damage Settings", Column = "Right"})
local AntiWaterToggle = CharacterTab:CreateToggle({
    Name = "Anti Water Damage",
    Column = 'Right',
    CurrentValue = false,
    Callback = function(Value)
        AntiWaterEnabled = Value
    end,
})

RunService.Stepped:Connect(function()
    if not NoClipEnabled then return end

    local char = player.Character
    if not char then return end

    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end
end)

CharacterTab:CreateSection({Name = "No Clip Settings", Column = "Right"})
local NoClipToggle = CharacterTab:CreateToggle({
    Name = "No Clip",
    Column = 'Right',
    CurrentValue = false,
    Callback = function(Value)
        NoClipEnabled = Value
    end,
})

local function SetInvisible(state)
    local char = player.Character
    if not char then return end

    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Decal") then
            if state then
                savedTransparency[obj] = obj.Transparency
                obj.Transparency = 1
            else
                if savedTransparency[obj] ~= nil then
                    obj.Transparency = savedTransparency[obj]
                end
            end
        end
    end
end

CharacterTab:CreateSection({Name = "Invisible Settings", Column = "Right"})
local InvisibleToggle = CharacterTab:CreateToggle({
    Name = "Invisible",
    Column = 'Right',
    CurrentValue = false,
    Callback = function(Value)
        InvisibleEnabled = Value
        SetInvisible(Value)
    end,
})

    return {
        weaponSizeEnabled = weaponSizeEnabled,
        sizeMultiplierEnabled = sizeMultiplierEnabled,
        autoEscapeEnabled = autoEscapeEnabled,
        antiLavaEnabled = AntiLavaEnabled,
        antiWaterEnabled = AntiWaterEnabled,
        noClipEnabled = NoClipEnabled,
        invisibleEnabled = InvisibleEnabled
    }
end
