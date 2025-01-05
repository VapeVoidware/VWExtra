repeat task.wait() until game:IsLoaded()
local collectionService = game:GetService("CollectionService")
local iron = 'rbxassetid://6850537969'
local espobjs = {}
local espfold = Instance.new("Folder")
local gui = Instance.new("ScreenGui", game:GetService("Players").LocalPlayer.PlayerGui)
gui.ResetOnSpawn = false
espfold.Parent = gui
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
    image.Image = iron
    image.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    image.Size = UDim2.new(0, 32, 0, 32)
    image.AnchorPoint = Vector2.new(0.5, 0.5)
    image.Parent = billboard
    local uicorner = Instance.new("UICorner")
    uicorner.CornerRadius = UDim.new(0, 4)
    uicorner.Parent = image
    espobjs[v] = billboard
end

local function addKit(tag, icon, custom)
    if (not custom) then
        collectionService:GetInstanceAddedSignal(tag):Connect(function(v)
            espadd(v.PrimaryPart, icon)
        end)
        collectionService:GetInstanceRemovedSignal(tag):Connect(function(v)
            if espobjs[v.PrimaryPart] then
                espobjs[v.PrimaryPart]:Destroy()
                espobjs[v.PrimaryPart] = nil
            end
        end)
        for i,v in pairs(collectionService:GetTagged(tag)) do
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
        for i,v in pairs(game.Workspace:GetChildren()) do
            check(v)
        end
    end
end

addKit("hidden-metal", "iron")