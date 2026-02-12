return function()
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
    
    local Net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
    local RegisterHit = Net:WaitForChild("RE/RegisterHit")
    local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
    local Modules = ReplicatedStorage:FindFirstChild("Modules")
    local Net = Modules and Modules:FindFirstChild("Net")
    local RegisterHit = Net and Net:FindFirstChild("RE/RegisterHit")
    local RegisterAttack = Net and Net:FindFirstChild("RE/RegisterAttack")
--// INITIALISATION //--
-- Validation via API distante + cache local
local KEY_API_URL = "https://oynx-api.onrender.com/api/validate" -- Remplacez par VOTRE lien Render
local USE_REMOTE_VALIDATION = true
local CACHE_FILE = "OYNX_key_cache.json"
local isAuthenticated = false
local KeyData = { Type = "normal", BlockedFeatures = {} }

local function LoadCachedKey()
    -- Cache désactivé
    return nil
end

local function SaveCachedKey(key, ttl, extraData)
    -- Cache désactivé (ne sauvegarde plus rien)
end

local function ValidateKeyRemote(key)
    if not key or key == "" then return false, "empty" end
    if not KEY_API_URL or KEY_API_URL == "" then return false, "no_url" end

    -- Récupération du HWID (Supporte plusieurs executors)
    local hwid = "unknown"
    if gethwid then 
        hwid = gethwid() 
    elseif game:GetService("RbxAnalyticsService") then
        pcall(function() hwid = game:GetService("RbxAnalyticsService"):GetClientId() end)
    end

    -- Tentative avec la fonction 'request' de l'executor (plus permissive pour localhost)
    local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if httpRequest then
        local response = httpRequest({
            Url = KEY_API_URL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode({ key = key, hwid = hwid })
        })

        if response and response.Body then
            local s, data = pcall(function() return HttpService:JSONDecode(response.Body) end)
            if not s or type(data) ~= "table" then return false, "invalid_response_json" end
            if data.valid then
                SaveCachedKey(key, data.ttl or 86400, data)
                KeyData.Type = data.type or "normal"
                KeyData.BlockedFeatures = data.blockedFeatures or {}
                return true, data
            end
            return false, data
        end
        -- Si httpRequest échoue sans réponse, on tente le fallback ou on retourne une erreur
    end

    -- Fallback HttpService standard
    local ok, resp = pcall(function()
        return HttpService:PostAsync(KEY_API_URL, HttpService:JSONEncode({ key = key, hwid = hwid }), Enum.HttpContentType.ApplicationJson)
    end)
    if not ok then return false, "request_failed: " .. tostring(resp) end -- Affiche l'erreur réelle
    if not resp then return false, "empty_response" end

    local s, data = pcall(function() return HttpService:JSONDecode(resp) end)
    if not s or type(data) ~= "table" then return false, "invalid_response" end
    -- Attend une réponse { valid = true/false, ttl = seconds, message = "..." }
    if data.valid then
        SaveCachedKey(key, data.ttl or 86400, data)
        KeyData.Type = data.type or "normal"
        KeyData.BlockedFeatures = data.blockedFeatures or {}
        return true, data
    end
    return false, data
end

-- Interface d'auth
local authWindow = Library:CreateWindow({ Name = "OYNX HUB - Auth" })
local authTab = authWindow:CreateTab("Key")
local enteredKey = ""
local apiUrl = KEY_API_URL
local useCache = false

-- authTab:CreateToggle({ Name = "Utiliser cache local", CurrentValue = useCache, Callback = function(v) useCache = v end })
authTab:CreateInput({ Name = "Entrer la clé", PlaceholderText = "Key", Callback = function(text) enteredKey = text end })

