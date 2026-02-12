return function(MovementTab, CharacterTab, player, Camera, Mouse, RunService, UserInputService, Debris, VirtualInputManager)

-- Variables pour les jumps
local currentJumps = 0
local maxJumps = 10
local multiJumpEnabled = false
local humanoid = nil

-- Variables SpeedHack
local speedEnabled = false
local speedValue = 16
local speedConnection = nil
local clickConnection = nil

-- Variables Fly
local flyEnabled = false
local flySpeed = 50
local flyConnection = nil

-- Variables Teleport
local isTpEnabled = false
local tpInputConnection = nil

-- Variables Dash Length
local DashEnabled = false
local DashConnection = nil
local DashLengthValue = 5

local DISTANCE = 2500

local function NoJump()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame = hrp.CFrame - Vector3.new(0, DISTANCE, 0)
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if not NoJumpEnabled then return end
    if input.KeyCode == Enum.KeyCode.U then
        NoJump()
    end
end)

MovementTab:CreateSection({Name = "Jump Setting", Column = "Right"})
local NoJumpToggle = MovementTab:CreateToggle({
    Name = "No Jump (TP Down) [U]",
    Column = "Right",
    CurrentValue = false,
    Callback = function(Value)
        NoJumpEnabled = Value
    end,
})

MovementTab:CreateToggle({
    Name = "Super Jump",
    CurrentValue = false,
    Flag = "SuperJump",
    Callback = function(Value)
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if not Value then return end
            if input.KeyCode == Enum.KeyCode.G then
                local character = player.Character or player.CharacterAdded:Wait()
                local rootPart = character:WaitForChild("HumanoidRootPart")
                local vectorForce = Instance.new("VectorForce")
                local attachment = Instance.new("Attachment", rootPart)
                vectorForce.Force = Vector3.new(0, 20500, 0)
                vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
                vectorForce.Attachment0 = attachment
                vectorForce.ApplyAtCenterOfMass = true
                vectorForce.Parent = rootPart
                Debris:AddItem(vectorForce, 0.5)
                Debris:AddItem(attachment, 0.5)
            end
        end)
    end,
})

MovementTab:CreateSection({Name = "Teleport", Column = "Left"})
local TPToggle = MovementTab:CreateToggle({
    Name = "Tp",
    Column = "Left",
    CurrentValue = false,
    Flag = "Tp",
    Callback = function(Value)
        isTpEnabled = Value
        if tpInputConnection then
            tpInputConnection:Disconnect()
            tpInputConnection = nil
        end
        if not Value then return end

        local DASH_DISTANCE_MAX = 2300
        local CURSOR_RADIUS = 180

        local function GetLowestHealthTarget()
            local lowestHealthTarget = nil
            local lowestHealthPercent = math.huge
            local lowestHealthPlayerName = ""
            local minCursorDist = CURSOR_RADIUS
            
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player and not table.find(whitelist, plr.Name) then
                    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local targetHRP = plr.Character.HumanoidRootPart
                        local targetHumanoid = plr.Character:FindFirstChildOfClass("Humanoid")
                        
                        if targetHumanoid then
                            local healthPercent = (targetHumanoid.Health / targetHumanoid.MaxHealth) * 100
                            
                            if healthPercent > 0 then
                                local screenPos, onScreen = Camera:WorldToViewportPoint(targetHRP.Position)
                                if onScreen then
                                    local cursorDist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                                    local worldDist = (player.Character.HumanoidRootPart.Position - targetHRP.Position).Magnitude
                                    
                                    if cursorDist < minCursorDist and worldDist < DASH_DISTANCE_MAX then
                                        if healthPercent < lowestHealthPercent then
                                            lowestHealthPercent = healthPercent
                                            lowestHealthTarget = targetHRP
                                            lowestHealthPlayerName = plr.Name
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            return lowestHealthTarget, lowestHealthPercent, lowestHealthPlayerName
        end

        local function SimulateKeyPressTp(key)
            VirtualInputManager:SendKeyEvent(true, key, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, key, false, game)
        end

        local function TeleportTo(target)
            local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if not rootPart or not target then return end
            local direction = (target.Position - rootPart.Position).Unit
            local destination = target.Position - direction * 3
            rootPart.CFrame = CFrame.new(destination)
            SimulateKeyPressTp(Enum.KeyCode.Z)
        end

        tpInputConnection = UserInputService.InputBegan:Connect(function(input, processed)
            if processed or not isTpEnabled then return end
            if input.KeyCode == Enum.KeyCode.H then
                local target, healthPercent, playerName = GetLowestHealthTarget()
                if target then
                    TeleportTo(target)
                end
            end
        end)
    end,
})

MovementTab:CreateSection({Name = "Speed Hack Setting", Column = "Left"})
local SpeedValue = MovementTab:CreateSlider({
    Name = "Speed Value",
    Column = "Left",
    Min = 16,
    Max = 2000,
    Suffix = "Speed",
    CurrentValue = 16,
    Callback = function(Value)
        speedValue = Value
    end,
})

local function activateSpeed()
    if speedConnection then speedConnection:Disconnect() end
    speedConnection = RunService.RenderStepped:Connect(function()
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = speedValue
            end
        end
    end)
end

local function deactivateSpeed()
    if speedConnection then speedConnection:Disconnect() end
    speedConnection = nil
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
        end
    end
end

local function HasSkullGuitar()
    local character = player.Character
    if character then
        local tool = character:FindFirstChildOfClass("Tool")
        if tool and tool.Name == "Skull Guitar" then
            return true
        end
    end
    return false
end

