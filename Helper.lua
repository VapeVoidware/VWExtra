local timedFunction = function(call, timeout, resFunction)
	timeout = timeout or 3
	local suc, err
	task.spawn(function()
		suc, err = pcall(function()
			return call()
		end)
	end)
	local start = tick()
	repeat
		task.wait()
	until suc ~= nil or tick() - start >= timeout
	if not suc then
		warn(debug.traceback(err))
	end
	if resFunction ~= nil then
		return resFunction(suc, err)
	end
	return suc, err
end

local WindUI

local commit = shared.WIND_UI_CUSTOM_COMMIT or "2b420a0b912cc10d05da639c8bde60eaa2c9f017"

local approved, res = false, nil
for i = 1, 5 do
	timedFunction(
		function()
			return shared.WindUIDevMode
					and isfolder("vwdev")
					and isfile("vwdev/windui.lua")
					and readfile("vwdev/windui.lua")
				or game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/WindUI/"..tostring(commit).."/dist/main.lua", true)
		end,
		5,
		function(suc, err)
			approved = suc
			res = suc and err
		end
	)
	if approved then
		break
	end
	task.wait(1)
end

WindUI = loadstring(res)()

getgenv().Toggles = getgenv().Toggles or {}
getgenv().Options = getgenv().Options or {}

if
	shared.NightsInTheForest
	or shared.VoidwareForsaken
	or shared.VoidwareDoors
	or shared.VoidwareHypershot
	or shared.VoidwareInkGame
	or shared.PlantsVSBrainrots
	or shared.TheForge
then
	shared.VoidwareCustom = true
end

local WindUIAdapter = {}

local function wrapElement(name, element, isToggle)
	local mt = {
		__index = function(self, k)
			if k == "Value" then
				return self:Get()
			elseif k == "Set" then
				return function(_, v)
					self:Set(v)
				end
			else
				return rawget(self, k) or element[k]
			end
		end,
	}
	local wrapper = setmetatable({
		_element = element,
		Get = function(self)
			if
				tostring(self._element.__type) == "Slider"
				and type(self._element.Value) == "table"
				and self._element.Value.Default ~= nil
			then
				return self._element.Value.Default
			elseif tostring(self._element.__type) == "Colorpicker" and self._element.Default ~= nil then
				return self._element.Default
			else
				return self._element.Value
			end
		end,
		Set = function(self, v)
			if self._element.Set then
				self._element:Set(v)
			elseif self._element.Select then
				self._element:Select(v)
			else
				self._element.Value = v
			end
		end,
		SetValue = function(self, v)
			return self:Set(v)
		end,
		SetVisible = function(self, vis)
			if not (self._element ~= nil and self._element.Visible ~= nil) then
				return
			end
			if vis == nil then
				vis = not self._element.Visible
			end
			self._element.Visible = vis
		end,
	}, mt)
	if isToggle then
		wrapper.Get = function(self)
			return self._element.Value
		end
		wrapper.Set = function(self, v)
			self._element:Set(v)
		end
	end
	return wrapper
end

local HttpService = game:GetService("HttpService")

local folderPath = "WindUI"
if not isfolder(folderPath) then
	makefolder(folderPath)
end

local function SaveFile(fileName, data)
	local filePath = folderPath .. "/" .. fileName .. ".json"
	local jsonData = HttpService:JSONEncode(data)
	writefile(filePath, jsonData)
end

local function LoadFile(fileName)
	local filePath = folderPath .. "/" .. fileName .. ".json"
	if isfile(filePath) then
		local jsonData = readfile(filePath)
		return HttpService:JSONDecode(jsonData)
	end
end

local function ListFiles()
	local files = {}
	for _, file in ipairs(listfiles(folderPath)) do
		local fileName = file:match("([^/]+)%.json$")
		if fileName then
			table.insert(files, fileName)
		end
	end
	return files
end

local Section_Meta = {
	main = {
		"fun",
		"automation",
		"bring stuff",
		"main",
		"teleport",
		"visuals",
		"local player",
	},
	other = {
		"information",
		"misc",
		"theme",
		"config",
	},
}

local section = setmetatable({
	_cache = {},
	register = function(self, _win)
		self._win = _win
	end,
}, {
	__call = function(self, name)
		if self._cache[name] then
			return self._cache[name]
		end
		self._cache[name] = self._win:Section({
			Title = name,
			Opened = true,
		})
		return self._cache[name]
	end,
})

