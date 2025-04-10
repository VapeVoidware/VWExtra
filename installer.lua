pcall(function()
	if shared.vape then shared.vape:Uninject() end
	if shared.GuiLibrary then shared.GuiLibrary:SelfDestruct() end
end)

local API = {
	Services = {
		TweenService = game:GetService("TweenService"),
		RunService = game:GetService("RunService"),
		HttpService = game:GetService("HttpService")
	},
	Register = {},
	ThemeColor = Color3.fromRGB(221, 222, 207)
}

local function randomString()
	local array = {}
	for i = 1, math.random(10, 20) do
		array[i] = string.char(math.random(32, 126))
	end
	return table.concat(array)
end

function API:Clean(element)
	local reg = self.Register[element]
	if reg then
		for _, part in pairs(reg.Parts) do pcall(part.Destroy, part) end
		for _, conn in pairs(reg.Connections) do pcall(conn.Disconnect, conn) end
		self.Register[element] = nil
	end
end

function API:Init()
	return {Parts = {}, Connections = {}}
end

function API:CreateElement(args)
	local element = Instance.new(args.ClassName, args.Parent)
	for key, value in pairs(args) do
		if key ~= "ClassName" and key ~= "Parent" then
			pcall(function() element[key] = value end)
		end
	end
	return element
end

function API:CreateTween(target, props, duration, style, direction)
	duration = duration or 0.5
	style = style or Enum.EasingStyle.Cubic
	direction = direction or Enum.EasingDirection.Out
	return self.Services.TweenService:Create(target, TweenInfo.new(duration, style, direction), props)
end

function API:CreateDownloadingContainer(parent)
	local container = self:CreateElement({
		ClassName = "Frame",
		Parent = parent,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0.8, 0, 0.12, 0),
		BackgroundColor3 = Color3.fromRGB(35, 35, 45),
		BorderSizePixel = 0
	})
	local corner = self:CreateElement({ClassName = "UICorner", Parent = container, CornerRadius = UDim.new(0, 10)})
	local glow = self:CreateElement({
		ClassName = "ImageLabel",
		Parent = container,
		Size = UDim2.new(1, 50, 1, 50),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = "rbxassetid://14898786664",
		ImageTransparency = 0.7,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(52, 31, 261, 502)
	})
	
	local progress = self:CreateElement({
		ClassName = "Frame",
		Parent = container,
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = self.ThemeColor,
		BorderSizePixel = 0
	})
	local progressCorner = self:CreateElement({ClassName = "UICorner", Parent = progress, CornerRadius = UDim.new(0, 10)})
	local gradient = self:CreateElement({
		ClassName = "UIGradient",
		Parent = progress,
		Color = ColorSequence.new(self.ThemeColor, self:GetSimilarColor(self.ThemeColor)),
		Rotation = 45,
		Offset = Vector2.new(0, 0)
	})
	
	local info = self:CreateElement({
		ClassName = "TextLabel",
		Parent = parent,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 0.65, 0),
		Size = UDim2.new(0.9, 0, 0, 35),
		BackgroundTransparency = 1,
		Text = "Downloading...",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextScaled = true,
		Font = Enum.Font.FredokaOne,
		TextTransparency = 0.1
	})
	local infoGlow = self:CreateElement({
		ClassName = "UIStroke",
		Parent = info,
		Thickness = 2,
		Color = self.ThemeColor,
		Transparency = 0.5
	})
	
	return {Container = container, Progress = progress, Gradient = gradient, Info = info}
end