local SpeedToggle = MovementTab:CreateToggle({
    Name = "Enable SpeedHack",
    Column = "Left",
    CurrentValue = false,
    Flag = "SpeedToggle",
    Callback = function(Value)
        speedEnabled = Value
        if clickConnection then
            clickConnection:Disconnect()
            clickConnection = nil
        end
        deactivateSpeed()
        if speedEnabled then
            clickConnection = UserInputService.InputBegan:Connect(function(input, processed)
                if processed then return end
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if HasSkullGuitar() then
                        activateSpeed()
                        task.delay(2, function()
                            deactivateSpeed()
                        end)
                    end
                end
            end)
        end
    end,
})

local jumpRequestConnection = nil
local stateChangedConnection = nil

local function onHumanoidStateChanged(_, newState)
    if newState == Enum.HumanoidStateType.Landed then
        currentJumps = 0
    end
end

local function setupHumanoid(character)
    humanoid = character:WaitForChild("Humanoid")
    if stateChangedConnection then
        stateChangedConnection:Disconnect()
    end
    stateChangedConnection = humanoid.StateChanged:Connect(onHumanoidStateChanged)
end

local function setupJumpRequest()
    if jumpRequestConnection then
        jumpRequestConnection:Disconnect()
    end
    jumpRequestConnection = UserInputService.JumpRequest:Connect(function()
        if multiJumpEnabled and humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Seated then
            if currentJumps < maxJumps then
                currentJumps = currentJumps + 1
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            else
                humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
                task.wait(0.1)
                currentJumps = 0
            end
        end
    end)
end

player.CharacterAdded:Connect(function(char)
    setupHumanoid(char)
end)

setupHumanoid(player.Character or player.CharacterAdded:Wait())
setupJumpRequest()

local MultiJumpToggle = MovementTab:CreateToggle({
    Name = "Multi Jump",
    Column = "Right",
    CurrentValue = false,
    Flag = "MultiJump",
    Callback = function(Value)
        multiJumpEnabled = Value
    end,
})

-- Fly Logic
local function StopFly()
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.PlatformStand = false
    end
    -- Reset de la vélocité pour éviter d'être propulsé à l'arrêt
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end
end

local function StartFly()
    StopFly()
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end

    hum.PlatformStand = true

    flyConnection = RunService.RenderStepped:Connect(function(dt)
        if not flyEnabled or not char.Parent or not root.Parent or hum.Health <= 0 then 
            StopFly() 
            return 
        end
        
        local camCF = Camera.CFrame
        local moveDir = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        
        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit
        end
        
        -- Déplacement CFrame (Ignore la physique/gravité)
        root.CFrame = root.CFrame + (moveDir * (flySpeed * dt))
        
        -- Maintien de la vélocité à 0 pour éviter les conflits physiques
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        
        -- Orientation vers la caméra
        root.CFrame = CFrame.new(root.Position, root.Position + camCF.LookVector)
    end)
end

player.CharacterAdded:Connect(function()
    if flyEnabled then
        task.wait(0.5)
        StartFly()
    end
end)

MovementTab:CreateSection({Name = "Fly Setting", Column = "Left"})
MovementTab:CreateSlider({
    Name = "Fly Speed",
    Column = "Left",
    Min = 10,
    Max = 500,
    Suffix = "",
    CurrentValue = 50,
    Callback = function(Value)
        flySpeed = Value
    end,
})

MovementTab:CreateToggle({
    Name = "Fly",
    Column = "Left",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(Value)
        flyEnabled = Value
        if flyEnabled then
            StartFly()
        else
            StopFly()
        end
    end,
})

local function ToggleDashLength(value)
    DashEnabled = value
    if DashEnabled then
        if DashConnection then task.cancel(DashConnection) end
        DashConnection = task.spawn(function()
            while DashEnabled do
                task.wait(0.1)
                local character = player.Character
                if character then
                    local currentValue = character:GetAttribute("DashLength")
                    if currentValue ~= DashLengthValue then
                        character:SetAttribute("DashLength", DashLengthValue)
                        character:SetAttribute("DashLengthAir", DashLengthValue)
                    end
                end
            end
        end)
    else
        if DashConnection then 
            task.cancel(DashConnection)
            DashConnection = nil
            local character = player.Character
            if character then
                character:SetAttribute("DashLength", 1)
                character:SetAttribute("DashLengthAir", 1)
            end
        end
    end
end

MovementTab:CreateSection({Name = "Dash Setting", Column = "Right"})
local DashLengthSlider = MovementTab:CreateSlider({
    Name = "Dash Length Value",
    Column = "Right",
    Min = 5,
    Max = 2000,
    Suffix = "",
    CurrentValue = 5,
    Callback = function(Value)
        DashLengthValue = Value
    end,
})

local DashLengthToggle = MovementTab:CreateToggle({
    Name = "Enable Dash Length",
    Column = "Right",
    CurrentValue = false,
    Callback = function(Value)
        ToggleDashLength(Value)
    end,
})

MovementTab:CreateButton({
    Name = "Fix Rollback (Reset Physics)",
    Column = "Left",
    Callback = function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local root = char.HumanoidRootPart
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            Library:Notify("Fix", "Physique réinitialisée", 2)
        end
    end,
})

    return {
        currentJumps = currentJumps,
        maxJumps = maxJumps,
        multiJumpEnabled = multiJumpEnabled,
        sizeMultiplierEnabled = sizeMultiplierEnabled,
        speedEnabled = speedEnabled,
        speedValue = speedValue,
        flyEnabled = flyEnabled,
        flySpeed = flySpeed,
        weaponSizeEnabled = weaponSizeEnabled,
        weaponSizeMultiplier = weaponSizeMultiplier
    }
end