authTab:CreateButton({ Name = "Valider la clé", Callback = function()
    -- si cache activé, tester cache d'abord
    if useCache then
        local cachedData = LoadCachedKey()
        if cachedData and cachedData.key then
            isAuthenticated = true
            KeyData.Type = cachedData.type or "normal"
            KeyData.BlockedFeatures = cachedData.blockedFeatures or {}
            Library:Notify("Auth", "Clé valable (cache)", 3)
            pcall(function() if authWindow and authWindow.Close then authWindow:Close() end end)
            return
        end
    end

    if USE_REMOTE_VALIDATION then
        if apiUrl and apiUrl ~= "" then KEY_API_URL = apiUrl end
        local ok, info = ValidateKeyRemote(enteredKey)
        if ok then
            isAuthenticated = true
            pcall(function() if authWindow and authWindow.Close then authWindow:Close() end end)
        else
            Library:Notify("Auth", "Clé refusée: " .. tostring(info), 3)
        end
    else
        -- mode hors-ligne: accepte simplement la saisie non-vide
        if enteredKey and enteredKey ~= "" then
            isAuthenticated = true
            pcall(function() if authWindow and authWindow.Close then authWindow:Close() end end)
        else
            Library:Notify("Auth", "Entrer une clé valide", 3)
        end
    end
end })

-- Attente si nécessaire
while not isAuthenticated do
    task.wait(0.5)
end

--// INITIALISATION //--
local authWindow = Library:CreateWindow({ Name = "OYNX HUB - Auth" })
local authTab = authWindow:CreateTab("Key")

--// SYSTÈME DE BLOCAGE DE FONCTIONNALITÉS //--
local function IsFeatureAllowed(name)
    if KeyData.Type == "whitelist" then return true end
    for _, blocked in ipairs(KeyData.BlockedFeatures) do
        -- Vérifie si le nom de l'onglet contient le mot bloqué (ex: "Aim" bloque "Aim")
        if string.find(string.lower(name), string.lower(blocked)) then
            return false
        end
    end
    return true
end

-- Hook pour intercepter la création d'onglets et bloquer le contenu si nécessaire
local OriginalCreateTab = Window.CreateTab
function Window:CreateTab(name, icon)
    local tab = OriginalCreateTab(self, name, icon)
    
    -- Wrapper pour intercepter la création des éléments DANS l'onglet
    local wrappedTab = setmetatable({}, {
        __index = function(self, key)
            local originalFunc = tab[key]
            if type(originalFunc) == "function" then
                return function(self, config, ...)
                    config = config or {}
                    -- Détermine le nom à vérifier (Name pour la plupart, Text pour Label)
                    local nameToCheck = config.Name or config.Text or ""
                    
                    if not IsFeatureAllowed(nameToCheck) then
                        -- Si c'est un Label (Titre de section), on l'affiche en rouge/bloqué
                        if key == "CreateLabel" then
                            config.Text = "🚫 " .. nameToCheck .. " (Bloqué)"
                            config.Color = Color3.fromRGB(200, 50, 50)
                            return originalFunc(tab, config, ...)
                        end
                        
                        -- Pour les autres éléments, on retourne un objet vide (cache l'élément)
                        return {
                            Set = function() end,
                            Get = function() return false end,
                            Refresh = function() end,
                            SetText = function() end,
                            SetColor = function() end
                        }
                    end
                    
                    return originalFunc(tab, config, ...)
                end
            end
            return originalFunc
        end
    })
    
    return wrappedTab
end

--// NOTIFICATION DE BIENVENUE //--
Library:Notify("Système", "Bienvenue ! Appuie sur K pour cacher l'UI.", 5)
    
    return {
        Library = Library,
        Window = nil,
        Players = Players,
        player = player,
        Mouse = Mouse,
        Camera = Camera,
        RunService = RunService,
        UserInputService = UserInputService,
        Debris = Debris,
        ReplicatedStorage = ReplicatedStorage,
        VirtualInputManager = VirtualInputManager,
        HttpService = HttpService,
        RegisterHit = RegisterHit,
        RegisterAttack = RegisterAttack
    }
end
