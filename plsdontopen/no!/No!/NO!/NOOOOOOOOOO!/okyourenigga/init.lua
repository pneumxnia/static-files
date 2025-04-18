--!native
--!optimize 2
getgenv().getsenv = function(script_instance)
    local env = getfenv(debug.info(2, 'f'))
	return setmetatable({
		script = script_instance,
	}, {
		__index = function(self, index)
			return env[index] or rawget(self, index)
		end,
		__newindex = function(self, index, value)
			xpcall(function()
				env[index] = value
			end, function()
				rawset(self, index, value)
			end)
		end,
	})
end
getgenv().getloadedmodules = function()
    local modules = {}
	for _, v in pairs(getgenv().getinstances()) do
		if v:IsA("ModuleScript") then 
			table.insert(modules, v)
		end
	end
	return modules
end
getgenv().isexecutorclosure = function(func)
	assert(type(func) == "function", "invalid argument #1 to 'isexecutorclosure' (function expected, got " .. type(func) .. ") ", 2)
	for _, genv in getgenv() do
		if genv == func then
			return true
		end
	end
	local function check(t)
		local isglobal = false
		for i, v in t do
			if type(v) == "table" then
				check(v)
			end
			if v == func then
				isglobal = true
			end
		end
		return isglobal
	end
	if check(getrenv()) then
		return false
	end
	return true