local LanguageFlags = {
	["en"] = "🇺🇸", -- English (United States default)
	["en-GB"] = "🇬🇧", -- English (United Kingdom)
	["en-CA"] = "🇨🇦", -- English (Canada)
	["fr"] = "🇫🇷", -- French
	["fr-CA"] = "🇨🇦", -- French (Canada)
	["es"] = "🇪🇸", -- Spanish (Spain)
	["es-CA"] = "🇪🇸", -- Spanish (Catalan)
	["ca"] = "🇪🇸", -- Spanish (Catalan)
	["da"] = "🇩🇰", -- Danish
	["es-MX"] = "🇲🇽", -- Spanish (Mexico)
	["pt"] = "🇵🇹", -- Portuguese
	["pt-BR"] = "🇧🇷", -- Portuguese (Brazil)
	["de"] = "🇩🇪", -- German
	["it"] = "🇮🇹", -- Italian
	["nl"] = "🇳🇱", -- Dutch
	["ru"] = "🇷🇺", -- Russian
	["uk"] = "🇺🇦", -- Ukrainian
	["pl"] = "🇵🇱", -- Polish
	["cs"] = "🇨🇿", -- Czech
	["sk"] = "🇸🇰", -- Slovak
	["sl"] = "🇸🇮", -- Slovenian
	["hr"] = "🇭🇷", -- Croatian
	["sr"] = "🇷🇸", -- Serbian
	["bs"] = "🇧🇦", -- Bosnian
	["mk"] = "🇲🇰", -- Macedonian
	["bg"] = "🇧🇬", -- Bulgarian
	["ro"] = "🇷🇴", -- Romanian
	["hu"] = "🇭🇺", -- Hungarian
	["tr"] = "🇹🇷", -- Turkish
	["el"] = "🇬🇷", -- Greek
	["he"] = "🇮🇱", -- Hebrew
	["ar"] = "🇸🇦", -- Arabic (default: Saudi Arabia)
	["fa"] = "🇮🇷", -- Persian
	["ur"] = "🇵🇰", -- Urdu
	["hi"] = "🇮🇳", -- Hindi
	["bn"] = "🇧🇩", -- Bengali
	["ta"] = "🇮🇳", -- Tamil (India)
	["te"] = "🇮🇳", -- Telugu
	["ml"] = "🇮🇳", -- Malayalam
	["kn"] = "🇮🇳", -- Kannada
	["pa"] = "🇮🇳", -- Punjabi
	["gu"] = "🇮🇳", -- Gujarati
	["ne"] = "🇳🇵", -- Nepali
	["si"] = "🇱🇰", -- Sinhala
	["th"] = "🇹🇭", -- Thai
	["lo"] = "🇱🇦", -- Lao
	["km"] = "🇰🇭", -- Khmer
	["vi"] = "🇻🇳", -- Vietnamese
	["id"] = "🇮🇩", -- Indonesian
	["ms"] = "🇲🇾", -- Malay
	["fil"] = "🇵🇭", -- Filipino
	["zh"] = "🇨🇳", -- Chinese (Simplified default: China)
	["zh-CN"] = "🇨🇳", -- Simplified Chinese
	["zh-Hans"] = "🇨🇳", -- Simplified Chinese
	["zh-TW"] = "🇹🇼", -- Traditional Chinese (Taiwan)
	["zh-HK"] = "🇭🇰", -- Traditional Chinese (Hong Kong)
	["ja"] = "🇯🇵", -- Japanese
	["ko"] = "🇰🇷", -- Korean
	["mn"] = "🇲🇳", -- Mongolian
	["am"] = "🇪🇹", -- Amharic
	["sw"] = "🇰🇪", -- Swahili
	["zu"] = "🇿🇦", -- Zulu
	["xh"] = "🇿🇦", -- Xhosa
	["st"] = "🇿🇦", -- Sotho
	["af"] = "🇿🇦", -- Afrikaans
	["yo"] = "🇳🇬", -- Yoruba
	["ig"] = "🇳🇬", -- Igbo
	["ha"] = "🇳🇬", -- Hausa
	["so"] = "🇸🇴", -- Somali,
	["no"] = "🇳🇴", -- Norwegian
}

