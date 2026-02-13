return function(VisualsTab, Mouse, Camera, Players, player, RunService, Library)
local ESPEnabled = false
local ESPBox = false
local ESPName = false
local ESPChams = false
local ESPContainer = Instance.new("Folder", game:GetService("CoreGui"))
ESPContainer.Name = "OYNX_ESP_CONTAINER"

local function ClearESP()
    ESPContainer:ClearAllChildren()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character then
            local hl = plr.Character:FindFirstChild("OYNX_Highlight")
            if hl then hl:Destroy() end
        end
    end
end

local function UpdateESP()
    if not ESPEnabled then 
        ClearESP()
        return 
    end

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") then
            local char = plr.Character
            local hrp = char.HumanoidRootPart
            local hum = char.Humanoid
            
            -- CHAMS (Highlight)
            if ESPChams then
                local hl = char:FindFirstChild("OYNX_Highlight")
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "OYNX_Highlight"
                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.5
                    hl.OutlineTransparency = 0
                    hl.Parent = char
                end
            else
                local hl = char:FindFirstChild("OYNX_Highlight")
                if hl then hl:Destroy() end
            end

            -- TEXT ESP (Name + Health)
            if ESPName then
                local bg = ESPContainer:FindFirstChild(plr.Name .. "_ESP")
                if not bg then
                    bg = Instance.new("BillboardGui")
                    bg.Name = plr.Name .. "_ESP"
                    bg.Adornee = char:FindFirstChild("Head") or hrp
                    bg.Size = UDim2.new(0, 200, 0, 50)
                    bg.StudsOffset = Vector3.new(0, 2, 0)
                    bg.AlwaysOnTop = true
                    bg.Parent = ESPContainer
                    
                    local nameLabel = Instance.new("TextLabel", bg)
                    nameLabel.Size = UDim2.new(1, 0, 1, 0)
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.TextStrokeTransparency = 0
                    nameLabel.TextSize = 13
                    nameLabel.Font = Enum.Font.GothamBold
                    nameLabel.Parent = bg
                end
                
                if bg and bg:FindFirstChild("TextLabel") then
                    local hp = math.floor(hum.Health)
                    bg.TextLabel.Text = plr.Name .. " [" .. hp .. "]"
                    bg.TextLabel.TextColor3 = Color3.fromHSV((hp/hum.MaxHealth)*0.3, 1, 1) -- Vert -> Rouge
                end
            else
                local bg = ESPContainer:FindFirstChild(plr.Name .. "_ESP")
                if bg then bg:Destroy() end
            end
        end
    end
end

RunService.RenderStepped:Connect(UpdateESP)

VisualsTab:CreateSection("ESP Settings")
VisualsTab:CreateToggle({
    Name = "Enable ESP (Master Switch)",
    Column = "Left",
    CurrentValue = false,
    Callback = function(v) ESPEnabled = v if not v then ClearESP() end end
})

VisualsTab:CreateToggle({
    Name = "Chams (Wallhack Color)",
    Column = "Left",
    CurrentValue = false,
    Callback = function(v) ESPChams = v end
})

VisualsTab:CreateToggle({
    Name = "Name & Health ESP",
    Column = "Left",
    CurrentValue = false,
    Callback = function(v) ESPName = v end
})

-- Custom Cursor
local CustomCursorId = ""
VisualsTab:CreateSection("Custom Cursor")
VisualsTab:CreateInput({
    Name = "Custom Cursor (ID or File)",
    PlaceholderText = "ID or cursor.png",
    Column = "Right",
    Callback = function(text) CustomCursorId = text end
})

local function GetLocalImageFiles()
    local files = {}
    if listfiles then
        pcall(function()
            for _, file in ipairs(listfiles("")) do
                local ext = file:sub(-4):lower()
                if ext == ".png" or ext == ".jpg" then
                    local name = file:match("([^/\\]+)$") or file
                    table.insert(files, name)
                end
            end
        end)
    end
    if #files == 0 then table.insert(files, "Aucune image trouvée") end
    return files
end

local CursorDropdown = VisualsTab:CreateDropdown({
    Name = "Choisir fichier (Workspace)",
    Options = GetLocalImageFiles(),
    CurrentOption = {"..."},
    Column = "Right",
    Callback = function(Option)
        if Option[1] and Option[1] ~= "Aucune image trouvée" and Option[1] ~= "..." then
            CustomCursorId = Option[1]
            Library:Notify("Cursor", "Fichier sélectionné: " .. Option[1], 2)
        end
    end
})

VisualsTab:CreateButton({
    Name = "Rafraîchir Liste Fichiers",
    Column = "Right",
    Callback = function()
        CursorDropdown:Refresh(GetLocalImageFiles(), true)
    end
})

VisualsTab:CreateButton({
    Name = "Apply Cursor",
    Column = "Right",
    Callback = function()
        if CustomCursorId ~= "" then
            local id = CustomCursorId
            -- Support pour fichier local (workspace)
            if isfile and isfile(id) and (getcustomasset or getsynasset) then
                local getAsset = getcustomasset or getsynasset
                id = getAsset(id)
            elseif not string.find(id, "rbxassetid://") and tonumber(id) then
                -- Support pour ID Roblox classique
                id = "rbxassetid://" .. id 
            end
            Mouse.Icon = id
        end
    end
})

VisualsTab:CreateButton({
    Name = "Reset Cursor",
    Column = "Right",
    Callback = function() Mouse.Icon = "" end
})

return {
    -- Variables ESP
    ESPEnabled = function() return ESPEnabled end,
    ESPBox = function() return ESPBox end,
    ESPName = function() return ESPName end,
    ESPChams = function() return ESPChams end,
    
    -- Fonctions ESP
    ClearESP = ClearESP,
    UpdateESP = UpdateESP,
    
    -- Variables Cursor
    CustomCursorId = function() return CustomCursorId end,
    
    -- Fonctions Cursor
    GetLocalImageFiles = GetLocalImageFiles,
    
    -- Container
    ESPContainer = ESPContainer
}
end
