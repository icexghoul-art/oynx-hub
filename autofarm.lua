return function(FarmTab, player, RunService, ReplicatedStorage, Library)
    -- ==================================================================================================== AUTO FARM ====================================================================================================

-- ==================================================================================================== 
-- VARIABLES AUTO FARM OPTIMISÉES (Remplace toutes les variables individuelles)
-- ====================================================================================================

local Farm = {
    -- Auto Farm Core
    Enabled = false,
    Mode = "Level",
    Connection = nil,
    Distance = 25,
    
    -- Settings
    BringMobs = false,
    AutoHaki = false,
    SafeFarm = true,
    SafeHP = 30,
    SafePos = Vector3.new(0, 500, 0),
    
    -- Quest
    AutoQuest = false,
    CurrentQuest = nil,
    
    -- Mastery
    AutoMastery = false,
    Weapons = {},
    CurrentWeapon = nil,
    Threshold = 600,
    WeaponLabel = nil,
    
    -- Boss
    AutoBoss = false,
    SelectedBoss = "Longma",
    BossList = {
        "Longma", "Soul Reaper", "Cake Queen", "Don Swan", 
        "Darkbeard", "Magma Admiral", "Saber Expert", "rip_indra True Form",
        "Order", "Cursed Captain", "Diamond", "Thunder God"
    }
}

-- ==================================================================================================== 
-- FONCTIONS AUTO FARM
-- ====================================================================================================

local function GetPlayerLevel()
    return player.Data.Level.Value or 1
end

local function GetCurrentArea()
    local placeId = game.PlaceId
    if placeId == 2753915549 then return 1
    elseif placeId == 4442272183 then return 2
    elseif placeId == 7449423635 then return 3
    end
    return 1
end

local function GetRecommendedEnemy()
    local level = GetPlayerLevel()
    local area = GetCurrentArea()
    
    if area == 3 then
        if level >= 2550 then return "Cookie Crafter"
        elseif level >= 2500 then return "Chocolate Bar Battler"
        elseif level >= 2450 then return "Candy Rebel"
        elseif level >= 2400 then return "Head Baker"
        elseif level >= 2350 then return "Cocoa Warrior"
        elseif level >= 2300 then return "Candy Pirate"
        elseif level >= 2250 then return "Peanut Scout"
        elseif level >= 2200 then return "Ice Cream Chef"
        elseif level >= 2150 then return "Cake Guard"
        elseif level >= 2100 then return "Baking Staff"
        elseif level >= 2050 then return "Chocolate Bar Battler"
        elseif level >= 2000 then return "Candy Rebel"
        elseif level >= 1950 then return "Forest Pirate"
        elseif level >= 1900 then return "Jungle Pirate"
        elseif level >= 1850 then return "Reborn Skeleton"
        elseif level >= 1800 then return "Demonic Soul"
        elseif level >= 1750 then return "Peanut Scout"
        elseif level >= 1700 then return "Ice Cream Chef"
        elseif level >= 1650 then return "Dragon Crew Warrior"
        elseif level >= 1600 then return "Female Islander"
        elseif level >= 1550 then return "Marine Commodore"
        elseif level >= 1500 then return "Fishman Raider"
        end
    
    elseif area == 2 then
        if level >= 1450 then return "Lava Pirate"
        elseif level >= 1400 then return "Ship Engineer"
        elseif level >= 1350 then return "Ship Officer"
        elseif level >= 1300 then return "Snow Lurker"
        elseif level >= 1250 then return "Winter Warrior"
        elseif level >= 1200 then return "Horned Warrior"
        elseif level >= 1150 then return "Lava Pirate"
        elseif level >= 1100 then return "Elemental"
        elseif level >= 1050 then return "Mole"
        elseif level >= 1000 then return "Vampire"
        elseif level >= 950 then return "Royal Squad"
        elseif level >= 900 then return "Mercenary"
        elseif level >= 850 then return "Factory Staff"
        elseif level >= 800 then return "Jungle Pirate"
        elseif level >= 750 then return "Gladiator"
        elseif level >= 700 then return "Raider"
        end
    
    else
        if level >= 700 then return "Galley Captain"
        elseif level >= 650 then return "God's Guard"
        elseif level >= 600 then return "Shandas"
        elseif level >= 550 then return "Royal Soldier"
        elseif level >= 500 then return "Sky Bandit"
        elseif level >= 450 then return "Toga Warrior"
        elseif level >= 400 then return "Prisoner"
        elseif level >= 350 then return "Military Spy"
        elseif level >= 300 then return "Gladiator"
        elseif level >= 250 then return "Chief Petty Officer"
        elseif level >= 200 then return "Marine Lieutenant"
        elseif level >= 150 then return "Mercenary"
        elseif level >= 100 then return "Desert Bandit"
        elseif level >= 75 then return "Pirate"
        elseif level >= 30 then return "Bandit"
        else return "Monkey"
        end
    end
    
    return "Bandit"