local RuntimeLib = {
	Init = function(self, _win)
		if shared.VoidwareCustom then
			self.Sections = setmetatable({}, {
				__index = function(self, key)
					return _win
				end,
			})
			--[[section:register(_win)
            self.Sections.Main = section("Main")
            self.Sections.Other = section("Other")
            self.Sections = setmetatable({
                Main = section("Main"),
                Other = section("Other")
            }, {
                __index = function(self, key)
                    return self.Sections.Other
                end
            })--]]
		else
			self.Sections.Games = _win:Section({
				Title = shared.VoidwareCustom and "Main" or "Games",
				Opened = true,
			})
			if shared.VoidwareCustom then
				WindUIAdapter._maintab = self.Sections.Games:Tab({ Title = "Main", Icon = "superscript" })
			end
			self.Sections.ESP = _win:Section({
				Title = "ESP",
				Opened = true,
			})
			self.Sections.Config = _win:Section({
				Title = "Config",
				Opened = true,
				Visible = false,
			})
			self.Sections.Other = _win:Section({
				Title = "Other",
				Opened = true,
			})
		end
		shared.CREATE_TAG_FUNCTION_WIND_UI = function(...)
			local args = { ... }
			pcall(function()
				_win:Tag(unpack(args))
			end)
		end
		pcall(function()
			if shared.TargetLanguage and LanguageFlags[tostring(shared.TargetLanguage)] then
				_win:Tag({
					Title = tostring(shared.TargetLanguage) .. " " .. tostring(
						LanguageFlags[tostring(shared.TargetLanguage)]
					),
					Color = Color3.fromHex("#ffffff"),
				})
			end
			if shared.VoidDev then
				if shared.ExternalDev then
					_win:Tag({
						Title = "🔥 Gay Mode",
						Color = Color3.fromHex("#5500ffff"),
					})
				else
					_win:Tag({
						Title = "🔥 Dev Mode",
						Color = Color3.fromHex("#9370DB"),
					})
				end
			end
			if shared.TestingMode or shared.StagingMode then
				_win:Tag({
					Title = "🛠️ Testing Mode",
					Color = Color3.fromHex("#FFD700"),
				})
			end
			if tostring(shared.environment) == "translator_env" then
				_win:Tag({
					Title = "✍️ (Translation) Testing Mode",
					Color = Color3.fromHex("#32CD32"),
				})
			end
		end)
		self._loaded = true
		WindUI._win = _win
		WindUI.OnUnload = _win.OnDestroy
	end,
	Sections = {},
	_loaded = false,
	GetSection = function(self, title)
		assert(self._loaded, "[RuntimeLib]: Tried getting section before being loaded.")
		title = string.lower(title)
		if shared.VoidwareCustom then
			if table.find(Section_Meta.main, title) then
				return self.Sections.Main
			elseif table.find(Section_Meta.other, title) then
				return self.Sections.Other
			else
				return WindUI._win
			end
		else
			if string.find(title, "esp") or string.find(title, "self") then
				return self.Sections.ESP
			elseif
				string.find(title, "misc")
				or string.find(title, "information")
				or string.find(title, "security")
				or string.find(title, "performance")
				or string.find(title, "useful")
				or string.find(title, "ui section")
				or string.find(title, "ambient")
			then
				return self.Sections.Other
			else
				return self.Sections.Games
			end
		end
	end,
	HandleSection = function(self, title, tab)
		if title ~= "Information" then
			return
		end
		if WindUI._win then
			for i, v in pairs(WindUI._win.TabModule.Tabs) do
				if v.Title == "Information" then
					WindUI._win:SelectTab(i)
					break
				end
			end
		end
		pcall(function()
			if shared.VW_AUTOFARM_SCRIPT then
				tab:Section({
					Title = "Voidware Auto Farm Script 🎉 ",
					TextXAlignment = "Left",
					TextSize = 20,
				})
			end
		end)
		shared.WindUI = WindUI
		local InviteCode = "voidware"
		local DiscordAPI = "https://discord.com/api/v10/invites/"
			.. InviteCode
			.. "?with_counts=true&with_expiration=true"

		local suc, Response
		task.spawn(function()
			local ok, result = pcall(function()
				return WindUI.Creator.Request({
					Url = DiscordAPI,
					Method = "GET",
					Headers = {
						["User-Agent"] = "RobloxBot/1.0",
						["Accept"] = "application/json",
					},
				})
			end)

			if ok and result and result.Body then
				local decoded = HttpService:JSONDecode(result.Body)
				suc, Response = true, decoded
			else
				suc, Response = false, result
			end
		end)

		local start = tick()
		repeat
			task.wait()
		until suc ~= nil or tick() - start >= 5

		if suc and Response and Response.guild then
			local DiscordInfo = tab:Paragraph({
				Title = Response.guild.name,
				Thumbnail = "https://cdn.discordapp.com/banners/1143463175019302942/1aeaf6910d47902a25094a0258714961.webp?size=512",
				Desc = ' <font color="#52525b">•</font> Member Count : '
					.. tostring(Response.approximate_member_count)
					.. '\n <font color="#16a34a">•</font> Online Count : '
					.. tostring(Response.approximate_presence_count),
				Image = "https://cdn.discordapp.com/icons/"
					.. Response.guild.id
					.. "/"
					.. Response.guild.icon
					.. ".png?size=1024",
				ImageSize = 42,
			})

			tab:Button({
				Title = shared.TRANSLATION_FUNCTION and shared.TRANSLATION_FUNCTION("Update Discord Info")
					or "Update Discord Info",
				Image = "refresh-ccw",
				Callback = function()
					local UpdatedResponse = game:GetService("HttpService"):JSONDecode(WindUI.Creator.Request({
						Url = DiscordAPI,
						Method = "GET",
					}).Body)

					if UpdatedResponse and UpdatedResponse and UpdatedResponse.guild then
						DiscordInfo:SetDesc(
							' <font color="#52525b">•</font> Member Count : '
								.. tostring(UpdatedResponse.approximate_member_count)
								.. '\n <font color="#16a34a">•</font> Online Count : '
								.. tostring(UpdatedResponse.approximate_presence_count)
						)
					end
				end,
			})
		else
			--[[Tabs.Tests:Paragraph({
                Title = "Error when receiving information about the Discord server",
                Desc = game:GetService("HttpService"):JSONEncode(Response),
                Image = "triangle-alert",
                ImageSize = 26,
                Color = "Red",
            })--]]
		end
		local keybind = shared.VoidwareInkGame and "M" or "RightShift"
		tab:Keybind({
			Title = shared.TRANSLATION_FUNCTION and shared.TRANSLATION_FUNCTION("Voidware Keybind")
				or "Voidware Keybind",
			Desc = shared.TRANSLATION_FUNCTION and shared.TRANSLATION_FUNCTION("Keybind to open ui")
				or "Keybind to open ui",
			Value = keybind,
			Callback = function(v)
				keybind = tostring(v)
				WindUI._win:SetToggleKey(Enum.KeyCode[v])
			end,
		})
		pcall(function()
			WindUI._win:SetToggleKey(Enum.KeyCode[keybind])
		end)
		WindUI._win:OnClose(function()
			WindUIAdapter:Notify("Window Closed", `Press {tostring(keybind)} to open Voidware again`, 1.5, true)
		end)
	end,
	LoadSaving = function(self)
		assert(self._loaded, "[RuntimeLib]: Tried loading saving before being loaded.")

		--local SavingTab = self.Sections.Config:Tab({ Title = "Saving" })
		--local LoadingTab = self.Sections.Config:Tab({ Title = "Loading" })

		local ConfigTab = self.Sections.Config:Tab({ Title = "Config" })
		local HttpService = game:GetService("HttpService")
		local FileSystem = {
			_verify_path = function(self, path)
				local folderPath = path:match("(.+)/[^/]+$") or path:match("(.+)\\[^\\]+$")

				if folderPath then
					local folders = {}
					local currentPath = ""
					for folder in folderPath:gmatch("[^/\\]+") do
						table.insert(folders, folder)
					end

					for _, folder in ipairs(folders) do
						currentPath = currentPath .. (currentPath == "" and "" or "/") .. folder
						local suc, err = self:addFolder(currentPath)
						if not suc then
							return false, err
						end
					end
				end
				return true
			end,
			addFolder = function(self, name)
				if not isfolder(name) then
					local suc, err = pcall(makefolder, name)
					if not suc then
						warn(err)
					end
					return suc, err
				end
				return true, nil
			end,
			addFile = function(self, path, contents, ignoreIfExists)
				self:_verify_path(path)

				if isfile(path) and ignoreIfExists then
					return
				end

				local suc, err = pcall(writefile, path, contents)
				if not suc then
					warn("Failed to write file: " .. tostring(err))
					return false, err
				end
				return true, nil
			end,
			fetchFile = function(self, path)
				self:_verify_path(path)
				return isfile(path) and readfile(path)
			end,
			encodeTable = function(self, tbl)
				local suc, res = pcall(function()
					return HttpService:JSONEncode(tbl)
				end)
				if not suc then
					warn(res)
					return nil
				end
				return res
			end,
			decodeTable = function(self, str)
				local suc, res = pcall(function()
					return HttpService:JSONDecode(str)
				end)
				if not suc then
					warn(res)
					return nil
				end
				return res
			end,
		}

		FileSystem:addFolder("voidware_linoria")

		local default_metatable
		default_metatable = setmetatable({}, {
			__call = function()
				return default_metatable
			end,
			__index = function()
				return default_metatable
			end,
			__default_metatableindex = function()
				return default_metatable
			end,
		})

		local ConfigManager = setmetatable({
			__config = "default",
			__resolver = {
				_cache = {},
				_resolveKey = function(self, key: string)
					key = tostring(key)
					if self._cache[key] then
						return self._cache[key]
					end
					local res
					if key == "Colorpicker" then
						res = "ColorPicker"
					else
						res = key
					end
					self._cache[key] = res
					return res
				end,
				_resolveValue = function(self, key, tbl)
					local _type = self:_resolveKey(key.__type)
					if _type == "ColorPicker" then
						tbl.transparency = key.Transparency
						tbl.value = tostring(Color3.fromHSV(key.Hue, key.Sat, key.Vib):ToHex())
					elseif _type == "Slider" then
						tbl.value = key.Value.Default
					elseif _type == "Input" then
						tbl.text = key.Value
					elseif _type == "Dropdown" then
						if not key.Multi then
							tbl.value = key.Value
						end
					else
						tbl.value = key.Value
					end
				end,
			},
			__loader = {
				_return = setmetatable({}, {
					__call = function(self, res, info)
						return {
							res = res,
							info = info,
						}
					end,
				}),
				_load_object = function(self, obj, config)
					local suc, err = pcall(function()
						local key = config.__registry[obj.idx]
						if not key then
							return self._return(false, "key not found!")
						end
						if obj.type == "ColorPicker" then
							if key.__type ~= "Colorpicker" then
								return self._return(false, "type mismatch (" .. tostring(obj.type) .. ")")
							end
							key:Update(Color3.fromHex(obj.value), obj.transparency)
						elseif obj.type == "Dropdown" then
							if key.__type ~= "Dropdown" then
								return self._return(false, "type mismatch (" .. tostring(obj.type) .. ")")
							end
							if key.Multi then
								return self._return(false, "dropdown with [multi] enabled")
							end
							key:Refresh({ key.value })
						else
							if key.Set then
								key:Set(obj.value)
							elseif key.Select then
								key:Select(obj.value)
							else
								key.Value = obj.value
							end
						end
						return self._return(true, "")
					end)
					if not suc then
						warn(
							"[_load_object]: Failure for "
								.. tostring(
									obj ~= nil and type(obj) == "table" and tostring(obj.idx) or "[invalid obj format]"
								)
								.. ": "
								.. tostring(err)
						)
					else
						if not err.res then
							warn("[_load_object]: Failure for " .. tostring(obj.idx) .. ": " .. tostring(err.err))
						end
					end
				end,
				load = function(self, data, config)
					for _, v in pairs(data) do
						task.spawn(function()
							self:_load_object(v, config)
						end)
					end
				end,
			},
		}, {
			__call = function(self)
				return self
			end,
			__index = function(self, key)
				if key == "CreateConfig" then
					return function(self, name)
						self._main_path = "voidware_linoria/" .. tostring(name)
						self._file_path = self._main_path .. "/settings/" .. tostring(name) .. ".json"
						FileSystem:addFolder(self._main_path)
						FileSystem:addFolder(self._main_path .. "/themes")
						FileSystem:addFolder(self._main_path .. "/settings")
						FileSystem:addFile(self._main_path .. "/settings/autoload.txt", tostring(name))
						FileSystem:addFile(self._file_path, FileSystem:encodeTable({ objects = {} }), true)
						self.__config = setmetatable({
							__main = self,
							__registry = {},
							__loader = self.__loader,
							__resolver = self.__resolver,
							__current_data = { objects = {} },
							Save = function(self)
								for i, v in pairs(self.__current_data.objects) do
									local reg = self.__registry[v.idx]
									if not reg then
										warn(
											"[__current_data]: Data table found for "
												.. tostring(v.idx)
												.. " but not in the registry???"
										)
										table.remove(self.__current_data.objects, i)
										continue
									end
									self.__resolver:_resolveValue(reg, v)
								end
								FileSystem:addFile(self._file_path, FileSystem:encodeTable(self.__current_data))
							end,
							Load = function(self)
								local file = FileSystem:fetchFile(self._file_path)
								if not file then
									warn("no config file found!")
									return
								end
								local data = FileSystem:decodeTable(file)
								if not data then
									warn("error fetching the data!")
									return
								end
								self.__loader:load(data.objects, self)
							end,
							Register = function(self, index, key)
								assert(
									not self.__registry[index],
									"[__config:Register]: Key with index " .. tostring(index) .. " already exists!"
								)
								self.__registry[index] = key
								local forIndex = {
									idx = index,
									type = self.__resolver:_resolveKey(key.__type),
								}
								self.__resolver:_resolveValue(key, forIndex)
								table.insert(self.__current_data.objects, forIndex)
							end,
						}, {
							__tostring = "__config",
							__index = function(self, key)
								warn("Unknown key given to __config: " .. tostring(key) .. "! Returning default val.")
								return default_metatable
							end,
						})
						return self.__config
					end
				else
					warn("Unknown key given to ConfigManager: " .. tostring(key) .. "! Returning default val.")
					return self
				end
			end,
		})
		ConfigManager = WindUI._win.ConfigManager
		local config = ConfigManager:CreateConfig("default")
		WindUI._config = config

		ConfigTab:Button({
			Title = "Save",
			Desc = "Saves elements to config",
			Callback = function()
				config:Save()
			end,
		})

		ConfigTab:Button({
			Title = "Load",
			Desc = "Loads elements from config",
			Callback = function()
				config:Load()
			end,
		})

		config:Load()

		--[[local fileNameInput = ""
        SavingTab:Input({
            Title = "Write File Name",
            PlaceholderText = "Enter file name",
            Callback = function(text)
                fileNameInput = text
            end
        })

        SavingTab:Button({
            Title = "Save File",
            Callback = function()
                if fileNameInput ~= "" then
                    SaveFile(fileNameInput, { Transparent = WindUI:GetTransparency(), Theme = WindUI:GetCurrentTheme() })
                end
            end
        })

        local filesDropdown
        local files = ListFiles()

        filesDropdown = LoadingTab:Dropdown({
            Title = "Select File",
            Multi = false,
            AllowNone = true,
            Values = files,
            Callback = function(selectedFile)
                fileNameInput = selectedFile
            end
        })

        LoadingTab:Button({
            Title = "Load File",
            Callback = function()
                if fileNameInput ~= "" then
                    local data = LoadFile(fileNameInput)
                    if data then
                        WindUI:Notify({
                            Title = "File Loaded",
                            Content = "Loaded data: " .. HttpService:JSONEncode(data),
                            Duration = 5,
                        })
                        if data.Transparent then 
                            WindUI._win:ToggleTransparency(data.Transparent)
                            ToggleTransparency:SetValue(data.Transparent)
                        end
                        if data.Theme then WindUI:SetTheme(data.Theme) end
                    end
                end
            end
        })

        LoadingTab:Button({
            Title = "Overwrite File",
            Callback = function()
                if fileNameInput ~= "" then
                    SaveFile(fileNameInput, { Transparent = WindUI:GetTransparency(), Theme = WindUI:GetCurrentTheme() })
                end
            end
        })

        LoadingTab:Button({
            Title = "Refresh List",
            Callback = function()
                filesDropdown:Refresh(ListFiles())
            end
        })--]]
	end,
	LoadThemes = function(self)
		local ThemesTab = self.Sections.Config:Tab({ Title = "Theme", Icon = "app-window-mac" })
		local themeValues = {}
		for name, _ in pairs(WindUI:GetThemes()) do
			table.insert(themeValues, name)
		end

		local themeDropdown = ThemesTab:Dropdown({
			Title = "Select Theme",
			Multi = false,
			AllowNone = false,
			Value = nil,
			Values = themeValues,
			Callback = function(theme)
				WindUI:SetTheme(theme)
			end,
		})
		if shared.VoidwareForsaken then
			pcall(function()
				WindUI:SetTheme("Red")
			end)
		else
			pcall(function()
				WindUI:SetTheme("Christmas")
			end)
		end
		themeDropdown:Select(WindUI:GetCurrentTheme())

		local ToggleTransparency = ThemesTab:Toggle({
			Title = "Toggle Window Transparency",
			Callback = function(e)
				WindUI._win:ToggleTransparency(e)
			end,
			Value = WindUI:GetTransparency(),
		})

		local currentThemeName = WindUI:GetCurrentTheme()
		local themes = WindUI:GetThemes()

		local ThemeAccent = themes[currentThemeName].Accent
		local ThemeOutline = themes[currentThemeName].Outline
		local ThemeText = themes[currentThemeName].Text
		local ThemePlaceholderText = themes[currentThemeName].Placeholder

		function updateTheme()
			WindUI:AddTheme({
				Name = currentThemeName,
				Accent = ThemeAccent,
				Outline = ThemeOutline,
				Text = ThemeText,
				Placeholder = ThemePlaceholderText,
			})
			WindUI:SetTheme(currentThemeName)
		end

		local CreateInput = ThemesTab:Input({
			Title = "Theme Name",
			Value = currentThemeName,
			Callback = function(name)
				currentThemeName = name
			end,
		})

		ThemesTab:Colorpicker({
			Title = "Background Color",
			Default = ThemeAccent,
			Callback = function(color)
				ThemeAccent = color:ToHex()
			end,
		})

		ThemesTab:Colorpicker({
			Title = "Outline Color",
			Default = ThemeOutline,
			Callback = function(color)
				ThemeOutline = color:ToHex()
			end,
		})

		ThemesTab:Colorpicker({
			Title = "Text Color",
			Default = ThemeText,
			Callback = function(color)
				ThemeText = color:ToHex()
			end,
		})

		ThemesTab:Colorpicker({
			Title = "Placeholder Text Color",
			Default = ThemePlaceholderText,
			Callback = function(color)
				ThemePlaceholderText = color:ToHex()
			end,
		})

		ThemesTab:Button({
			Title = "Update Theme",
			Callback = function()
				updateTheme()
			end,
		})
	end,
	RegisterSavingObject = function(self, index, obj)
		task.spawn(function()
			repeat
				task.wait()
			until WindUI._config ~= nil or WindUI.Unloaded
			WindUI._config:Register(index, obj)
		end)
	end,
}