function API:CreateConfigButton(parent, config)
	local button = self:CreateElement({
		ClassName = "TextButton",
		Parent = parent,
		Size = UDim2.new(1, -10, 0, 70),
		BackgroundColor3 = Color3.fromRGB(40, 40, 50),
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false
	})
	local corner = self:CreateElement({ClassName = "UICorner", Parent = button, CornerRadius = UDim.new(0, 10)})
	local glow = self:CreateElement({
		ClassName = "ImageLabel",
		Parent = button,
		Size = UDim2.new(1, 40, 1, 40),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = "rbxassetid://14898786664",
		ImageTransparency = 0.8,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(52, 31, 261, 502)
	})
	
	local title = self:CreateElement({
		ClassName = "TextLabel",
		Parent = button,
		Position = UDim2.new(0, 15, 0, 8),
		Size = UDim2.new(1, -90, 0, 25),
		BackgroundTransparency = 1,
		Text = "<b>" .. config.name .. "</b>",
		TextColor3 = Color3.fromRGB(unpack(config.color)),
		TextSize = 20,
		TextXAlignment = Enum.TextXAlignment.Left,
		RichText = true,
		Font = Enum.Font.FredokaOne
	})
	
	local desc = self:CreateElement({
		ClassName = "TextLabel",
		Parent = button,
		Position = UDim2.new(0, 15, 0, 35),
		Size = UDim2.new(1, -90, 0, 30),
		BackgroundTransparency = 1,
		Text = config.description,
		TextColor3 = Color3.fromRGB(180, 180, 200),
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Font = Enum.Font.SourceSans
	})
	
	local install = self:CreateElement({
		ClassName = "TextButton",
		Parent = button,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -15, 0.5, 0),
		Size = UDim2.new(0, 70, 0, 35),
		BackgroundColor3 = Color3.fromRGB(80, 255, 80),
		Text = "Install",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.FredokaOne,
		TextSize = 18
	})
	local installCorner = self:CreateElement({ClassName = "UICorner", Parent = install, CornerRadius = UDim.new(0, 8)})
	local installGlow = self:CreateElement({
		ClassName = "UIStroke",
		Parent = install,
		Thickness = 2,
		Color = Color3.fromRGB(100, 255, 100),
		Transparency = 0.6
	})
	
	button.MouseEnter:Connect(function()
		self:CreateTween(button, {BackgroundColor3 = Color3.fromRGB(50, 50, 60)}, 0.3, Enum.EasingStyle.Sine):Play()
		self:CreateTween(glow, {ImageTransparency = 0.6}, 0.3, Enum.EasingStyle.Sine):Play()
	end)
	button.MouseLeave:Connect(function()
		self:CreateTween(button, {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}, 0.3, Enum.EasingStyle.Sine):Play()
		self:CreateTween(glow, {ImageTransparency = 0.8}, 0.3, Enum.EasingStyle.Sine):Play()
	end)
	install.MouseEnter:Connect(function()
		self:CreateTween(install, {BackgroundColor3 = Color3.fromRGB(100, 255, 100)}, 0.3, Enum.EasingStyle.Sine):Play()
		self:CreateTween(installGlow, {Transparency = 0.3}, 0.3, Enum.EasingStyle.Sine):Play()
	end)
	install.MouseLeave:Connect(function()
		self:CreateTween(install, {BackgroundColor3 = Color3.fromRGB(80, 255, 80)}, 0.3, Enum.EasingStyle.Sine):Play()
		self:CreateTween(installGlow, {Transparency = 0.6}, 0.3, Enum.EasingStyle.Sine):Play()
	end)
	
	return {Button = button, Install = install}
end