end

local function GetQuestGiver(enemyName)
    local questMap = {
        ["Bandit"] = "BanditQuest1",
        ["Monkey"] = "JungleQuest",
        ["Pirate"] = "BuggyQuest1",
        ["Desert Bandit"] = "DesertQuest",
        ["Snow Bandit"] = "SnowQuest",
        ["Marine Lieutenant"] = "MarineQuest2",
        ["Mercenary"] = "Area1Quest",
        ["Gladiator"] = "ColosseumQuest",
        ["Military Spy"] = "MagmaQuest",
        ["Prisoner"] = "ImpelQuest",
        ["Sky Bandit"] = "SkyExp1Quest",
        ["Royal Soldier"] = "SkyExp1Quest",
        ["Shandas"] = "ShandiaQuest",
        ["God's Guard"] = "SkyExp2Quest",
        ["Galley Captain"] = "FountainQuest",
        ["Raider"] = "Area1Quest",
        ["Factory Staff"] = "Area2Quest",
        ["Vampire"] = "VampireQuest",
        ["Royal Squad"] = "RoyalQuest",
        ["Lava Pirate"] = "FireSideQuest",
        ["Ship Officer"] = "ShipQuest2",
        ["Snow Lurker"] = "FrostQuest",
        ["Fishman Raider"] = "FishmanQuest",
        ["Forest Pirate"] = "DeepForestIsland",
        ["Reborn Skeleton"] = "HauntedQuest1",
        ["Demonic Soul"] = "HauntedQuest2",
        ["Peanut Scout"] = "NutsIslandQuest",
        ["Ice Cream Chef"] = "IceCreamIslandQuest",
        ["Cookie Crafter"] = "CakeQuest1",
        ["Cake Guard"] = "CakeQuest2",
        ["Cocoa Warrior"] = "ChocQuest1",
        ["Candy Rebel"] = "CandyQuest1",
    }
    
    return questMap[enemyName] or "BanditQuest1"
end

local function AcceptQuest(questGiver)
    pcall(function()
        local CommF_ = game:GetService("ReplicatedStorage").Remotes.CommF_
        CommF_:InvokeServer("StartQuest", questGiver, 1)
        task.wait(0.3)
        Farm.CurrentQuest = questGiver
    end)
end

local function CheckQuestCompletion()
    pcall(function()
        local questGui = player.PlayerGui:FindFirstChild("Main")
        if questGui then
            local quest = questGui:FindFirstChild("Quest")
            if quest and quest.Visible then
                local container = quest:FindFirstChild("Container")
                if container then
                    local questTitle = container:FindFirstChild("QuestTitle")
                    if questTitle and questTitle.Title.Text == "✓" then
                        task.wait(0.5)
                        AcceptQuest(Farm.CurrentQuest)
                    end
                end
            else
                if Farm.CurrentQuest then
                    AcceptQuest(Farm.CurrentQuest)
                end
            end
        end
    end)