WindUIAdapter.RuntimeLib = RuntimeLib

local UserInputService = game:GetService("UserInputService")
local ismobile = UserInputService.TouchEnabled
	and not UserInputService.KeyboardEnabled
	and not UserInputService.MouseEnabled

local isDelta = timedFunction(
	function()
		return string.find(string.lower(tostring(identifyexecutor())), "delta")
	end,
	5,
	function(suc, err)
		return suc and err
	end
)
function WindUIAdapter:CreateWindow(opts)
	local win = WindUI:CreateWindow({
		Title = opts.Title or "Window",
		Icon = opts.Icon or "door-open",
		Background = opts.Background,
		Author = opts.Footer,
		NewElements = true,
		Folder = opts.Folder or "WindUIAdapter",
		Size = opts.Size or (isDelta and UDim2.fromOffset(720, 620) or UDim2.fromOffset(520, 420)),
		-- opts.Size or ismobile and shared.MobileSizeTesting and UDim2.fromOffset(320, 240) or UDim2.fromOffset(580, 460),
		Theme = opts.Theme or "Dark",
		HideSearchBar = opts.HideSearchBar,
		ScrollBarEnabled = false,
		User = { Enabled = opts.UserEnabled },
		Topbar = {
			Height = 44,
			ButtonsType = "Mac",
		},
	})
	RuntimeLib:Init(win)
	local obj = setmetatable({ _win = win }, { __index = WindUIAdapter.Window })
	--obj.Unload = WindUIAdapter.Unload
	obj.Unloaded = false
	return obj
