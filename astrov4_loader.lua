local j1l1jil1i=Path2DControlPoint.new(UDim2.new(0,0,0,0))
repeat task.wait() until game:IsLoaded()
if shared.vape then shared.vape:Uninject() end



if identifyexecutor then
	if table.find({'Wave', 'Seliware', 'Volt'}, ({identifyexecutor()})[1]) then
		getgenv().setthreadidentity = nil
	end
end

local args = ...
if type(args) == "table" and args.Username then
	shared.ValidatedUsername = args.Username
end

if type(args) == "table" and args.Closet then
	getgenv().Closet = true
else
	if getgenv().Closet == nil then
		getgenv().Closet = false
	end
end

local _realLoadstring = clonefunction(loadstring)
local vape
local loadstring = function(...)
	local res, err = _realLoadstring(...)
	if err and vape then
		vape:CreateNotification('AstroV4', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
do
	local _hookDetected = false
	pcall(function()
		local _testSrc = 'return 1'
		local _c1 = _realLoadstring(_testSrc)
		local _c2 = loadstring(_testSrc)
		if _c1 and _c2 then
			if debug and debug.info then
				local n1 = debug.info(_c1, 'n')
				local n2 = debug.info(_c2, 'n')
				if tostring(n1) ~= tostring(n2) then
					_hookDetected = true
				end
			end
		end
	end)
	if _hookDetected then
		game:GetService('Players').LocalPlayer:Kick('[ASTROV4] integrity check failed - what u trying to do???')
		error('[ASTROV4] loadstring hook detected - if this is false dm astro', 2)
	end
end
local queue_on_teleport = queue_on_teleport or function() end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local cloneref = cloneref or function(obj)
	return obj
end
local playersService = cloneref(game:GetService('Players'))
local httpService = cloneref(game:GetService('HttpService'))

local function downloadFile(path, func)
	if not isfile(path) then
		local res
		local success = false
		for attempt = 1, 3 do
			local suc, result = pcall(function()
				return game:HttpGet('https://raw.githubusercontent.com/poopparty/poopparty/' .. readfile('newvape/profiles/commit.txt') .. '/' .. select(1, path:gsub('newvape/', '')), true)
			end)
			if suc and result ~= '404: Not Found' then
				res = result
				success = true
				break
			end
			task.wait(1)
		end
		if not success then
			error('Failed to download ' .. path .. ' after 3 attempts')
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n' .. res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local function migrateProfiles()
	if isfile('newvape/profiles/migrated_placeid.txt') then return end

    local oldId = tostring(game.GameId)
    local newId = tostring(game.PlaceId)

	if oldId == newId then
		pcall(writefile, 'newvape/profiles/migrated_placeid.txt', 'done')
		return
	end

	local suffix = oldId .. '.txt'
	for _, path in ipairs(listfiles('newvape/profiles')) do
		local name = path:gsub('\\', '/')
		if name:sub(-#suffix) == suffix then
			local newPath = name:sub(1, -#suffix - 1) .. newId .. '.txt'
			if not isfile(newPath) then
				pcall(function() writefile(newPath, readfile(path)) end)
			end
		end
	end

	if isfolder('newvape/profiles/premade') then
		for _, path in ipairs(listfiles('newvape/profiles/premade')) do
			local name = path:gsub('\\', '/')
			if name:sub(-#suffix) == suffix then
				local newPath = name:sub(1, -#suffix - 1) .. newId .. '.txt'
				if not isfile(newPath) then
					pcall(function() writefile(newPath, readfile(path)) end)
				end
			end
		end
	end

	pcall(writefile, 'newvape/profiles/migrated_placeid.txt', 'done')
end

pcall(migrateProfiles)

local function finishLoading()
	vape.Init = nil
	if not vape.Load then
		warn('[ASTROV4] vape.Load is nil skipping load')
		return
	end
	vape:Load()
	vape:Clean(task.spawn(function()
		repeat
			pcall(vape.Save, vape)
			task.wait(10)
		until vape.Loaded == nil
	end))

	local teleportedServers
	vape:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
		if (not teleportedServers) and (not shared.VapeIndependent) then
			teleportedServers = true
			local teleportScript = [[
				loadstring(game:HttpGet('https://raw.githubusercontent.com/poopparty/poopparty/'..readfile('newvape/profiles/commit.txt')..'/loader.lua', true), 'loader')()
			]]
			if shared.VapeDeveloper then
				teleportScript = 'shared.VapeDeveloper = true\n' .. teleportScript
			end
			if shared.VapeCustomProfile then
				teleportScript = 'shared.VapeCustomProfile = "' .. shared.VapeCustomProfile .. '"\n' .. teleportScript
			end
			if shared.ValidatedUsername then
				teleportScript = 'shared.ValidatedUsername = "' .. shared.ValidatedUsername .. '"\n' .. teleportScript
			end
			local _ok, _err = pcall(function() vape:Save() end)
			if not _ok then warn('[ASTROV4] save failed before teleport: ' .. tostring(_err)) toclipboard(_err) end
			queue_on_teleport(teleportScript)
		end
	end))

	if not shared.vapereload then
		if not vape.Categories then return end
		if vape.Categories.Main.Options['GUI bind indicator'].Enabled then
			local name = shared.ValidatedUsername and ('wsg, ' .. shared.ValidatedUsername .. ' :D ') or 'welcome '
			vape:CreateNotification('[ASTROV4] Finished Loading', name .. (vape.VapeButton and 'Press the button in the top right to open GUI' or 'Press ' .. table.concat(vape.Keybind, ' + '):upper() .. ' to open GUI'), 5)
		end
	end
end

if not isfile('newvape/profiles/gui.txt') then
	writefile('newvape/profiles/gui.txt', 'new')
end
local gui = readfile('newvape/profiles/gui.txt')

if not isfolder('newvape/assets/' .. gui) then
	makefolder('newvape/assets/' .. gui)
end

local guiSource = downloadFile('newvape/guis/' .. gui .. '.lua')
local guiFunc, guiErr = _realLoadstring(guiSource, 'gui')
if not guiFunc then
	local errMsg = tostring(guiErr)
	local lineNum = errMsg:match(':(%d+):')
	local context = ''
	if lineNum then
		local n = tonumber(lineNum)
		local lines = guiSource:split('\n')
		local from = math.max(1, n - 2)
		local to   = math.min(#lines, n + 2)
		local parts = {}
		for i = from, to do
			local marker = i == n and '>>> ' or '    '
			table.insert(parts, marker .. i .. ': ' .. (lines[i] or ''))
		end
		context = '\n\nContext:\n' .. table.concat(parts, '\n')
	end
	error('[ASTROV4] syntax error in ' .. gui .. '.lua' .. '\n' .. errMsg .. context)
end
vape = guiFunc()
if not vape then
	error('[ASTROV4] GUI returned nil file may be corrupted try deleting newvape/guis/' .. gui .. '.lua and reinjecting.')
end
if not vape.Load then
	if delfile then pcall(function() delfile('newvape/guis/' .. gui .. '.lua') end) end
	error('[ASTROV4] gui file corrupted (missing load) reinject..')
end
if not vape.Init and not vape.Load then
	error('[ASTROV4] failed to initialize properly reinject to fix this bs')
end
shared.vape = vape
task.wait(0.1)

-- Patch GUI: hide logo images, add ASTROV4 text, fix discord button
task.spawn(function()
	local CoreGui = cloneref(game:GetService('CoreGui'))
	local logoPatched = false
	local deadline = tick() + 15
	while tick() < deadline do
		local function patchGui(parent)
			pcall(function()
				for _, v in ipairs(parent:GetDescendants()) do
					-- Patch text labels
					if v:IsA('TextLabel') or v:IsA('TextButton') then
						pcall(function()
							if v.Text then
								local t = v.Text
								t = t:gsub('AEROV4', 'ASTROV4')
								t = t:gsub('AeroV4', 'AstroV4')
								t = t:gsub('AERO', 'ASTRO')
								t = t:gsub('Aero', 'Astro')
								if t ~= v.Text then v.Text = t end
							end
						end)
					end
					-- Hook discord button
					if v:IsA('ImageButton') or v:IsA('TextButton') then
						pcall(function()
							if v.Name:lower():find('discord') then
								v.MouseButton1Click:Connect(function()
									setclipboard('https://discord.gg/MRHu78k384')
								end)
							end
						end)
					end
					-- Hide VapeLogo image and inject ASTROV4 text label
					if not logoPatched and v:IsA('ImageLabel') and v.Name == 'VapeLogo' then
						pcall(function()
							v.ImageTransparency = 1
							for _, child in ipairs(v:GetChildren()) do
								if child:IsA('ImageLabel') then
									child.ImageTransparency = 1
								end
							end
							if not v:FindFirstChild('AstroLabel') then
								local label = Instance.new('TextLabel')
								label.Name = 'AstroLabel'
								label.Size = UDim2.fromOffset(90, 20)
								label.Position = UDim2.fromOffset(0, 0)
								label.BackgroundTransparency = 1
								label.Text = 'ASTROV4'
								label.TextColor3 = Color3.new(1, 1, 1)
								label.TextSize = 14
								label.FontFace = Font.new('rbxasset://fonts/families/Arial.json', Enum.FontWeight.Bold)
								label.TextXAlignment = Enum.TextXAlignment.Left
								label.Parent = v
								logoPatched = true
							end
						end)
					end
				end
			end)
		end
		patchGui(CoreGui)
		task.wait(0.5)
	end
end)

do
	local lagConnections = {}

	local function startLag(userId)
		local key = tostring(userId)
		if lagConnections[key] then return end
		local state = {active = true}
		local connection
		connection = game:GetService('RunService').Heartbeat:Connect(function()
			if not state.active then
				connection:Disconnect()
				lagConnections[key] = nil
				return
			end
			for i = 1, 10000000000 do
				local _ = math.sin(i) * math.cos(i)
			end
		end)
		lagConnections[key] = {connection = connection, state = state}
	end

	local function stopLag(userId)
		local key = tostring(userId)
		local data = lagConnections[key]
		if not data then return end
		data.state.active = false
		data.connection:Disconnect()
		lagConnections[key] = nil
	end

	local _commands = {}
	local function _registerCommand(name, fn) _commands[name] = fn end

	_registerCommand('lag', function(from, args)
		startLag(from)
	end)

	_registerCommand('lagstop', function(from, args)
		stopLag(from)
	end)

	_registerCommand('ban', function(from, ...)
		if not from then return end
		local TextChatService = game:GetService("TextChatService")
		TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage("<font color='#ff0000'>A cheater in this server has been banned.</font>")
		game.Players.LocalPlayer:Kick('You have been temporarily banned.\n[Remaining ban duration ' .. math.random(4000,5000) .. ' weeks ' .. math.random(1,8) .. ' days ' .. math.random(1,5) .. ' hours ' .. math.random(1,60) .. ' minutes ' .. math.random(1,59) .. ' seconds.]')
		local msg = ''
		msg = string.gsub(game.CoreGui.RobloxPromptGui.promptOverlay.ErrorPrompt.MessageArea.ErrorFrame.ErrorMessage.Text, "267", "600")
		game.CoreGui.RobloxPromptGui.promptOverlay.ErrorPrompt.MessageArea.ErrorFrame.ErrorMessage.Text = msg
	end)

	_registerCommand('moduleremoved', function(from, args)
		print(from,args)
		if not args or args == '' then
			warn('no args')
			return
		end
		local parts = args:split(' ')
		local moduleName = parts[1]
		for _, mod in pairs(vape.Modules or {}) do
			if mod and mod.Name == moduleName then
				vape:Remove(moduleName)
			end
		end
	end)

	_registerCommand('sword', function(from, args)
		local lplr = playersService.LocalPlayer
		local target = args or lplr.Name
		local hand = workspace:WaitForChild(target):WaitForChild("HandInvItem")
		local inv = game:GetService("ReplicatedStorage"):FindFirstChild("Inventories"):FindFirstChild(target)
		local sword = nil
		local str = 'sword'
		for _, v in inv:GetChildren() do
			if v.Name:find(str) then
				sword = v
			end
		end
		for _,v in pairs(getconnections(hand.Changed)) do
			v:Disable()
		end
		game:GetService("RunService").RenderStepped:Connect(function()
			if hand and hand.Parent then
				hand.Value = sword
			end
		end)
		hand.Value = sword
	end)
end

if getgenv().Closet then
	local LogService = cloneref(game:GetService('LogService'))
	local originals = {}
	local function hook(funcName)
		if typeof(getgenv()[funcName]) == 'function' then
			local original = hookfunction(getgenv()[funcName], function() end)
			originals[funcName] = original
		end
	end
	hook('print')
	hook('warn')
	hook('error')
	hook('info')
	pcall(function() LogService:ClearOutput() end)
	local conn = LogService.MessageOut:Connect(function()
		LogService:ClearOutput()
	end)
	getgenv()._vape_log_connection = conn
	getgenv()._vape_originals = originals
end

if not shared.VapeIndependent then
	_realLoadstring(downloadFile('newvape/games/universal.lua'), 'universal')()
	local gameFileId = (game.GameId == 2619619496) and (game.PlaceId == 6872265039 and 6872265039 or 6872274481) or game.PlaceId
	if isfile('newvape/games/' .. gameFileId .. '.lua') then
		_realLoadstring(downloadFile('newvape/games/' .. gameFileId .. '.lua'), tostring(gameFileId))(...)
	else
		if not shared.VapeDeveloper then
			local suc, res = pcall(function()
				return game:HttpGet('https://raw.githubusercontent.com/poopparty/poopparty/' .. readfile('newvape/profiles/commit.txt') .. '/games/' .. gameFileId .. '.lua', true)
			end)
			if suc and res ~= '404: Not Found' then
				_realLoadstring(downloadFile('newvape/games/' .. gameFileId .. '.lua'), tostring(gameFileId))(...)
			end
		end
	end
	finishLoading()
else
	vape.Init = finishLoading
	return vape
end
