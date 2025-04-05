local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local function loadJson(path)
	local suc, res = pcall(function()
		return HttpService:JSONDecode(readfile(path))
	end)
	return suc and type(res) == 'table' and res or nil, res
end

local function retry(func, attempts, slowmode)
    attempts = attempts and tonumber(attempts) or 3
    slowmode = slowmode and tonumber(slowmode) or 1
    assert(func ~= nil and type(func) == "function", `function expected got {tostring(type(func))}!`)
    local res = nil
    repeat
        attempts = attempts - 1
        local suc, err = pcall(func)
        if suc then
            res = err
            attempts = -1
        end
        task.wait(slowmode)
    until attempts <= 0
    return res
end

local changelogData = retry(function()
    return HttpService:JSONDecode(game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/VWExtra/main/UpdateMeta.json", true))
end, 10, 3) or loadJson("VW_Update_Log.json")

if not changelogData then warn("[VW Update Log]: Failure loading changelogData!"); return end
pcall(function() writefile("VW_Update_Log.json", HttpService:JSONEncode(changelogData)) end)

local localData = loadJson("Local_VW_Update_Log.json") or {lastRead = ""}

local function getNewestUpdate()
    for i,v in pairs(changelogData) do
        if v.new then return v end
    end
    return nil
end

local newest = getNewestUpdate()
if not newest then warn("[VW Update Log]: Failure getting newest update!"); return end

if not shared.UpdateLogBypass and localData.lastRead == tostring(newest.updateLogId) then return end

local function save()
    localData.lastRead = tostring(newest.updateLogId)
    writefile("Local_VW_Update_Log.json", HttpService:JSONEncode(localData))
end

local function addBlur(parent)
	local blur = Instance.new('ImageLabel')
	blur.Name = 'Blur'
	blur.Size = UDim2.new(1, 89, 1, 52)
	blur.Position = UDim2.fromOffset(-48, -31)
	blur.BackgroundTransparency = 1
	blur.Image = 'rbxassetid://14898786664'
	blur.ScaleType = Enum.ScaleType.Slice
	blur.SliceCenter = Rect.new(52, 31, 261, 502)
	blur.Parent = parent

	return blur
end

local function createChangelogUI()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ChangelogUI"
	screenGui.Parent = playerGui
	screenGui.ResetOnSpawn = false

	local mainFrame = Instance.new("Frame")
	mainFrame.Size = UDim2.new(0.85, 0, 0.9, 0)
	mainFrame.Position = UDim2.new(0.5, 0, 0.05, 0)
	mainFrame.AnchorPoint = Vector2.new(0.5, 0)
	mainFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 20)
	corner.Parent = mainFrame

	local titleBar = Instance.new("Frame")
	titleBar.Size = UDim2.new(1, 0, 0, 40)
	titleBar.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
	titleBar.BorderSizePixel = 0
	titleBar.Parent = mainFrame

	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 20)
	titleCorner.Parent = titleBar

	local closeButton = Instance.new("TextButton")
	closeButton.Size = UDim2.new(0, 30, 0, 30)
	closeButton.Position = UDim2.new(1, -40, 0, 5)
	closeButton.BackgroundColor3 = Color3.fromRGB(129, 145, 186)
	closeButton.Text = "x"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.Font = Enum.Font.SourceSansBold
	closeButton.TextSize = 20
	closeButton.Parent = titleBar
	
	addBlur(closeButton)

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 8)
	closeCorner.Parent = closeButton
	
	local logtitle = Instance.new("TextLabel")
	logtitle.TextScaled = true
	logtitle.Font = Enum.Font.FredokaOne
	logtitle.Position = UDim2.new(0.5, 0, 0, 5)
	logtitle.AnchorPoint = Vector2.new(0.5, 0)
	logtitle.Parent = titleBar
	logtitle.Text = "VW Update Log"
	logtitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	logtitle.AutomaticSize = Enum.AutomaticSize.X
	logtitle.Size = UDim2.new(0, 100, 0, 30)
	logtitle.BackgroundTransparency = 1
	
	local logstroke = Instance.new("UIStroke")
	logstroke.Parent = logtitle
	logstroke.Color = Color3.fromRGB(0, 0, 0)
	logstroke.Thickness = 2

	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Size = UDim2.new(1, -30, 1, -50)
	scrollingFrame.Position = UDim2.new(0, 19, 0, 45)
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.BorderSizePixel = 0
	scrollingFrame.ScrollBarThickness = 10
	scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 140)
	scrollingFrame.ScrollingEnabled = true
	scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
	scrollingFrame.Parent = mainFrame

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 15)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = scrollingFrame

	local function createUpdateEntry(updateData)
		if not updateData.visible then return end

		local entryFrame = Instance.new("Frame")
		entryFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 100)
		entryFrame.BorderSizePixel = 0

		local entryCorner = Instance.new("UICorner")
		entryCorner.CornerRadius = UDim.new(0, 15)
		entryCorner.Parent = entryFrame

		local titleLabel = Instance.new("TextLabel")
		titleLabel.Size = UDim2.new(1, -150, 0, 50)
		titleLabel.Position = UDim2.new(0, 15, 0, 15)
		titleLabel.BackgroundTransparency = 1
		titleLabel.Text = updateData.title
		titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		titleLabel.Font = Enum.Font.SourceSansBold
		titleLabel.TextSize = 32
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.Parent = entryFrame

		local dateLabel = Instance.new("TextLabel")
		dateLabel.Size = UDim2.new(0, 240, 0, 30)
		dateLabel.Position = UDim2.new(0, 15, 0, 65)
		dateLabel.BackgroundTransparency = 1
		dateLabel.Text = updateData.date
		dateLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
		dateLabel.Font = Enum.Font.SourceSans
		dateLabel.TextSize = 20
		dateLabel.TextXAlignment = Enum.TextXAlignment.Left
		dateLabel.Parent = entryFrame

		if updateData.new then
			local newBadge = Instance.new("TextLabel")
			newBadge.Size = UDim2.new(0, 80, 0, 30)
			newBadge.Position = UDim2.new(0, 265, 0, 65)
			newBadge.BackgroundColor3 = Color3.fromRGB(80, 255, 80)
			newBadge.Text = "NEW"
			newBadge.TextColor3 = Color3.fromRGB(255, 255, 255)
			newBadge.Font = Enum.Font.SourceSansBold
			newBadge.TextSize = 18
			newBadge.Parent = entryFrame
			
			addBlur(newBadge)
			
			local badgeStroke = Instance.new("UIStroke", newBadge)

			local badgeCorner = Instance.new("UICorner")
			badgeCorner.CornerRadius = UDim.new(0, 8)
			badgeCorner.Parent = newBadge
		end

		if updateData.image and updateData.image.assetId then
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Size = UDim2.new(0, 100, 0, 100 * updateData.image.aspectRatio)
			imageLabel.Position = UDim2.new(1, -120, 0, 15)
			imageLabel.BackgroundTransparency = 1
			imageLabel.Image = updateData.image.assetId
			imageLabel.Parent = entryFrame
			
			addBlur(imageLabel)

			local imageCorner = Instance.new("UICorner")
			imageCorner.CornerRadius = UDim.new(0, 8)
			imageCorner.Parent = imageLabel
		end

		local bodyLabel = Instance.new("TextLabel")
		bodyLabel.Size = UDim2.new(1, -30, 0, 0)
		bodyLabel.Position = UDim2.new(0, 15, 0, 110)
		bodyLabel.BackgroundTransparency = 1
		bodyLabel.Text = updateData.body
		bodyLabel.TextColor3 = Color3.fromRGB(230, 230, 255)
		bodyLabel.Font = Enum.Font.SourceSans
		bodyLabel.TextSize = 22
		bodyLabel.TextXAlignment = Enum.TextXAlignment.Left
		bodyLabel.TextYAlignment = Enum.TextYAlignment.Top
		bodyLabel.TextWrapped = true
		bodyLabel.RichText = true
		bodyLabel.Parent = entryFrame

		task.wait()
		local textHeight = bodyLabel.TextBounds.Y
		if textHeight == 0 then
			local lineCount = select(2, updateData.body:gsub("\n", "")) + 1
			textHeight = lineCount * bodyLabel.TextSize 
		end
		local padding = 115
		bodyLabel.Size = UDim2.new(1, -30, 0, textHeight)
		entryFrame.Size = UDim2.new(1, 0, 0, textHeight + padding)

		task.spawn(function()
			task.wait(0.1) 
			local finalHeight = bodyLabel.TextBounds.Y
			if finalHeight ~= textHeight then
				bodyLabel.Size = UDim2.new(1, -30, 0, finalHeight)
				entryFrame.Size = UDim2.new(1, 0, 0, finalHeight + padding)
				scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 30)
			end
		end)

		entryFrame.Parent = scrollingFrame
	end

	for _, update in ipairs(changelogData) do
		createUpdateEntry(update)
	end

	task.wait()
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 30)

	closeButton.MouseButton1Click:Connect(function()
		screenGui:Destroy()
        save()
	end)
end

createChangelogUI()