end

WindUIAdapter.Window = {}

function WindUIAdapter.Window:AddTab(title, icon)
	--local tab = self._win:Tab({ Title = title, Icon = icon })
	--return setmetatable({ _tab = tab }, { __index = WindUIAdapter.Tab })
	return setmetatable({ _win = self._win }, { __index = WindUIAdapter.TempTab })
end

local function GetTab(name)
	if shared.TRANSLATION_FUNCTION then
		name = shared.TRANSLATION_FUNCTION(name)
	end
	for i, v in pairs(WindUI._win.TabModule.Tabs) do
		if v.Title == name then
			return v
		end
	end
end

local function GetMiscTab()
	if WindUI._misctab then
		return WindUI._misctab
	end
	WindUI._misctab = GetTab("Misc")
	return WindUI._misctab
end

local function GetAutomationTab()
	if WindUI._automationtab then
		return WindUI._automationtab
	end
	WindUI._automationtab = GetTab("Automation") or GetTab("Auto")
	return WindUI._automationtab
end

local Tabs_Meta = {
	maintab = {
		"hitbox expansion",
		"tree farm",
		--"taming",
		"infintie saplings",
		"entity godmode",
		--"fishing",
		"kill aura",
		"farm settings",
		--"mine aura",
		"ice aura",
		"ore aura",
		"aura",
		"health",
		"auto bandage",
		"other",
		"auto eat",
		"infinitefly",
		"security",
		"auto vote",
		"interaction",
		"killaura",
		"webhook message",
		"anti death",
		"infinite stamina",
		"full bright",
		"player attach",
		"gun mods",
		"anti hit",
	},
	automation = {
		"auto sell",
		"auto buy",
		"auto fuse",
		"auto chest",
		"auto favorite",
		"auto crock pot",
		"auto campfire",
		"auto collect",
		"plant stuff",
		"plant & build stuff",
		"auto open seed boxes",
		"auto brainrot invasion",
		"auto complete flow game",
	},
	playertab = {
		"fly",
		--"performance",
		"security",
		"player",
		"ambient",
		"self",
	},
	misc = {
		"useful stuff",
		"coordinates",
		"credits",
		"misc",
	},
	visuals = {
		"main esp",
		"esp",
		"esp settings",
		"hide and seek esp",
	},
	rebel = {
		"rebel",
		"aimbot",
		"auto shoot",
	},
	vip = {
		"vip",
		"title choice",
	},
	updatefocused = {
		--"update focused",
		"fairy update",
		"christmas",
		"classes",
		"thanksgiving",
		"injured deer",
		"fishing",
		"taming",
		"halloween",
		"candy farm",
		"maze",
	},
}

