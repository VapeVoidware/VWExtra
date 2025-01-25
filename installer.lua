local API = {
	__color = Color3.fromRGB(221, 222, 207)
}
API.Register = {}
API.Services = {
	TweenService = game:GetService("TweenService"),
	RunService = game:GetService("RunService"),
	HttpService = game:GetService("HttpService")
}

local function randomString()
	local array = {}
	for i = 1, math.random(10, 100) do
		array[i] = string.char(math.random(32, 126))
	end
	return table.concat(array)
end

function API:Clean(element)
	local Register = self.Register[element]
	if Register then
		for i,v in pairs(Register.Parts) do
			pcall(function()
				v:Destroy()
			end)
		end
		for i,v in pairs(Register.Connections) do
			pcall(function()
				v:Disconnect()
			end)
		end
		self.Register[element] = nil
	end
end

function API:Init()
	return {Parts = {}, Connections = {}}
end

function API:CreateElement(args)
	local _element = Instance.new(args.ClassName, args.Parent)
	local core = {"ClassName", "Parent"}
	for i,v in pairs(args) do
		if not table.find(core, tostring(i)) then
			local suc, err = pcall(function()
				_element[i] = v
			end)
			if err then
				local notif = "[API:CreateElement]: Failure in loading args - "..tostring(err)
				warn(debug.traceback(notif))
			end
			--[[if _element[i] then
				_element[i] = v
			else
				local notif = '[API:CreateElement]: Element ('..tostring(_element)..") doesn't have "..tostring(i).."! Check your spelling please."
				warn(debug.traceback(notif))
			end--]]
		end
	end
	return _element
end

function API:CreateDownloadingContainer(parent)
	local self = API
	
	local Downloading_API = {}
	
	local _container = self:CreateElement({
		ClassName = "ImageLabel",
		Parent = parent,
		Name = "_CONTAINER",
		Archivable = true,
		Active = false,
		AnchorPoint = Vector2.new(0.5, 0.5),
		AutomaticSize = Enum.AutomaticSize.None,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderMode = Enum.BorderMode.Outline,
		BorderSizePixel = 0,
		Interactable = true,
		LayoutOrder = 0,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Rotation = 0,
		Size = UDim2.new(0.5, 0, 0.05, 0),
		SizeConstraint = Enum.SizeConstraint.RelativeXY,
		Visible = true,
		ZIndex = 1,
		ClipsDescendants = false,
		Image = "rbxassetid://79522799650481",
		ImageColor3 = Color3.fromRGB(19, 21, 27),
		ImageTransparency = 0,
		ScaleType = Enum.ScaleType.Stretch,
		AutoLocalize = true
	})
	
	local _rect = self:CreateElement({
		ClassName = "ImageLabel",
		Parent = _container,
		Name = "_RECT",
		Archivable = true,
		Active = false,
		AnchorPoint = Vector2.new(0, 0),
		AutomaticSize = Enum.AutomaticSize.None,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderMode = Enum.BorderMode.Outline,
		BorderSizePixel = 0,
		Interactable = true,
		LayoutOrder = 0,
		Position = UDim2.new(0, 0, 0, 0),
		Rotation = 0,
		Size = UDim2.new(0.5, 0, 1, 0),
		SizeConstraint = Enum.SizeConstraint.RelativeXY,
		Visible = true,
		ZIndex = 1,
		ClipsDescendants = false,
		Image = "rbxassetid://79522799650481",
		ImageColor3 = Color3.fromRGB(255, 255, 255),
		ImageTransparency = 0,
		ScaleType = Enum.ScaleType.Stretch,
		AutoLocalize = true
	})
	
	local _gradient = self:CreateElement({
		ClassName = "UIGradient",
		Parent = _rect,
		Name = "_GRADIENT",
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
		}),
		Enabled = true,
		Rotation = 0,
		Transparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 0)
		},
		Archivable = true
	})
	
	local _info = self:CreateElement({
		ClassName = "TextLabel",
		Parent = parent,
		Name = "_INFO",
		Archivable = true,
		AnchorPoint = Vector2.new(0.5, 1),
		AutomaticSize = Enum.AutomaticSize.None,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderMode = Enum.BorderMode.Outline,
		BorderSizePixel = 0,
		Interactable = true,
		LayoutOrder = 0,
		Position = UDim2.new(0.5, 0, 0.95, 0),
		Rotation = 0,
		Size = UDim2.new(1, 0, 0, 35),
		SizeConstraint = Enum.SizeConstraint.RelativeXY,
		Visible = true,
		ZIndex = 1,
		ClipsDescendants = false,
		AutoLocalize = true,
		LineHeight = 1,
		MaxVisibleGraphemes = -1,
		RichText = false,
		Text = "Downloading...",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextDirection = Enum.TextDirection.Auto,
		TextScaled = true,
		TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
		TextStrokeTransparency = 1
	})
	
	Downloading_API = {
		Container = _container,
		Rect = _rect,
		Gradient = _gradient,
		Info = _info
	}
	
	return Downloading_API
