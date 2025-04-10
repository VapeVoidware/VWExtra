local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

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

local NotificationSystem = {}
NotificationSystem.__index = NotificationSystem

function NotificationSystem.new()
	local self = setmetatable({}, NotificationSystem)
	self.ScreenGui = Instance.new("ScreenGui")
	self.ScreenGui.Name = "NotificationGui"
	self.ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	self.ScreenGui.ResetOnSpawn = false
	self.Notifications = {}
	return self
end

local isActive = false

function NotificationSystem:CreateNotification(title, message, isInteractive, onYes, onNo)
	repeat task.wait() until not isActive
	isActive = true
	local notificationFrame = Instance.new("Frame")
	notificationFrame.Size = UDim2.new(0, 300, 0, 120)
	notificationFrame.Position = UDim2.new(1, 20, 0, -150)
	notificationFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
	notificationFrame.BorderSizePixel = 0
	notificationFrame.Parent = self.ScreenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = notificationFrame

	local blur = Instance.new("ImageLabel")
	blur.Name = "Blur"
	blur.Size = UDim2.new(1, 89, 1, 52)
	blur.Position = UDim2.fromOffset(-48, -31)
	blur.BackgroundTransparency = 1
	blur.Image = "rbxassetid://14898786664"
	blur.ScaleType = Enum.ScaleType.Slice
	blur.SliceCenter = Rect.new(52, 31, 261, 502)
	blur.Parent = notificationFrame

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -20, 0, 30)
	titleLabel.Position = UDim2.new(0, 10, 0, 10)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.Font = Enum.Font.FredokaOne
	titleLabel.TextSize = 20
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = notificationFrame

	local messageLabel = Instance.new("TextLabel")
	messageLabel.Size = UDim2.new(1, -20, 0, 40)
	messageLabel.Position = UDim2.new(0, 10, 0, 40)
	messageLabel.BackgroundTransparency = 1
	messageLabel.Text = message
	messageLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
	messageLabel.Font = Enum.Font.SourceSans
	messageLabel.TextSize = 16
	messageLabel.TextXAlignment = Enum.TextXAlignment.Left
	messageLabel.TextWrapped = true
	messageLabel.Parent = notificationFrame

	local tweenIn = TweenService:Create(notificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Position = UDim2.new(1, -320, 0, 20) 
	})
	tweenIn:Play()

	if isInteractive then
		local yesButton = Instance.new("TextButton")
		yesButton.Size = UDim2.new(0, 60, 0, 30)
		yesButton.Position = UDim2.new(0, 150, 0, 80)
		yesButton.BackgroundColor3 = Color3.fromRGB(80, 255, 80)
		yesButton.Text = "Yes"
		yesButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		yesButton.Font = Enum.Font.SourceSansBold
		yesButton.TextSize = 18
		yesButton.Parent = notificationFrame

		local yesCorner = Instance.new("UICorner")
		yesCorner.CornerRadius = UDim.new(0, 8)
		yesCorner.Parent = yesButton

		local noButton = Instance.new("TextButton")
		noButton.Size = UDim2.new(0, 60, 0, 30)
		noButton.Position = UDim2.new(0, 220, 0, 80)
		noButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
		noButton.Text = "No"
		noButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		noButton.Font = Enum.Font.SourceSansBold
		noButton.TextSize = 18
		noButton.Parent = notificationFrame

		local noCorner = Instance.new("UICorner")
		noCorner.CornerRadius = UDim.new(0, 8)
		noCorner.Parent = noButton

		yesButton.MouseEnter:Connect(function()
			TweenService:Create(yesButton, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(120, 255, 120) }):Play()
		end)
		yesButton.MouseLeave:Connect(function()
			TweenService:Create(yesButton, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(80, 255, 80) }):Play()
		end)
		noButton.MouseEnter:Connect(function()
			TweenService:Create(noButton, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(255, 120, 120) }):Play()
		end)
		noButton.MouseLeave:Connect(function()
			TweenService:Create(noButton, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(255, 80, 80) }):Play()
		end)

		local function closeNotification()
			local tweenOut = TweenService:Create(notificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
				Position = UDim2.new(1, 20, 0, 20)
			})
			tweenOut:Play()
			tweenOut.Completed:Connect(function()
				notificationFrame:Destroy()
			end)
			isActive = false
		end

		yesButton.MouseButton1Click:Connect(function()
			if onYes then onYes() end
			closeNotification()
		end)
		noButton.MouseButton1Click:Connect(function()
			if onNo then onNo() end
			closeNotification()
		end)

		task.delay(15, function()
			if notificationFrame.Parent then
				closeNotification()
			end
		end)
	else
		task.delay(5, function()
			if notificationFrame.Parent then
				local tweenOut = TweenService:Create(notificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
					Position = UDim2.new(1, 20, 0, 20)
				})
				tweenOut:Play()
				tweenOut.Completed:Connect(function()
					notificationFrame:Destroy()
				end)
			end
			isActive = false
		end)
	end

	table.insert(self.Notifications, notificationFrame)
	return notificationFrame