local Sec_Meta = {
	"bring settings",
}

if shared.VoidwareInkGame then
	table.insert(Tabs_Meta.misc, "performance")
else
	Tabs_Meta.rebel = nil
	Tabs_Meta.vip = nil
	if shared.TheForge then
		local id1, id2 = table.find(Tabs_Meta.maintab, "kill aura"), table.find(Tabs_Meta.maintab, "mine aura")
		if id1 then
			table.remove(Tabs_Meta.maintab, id1)
		end
		if id2 then
			table.remove(Tabs_Meta.maintab, id2)
		end
		table.insert(Tabs_Meta.visuals, "performance")
		table.remove(Tabs_Meta.misc, table.find(Tabs_Meta.misc, "useful stuff"))
		table.insert(Tabs_Meta.visuals, "useful stuff")
	end
end

WindUIAdapter.TempTabBox = {}
function WindUIAdapter.TempTabBox:AddTab(title, icon)
	return WindUIAdapter.TempTab:handleGroupBox(title, icon)
end

WindUIAdapter.TempTab = {}
function WindUIAdapter.TempTab:AddRightTabbox()
	return setmetatable({ _win = self._win }, { __index = WindUIAdapter.TempTabBox })
end
function WindUIAdapter.TempTab:handleGroupBox(title, icon)
	local searchIndex = shared.REVERT_TRANSLATION_META and shared.REVERT_TRANSLATION_META[title] or title
	local section = RuntimeLib:GetSection(title) or self._win
	if shared.VoidwareCustom then
		if string.find(string.lower(searchIndex), "bring") then
			WindUIAdapter._bringitemstab = WindUIAdapter._bringitemstab
				or section:Tab({ Title = "Bring Stuff", Icon = "bring-to-front" })
			local sec = WindUIAdapter._bringitemstab:Section({
				Title = title,
				TextXAlignment = "Left",
				Icon = icon,
				TextSize = 17,
			})
			local result = setmetatable({ _tab = sec }, {
				__index = function(self, key)
					return WindUIAdapter.Tab[key] or sec[key]
				end,
			})
			return result
		elseif table.find(Tabs_Meta.maintab, string.lower(searchIndex)) then
			WindUIAdapter._maintab = WindUIAdapter._maintab or section:Tab({ Title = "Main", Icon = "superscript" })
			local sec = WindUIAdapter._maintab:Section({
				Title = title,
				TextXAlignment = "Left",
				Icon = icon,
				TextSize = 17,
			})
			local result = setmetatable({ _tab = sec }, {
				__index = function(self, key)
					return WindUIAdapter.Tab[key] or sec[key]
				end,
			})
			return result
		elseif Tabs_Meta.updatefocused ~= nil and table.find(Tabs_Meta.updatefocused, string.lower(searchIndex)) then
			WindUIAdapter._updatefocusedtab = WindUIAdapter._updatefocusedtab
				or GetTab("Update Focused")
				or section:Tab({ Title = "Update Focused", Icon = "nut" })
			local sec = WindUIAdapter._updatefocusedtab:Section({
				Title = title,
				TextXAlignment = "Left",
				Icon = icon,
				TextSize = 17,
			})
			local result = setmetatable({ _tab = sec }, {
				__index = function(self, key)
					return WindUIAdapter.Tab[key] or sec[key]
				end,
			})
			return result
		elseif Tabs_Meta.vip ~= nil and table.find(Tabs_Meta.vip, string.lower(searchIndex)) then
			WindUIAdapter._viptab = WindUIAdapter._viptab or section:Tab({ Title = "VIP", Icon = "star" })
			WindUIAdapter._viptab:Section({
				Title = title,
				TextXAlignment = "Left",
				Icon = icon,
				TextSize = 17,
			})
			local result = setmetatable({ _tab = WindUIAdapter._viptab }, {
				__index = function(self, key)
					return WindUIAdapter.Tab[key] or WindUIAdapter._viptab[key]
				end,
			})
			return result
		elseif Tabs_Meta.rebel ~= nil and table.find(Tabs_Meta.rebel, string.lower(searchIndex)) then
			WindUIAdapter._rebeltab = WindUIAdapter._rebeltab or section:Tab({ Title = "Rebel", Icon = "sword" })
			WindUIAdapter._rebeltab:Section({
				Title = title,
				TextXAlignment = "Left",
				Icon = icon,
				TextSize = 17,
			})
			local result = setmetatable({ _tab = WindUIAdapter._rebeltab }, {
				__index = function(self, key)
					return WindUIAdapter.Tab[key] or WindUIAdapter._rebeltab[key]
				end,
			})
			return result
		elseif table.find(Tabs_Meta.automation, string.lower(searchIndex)) then
			local tab = GetAutomationTab()
			if string.lower(title) == "auto chest" then
				title = "Auto Chest [BETA]"
			end
			if shared.TRANSLATION_FUNCTION then
				title = shared.TRANSLATION_FUNCTION(title)
			end
			local sec = tab:Section({
				Title = title,
				TextXAlignment = "Left",
				Icon = icon,
				TextSize = 17,
			})
			local result = setmetatable({ _tab = sec }, {
				__index = function(self, key)
					return WindUIAdapter.Tab[key] or sec[key]
				end,
			})
			return result
		elseif table.find(Tabs_Meta.playertab, string.lower(searchIndex)) then
			WindUIAdapter._playertab = WindUIAdapter._playertab
				or section:Tab({
					Title = shared.TRANSLATION_FUNCTION and shared.TRANSLATION_FUNCTION("Local Player")
						or "Local Player",
					Icon = "circle-user",
				})
			if title == "Player" then
				title = "Movement"
			end
			WindUIAdapter._playertab:Section({
				Title = title,
				TextXAlignment = "Left",
				Icon = icon,
				TextSize = 17,
			})
			local result = setmetatable({ _tab = WindUIAdapter._playertab }, {
				__index = function(self, key)
					return WindUIAdapter.Tab[key] or WindUIAdapter._playertab[key]
				end,
			})
			return result
		elseif table.find(Tabs_Meta.misc, string.lower(searchIndex)) then
			local tab = GetMiscTab() or section:Tab({ Title = "Misc", Icon = "wrench" })
			tab:Section({
				Title = title,
				TextXAlignment = "Left",
				Icon = icon,
				TextSize = 17,
			})
			local result = setmetatable({ _tab = tab }, {
				__index = function(self, key)
					return WindUIAdapter.Tab[key] or tab[key]
				end,
			})
			return result
		elseif table.find(Tabs_Meta.visuals, string.lower(searchIndex)) then
			WindUIAdapter._visualstab = WindUIAdapter._visualstab
				or section:Tab({
					Title = shared.TRANSLATION_FUNCTION and shared.TRANSLATION_FUNCTION("Visuals") or "Visuals",
					Icon = "eye",
				})
			if
				title ~= "ESP" and ((not shared.VoidwareForsaken) or (shared.VoidwareForsaken and title ~= "Main ESP"))
			then
				WindUIAdapter._visualstab:Section({
					Title = title,
					TextXAlignment = "Left",
					Icon = icon,
					TextSize = 17,
				})
			end
			local result = setmetatable({ _tab = WindUIAdapter._visualstab }, {
				__index = function(self, key)
					return WindUIAdapter.Tab[key] or WindUIAdapter._visualstab[key]
				end,
			})
			return result
		end
	end
	local tab = section:Tab({ Title = title, Icon = icon })
	local result = setmetatable({ _tab = tab }, {
		__index = function(self, key)
			return WindUIAdapter.Tab[key] or tab[key]
		end,
	})
	RuntimeLib:HandleSection(title, tab)
	return result