end

function API:CreateConfigsTemplate(parent)
	local self = API
	local _template = self:CreateElement({
		ClassName = "Frame",
		Parent = parent,
		Name = "_TEMPLATE",
		Archivable = true,
		Active = false,
		AnchorPoint = Vector2.new(0, 0),
		AutomaticSize = Enum.AutomaticSize.None,
		BackgroundColor3 = Color3.fromRGB(0, 11, 20),
		BackgroundTransparency = 0.22,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Interactable = true,
		LayoutOrder = 0,
		Rotation = 0,
		Size = UDim2.new(1, 0, 0, 75),
		SizeConstraint = Enum.SizeConstraint.RelativeXY,
		Visible = true,
		ZIndex = 1,
		ClipsDescendants = false,
		AutoLocalize = true
	})
	
	local _corner = self:CreateElement({
		ClassName = "UICorner",
		Parent = _template,
		Name = "_CORNER",
		CornerRadius = UDim.new(0, 8),
		Archivable = true
	})
	
	local _extra = self:CreateElement({
		ClassName = "Frame",
		Parent = _template,
		Name = "_EXTRA",
		Archivable = true,
		Active = false,
		AnchorPoint = Vector2.new(0, 0.5),
		AutomaticSize = Enum.AutomaticSize.None,
		BackgroundColor3 = Color3.fromRGB(50, 50, 50),
		--BackgroundTransparency = 0.2,
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Interactable = true,
		LayoutOrder = 0,
		Position = UDim2.new(0.01, 0, 0.5, 0),
		Rotation = 0,
		Size = UDim2.new(0.05, 0, 0.7, 0),
		SizeConstraint = Enum.SizeConstraint.RelativeXY,
		Visible = true,
		ZIndex = 1,
		ClipsDescendants = false,
		AutoLocalize = true
	})
	
	local _extra_corner = self:CreateElement({
		ClassName = "UICorner",
		Parent = _extra,
		Name = "_CORNER",
		CornerRadius = UDim.new(0, 10),
		Archivable = true
	})
	
	local _extra_image = self:CreateElement({
		ClassName = "ImageLabel",
		Parent = _extra,
		Name = "_IMAGE",
		Archivable = true,
		Active = false,
		AnchorPoint = Vector2.new(0.5, 0.5),
		AutomaticSize = Enum.AutomaticSize.None,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderMode = Enum.BorderMode.Outline,
		BorderSizePixel = 0,
		Interactable = true,
		LayoutOrder = 0,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Rotation = 0,
		--Size = UDim2.new(1, 0, 1, 0),
		Size = UDim2.new(2, 0, 1, 0),
		SizeConstraint = Enum.SizeConstraint.RelativeXY,
		Visible = true,
		ZIndex = 1,
		ClipsDescendants = false, 
		Image = "rbxassetid://87083426448690",
		ImageColor3 = Color3.fromRGB(200, 200, 200),
		ImageTransparency = 0,
		ScaleType = Enum.ScaleType.Fit,
		AutoLocalize = true
	})
	
	local _button = self:CreateElement({
		ClassName = "ImageButton",
		Parent = _template,
		Name = "_BUTTON",
		Active = true,
		AnchorPoint = Vector2.new(1, 0.5),
		AutoButtonColor = true,
		AutomaticSize = Enum.AutomaticSize.None,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderMode = Enum.BorderMode.Outline,
		BorderSizePixel = 0,
		Interactable = true,
		LayoutOrder = 0,
		Modal = false,
		Position = UDim2.new(1, -5, 0.5, 0),
		Rotation = 0,
		Size = UDim2.new(0.2, 0, 1, 0),
		SizeConstraint = Enum.SizeConstraint.RelativeXY,
		Visible = true,
		ZIndex = 1,
		ClipsDescendants = false,
		Image = "rbxassetid://124765638658755",
		ImageColor3 = Color3.fromRGB(255, 255, 255),
		ImageTransparency = 0,
		ScaleType = Enum.ScaleType.Fit,
		AutoLocalize = true
	})
	
	local _title = self:CreateElement({
		ClassName = "TextLabel",
		Parent = _template,
		Name = "_TITLE",
		Archivable = true,
		Active = false,
		AnchorPoint = Vector2.new(0, 0),
		AutomaticSize = Enum.AutomaticSize.None,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderMode = Enum.BorderMode.Outline,
		BorderSizePixel = 0,
		Interactable = true,
		LayoutOrder = 0,
		Position = UDim2.new(0.076, 0, 0.15, 0),
		Rotation = 0,
		Size = UDim2.new(1, -90, 0, 25),
		SizeConstraint = Enum.SizeConstraint.RelativeXY,
		Visible = true,
		ZIndex = 1,
		ClipsDescendants = false,
		AutoLocalize = true,
		LineHeight = 1,
		MaxVisibleGraphemes = -1,
		RichText = true,
		Text = "<font color='#ffffff'>Config: </font><b>Blatant</b>",
		TextColor3 = Color3.fromRGB(142, 45, 226),
		TextDirection = Enum.TextDirection.Auto,
		TextSize = 13,
		TextScaled = true,
		TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
		TextStrokeTransparency = 1,
		TextTransparency = 0,
		TextTruncate = Enum.TextTruncate.None,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center
	})
	
	local _description = self:CreateElement({
		ClassName = "TextLabel",
		Parent = _template,
		Name = "_DESCRIPTION",
		Archivable = true,
		Active = false,
		AnchorPoint = Vector2.new(0, 0),
		AutomaticSize = Enum.AutomaticSize.None,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderMode = Enum.BorderMode.Outline,
		BorderSizePixel = 0,
		Interactable = true,
		Position = UDim2.new(0.076, 0, 0.55, 0),
		Rotation = 0,
		Size = UDim2.new(1, -90, 0, 20),
		SizeConstraint = Enum.SizeConstraint.RelativeXY,
		Visible = true,
		ZIndex = 1,
		ClipsDescendants = false,
		AutoLocalize = true,
		LineHeight = 1,
		MaxVisibleGraphemes = -1,
		RichText = true,
		Text = "Embrace the thrill of going full throttle with this config!",
		TextColor3 = Color3.fromRGB(170, 170, 170),
		TextDirection = Enum.TextDirection.Auto,
		TextScaled = true,
		TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
		TextStrokeTransparency = 1,
		TextTransparency = 0,
		TextTruncate = Enum.TextTruncate.None,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center
	})
	
	return {
		Instance = _template,
		Title = _title,
		Description = _description,
		Button = _button,
		Image = _extra_image
	}