end

local function BringMobs(targetEnemy)
    if not Farm.BringMobs then return end
    
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local myHRP = char.HumanoidRootPart
    local bringPos = myHRP.CFrame * CFrame.new(0, 0, -15)
    
    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, mob in pairs(enemies:GetChildren()) do
            if mob.Name == targetEnemy then
                local mobHRP = mob:FindFirstChild("HumanoidRootPart")
                local mobHum = mob:FindFirstChild("Humanoid")
                
                if mobHRP and mobHum and mobHum.Health > 0 then
                    local dist = (mobHRP.Position - myHRP.Position).Magnitude
                    
                    if dist <= 300 then
                        pcall(function()
                            mobHRP.CFrame = bringPos
                            mobHRP.CanCollide = false
                            mobHRP.Size = Vector3.new(50, 50, 50)
                            mobHRP.Transparency = 0.8
                            
                            if mobHRP:FindFirstChild("BodyVelocity") then
                                mobHRP.BodyVelocity:Destroy()
                            end
                            
                            local bv = Instance.new("BodyVelocity", mobHRP)
                            bv.Velocity = Vector3.new(0, 0, 0)
                            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                        end)
                    end
                end
            end
        end
    end
end

local function EnableHaki()
    if not Farm.AutoHaki then return end
    
    pcall(function()
        local CommF_ = game:GetService("ReplicatedStorage").Remotes.CommF_
        if not player.Character:FindFirstChild("HasBuso") then
            CommF_:InvokeServer("Buso")
        end
    end)
end

local function EquipWeapon(weaponName)
    local char = player.Character
    if not char then return false end
    
    local tool = player.Backpack:FindFirstChild(weaponName) or char:FindFirstChild(weaponName)
    
    if tool and tool:IsA("Tool") then
        if tool.Parent == player.Backpack then
            char.Humanoid:EquipTool(tool)
        end
        return true
    end
    
    return false
end

local function GetPlayerWeapons()
    local weapons = {}
    
    for _, tool in pairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            if not table.find(weapons, tool.Name) then
                table.insert(weapons, tool.Name)
            end
        end
    end
    
    local char = player.Character
    if char then
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                if not table.find(weapons, tool.Name) then
                    table.insert(weapons, tool.Name)
                end
            end
        end
    end
    
    table.sort(weapons)
    
    if #weapons == 0 then
        return {"Aucune arme trouvée"}
    end
    
    return weapons
end

local function GetWeaponMastery(weaponName)
    local tool = player.Backpack:FindFirstChild(weaponName) or (player.Character and player.Character:FindFirstChild(weaponName))
    
    if tool then
        local level = tool:FindFirstChild("Level")
        if level then
            return level.Value or 0
        end
    end
    
    return 0
end

local function GetNextMasteryWeapon()
    for _, weaponName in ipairs(Farm.Weapons) do
        local tool = player.Backpack:FindFirstChild(weaponName) or (player.Character and player.Character:FindFirstChild(weaponName))
        
        if tool then
            local mastery = GetWeaponMastery(weaponName)
            
            if mastery < Farm.Threshold then
                Farm.CurrentWeapon = weaponName
                return weaponName
            end
        end
    end
    
    if #Farm.Weapons > 0 then
        Farm.CurrentWeapon = Farm.Weapons[1]
        return Farm.Weapons[1]
    end
    
    return nil
end

local function CheckMasteryCompletion()
    for i, weaponName in ipairs(Farm.Weapons) do
        local mastery = GetWeaponMastery(weaponName)
        
        if mastery >= Farm.Threshold then
            Library:Notify("Mastery Complete! 🎉", weaponName .. " reached " .. mastery, 5)
            table.remove(Farm.Weapons, i)
            break
        end
    end
end

-- ==================================================================================================== 
-- ONGLET AUTO FARM GUI
-- ====================================================================================================