end

function WindUIAdapter.TempTab:AddLeftGroupbox(...)
	return self:handleGroupBox(...)
end

function WindUIAdapter.TempTab:AddRightGroupbox(...)
	return self:handleGroupBox(...)
end

WindUIAdapter.Tab = {}

function WindUIAdapter.Tab:AddLeftGroupbox()
	return self
end

function WindUIAdapter.Tab:AddRightGroupbox()
	return self
end

--[[function WindUIAdapter.Tab:Section(opts)
    return self._tab:Section(opts)
end--]]

function WindUIAdapter.Tab:AddToggle(name, opts)
	local changedListeners = {}
	local toggle = self._tab:Toggle({
		Title = opts.Name or opts.Text or opts.Title or name,
		Value = opts.Default,
		Callback = function(v)
			if opts.Callback then
				pcall(opts.Callback, v)
			end
			for i, func in pairs(changedListeners) do
				if type(func) ~= "function" then
					table.remove(changedListeners, i)
					continue
				end
				pcall(func, v)
			end
		end,
		Desc = opts.Desc,
		Icon = opts.Icon or "check",
		Type = opts.Type,
	})
	RuntimeLib:RegisterSavingObject(name, toggle)
	local real_tab = self._tab
	local runtime_self = self
	local wrapper = wrapElement(name, toggle, true)
	local result = setmetatable({ _toggle = toggle, _wrapper = wrapper }, {
		__index = function(self, k)
			if k == "AddColorPicker" then
				return function(_, cname, copts)
					runtime_self:AddColorPicker(cname, copts)
				end
			elseif k == "AddKeyPicker" then
				return function(_, kname, kopts)
					if shared.VoidwareInkGame then
						if not kopts.Callback then
							kopts.Callback = function()
								self._wrapper:SetValue(not self._wrapper.Value)
							end
						end
						runtime_self:AddKeyPicker(kname, kopts)
					end
				end
			elseif k == "SetVisible" then
				return function(_, vis)
					if vis == nil then
						vis = not toggle.Visible
					end
					toggle.Visible = vis
				end
			elseif k == "OnChanged" then
				return function(_, func)
					table.insert(changedListeners, func)
				end
			else
				return wrapper[k]
			end
		end,
	})
	getgenv().Toggles[name] = result
	return result
end

function WindUIAdapter.Tab:AddButton(name, callback, desc, locked, patched)
	if type(name) == "table" then
		return self._tab:Button({
			Title = name.Text or name.Title or "Button",
			Callback = name.Callback,
			Desc = name.Desc,
			Icon = name.Icon,
			Locked = name.Patched or name.Locked,
			LockText = name.Patched and "Patched",
		})
	else
		return self._tab:Button({
			Title = name,
			Callback = callback,
			Desc = desc,
			Locked = patched or locked,
			LockText = patched and "Patched",
		})
	end
end