end

function API:CreateUI()
	
	local UI_API = {}
	
	local lplr = game:GetService("Players").LocalPlayer
	local gui = lplr.PlayerGui
	
	local _core = self:CreateElement({
		ClassName = "ScreenGui",
		Parent = gui,
		Name = randomString(),
		SafeAreaCompatibility = Enum.SafeAreaCompatibility.None,
		ScreenInsets = Enum.ScreenInsets.None,
		Archivable = true,
		Enabled = true,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		AutoLocalize = true
	})
	
	API.Instance = _core
	
	local _scale = self:CreateElement({
		ClassName = "UIScale",
		Parent = _core,
		Name = "__SCALE",
		--Scale = 0.5
		Scale = 1
	})
	
	local _background = self:CreateElement({
		ClassName = "ImageLabel",
		Parent = _core,
		Name = "__BACKGROUND",
		Active = false,
		AnchorPoint = Vector2.new(0.5, 0.5),
		AutomaticSize = Enum.AutomaticSize.None,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderMode = Enum.BorderMode.Outline,
		BorderSizePixel = 0,
		Interactable = true,
		LayoutOrder = 0,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Rotation = 0,
		Size = UDim2.new(1, 0, 1, 0),
		SizeConstraint = Enum.SizeConstraint.RelativeXY,
		Visible = true,
		ZIndex = 1,
		ClipsDescendants = false,
		Image = "rbxassetid://88286925143566",
		ImageColor3 = Color3.fromRGB(255, 255, 255),
		ImageTransparency = 0,
		ScaleType = Enum.ScaleType.Fit,
		AutoLocalize = true
	})
	
	local _container = self:CreateElement({
		ClassName = "Frame",
		Parent = _background,
		Name = "_CONTAINER",
		Archivable = true,
		Active = false,
		AnchorPoint = Vector2.new(0.5, 0.5),
		AutomaticSize = Enum.AutomaticSize.None,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderMode = Enum.BorderMode.Outline,
		BorderSizePixel = 0,
		Interactable = true,
		LayoutOrder = 0,
		Position = UDim2.new(0.5, 0, 0.5, 5),
		Rotation = 0,
		Size = UDim2.new(0.5, 0, 0.7, 0),
		SizeConstraint = Enum.SizeConstraint.RelativeXY,
		Visible = true,
		ZIndex = 1,
		ClipsDescendants = false,
		AutoLocalize = true
	})
	
	local _info = self:CreateElement({
		ClassName = "ImageLabel",
		Parent = _container,
		Name = "_INFO",
		Archivable = true,
		Active = false, 
		AnchorPoint = Vector2.new(0.5, 0),
		AutomaticSize = Enum.AutomaticSize.None,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderMode = Enum.BorderMode.Outline,
		BorderSizePixel = 0,
		Interactable = true,
		LayoutOrder = 0,
		Position = UDim2.new(0.5, 0, 0.25, 0),
		Rotation = 0,
		Size = UDim2.new(0.4, 0, 0.05, 0),
		SizeConstraint = Enum.SizeConstraint.RelativeXY,
		Visible = true,
		ZIndex = 1,
		ClipsDescendants = false,
		Image = "rbxassetid://99239684647571",
		ImageColor3 = Color3.fromRGB(255, 255, 255),
		ImageTransparency = 0,
		ScaleType = Enum.ScaleType.Fit,
		AutoLocalize = true
	})
	
	local _configs = self:CreateElement({
		ClassName = "CanvasGroup",
		Parent = _container,
		Name = "_CONFIGS",
		GroupColor3 = Color3.fromRGB(255, 255, 255),
		GroupTransparency = 0,
		Archivable = true,
		Active = false,
		AnchorPoint = Vector2.new(0.5, 0),
		AutomaticSize = Enum.AutomaticSize.None,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderMode = Enum.BorderMode.Outline,
		BorderSizePixel = 0,
		Interactable = true,
		LayoutOrder = 0,
		Position = UDim2.new(0.5, 0, 0.325, 0),
		Rotation = 0,
		Size = UDim2.new(0.98, 0, 0.665, 0),
		SizeConstraint = Enum.SizeConstraint.RelativeXY,
		Visible = true,
		ZIndex = 1,
		AutoLocalize = true
	})
	
	local _configs_scroll = self:CreateElement({
		ClassName = "ScrollingFrame",
		Parent = _configs,
		Name = "_SCROLL",
		Archivable = true,
		Active = true,
		AnchorPoint = Vector2.new(0, 0),
		AutomaticSize = Enum.AutomaticSize.None,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderMode = Enum.BorderMode.Outline,
		BorderSizePixel = 0,
		Interactable = true,
		LayoutOrder = 0,
		Position = UDim2.new(0.05, 0, 0, 0),
		Rotation = 0,
		Size = UDim2.new(0.9, 0, 1, 0),
		SizeConstraint = Enum.SizeConstraint.RelativeXY,
		Visible = true,
		ZIndex = 1,
		ClipsDescendants = true,
		AutoLocalize = true,
		BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png",
		CanvasPosition = Vector2.new(0, 0),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.XY,
		ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
		MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
		ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
		ScrollBarImageTransparency = 0,
		ScrollBarThickness = 2,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollingEnabled = true,
		TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png",
		VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right
	})
	
	local _configs_scroll_list = self:CreateElement({
		ClassName = "UIListLayout",
		Parent = _configs_scroll,
		Name = "_LIST",
		Padding = UDim.new(0, 14),
		Archivable = true,
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.Name,
		Wraps = false,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		ItemLineAlignment = Enum.ItemLineAlignment.Automatic,
		VerticalAlignment = Enum.VerticalAlignment.Top
	})
	
	local _downloading = self:CreateElement({
		ClassName = "CanvasGroup",
		Parent = _container,
		Name = "_DOWNLOADING",
		GroupColor3 = Color3.fromRGB(255, 255, 255),
		GroupTransparency = 1,
		Active = false, 
		AnchorPoint = Vector2.new(0.5, 0),
		AutomaticSize = Enum.AutomaticSize.None,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderMode = Enum.BorderMode.Outline,
		BorderSizePixel = 0,
		Interactable = true,
		LayoutOrder = 0,
		Position = UDim2.new(0.5, 0, 0.325, 0),
		Rotation = 0,
		Size = UDim2.new(0.98, 0, 0.665, 0),
		SizeConstraint = Enum.SizeConstraint.RelativeXY,
		Visible = true,
		ZIndex = 1,
		AutoLocalize = true
	})
	
	local _downloading_container = self:CreateDownloadingContainer(_downloading)
	_downloading_container.Rect.Size = UDim2.new(0, 0, 1, 0)
	
	task.spawn(function()
		local Magic = {
			API.__color, API:GetSimilarColor(API.__color)
		}
		local function mix(firstColor, secondColor, blendFactor)
			local inverseBlendFactor = 1 - blendFactor
			return Color3.new(
				firstColor.R * blendFactor + secondColor.R * inverseBlendFactor,
				firstColor.G * blendFactor + secondColor.G * inverseBlendFactor,
				firstColor.B * blendFactor + secondColor.B * inverseBlendFactor
			)
		end
		local u_time = 0
		local con = API.Services.RunService.RenderStepped:Connect(function(deltaTime)
			Magic = API:UpdateColors(Magic)
			u_time = u_time + deltaTime
			local colorseq = {}
			for i = 0, 19, 1 do
				local color = mix(Magic[1], Magic[2], 0.5 + 0.5 * math.sin(3.0 * (i / 19 + u_time)))
				table.insert(colorseq, ColorSequenceKeypoint.new(i / 19, color))
			end
			local cx = ColorSequence.new(colorseq)
			_downloading_container.Gradient.Color = cx
		end)
		API.Register.DownloadRegister = API.Register.DownloadRegister or API:Init()
		table.insert(API.Register.DownloadRegister.Connections, con)
	end)
	
	UI_API.DownloadingAPI = _downloading_container
	UI_API.DownloadingInfo = _downloading_container.Info
	UI_API.DownloadingRect = _downloading_container.Rect
	
	UI_API.Configs = _configs
	UI_API.Downloading = _downloading
	
	UI_API.CloseDownloadingTab = function(ignore)
		_downloading.GroupTransparency = 1
		if (not ignore) then
			_configs.GroupTransparency = 0
		end
	end

	UI_API.OpenDownloadingTab = function(ignore)
		_downloading.GroupTransparency = 0
		if (not ignore) then
			_configs.GroupTransparency = 1
		end
	end
	
	UI_API.CloseConfigsTab = function(ignore)
		_configs.GroupTransparency = 1
		if (not ignore) then
			_downloading.GroupTransparency = 0
		end
	end
	
	UI_API.OpenConfigsTab = function(ignore)
		_configs.GroupTransparency = 0
		if (not ignore) then
			_downloading.GroupTransparency = 1
		end
	end
	
	UI_API.CreateConfigButton = function(args)
		local Name, Description, Callback, Image, Color = args.Name, args.Description, args.Callback, args.Image, args.Color
		local Register = API:Init()
		local _configbutton = API:CreateConfigsTemplate(_configs_scroll)
		_configbutton.Title.Text = "<font color='#ffffff'>Config: </font><b>"..Name.."</b>"
		_configbutton.Description.Text = Description
		if Image then
			_configbutton.Image.Image = Image
		end
		_configbutton.Image.Visible = false
		if Color then
			_configbutton.Title.TextColor3 = Color
		end
		table.insert(Register.Connections, _configbutton.Button.MouseButton1Click:Connect(Callback))
		table.insert(Register.Parts, _configbutton.Instance)
		
		local ID = randomString()
		_configbutton.Instance:SetAttribute("ID", ID)
		
		API.Register[ID] = Register
	end
	
	UI_API.DestroyUI = function()
		API:SelfDestruct()
	end
	
	return UI_API