FarmTab:CreateSection({Name = "Auto Farm Settings", Column = "Left"})
    
FarmTab:CreateToggle({
    Name = "Enable Auto Farm",
    Column = "Left",
    CurrentValue = false,
    Callback = function(Value)
        Farm.Enabled = Value
        
        if Value then
            toggleFastAttack(true)
            Library:Notify("Auto Farm", "Démarré en mode: " .. Farm.Mode, 3)
        else
            toggleFastAttack(false)
            Library:Notify("Auto Farm", "Arrêté", 2)
        end
    end,
})

FarmTab:CreateDropdown({
    Name = "Farm Mode",
    Column = "Left",
    Options = {"Level", "Quest", "Mastery", "Boss"},
    CurrentOption = {"Level"},
    Callback = function(Option)
        Farm.Mode = Option[1]
        Library:Notify("Farm Mode", "Changé pour: " .. Option[1], 2)
    end,
})

FarmTab:CreateSlider({
    Name = "Farm Distance",
    Column = "Left",
    Min = 5,
    Max = 50,
    Suffix = " studs",
    CurrentValue = 25,
    Callback = function(Value)
        Farm.Distance = Value
    end,
})

FarmTab:CreateSection({Name = "Safe Farm", Column = "Right"})

FarmTab:CreateToggle({
    Name = "Safe Farm (TP si low HP)",
    Column = "Right",
    CurrentValue = true,
    Callback = function(Value)
        Farm.SafeFarm = Value
    end,
})

FarmTab:CreateSlider({
    Name = "Safe HP Threshold",
    Column = "Right",
    Min = 10,
    Max = 80,
    Suffix = "%",
    CurrentValue = 30,
    Callback = function(Value)
        Farm.SafeHP = Value
    end,
})

FarmTab:CreateSection({Name = "Bring Mobs", Column = "Left"})

FarmTab:CreateToggle({
    Name = "Bring Mobs (Teleport)",
    Column = "Left",
    CurrentValue = false,
    Callback = function(Value)
        Farm.BringMobs = Value
    end,
})

FarmTab:CreateToggle({
    Name = "Auto Buso Haki",
    Column = "Left",
    CurrentValue = false,
    Callback = function(Value)
        Farm.AutoHaki = Value
    end,
})

FarmTab:CreateSection({Name = "Quest Farm", Column = "Right"})

FarmTab:CreateToggle({
    Name = "Auto Accept Quest",
    Column = "Right",
    CurrentValue = false,
    Callback = function(Value)
        Farm.AutoQuest = Value
    end,
})

FarmTab:CreateSection({Name = "Mastery Farm", Column = "Left"})

FarmTab:CreateToggle({
    Name = "Auto Mastery Farm",
    Column = "Left",
    CurrentValue = false,
    Callback = function(Value)
        Farm.AutoMastery = Value
    end,
})

local WeaponDropdown = FarmTab:CreateDropdown({
    Name = "Select Weapon",
    Column = "Left",
    Options = GetPlayerWeapons(),
    CurrentOption = {"Aucune arme trouvée"},
    Callback = function(Option)
        if Option[1] and Option[1] ~= "Aucune arme trouvée" then
            local weaponName = Option[1]
            
            if not table.find(Farm.Weapons, weaponName) then
                table.insert(Farm.Weapons, weaponName)
                local mastery = GetWeaponMastery(weaponName)
                Library:Notify("Mastery", weaponName .. " ajoutée (Lvl: " .. mastery .. ")", 3)
            else
                Library:Notify("Erreur", weaponName .. " est déjà dans la liste", 2)
            end
        end
    end,
})