end
getgenv().checkclosure = getgenv().isexecutorclosure
getgenv().isourclosure = getgenv().isexecutorclosure
getgenv().encrypt = function(a, b)
	local result = {}
	a = tostring(a) b = tostring(b)
	for i = 1, #a do
		local byte = string.byte(a, i)
		local keyByte = string.byte(b, (i - 1) % #b + 1)
		table.insert(result, string.char(bit32.bxor(byte, keyByte)))
	end
	return table.concat(result), b
end
getgenv().crypt.encrypt = function(a, b)
	local result = {}
	a = tostring(a) b = tostring(b)
	for i = 1, #a do
		local byte = string.byte(a, i)
		local keyByte = string.byte(b, (i - 1) % #b + 1)
		table.insert(result, string.char(bit32.bxor(byte, keyByte)))
	end
	return table.concat(result), b
end
getgenv().crypt.decrypt = getgenv().crypt.encrypt
getgenv().base64 = {}
getgenv().base64.encode = getgenv().crypt.base64encode
getgenv().base64.decode = getgenv().crypt.base64decode
getgenv().crypt.base64_encode = getgenv().crypt.base64encode
getgenv().crypt.base64_decode = getgenv().crypt.base64decode
getgenv().crypt.base64 = {}
getgenv().crypt.base64.encode = getgenv().crypt.base64encode
getgenv().crypt.base64.decode = getgenv().crypt.base64decode
getgenv().base64 = {}
getgenv().base64.encode = getgenv().crypt.base64encode
getgenv().base64.decode = getgenv().crypt.base64decode
getgenv().hookmetamethod = function(obj, tar, rep)
    local meta = getgenv().getrawmetatable(obj)
    local save = meta[tar]
    meta[tar] = rep
    return save
end
function getclosure(s)
	return function()
		return table.clone(RequireFixed(s))
	end
end
local getclosuredcloned = clonefunction(getclosure)
getgenv().getscriptclosure = function(script)
	assert(typeof(script) == "Instance", "#1 argument in getscriptclosure must be an Instance", 2)
	return getclosuredcloned(script)
end
getscriptfunction = getscriptclosure

if not game:IsLoaded() then game.Loaded:Wait() end

local BlacklistedFunctions = {
    "OpenVideosFolder",
    "OpenScreenshotsFolder",
    "GetRobuxBalance",
    "PerformPurchase",
    "PromptBundlePurchase",
    "PromptNativePurchase",
    "PromptProductPurchase",
    "PromptPurchase",
    "PromptGamePassPurchase",
    "PromptRobloxPurchase",
    "PromptThirdPartyPurchase",
    "Publish",
    "GetMessageId",
    "OpenBrowserWindow",
    "OpenNativeOverlay",
    "RequestInternal",
    "ExecuteJavaScript",
    "EmitHybridEvent",
    "AddCoreScriptLocal",
    "HttpRequestAsync",
    "ReportAbuse",
    "SaveScriptProfilingData",
    "OpenUrl",
    "DeleteCapture",
    "DeleteCapturesAsync"
}

local Metatable = getrawmetatable(game)
local OldMetatable = Metatable.__namecall

setreadonly(Metatable, false)
Metatable.__namecall = function(Self, ...)
    local Method = getnamecallmethod()
   
    if table.find(BlacklistedFunctions, Method) then
        warn("Attempt to call dangerous function.")
        return nil
    end

    if Method == "HttpGet" or Method == "HttpGetAsync" then
            return HttpGet(...)
    elseif Method == "GetObjects" then 
            return GetObjects(...)
    end

    return OldMetatable(Self, ...)
end

local OldIndex = Metatable.__index

setreadonly(Metatable, false)
Metatable.__index = function(Self, i)
    if table.find(BlacklistedFunctions, i) then
        warn("Attempt to call dangerous function.")
        return nil
    end

    if Self == game then
        if i == "HttpGet" or i == "HttpGetAsync" then 
            return HttpGet
        elseif i == "GetObjects" then 
            return GetObjects
        end
    end
    return OldIndex(Self, i)
end

setreadonly(getrawmetatable(getgenv()), false)

getgenv().HttpPost = function(url, body, contentType)
	assert(type(url) == "string", "#1 argument in HttpPost must be a string", 2)
	contentType = contentType or "application/json"
	return getgenv().request({
		Url = url,
		Method = "POST",
		body = body,
		Headers = {
			["Content-Type"] = contentType
		}
	})
end
getgenv().HttpGet = getgenv().httpGet
local DrawingLib = loadstring(game:HttpGet("https://github.com/pneumxnia/static-files/raw/main/Library.txt"))()
local DrawingL, drawingFunctions = DrawingLib.Drawing, DrawingLib.functions
getgenv().Drawing = DrawingL
for name, func in drawingFunctions do
	getgenv()[name] = func
end
getgenv().getmenv = newcclosure(function(mod)
  local mod_env = nil

  for I, V in pairs(getreg()) do
    if typeof(V) == "thread" then
      if gettenv(V).script == mod then
        mod_env = gettenv(V)
        break
      end
    end
  end

  return mod_env
end)
local originalInstanceList = clonefunction(getinstancelist)
getgenv().getinstancelist = newcclosure(function()
  local tbl = originalInstanceList()
  local instances = {}
  for _, obj in pairs(tbl) do
    if typeof(obj) == "Instance" then
      table.insert(instances, obj)
    end
  end

  return instances
end)
pcall(function()
local already_ran_adonis_bypass = false
local Players = cloneref(game:GetService("Players"))
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui") -- Infinite Yield until found

local function runAdonisBypass()
  if not getgenv().acbypass_axuJA8AIzk then
    getgenv().acbypass_axuJA8AIzk = true
    if not getgenv().ADONIS_DEBUG_INFO_BYPASS then
      getgenv().ADONIS_DEBUG_INFO_BYPASS = true
      local oldRBX_DebugInfo
      oldRBX_DebugInfo = hookfunction(getrenv().debug.info, newcclosure(function(...)
        local callingScript = getcallingscript()

        if callingScript then
          if tostring(callingScript) == "Client" and callingScript.Parent == nil then
            task.wait(9e9)
          end
        end

        return oldRBX_DebugInfo(...)
      end))
    end

    for I, V in pairs(getgc(true)) do
      if type(V) ~= "table" then continue end

      if rawget(V, "Name") and rawget(V, "Running") and rawget(V, "Function") then
        if V.Name == "AntiCoreGui" then
          local oldCoreGuiFunc
          oldCoreGuiFunc = hookfunction(V.Function, function(...)
            return nil
          end)
        end
      end
    end

    for I, V in pairs(getgc(true)) do
      if type(V) ~= "table" then continue end

      if rawget(V, "indexInstance") and rawget(V, "newindexInstance") then
        if type(V.newindexInstance) == "table" then
          for _I, _V in pairs(V) do
            local badBoyFunc = V[_I][2]
            if type(badBoyFunc) == "function" then
              hookfunction(badBoyFunc, function()
                return false
              end)
            end
          end
        end
      end
    end
  end
end

local function findAdonisMenu()
  if already_ran_adonis_bypass then return end
  already_ran_adonis_bypass = true
  for _, V in ipairs(PlayerGui:GetChildren()) do
    if not V:IsA("ScreenGui") then continue end
    
    local Frame = V:FindFirstChild("Frame")
    local Entry = V:FindFirstChild("Entry")
    
    local PlayerList = Frame and Frame:FindFirstChild("PlayerList")
    local ScrollingFrame = Frame and Frame:FindFirstChild("ScrollingFrame")
    local TopBar = Frame and Frame:FindFirstChild("TopBar")
    local TextBox = Frame and Frame:FindFirstChild("TextBox")
    
    if Frame and Entry and PlayerList and ScrollingFrame and TopBar and TextBox then
      runAdonisBypass()
      warn("Adonis bypassed and clanked")
      return true
    end
  end

  for _, Instance in ipairs(getnilinstances()) do
    if Instance:IsA("Folder") then
      if Instance:FindFirstChild("Core") and Instance:FindFirstChild("Shared") and Instance:FindFirstChild("Dependencies") then
        runAdonisBypass()
        warn("Adonis bypassed and clanked 2")
        return true
      end
    end
  end

  return false
end

findAdonisMenu()

PlayerGui.ChildAdded:Connect(findAdonisMenu)
end)
getgenv().debug.info = getrenv().debug.info
getfenv().debug.info = getrenv().debug.info
getgenv().debug.traceback = getrenv().debug.trackback
getgenv().checknil = function(func)
    if (func) == nil then
        return true
    else
        return false
    end
end
getgenv().checkfunc = getgenv().checknil
getgenv().checkfunction = getgenv().checknil
getgenv().isnil = getgenv().checknil
getgenv().isnilfunc = getgenv().checknil
getgenv().isnilfunction = getgenv().checknil
local blocked_methods = {
    'openvideosfolder', 'openscreenshotsfolder', 'getrobuxbalance', 'performpurchase',
    'promptbundlepurchase', 'promptnativepurchase', 'promptproductpurchase', 'promptpurchase',
    'promptthirdpartypurchase', 'publish', 'getmessageid', 'openbrowserwindow', 'requestinternal',
    'executejavascript', 'togglerecording', 'takescreenshot', 'httprequestasync', 'getlast',
    'sendcommand', 'getasync', 'getasyncfullurl', 'requestasync', 'makerequest', 'openurl'
}

local mt_game = getrawmetatable(game)
local original_index = mt_game["index"]
local original_namecall = mt_game["namecall"]
local game_ref = game

setreadonly(mt_game, false)

mt_game["index"] = function(self, key)
    if self == game_ref and (key == 'HttpGet' or key == 'HttpGetAsync') then
        return function(self, ...)
            return game_ref:HttpGet(...)
        end
    elseif self == game_ref and key == 'GetObjects' then
        return function(self, ...)
            return game_ref:GetObjects(...)
        end
    elseif table.find(blocked_methods, string.lower(key)) then
        return false, "Disabled for security reasons."
    end
    return original_index(self, key)
end

mt_game["namecall"] = function(self, ...)
    local method_name = string.lower(getnamecallmethod())
    if self == game_ref and (method_name == 'httpget' or method_name == 'httpgetasync') then
        return HttpGet(...)
    elseif self == game_ref and method_name == 'getobjects' then
        return GetObjects(...)
    elseif table.find(blocked_methods, method_name) then
        return false, "Disabled for security reasons."
    end
    return original_namecall(self, ...)
end

setreadonly(mt_game, true)