function WindUIAdapter.Tab:AddSlider(name, opts)
	local changedListeners = {}
	local slider = self._tab:Slider({
		Title = opts.Text or opts.Title or name,
		Value = {
			Min = opts.Min or 0,
			Max = opts.Max or 100,
			Default = opts.Default or 0,
		},
		Step = opts.Rounding or opts.Step or 1,
		Callback = function(v)
			if opts.Callback then
				pcall(opts.Callback, v)
			end
			for i, func in pairs(changedListeners) do
				if type(func) ~= "function" then
					table.remove(changedListeners, i)
					continue
				end
				pcall(func, v)
			end
		end,
		Desc = opts.Desc,
	})
	RuntimeLib:RegisterSavingObject(name, slider)
	local wrapper = wrapElement(name, slider)
	function wrapper:OnChanged(func)
		table.insert(changedListeners, func)
	end
	getgenv().Options[name] = wrapper
	return wrapper
end

function WindUIAdapter.Tab:AddDropdown(name, opts)
	local changedListeners = {}
	opts.AllowNone = opts.AllowNull
	opts.Values = opts.Values or {}
	if opts.SearchBarEnabled == nil then
		opts.SearchBarEnabled = #opts.Values > 5
	end
	local dropdown = self._tab:Dropdown({
		Title = opts.Text or opts.Title or name,
		Values = opts.Values,
		Value = opts.Default,
		SearchBarEnabled = opts.SearchBarEnabled,
		Multi = opts.Multi,
		AllowNone = opts.AllowNone,
		HideSearchBar = false,
		Callback = function(v)
			if opts.Callback then
				pcall(opts.Callback, v)
			end
			for i, func in pairs(changedListeners) do
				if type(func) ~= "function" then
					table.remove(changedListeners, i)
					continue
				end
				pcall(func, v)
			end
		end,
		Desc = opts.Desc,
	})
	RuntimeLib:RegisterSavingObject(name, dropdown)
	local wrapper = wrapElement(name, dropdown)
	function wrapper:SetValues(newValues)
		if dropdown.Refresh then
			dropdown:Refresh(newValues)
		end
	end
	function wrapper:OnChanged(func)
		table.insert(changedListeners, func)
	end
	getgenv().Options[name] = wrapper
	return wrapper
end

function WindUIAdapter.Tab:AddColorPicker(name, opts)
	local changedListeners = {}
	local cp = self._tab:Colorpicker({
		Title = opts.Text or opts.Title or name,
		Default = opts.Default or Color3.new(1, 1, 1),
		Callback = function(v)
			if opts.Callback then
				pcall(opts.Callback, v)
			end
			for i, func in pairs(changedListeners) do
				if type(func) ~= "function" then
					table.remove(changedListeners, i)
					continue
				end
				pcall(func, v)
			end
		end,
		Desc = opts.Desc,
		Transparency = opts.Transparency,
	})
	RuntimeLib:RegisterSavingObject(name, cp)
	local wrapper = wrapElement(name, cp)
	function wrapper:OnChanged(func)
		table.insert(changedListeners, func)
	end
	getgenv().Options[name] = wrapper
	return wrapper
end

function WindUIAdapter.Tab:AddKeyPicker(name, opts)
	local changedListeners = {}
	local kp = self._tab:Keybind({
		Title = opts.Text or opts.Title or name,
		Value = opts.Default,
		Callback = function(v)
			if opts.Callback then
				pcall(opts.Callback, v)
			end
			for i, func in pairs(changedListeners) do
				if type(func) ~= "function" then
					table.remove(changedListeners, i)
					continue
				end
				pcall(func, v)
			end
		end,
		Desc = opts.Desc,
		CanChange = opts.CanChange,
	})
	RuntimeLib:RegisterSavingObject(name, kp)
	local wrapper = wrapElement(name, kp)
	function wrapper:OnChanged(func)
		table.insert(changedListeners, func)
	end
	getgenv().Options[name] = wrapper
	return wrapper
end

function WindUIAdapter.Tab:AddLabel(text)
	return setmetatable({ AddKeyPicker = function() end }, { __index = self._tab:Paragraph({ Title = text }) })
end

function WindUIAdapter.Tab:AddDivider()
	return self._tab:Divider()
end

function WindUIAdapter.Tab:AddInput(name, opts)
	local changedListeners = {}
	local inp = self._tab:Input({
		Title = opts.Text or opts.Title or name,
		Value = opts.Default or opts.Value,
		Placeholder = opts.Placeholder,
		Callback = function(v)
			if opts.Callback then
				pcall(opts.Callback, v)
			end
			for i, func in pairs(changedListeners) do
				if type(func) ~= "function" then
					table.remove(changedListeners, i)
					continue
				end
				pcall(func, v)
			end
		end,
		Desc = opts.Desc,
		Type = opts.Type,
		InputIcon = opts.InputIcon,
		ClearTextOnFocus = opts.ClearTextOnFocus,
	})
	local wrapper = wrapElement(name, inp)
	function wrapper:OnChanged(func)
		table.insert(changedListeners, func)
	end
	getgenv().Options[name] = wrapper
	return wrapper
end

function WindUIAdapter:GiveSignal(signal)
	self._signals = self._signals or {}
	table.insert(self._signals, signal)
end

function WindUIAdapter:Unload()
	pcall(function()
		shared.CREATE_TAG_FUNCTION_WIND_UI = nil
	end)
	if self._win then
		pcall(function()
			self._win:Close():Destroy()
		end)
		task.spawn(function()
			task.wait(0.5)
			pcall(function()
				local a = game.CoreGui
				--a["WindUI"]:Destroy()
				a["WindUI/Dropdowns"]:Destroy()
				a["WindUI/Notifications"]:Destroy()
			end)
		end)
	end
	self.Unloaded = true
	getgenv().voidware_loaded = false
	shared.Voidware_InkGame_Library = nil
	shared.Voidware_Forsaken_Library = nil
	shared.Voidware_Hypershot_Library = nil
	shared.Voidware_NightsInTheForest_Library = nil
end

function WindUIAdapter:Notify(title, msg, dur, check)
	if setthreadidentity and type(setthreadidentity) == "function" then
		pcall(setthreadidentity, 8)
	end
	if not check then
		dur = msg
		msg = title
		title = "Voidware"
	else
		title = "Voidware | " .. tostring(title)
	end
	return WindUI:Notify({
		Title = title,
		Content = msg,
		Icon = "bell",
		Duration = dur or 5,
	})
end

return setmetatable(WindUIAdapter, { __index = WindUI })