end

API.__old = Color3.fromRGB(0, 0, 0)
function API:UpdateColors(_old)
	if API.__old ~= API.__color then
		API.__old = API.__color
		return {
			API.__color, API:GetSimilarColor(API.__color)
		}
	else
		return _old
	end
end

function API:GetSimilarColor(color, variance)
	variance = variance or 15 

	local function clamp(value)
		return math.clamp(value, 0, 255)
	end

	local r = clamp(color.R * 255 + math.random(-variance, variance))
	local g = clamp(color.G * 255 + math.random(-variance, variance))
	local b = clamp(color.B * 255 + math.random(-variance, variance))

	return Color3.fromRGB(r, g, b)
end

function API:SelfDestruct()
	for i,v in pairs(API.Register) do
		API:Clean(i)
	end
	self.Instance:Destroy()
end

function API:CreateDownloadingAPI(api)
	local _api = {
		_abort = false,
		_debug = {},
		Status = 0,
		Tasks = {},
		API = api,
		INFO = api.DownloadingInfo,
		RECT = api.DownloadingRect
	}
	function _api:Init()
		local con = API.Services.RunService.RenderStepped:Connect(function()
			API:CreateTween(_api.RECT, {Size = UDim2.new(_api.Status/100, 0, 1, 0)}):Play()
		end)
		API.Register.DownloadRegister = API.Register.DownloadRegister or API:Init()
		table.insert(API.Register.DownloadRegister.Connections, con)
	end
	function _api:Abort(err)
		self.INFO.Text = "Failure: "..tostring(err).."! Aborting..."
		warn(debug.traceback(self.INFO.Text))
		_api._abort = true
		_api:Clean()
		task.wait(1)
		_api.API.CloseDownloadingTab()
	end
	function _api:Clean()
		table.clear(_api.Tasks)
		API:Clean("DownloadRegister")
		API.Register.DownloadRegister = API:Init()
	end
	function _api:GiveTask(_task, add)
		table.insert(self.Tasks, {
			Task = _task,
			Add = add
		})
		local suc, err = pcall(function()
			_task()
		end)
		if (not suc) then
			_api:Abort(err)
		else
			_api.Status += add
		end
	end
	function _api:SelfDestruct()
		self.INFO.Text = "Success! Closing the installer in 5 seconds..."

		local initialTween = API.Services.TweenService:Create(
			_api.RECT, 
			TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
			{ Size = UDim2.new(0, 0, 1, 0) }
		)
		initialTween:Play()
		initialTween.Completed:Wait() 

		local closeTween = API.Services.TweenService:Create(
			_api.RECT, 
			TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
			{ Size = UDim2.new(1, 0, 1, 0) }
		)
		closeTween:Play()
		closeTween.Completed:Wait() 

		API:SelfDestruct()
	end
	
	_api.Change = function(text)
		_api.INFO.Text = tostring(text)
	end

	function _api:Boot(_end)
		for i,v in pairs(self.Tasks) do
			if _api._abort then break end
			local suc, err = pcall(function()
				v.Task()
			end)
			if (not suc) then
				_api:Abort(err)
			else
				table.insert(_api._debug, {
					Task = i
				})
				_api.Tasks[i] = nil
				if _api.Status + v.Add > 100 then 
					_api.Status = 100
				else
					_api.Status += v.Add
				end
				if _api.Status == 100 then
					_api:Clean()
					if _end ~= nil and type(_end) == "function" then
						_end()
					else
						_api:SelfDestruct()
					end
				end
			end
		end
	end
	return _api
