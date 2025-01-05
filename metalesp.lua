repeat task.wait() until game:IsLoaded()

local Keybind = shared.Keybind or "RightShift"
local collectionService = game:GetService("CollectionService")
local debris = game:GetService("Debris")
local Icons = {
    ["iron"] = "rbxassetid://6850537969",
    ["bee"] = "rbxassetid://7343272839",
    ["natures_essence_1"] = "rbxassetid://11003449842",
    ["thorns"] = "rbxassetid://9134549615",
    ["mushrooms"] = "rbxassetid://9134534696",
    ["wild_flower"] = "rbxassetid://9134545166",
    ["crit_star"] = "rbxassetid://9866757805",
    ["vitality_star"] = "rbxassetid://9866757969"
}
local espobjs = {}
local espfold = Instance.new("Folder")
local gui = Instance.new("ScreenGui", game:GetService("Players").LocalPlayer.PlayerGui)
gui.ResetOnSpawn = false
espfold.Parent = gui

local hidden = false

local function isKeybindValid(key)
    return Enum.KeyCode[key] ~= nil
end

local function showNotification(message)
    local notification = Instance.new("TextLabel")
    notification.Size = UDim2.new(0, 300, 0, 50)
    notification.Position = UDim2.new(0.5, -150, 0, 50)
    notification.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    notification.TextColor3 = Color3.new(1, 1, 1)
    notification.Font = Enum.Font.SourceSansBold
    notification.TextSize = 20
    notification.Text = message
    notification.AnchorPoint = Vector2.new(0.5, 0)
    notification.Parent = gui

    debris:AddItem(notification, 3)
end

if not isKeybindValid(Keybind) then
    showNotification("Invalid keybind! Defaulting to RightShift.")
    Keybind = "RightShift"
else
    showNotification("Press "..tostring(Keybind).." to show/hide esp")
end

local function espadd(v, icon)
    local billboard = Instance.new("BillboardGui")
    billboard.Parent = espfold
    billboard.Name = "iron"
    billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 1.5)
    billboard.Size = UDim2.new(0, 32, 0, 32)
    billboard.AlwaysOnTop = true
    billboard.Adornee = v
    local image = Instance.new("ImageLabel")
    image.BackgroundTransparency = 0.5
    image.BorderSizePixel = 0
    image.Image = Icons[icon] or ""
    image.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    image.Size = UDim2.new(0, 32, 0, 32)
    image.AnchorPoint = Vector2.new(0.5, 0.5)
    image.Parent = billboard
    local uicorner = Instance.new("UICorner")
    uicorner.CornerRadius = UDim.new(0, 4)
    uicorner.Parent = image
    espobjs[v] = billboard
end

local connections = {}

local function reset()
    for _, v in pairs(connections) do
        pcall(function() v:Disconnect() end)
    end
    espfold:ClearAllChildren()
    table.clear(espobjs)
end

local function addKit(tag, icon, custom)
    if not custom then
        local con1 = collectionService:GetInstanceAddedSignal(tag):Connect(function(v)
            espadd(v.PrimaryPart, icon)
        end)
        local con2 = collectionService:GetInstanceRemovedSignal(tag):Connect(function(v)
            if espobjs[v.PrimaryPart] then
                espobjs[v.PrimaryPart]:Destroy()
                espobjs[v.PrimaryPart] = nil
            end
        end)
        table.insert(connections, con1)
        table.insert(connections, con2)
        for _, v in pairs(collectionService:GetTagged(tag)) do
            espadd(v.PrimaryPart, icon)
        end
    else
        local function check(v)
            if v.Name == tag and v.ClassName == "Model" then
                espadd(v.PrimaryPart, icon)
            end
        end
        game.Workspace.ChildAdded:Connect(check)
        game.Workspace.ChildRemoved:Connect(function(v)
            pcall(function()
                if espobjs[v.PrimaryPart] then
                    espobjs[v.PrimaryPart]:Destroy()
                    espobjs[v.PrimaryPart] = nil
                end
            end)
        end)
        for _, v in pairs(game.Workspace:GetChildren()) do
            check(v)
        end
    end
end

local function recreateESP()
    reset()
    addKit("hidden-metal", "iron")
    addKit("bee", "bee")
    addKit("treeOrb", "natures_essence_1")
    
    addKit("Thorns", "thorns", true)
    addKit("Mushrooms", "mushrooms", true)
    addKit("Flower", "wild_flower", true)
    addKit("CritStar", "crit_star", true)
	addKit("VitalityStar", "vitality_star", true)
end

local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode[Keybind] then
        if hidden then recreateESP(); hidden = false else reset(); hidden = true end
    end
end)

recreateESP()