function API:CreateUI()
	local gui = game:GetService("Players").LocalPlayer.PlayerGui
	local core = self:CreateElement({
		ClassName = "ScreenGui",
		Parent = gui,
		Name = randomString(),
		IgnoreGuiInset = true,
		ResetOnSpawn = false
	})
	self.Instance = core
	
	local background = self:CreateElement({
		ClassName = "Frame",
		Parent = core,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(25, 25, 35),
		BorderSizePixel = 0
	})
	local corner = self:CreateElement({ClassName = "UICorner", Parent = background, CornerRadius = UDim.new(0, 14)})
	local glow = self:CreateElement({
		ClassName = "ImageLabel",
		Parent = background,
		Size = UDim2.new(1, 60, 1, 60),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = "rbxassetid://14898786664",
		ImageTransparency = 0.6,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(52, 31, 261, 502)
	})
	
	local title = self:CreateElement({
		ClassName = "TextLabel",
		Parent = background,
		Position = UDim2.new(0, 15, 0, 15),
		Size = UDim2.new(1, -60, 0, 35),
		BackgroundTransparency = 1,
		Text = "Voidware Installer",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 28,
		Font = Enum.Font.FredokaOne,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	local titleGlow = self:CreateElement({
		ClassName = "UIStroke",
		Parent = title,
		Thickness = 2,
		Color = Color3.fromRGB(255, 255, 255),
		Transparency = 0.4
	})
	
	local closeButton = self:CreateElement({
		ClassName = "TextButton",
		Parent = background,
		Size = UDim2.new(0, 35, 0, 35),
		Position = UDim2.new(1, -45, 0, 10),
		BackgroundColor3 = Color3.fromRGB(255, 80, 80),
		Text = "×",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.FredokaOne,
		TextSize = 24
	})
	local closeCorner = self:CreateElement({ClassName = "UICorner", Parent = closeButton, CornerRadius = UDim.new(0, 10)})
	local closeGlow = self:CreateElement({
		ClassName = "ImageLabel",
		Parent = closeButton,
		Size = UDim2.new(1, 40, 1, 40),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = "rbxassetid://14898786664",
		ImageTransparency = 0.7,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(52, 31, 261, 502)
	})
	
	closeButton.MouseEnter:Connect(function()
		self:CreateTween(closeButton, {BackgroundColor3 = Color3.fromRGB(255, 120, 120)}, 0.3, Enum.EasingStyle.Sine):Play()
		self:CreateTween(closeGlow, {ImageTransparency = 0.5}, 0.3, Enum.EasingStyle.Sine):Play()
	end)
	closeButton.MouseLeave:Connect(function()
		self:CreateTween(closeButton, {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}, 0.3, Enum.EasingStyle.Sine):Play()
		self:CreateTween(closeGlow, {ImageTransparency = 0.7}, 0.3, Enum.EasingStyle.Sine):Play()
	end)
	closeButton.MouseButton1Click:Connect(function()
		local closeTween = self:CreateTween(background, {
			Size = UDim2.new(0.55, 0, 0, 0),
			Position = UDim2.new(0.5, 0, 0.2, 0)
		}, 0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		self:CreateTween(glow, {ImageTransparency = 1}, 0.6, Enum.EasingStyle.Sine):Play()
		self:CreateTween(background, {BackgroundTransparency = 0.5}, 0.6, Enum.EasingStyle.Sine):Play()
		closeTween:Play()
		closeTween.Completed:Connect(function()
			self:SelfDestruct()
		end)
	end)
	
	local configs = self:CreateElement({
		ClassName = "ScrollingFrame",
		Parent = background,
		Position = UDim2.new(0, 15, 0, 60),
		Size = UDim2.new(1, -30, 1, -75),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Color3.fromRGB(150, 150, 170),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y
	})
	local list = self:CreateElement({
		ClassName = "UIListLayout",
		Parent = configs,
		Padding = UDim.new(0, 12),
		SortOrder = Enum.SortOrder.LayoutOrder
	})
	
	local downloading = self:CreateElement({
		ClassName = "Frame",
		Parent = background,
		Position = UDim2.new(0, 15, 0, 60),
		Size = UDim2.new(1, -30, 1, -75),
		BackgroundTransparency = 1,
		Visible = false
	})
	local downloadContainer = self:CreateDownloadingContainer(downloading)
	
	self:CreateTween(background, {Size = UDim2.new(0.55, 0, 0.75, 0)}, 0.8, Enum.EasingStyle.Cubic):Play()
	self:CreateTween(glow, {ImageTransparency = 0.6}, 0.8, Enum.EasingStyle.Sine):Play()
	
	local uiAPI = {
		Configs = configs,
		Downloading = downloading,
		DownloadAPI = downloadContainer,
		OpenConfigs = function() 
			self:CreateTween(downloading, {Position = UDim2.new(0, 15, 1, 0)}, 0.5, Enum.EasingStyle.Sine):Play()
			self:CreateTween(configs, {Position = UDim2.new(0, 15, 0, 60)}, 0.5, Enum.EasingStyle.Sine):Play()
			task.wait(0.1)
			downloading.Visible = false
			configs.Visible = true
		end,
		OpenDownloading = function() 
			self:CreateTween(configs, {Position = UDim2.new(0, 15, -1, 0)}, 0.5, Enum.EasingStyle.Sine):Play()
			self:CreateTween(downloading, {Position = UDim2.new(0, 15, 0, 60)}, 0.5, Enum.EasingStyle.Sine):Play()
			task.wait(0.1)
			configs.Visible = false
			downloading.Visible = true
		end,
		Destroy = function() self:SelfDestruct() end
	}
	
	return uiAPI
end

function API:CreateDownloadAPI(ui)
	local download = {
		Status = 0,
		Tasks = {},
		Info = ui.DownloadAPI.Info,
		Progress = ui.DownloadAPI.Progress,
		Gradient = ui.DownloadAPI.Gradient
	}
	
	download.Init = function()
		local conn1 = self.Services.RunService.RenderStepped:Connect(function()
			self:CreateTween(download.Progress, {Size = UDim2.new(download.Status / 100, 0, 1, 0)}, 0.4, Enum.EasingStyle.Sine):Play()
		end)
		local conn2 = self.Services.RunService.RenderStepped:Connect(function(dt)
			local offset = download.Gradient.Offset.X + dt * 0.5 
			if offset > 1 then offset = -1 end
			download.Gradient.Offset = Vector2.new(offset, 0)
		end)
		self.Register.Download = self.Register.Download or self:Init()
		table.insert(self.Register.Download.Connections, conn1)
		table.insert(self.Register.Download.Connections, conn2)
	end
	
	download.AddTask = function(task, weight)
		table.insert(download.Tasks, {Task = task, Weight = weight})
	end
	
	download.Run = function(callback)
		self:Clean("Download")
		download.Init()
		ui.OpenDownloading()
		download.Gradient.Color = ColorSequence.new(API.ThemeColor, self:GetSimilarColor(API.ThemeColor))
		for i, taskData in pairs(download.Tasks) do
			local suc, err = pcall(taskData.Task)
			if not suc then
				download.Info.Text = "Error: " .. err
				self:CreateTween(download.Info, {TextColor3 = Color3.fromRGB(255, 80, 80)}, 0.3, Enum.EasingStyle.Sine):Play()
				task.wait(2)
				ui.OpenConfigs()
				return
			end
			download.Status = math.min(100, download.Status + taskData.Weight)
		end
		download.Info.Text = "Success! Launching in 3 seconds..."
		self:CreateTween(download.Info, {TextColor3 = Color3.fromRGB(80, 255, 80)}, 0.3, Enum.EasingStyle.Sine):Play()
		task.wait(3)
		if callback then callback() end
		self:SelfDestruct()
	end
	
	download.UpdateText = function(text) 
		download.Info.Text = text 
		self:CreateTween(download.Info, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.3, Enum.EasingStyle.Sine):Play()
	end
	
	return download
end

function API:SelfDestruct()
	for id in pairs(self.Register) do self:Clean(id) end
	self.Instance:Destroy()
end

function API:GetSimilarColor(color)
	local r = math.clamp(color.R * 255 + math.random(-50, 50), 0, 255)
	local g = math.clamp(color.G * 255 + math.random(-50, 50), 0, 255)
	local b = math.clamp(color.B * 255 + math.random(-50, 50), 0, 255)
	return Color3.fromRGB(r, g, b)
end

local Installer = {}
function Installer:FetchFiles(dir)
	local url = "https://api.github.com/repos/Erchobg/VoidwareProfiles/contents/Installer/" .. dir .. "?ref=main"
	local res = request({Url = url, Method = "GET"})
	if res.StatusCode == 200 then
		local data = API.Services.HttpService:JSONDecode(res.Body)
		local files = {}
		for _, v in pairs(data) do
			if v.name and v.name ~= ".DS_Store" then table.insert(files, v.name) end
		end
		return files
	end
	error("Failed to fetch files")
end

function Installer:InstallFiles(files, dir, download)
	for _, file in pairs(files) do
		download.UpdateText("Downloading " .. file .. "...")
		local content = game:HttpGet("https://raw.githubusercontent.com/Erchobg/VoidwareProfiles/main/Installer/" .. dir .. "/" .. file)
		for _, folder in pairs({"vape/profiles", "rise/profiles", "vape/libraries", "rise/libraries"}) do
			if not isfolder(folder) then makefolder(folder) end
		end
		for _, path in pairs({"vape/profiles/" .. file, "rise/profiles/" .. file}) do
			if isfile(path) then delfile(path) end
			writefile(path, content)
		end
		for _, lib in pairs({"vape/libraries/profilesinstalled3.txt", "vape/libraries/profilesinstalled5.txt", "rise/libraries/profilesinstalled3.txt", "rise/libraries/profilesinstalled5.txt"}) do
			writefile(lib, "true")
		end
	end
end

local ui = API:CreateUI()
local metaUrl = "https://raw.githubusercontent.com/VapeVoidware/VWExtra/main/InstallerMeta.json" 
local metaData = API.Services.HttpService:JSONDecode(game:HttpGet(metaUrl))
if not metaData or not metaData.configs then error("Failed to load metafile") end

for _, config in pairs(metaData.configs) do
	local btn = API:CreateConfigButton(ui.Configs, config)
	btn.Install.MouseButton1Click:Connect(function()
		API.ThemeColor = Color3.fromRGB(unpack(config.color))
		local download = API:CreateDownloadAPI(ui)
		download.AddTask(function() 
			download.UpdateText("Fetching files...")
			local files = Installer:FetchFiles(config.directory)
			download.Files = files
		end, 20)
		download.AddTask(function() 
			Installer:InstallFiles(download.Files, config.directory, download)
		end, 70)
		download.AddTask(function() 
			download.UpdateText("Finalizing...")
			task.wait(1)
		end, 10)
		download.Run(function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/VWRewrite/main/NewMainScript.lua", true))()
		end)
	end)
end

ui.OpenConfigs()
shared.Instance = API.Instance