FarmTab:CreateButton({
    Name = "🔄 Refresh Weapon List",
    Column = "Left",
    Callback = function()
        local weapons = GetPlayerWeapons()
        WeaponDropdown:Refresh(weapons, true)
        Library:Notify("Weapons", #weapons .. " arme(s) détectée(s)", 2)
    end,
})

FarmTab:CreateButton({
    Name = "📋 Show Mastery List",
    Column = "Left",
    Callback = function()
        if #Farm.Weapons == 0 then
            Library:Notify("Mastery", "Aucune arme dans la liste", 2)
        else
            print("=== MASTERY ROTATION ===")
            for i, weapon in ipairs(Farm.Weapons) do
                local mastery = GetWeaponMastery(weapon)
                print(i .. ". " .. weapon .. " - Mastery: " .. mastery .. "/" .. Farm.Threshold)
            end
            print("========================")
            Library:Notify("Mastery", #Farm.Weapons .. " arme(s) en rotation", 2)
        end
    end,
})

FarmTab:CreateButton({
    Name = "🗑️ Clear Mastery List",
    Column = "Left",
    Callback = function()
        Farm.Weapons = {}
        Library:Notify("Mastery", "Liste vidée", 2)
    end,
})

FarmTab:CreateSlider({
    Name = "Mastery Threshold",
    Column = "Left",
    Min = 100,
    Max = 600,
    Suffix = " lvl",
    CurrentValue = 600,
    Callback = function(Value)
        Farm.Threshold = Value
    end,
})

Farm.WeaponLabel = FarmTab:CreateLabel({
    Text = "Current Weapon: None",
    Column = "Left",
})

task.spawn(function()
    while true do
        task.wait(2)
        if Farm.AutoMastery and Farm.CurrentWeapon then
            local mastery = GetWeaponMastery(Farm.CurrentWeapon)
            Farm.WeaponLabel:SetText("Current: " .. Farm.CurrentWeapon .. " (Lvl: " .. mastery .. ")")
        else
            Farm.WeaponLabel:SetText("Current Weapon: None")
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(30)
        if Farm.AutoMastery then
            CheckMasteryCompletion()
        end
    end
end)

FarmTab:CreateSection({Name = "Boss Farm", Column = "Right"})

FarmTab:CreateToggle({
    Name = "Auto Boss Farm",
    Column = "Right",
    CurrentValue = false,
    Callback = function(Value)
        Farm.AutoBoss = Value
    end,
})

FarmTab:CreateDropdown({
    Name = "Select Boss",
    Column = "Right",
    Options = Farm.BossList,
    CurrentOption = {"Longma"},
    Callback = function(Option)
        Farm.SelectedBoss = Option[1]
    end,
})

FarmTab:CreateSection({Name = "Farm Info", Column = "Right"})

FarmTab:CreateLabel({
    Text = "Current Level: " .. GetPlayerLevel(),
    Column = "Right",
})

FarmTab:CreateLabel({
    Text = "Recommended Enemy: " .. GetRecommendedEnemy(),
    Column = "Right",
})

FarmTab:CreateButton({
    Name = "🔄 Refresh Info",
    Column = "Right",
    Callback = function()
        Library:Notify("Info", "Level: " .. GetPlayerLevel() .. " | Enemy: " .. GetRecommendedEnemy(), 3)
    end,
})

player.Backpack.ChildAdded:Connect(function(child)
    if child:IsA("Tool") then
        task.wait(0.5)
        WeaponDropdown:Refresh(GetPlayerWeapons(), true)
    end
end)

player.Backpack.ChildRemoved:Connect(function(child)
    if child:IsA("Tool") then
        task.wait(0.5)
        WeaponDropdown:Refresh(GetPlayerWeapons(), true)
    end
end)

player.CharacterAdded:Connect(function(char)
    task.wait(1)
    WeaponDropdown:Refresh(GetPlayerWeapons(), true)
    
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            task.wait(0.5)
            WeaponDropdown:Refresh(GetPlayerWeapons(), true)
        end
    end)
end)

-- ============================================
-- DÉMARRAGE DE LA BOUCLE AUTO FARM (1 seule fois)
-- ============================================
task.spawn(function()
    while true do
        task.wait(0.1)
        
        if Farm.Enabled then
            pcall(function()
                local char = player.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                
                local myHRP = char.HumanoidRootPart
                local humanoid = char:FindFirstChild("Humanoid")
                
                if not humanoid or humanoid.Health <= 0 then return end
                
                -- Safe Farm
                if Farm.SafeFarm then
                    local healthPercent = (humanoid.Health / humanoid.MaxHealth) * 100
                    if healthPercent < Farm.SafeHP then
                        myHRP.CFrame = CFrame.new(Farm.SafePos)
                        task.wait(5)
                        return
                    end
                end
                
                local targetEnemy = nil
                
                -- Mode Selection
                if Farm.Mode == "Level" then
                    targetEnemy = GetRecommendedEnemy()
                    
                elseif Farm.Mode == "Quest" then
                    targetEnemy = GetRecommendedEnemy()
                    
                    if Farm.AutoQuest then
                        local questGiver = GetQuestGiver(targetEnemy)
                        if not Farm.CurrentQuest or Farm.CurrentQuest ~= questGiver then
                            AcceptQuest(questGiver)
                        end
                        CheckQuestCompletion()
                    end
                    
                elseif Farm.Mode == "Mastery" then
                    targetEnemy = GetRecommendedEnemy()
                    
                    if Farm.AutoMastery and #Farm.Weapons > 0 then
                        local weapon = GetNextMasteryWeapon()
                        if weapon then
                            EquipWeapon(weapon)
                        end
                    end
                    
                elseif Farm.Mode == "Boss" then
                    if Farm.AutoBoss then
                        targetEnemy = Farm.SelectedBoss
                    end
                end
                
                if not targetEnemy then return end
                
                -- Find Target
                local enemies = workspace:FindFirstChild("Enemies")
                local target = nil
                local minDist = math.huge
                
                if enemies then
                    for _, mob in pairs(enemies:GetChildren()) do
                        if mob.Name == targetEnemy then
                            local mobHRP = mob:FindFirstChild("HumanoidRootPart")
                            local mobHum = mob:FindFirstChild("Humanoid")
                            
                            if mobHRP and mobHum and mobHum.Health > 0 then
                                local dist = (mobHRP.Position - myHRP.Position).Magnitude
                                if dist < minDist then
                                    minDist = dist
                                    target = mob
                                end
                            end
                        end
                    end
                end
                
                if target and target:FindFirstChild("HumanoidRootPart") then
                    local targetHRP = target.HumanoidRootPart
                    
                    EnableHaki()
                    BringMobs(targetEnemy)
                    
                    myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, Farm.Distance, 0)
                else
                    myHRP.Velocity = Vector3.new(0, 0, 0)
                end
            end)
        end
    end
end)

    return {
        -- Auto Farm Core
        Enabled = Farm.Enabled,
        Mode = Farm.Mode,
        Distance = Farm.Distance,
        
        -- Settings
        BringMobs = Farm.BringMobs,
        AutoHaki = Farm.AutoHaki,
        SafeFarm = Farm.SafeFarm,
        SafeHP = Farm.SafeHP,
        
        -- Quest
        AutoQuest = Farm.AutoQuest,
        CurrentQuest = Farm.CurrentQuest,
        
        -- Mastery
        AutoMastery = Farm.AutoMastery,
        Weapons = Farm.Weapons,
        CurrentWeapon = Farm.CurrentWeapon,
        Threshold = Farm.Threshold,
        
        -- Boss
        AutoBoss = Farm.AutoBoss,
        SelectedBoss = Farm.SelectedBoss,
        BossList = Farm.BossList,
        
        -- Functions
        GetPlayerLevel = GetPlayerLevel,
        GetRecommendedEnemy = GetRecommendedEnemy,
        GetPlayerWeapons = GetPlayerWeapons,
        GetWeaponMastery = GetWeaponMastery
    }
end