end

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
	mainFrame.Position = UDim2.new(0.5, 0, 1.05, 0)
	mainFrame.AnchorPoint = Vector2.new(0.5, 0)
	mainFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
	mainFrame.BorderSizePixel = 0
	mainFrame.BackgroundTransparency = 1 
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
	
	--addBlur(closeButton)

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

	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	local mainTween = TweenService:Create(mainFrame, tweenInfo, {
		Position = UDim2.new(0.5, 0, 0.05, 0),
		BackgroundTransparency = 0
	})
	mainTween:Play()

	closeButton.MouseEnter:Connect(function()
		TweenService:Create(closeButton, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(255, 80, 80)
		}):Play()
	end)
	closeButton.MouseLeave:Connect(function()
		TweenService:Create(closeButton, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(129, 145, 186)
		}):Play()
	end)

	local function createUpdateEntry(updateData)
		if not updateData.visible then return end

		local entryFrame = Instance.new("Frame")
		entryFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 100)
		entryFrame.BorderSizePixel = 0
		entryFrame.BackgroundTransparency = 1 

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

			newBadge.MouseEnter:Connect(function()
				local hoverTween = TweenService:Create(newBadge, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Size = UDim2.new(0, 90, 0, 34), 
					BackgroundColor3 = Color3.fromRGB(120, 255, 120) 
				})
				local strokeTween = TweenService:Create(badgeStroke, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Thickness = 2 
				})
				hoverTween:Play()
				strokeTween:Play()
				
				task.spawn(function()
					while newBadge:IsDescendantOf(game) and newBadge:IsMouseOver() do
						TweenService:Create(newBadge, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
							BackgroundColor3 = Color3.fromRGB(80, 255, 80)
						}):Play()
						task.wait(0.5)
						TweenService:Create(newBadge, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
							BackgroundColor3 = Color3.fromRGB(120, 255, 120)
						}):Play()
						task.wait(0.5)
					end
				end)
			end)

			newBadge.MouseLeave:Connect(function()
				local leaveTween = TweenService:Create(newBadge, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Size = UDim2.new(0, 80, 0, 30), 
					BackgroundColor3 = Color3.fromRGB(80, 255, 80) 
				})
				local strokeTween = TweenService:Create(badgeStroke, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Thickness = 1 
				})
				leaveTween:Play()
				strokeTween:Play()
			end)
		end

		if updateData.image and updateData.image.assetId then
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Size = UDim2.new(0, updateData.image.banner and 200 or 100, 0, 100 * updateData.image.aspectRatio)
			imageLabel.Position = UDim2.new(1, updateData.image.banner and -220 or -120, 0, 15)
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

		entryFrame.Parent = scrollingFrame
		local entryTween = TweenService:Create(entryFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0
		})
		entryTween:Play()

		task.spawn(function()
			task.wait(0.1)
			local finalHeight = bodyLabel.TextBounds.Y
			if finalHeight ~= textHeight then
				bodyLabel.Size = UDim2.new(1, -30, 0, finalHeight)
				entryFrame.Size = UDim2.new(1, 0, 0, finalHeight + padding)
				scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 30)
			end
		end)
	end

	for _, update in ipairs(changelogData) do
		createUpdateEntry(update)
		task.wait(0.1) 
	end

	task.wait()
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 30)

	closeButton.MouseButton1Click:Connect(function()
		local closeTween = TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
			Position = UDim2.new(0.5, 0, 1.05, 0),
			BackgroundTransparency = 1
		})
		closeTween:Play()
		closeTween.Completed:Connect(function()
			screenGui:Destroy()
			save()
		end)
	end)
end

local notificationSys = NotificationSystem.new()
notificationSys:CreateNotification(
	"New Update Available!",
	"A new Voidware update (" .. (newest.title or "v" .. newest.updateLogId) .. ") is here! Open the changelog?",
	true, 
	function()
		createChangelogUI()
	end,
	function() 
		save()
	end
)