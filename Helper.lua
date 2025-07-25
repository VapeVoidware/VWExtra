local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

getgenv().Toggles = getgenv().Toggles or {}
getgenv().Options = getgenv().Options or {}

local WindUIAdapter = {}

local function wrapElement(name, element, isToggle)
    local mt = {
        __index = function(self, k)
            if k == "Value" then
                return self:Get()
            elseif k == "Set" then
                return function(_, v) self:Set(v) end
            else
                return rawget(self, k) or element[k]
            end
        end
    }
    local wrapper = setmetatable({
        _element = element,
        Get = function(self)
            if tostring(self._element.__type) == "Slider" and type(self._element.Value) == "table" and self._element.Value.Default ~= nil then
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
            if not (self._element ~= nil and self._element.Visible ~= nil) then return end
            if vis == nil then
                vis = not self._element.Visible
            end
            self._element.Visible = vis
        end
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

local RuntimeLib = {
    Init = function(self, _win)
        self.Sections.Games = _win:Section({
            Title = "Games",
            Opened = true
        })
        self.Sections.ESP = _win:Section({
            Title = "ESP",
            Opened = true
        })
        self.Sections.Config = _win:Section({
            Title = "Config",
            Opened = true
        })
        self.Sections.Other = _win:Section({
            Title = "Other",
            Opened = true
        })
        self._loaded = true
        WindUI._win = _win
        WindUI.OnUnload = _win.OnDestroy
    end,
    Sections = {},
    _loaded = false,
    GetSection = function(self, title)
        assert(self._loaded, "[RuntimeLib]: Tried getting section before being loaded.")
        title = string.lower(title)
        if string.find(title, "esp") or string.find(title, "self") then
            return self.Sections.ESP
        elseif string.find(title, "misc") or string.find(title, "information") or string.find(title, "security") or string.find(title, "performance") or string.find(title, "useful") or string.find(title, "ui section") or string.find(title, "ambient") then
            return self.Sections.Other
        else
            return self.Sections.Games
        end
    end,
    HandleSection = function(self, title, tab)
        if title ~= "Information" then return end
        if WindUI._win then
            WindUI._win:SelectTab(13)
        end
        local InviteCode = "voidware"
        local DiscordAPI = "https://discord.com/api/v10/invites/" .. InviteCode .. "?with_counts=true&with_expiration=true"

        local suc, Response = pcall(function()
            return game:GetService("HttpService"):JSONDecode(WindUI.Creator.Request({
                Url = DiscordAPI,
                Method = "GET",
                Headers = {
                    ["User-Agent"] = "RobloxBot/1.0",
                    ["Accept"] = "application/json"
                }
            }).Body)
        end)

        if suc and Response and Response.guild then
            local DiscordInfo = tab:Paragraph({
                Title = Response.guild.name,
                Desc = 
                    ' <font color="#52525b">•</font> Member Count : ' .. tostring(Response.approximate_member_count) .. 
                    '\n <font color="#16a34a">•</font> Online Count : ' .. tostring(Response.approximate_presence_count)
                ,
                Image = "https://cdn.discordapp.com/icons/" .. Response.guild.id .. "/" .. Response.guild.icon .. ".png?size=1024",
                ImageSize = 42,
            })

            tab:Button({
                Title = "Update Discord Info",
                Image = "refresh-ccw",
                Callback = function()
                    local UpdatedResponse = game:GetService("HttpService"):JSONDecode(WindUI.Creator.Request({
                        Url = DiscordAPI,
                        Method = "GET",
                    }).Body)
                        
                    if UpdatedResponse and UpdatedResponse and UpdatedResponse.guild then
                        DiscordInfo:SetDesc(
                            ' <font color="#52525b">•</font> Member Count : ' .. tostring(UpdatedResponse.approximate_member_count) .. 
                            '\n <font color="#16a34a">•</font> Online Count : ' .. tostring(UpdatedResponse.approximate_presence_count)
                        )
                    end
                end
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
        tab:Keybind({
            Title = "Voidware Keybind",
            Desc = "Keybind to open ui",
            Value = "M",
            Callback = function(v)
                WindUI._win:SetToggleKey(Enum.KeyCode[v])
            end
        })
    end,
    LoadSaving = function(self)
        assert(self._loaded, "[RuntimeLib]: Tried loading saving before being loaded.")

        --local SavingTab = self.Sections.Config:Tab({ Title = "Saving" })
        --local LoadingTab = self.Sections.Config:Tab({ Title = "Loading" })

        local ConfigTab = self.Sections.Config:Tab({ Title = "Config" })

        local ConfigManager = WindUI._win.ConfigManager
        local config = ConfigManager:CreateConfig("default")
        WindUI._config = config

        ConfigTab:Button({
            Title = "Save",
            Desc = "Saves elements to config",
            Callback = function()
                config:Save()
            end
        })
        
        ConfigTab:Button({
            Title = "Load",
            Desc = "Loads elements from config",
            Callback = function()
                config:Load()
            end
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
        local ThemesTab = self.Sections.Config:Tab({ Title = "Theme" , Icon = "app-window-mac" })
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
            end
        })
        themeDropdown:Select(WindUI:GetCurrentTheme())

        local ToggleTransparency = ThemesTab:Toggle({
            Title = "Toggle Window Transparency",
            Callback = function(e)
                WindUI._win:ToggleTransparency(e)
            end,
            Value = WindUI:GetTransparency()
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
                Placeholder = ThemePlaceholderText
            })
            WindUI:SetTheme(currentThemeName)
        end

        local CreateInput = ThemesTab:Input({
            Title = "Theme Name",
            Value = currentThemeName,
            Callback = function(name)
                currentThemeName = name
            end
        })

        ThemesTab:Colorpicker({
            Title = "Background Color",
            Default = Color3.fromHex(ThemeAccent),
            Callback = function(color)
                ThemeAccent = color:ToHex()
            end
        })

        ThemesTab:Colorpicker({
            Title = "Outline Color",
            Default = Color3.fromHex(ThemeOutline),
            Callback = function(color)
                ThemeOutline = color:ToHex()
            end
        })

        ThemesTab:Colorpicker({
            Title = "Text Color",
            Default = Color3.fromHex(ThemeText),
            Callback = function(color)
                ThemeText = color:ToHex()
            end
        })

        ThemesTab:Colorpicker({
            Title = "Placeholder Text Color",
            Default = Color3.fromHex(ThemePlaceholderText),
            Callback = function(color)
                ThemePlaceholderText = color:ToHex()
            end
        })

        ThemesTab:Button({
            Title = "Update Theme",
            Callback = function()
                updateTheme()
            end
        })
    end,
    RegisterSavingObject = function(self, index, obj)
        task.spawn(function()
            repeat task.wait() until WindUI._config ~= nil or WindUI.Unloaded
            WindUI._config:Register(index, obj)
        end)
    end
}

WindUIAdapter.RuntimeLib = RuntimeLib

function WindUIAdapter:CreateWindow(opts)
    local win = WindUI:CreateWindow({
        Title = opts.Title or "Window",
        Icon = opts.Icon,
        Author = opts.Footer,
        Folder = opts.Folder or "WindUIAdapter",
        Size = opts.Size or UDim2.fromOffset(580, 460),
        Theme = opts.Theme or "Dark",
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
    return setmetatable({_win = self._win}, { __index = WindUIAdapter.TempTab })
end

WindUIAdapter.TempTab = {}
function WindUIAdapter.TempTab:handleGroupBox(title, icon)
    local section = RuntimeLib:GetSection(title) or self._win
    local tab = section:Tab({ Title = title, Icon = icon })
    local result = setmetatable({ _tab = tab }, { __index = WindUIAdapter.Tab })
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

function WindUIAdapter.Tab:AddToggle(name, opts)
    local changedListeners = {}
    local toggle = self._tab:Toggle({
        Title = opts.Text or opts.Title or name,
        Value = opts.Default,
        Callback = function(v)
            if opts.Callback then
                pcall(opts.Callback, v)
            end
            for i, func in pairs(changedListeners) do
                if type(func) ~= "function" then table.remove(changedListeners, i); continue end
                pcall(func, v)
            end
        end,
        Desc = opts.Desc,
        Icon = opts.Icon,
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
                    --runtime_self:AddKeyPicker(kname, kopts)
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
        end
    })
    getgenv().Toggles[name] = result
    return result
end

function WindUIAdapter.Tab:AddButton(name, callback)
    if type(name) == "table" then
        return self._tab:Button({
            Title = name.Text or name.Title or "Button",
            Callback = name.Callback,
            Desc = name.Desc,
            Icon = name.Icon,
            Locked = name.Locked,
        })
    else
        return self._tab:Button({
            Title = name,
            Callback = callback,
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
                if type(func) ~= "function" then table.remove(changedListeners, i); continue end
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
    local dropdown = self._tab:Dropdown({
        Title = opts.Text or opts.Title or name,
        Values = opts.Values or {},
        Value = opts.Default,
        Multi = opts.Multi,
        AllowNone = opts.AllowNone,
        Callback = function(v)
            if opts.Callback then
                pcall(opts.Callback, v)
            end
            for i, func in pairs(changedListeners) do
                if type(func) ~= "function" then table.remove(changedListeners, i); continue end
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
        Default = opts.Default or Color3.new(1,1,1),
        Callback = function(v)
            if opts.Callback then
                pcall(opts.Callback, v)
            end
            for i, func in pairs(changedListeners) do
                if type(func) ~= "function" then table.remove(changedListeners, i); continue end
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
                if type(func) ~= "function" then table.remove(changedListeners, i); continue end
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
    return setmetatable({AddKeyPicker = function() end}, { __index = self._tab:Paragraph({ Title = text }) })
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
                if type(func) ~= "function" then table.remove(changedListeners, i); continue end
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
    if self._win then
        pcall(function() self._win:Close():Destroy() end)
        task.spawn(function()
            task.wait(0.5)
            pcall(function()
                local a = game:GetService("CoreGui")
                --a["WindUI"]:Destroy()
                a["WindUI/Dropdowns"]:Destroy()
                a["WindUI/Notifications"]:Destroy()
            end)
        end)
    end
    self.Unloaded = true
    getgenv().voidware_loaded = false
    shared.Voidware_InkGame_Library = nil
end

function WindUIAdapter:Notify(msg, dur)
    return WindUI:Notify({
        Title = "Voidware",
        Content = msg,
        Duration = dur or 5
    })
end

return setmetatable(WindUIAdapter, { __index = WindUI })
