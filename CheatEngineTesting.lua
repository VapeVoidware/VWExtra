local CheatEngineMode = false

print("Starting CheatEngineMode checks...")

if (not getgenv) or (getgenv and type(getgenv) ~= "function") then 
    CheatEngineMode = true
    print("CheatEngineMode triggered: getgenv missing or not a function")
end

if getgenv and not getgenv().shared then 
    CheatEngineMode = true
    print("CheatEngineMode triggered: getgenv().shared missing, creating it")
    getgenv().shared = {} 
end

if getgenv and not getgenv().debug then 
    CheatEngineMode = true
    print("CheatEngineMode triggered: getgenv().debug missing, creating fallback")
    getgenv().debug = {traceback = function(string) return string end} 
end

if getgenv and not getgenv().require then 
    CheatEngineMode = true
    print("CheatEngineMode triggered: getgenv().require missing")
end

if getgenv and getgenv().require and type(getgenv().require) ~= "function" then 
    CheatEngineMode = true
    print("CheatEngineMode triggered: getgenv().require is not a function")
end

local debugChecks = {
    Type = "table",
    Functions = {
        "getupvalue",
        "getupvalues",
        "getconstants",
        "getproto"
    }
}

local function checkExecutor()
    if identifyexecutor ~= nil and type(identifyexecutor) == "function" then
        local suc, res = pcall(function() return identifyexecutor() end)
        local blacklist = {'solara', 'cryptic', 'xeno', 'ember', 'ronix'}
        local core_blacklist = {'solara', 'xeno'}
        if suc then
            for i,v in pairs(blacklist) do
                if string.find(string.lower(tostring(res)), v) then
                    CheatEngineMode = true
                    print("CheatEngineMode triggered: executor found in blacklist ->", v)
                end
            end
            for i,v in pairs(core_blacklist) do
                if string.find(string.lower(tostring(res)), v) then
                    pcall(function()
                        getgenv().queue_on_teleport = function() warn('queue_on_teleport disabled!') end
                    end)
                    print("Core blacklist executor detected:", v)
                end
            end
            if string.find(string.lower(tostring(res)), "delta") then
                getgenv().isnetworkowner = function() return true end
                print("Delta executor detected, isnetworkowner patched")
            end
        end
    end
end

task.spawn(function() pcall(checkExecutor) end)
task.spawn(function() pcall(function() if isfile("VW_API_KEY.txt") then delfile("VW_API_KEY.txt") end end) end)

local function checkRequire()
    if CheatEngineMode then 
        print("checkRequire skipped because CheatEngineMode is already true") 
        return 
    end

    local bedwarsID = {
        game = {6872274481, 8444591321, 8560631822},
        lobby = {6872265039}
    }

    if table.find(bedwarsID.game, game.PlaceId) then
        repeat task.wait() until game:GetService("Players").LocalPlayer.Character
        repeat task.wait() until game:GetService("Players").LocalPlayer.PlayerGui and game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("TopBarAppGui")
        local suc, data = pcall(function()
            return require(game:GetService("ReplicatedStorage").TS.remotes).default.Client
        end)
        if (not suc) or type(data) ~= 'table' or (not data.Get) then
            CheatEngineMode = true
            print("CheatEngineMode triggered: require check failed")
        end
    end
end

--task.spawn(function() pcall(checkRequire) end)

local function checkDebug()
    if CheatEngineMode then 
        print("checkDebug skipped because CheatEngineMode is already true") 
        return 
    end

    if not getgenv().debug then 
        CheatEngineMode = true
        print("CheatEngineMode triggered: getgenv().debug missing in checkDebug")
    else 
        if type(debug) ~= debugChecks.Type then 
            CheatEngineMode = true
            print("CheatEngineMode triggered: debug type mismatch")
        else 
            for i, v in pairs(debugChecks.Functions) do
                if not debug[v] or type(debug[v]) ~= "function" then 
                    CheatEngineMode = true
                    print("CheatEngineMode triggered: debug function missing or invalid ->", v)
                else
                    local suc, res = pcall(debug[v])
                    if tostring(res) == "Not Implemented" then 
                        CheatEngineMode = true
                        print("CheatEngineMode triggered: debug function returns 'Not Implemented' ->", v)
                    end
                end
            end
        end
    end
end

if (not CheatEngineMode) then checkDebug() end
shared.CheatEngineMode = shared.CheatEngineMode or CheatEngineMode
print("Final CheatEngineMode:", CheatEngineMode)