end

local tweenDuration = 1
local tweenInfo = TweenInfo.new(tweenDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

function API:CreateTween(target, propertyTable)
	return API.Services.TweenService:Create(target, tweenInfo, propertyTable)
end

local a = API:CreateUI()
a.CloseConfigsTab(true)
a.CloseDownloadingTab(true)
local _main = 'https://api.github.com/repos/Erchobg/VoidwareProfiles/contents/Installer/'
local __main = 'https://raw.githubusercontent.com/Erchobg/VoidwareProfiles/main/Installer/'
local __dir = ''
local InstallerAPI = {}
function InstallerAPI:FetchFiles(dir)
	__dir = dir.."/"
	local __files = {}
	local _dir = _main..dir..'?ref=main'
	local res = request({
		Url = _dir,
		Method = "GET"
	})
	if res.StatusCode == 200 then
		local _data = API.Services.HttpService:JSONDecode(res.Body)
		for i,v in next, _data do 
			if type(v) == 'table' and v.name and v.name ~= '.DS_Store' then 
				table.insert(__files, v.name) 
			end
		end
		return __files
	else
		return error("Failure fetching profiles")
	end
end
function InstallerAPI:Check()
	if (not isfolder('vape')) then makefolder('vape') end
	if (not isfolder('rise')) then makefolder('rise') end
	if (not isfolder('vape/profiles')) then makefolder('vape/profiles') end
	if (not isfolder('rise/profiles')) then makefolder('rise/profiles') end
end
function InstallerAPI:InstallFiles(__files, _api)
	self:Check()
	for i,v in pairs(__files) do
		_api.Change("Downloading "..v.."...")
		print(__main..__dir..v)
		local res = game:HttpGet(__main..__dir..v)
		writefile('vape/profiles/'..v, res)
		writefile('rise/profiles/'..v, res)
	end
end
InstallerAPI.Callback = function(dir, color)
	return function()
		a.CloseConfigsTab()
		if color then
			API.__color = Color3.fromRGB(unpack(color))
		end
		if dir then
			local __files = {}
			local DownloadAPI = API:CreateDownloadingAPI(a, unpack(color))
			DownloadAPI:Init()
			DownloadAPI:GiveTask(function()
				DownloadAPI.Change("Fetching Profiles...")
				__files = InstallerAPI:FetchFiles(dir)
			end, 10)
			DownloadAPI:GiveTask(function()
				DownloadAPI.Change("Downloading Profiles...")
				InstallerAPI:InstallFiles(__files, DownloadAPI)
			end, 70)
			DownloadAPI:GiveTask(function()
				DownloadAPI.Change("Finishing up...")
				task.wait(1)
			end, 20)
			DownloadAPI:Boot()
		end
	end
end
a.CreateConfigButton({
	Name = "Blood",
	Description = "🩸",
	Callback = InstallerAPI.Callback('VWBlood', {220, 20, 60}),
	Image = "rbxassetid://14368301329",
	Color = Color3.fromRGB(220, 20, 60)
})
a.CreateConfigButton({
	Name = "Pink",
	Description = "🌸",
	Callback = InstallerAPI.Callback('VWPink', {255, 192, 203}),
	Image = "rbxassetid://14368301329",
	Color = Color3.fromRGB(255, 192, 203)
})
a.CreateConfigButton({
	Name = "Blue",
	Description = "🌊",
	Callback = InstallerAPI.Callback('VWBlue', {0, 122, 255}),
	Image = "rbxassetid://14368301329",
	Color = Color3.fromRGB(0, 122, 255)
})
a.CreateConfigButton({
	Name = "Orange",
	Description = "🍊",
	Callback = InstallerAPI.Callback('VWOrange', {255, 165, 0}),
	Image = "rbxassetid://14368301329",
	Color = Color3.fromRGB(255, 165, 0)
})
a.CreateConfigButton({
	Name = "Rainbow",
	Description = "🌈",
	Callback = InstallerAPI.Callback('VWRainbow', {255, 105, 180}),
	Image = "rbxassetid://14368301329",
	Color = Color3.fromRGB(255, 105, 180)
})
a.CreateConfigButton({
	Name = "Purple",
	Description = "🟣",
	Callback = InstallerAPI.Callback('VWPurple', {138, 43, 226}),
	Image = "rbxassetid://14368301329",
	Color = Color3.fromRGB(138, 43, 226)
})
a.OpenConfigsTab()
shared.Instance = API.Instance