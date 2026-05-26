local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ROUND_TIME = 120
local INTERMISSION_TIME = 10
local MIN_PLAYERS = 2

local roundActive = false
local alivePlayers = {}

local Events = Instance.new("Folder")
Events.Name = "Events"
Events.Parent = ReplicatedStorage

local UpdateRound = Instance.new("RemoteEvent")
UpdateRound.Name = "UpdateRound"
UpdateRound.Parent = Events

local PlayerDied = Instance.new("RemoteEvent")
PlayerDied.Name = "PlayerDied"
PlayerDied.Parent = Events

local function getSpawns()
	local folder = workspace:FindFirstChild("Spawns")
	if not folder then return {} end
	return folder:GetChildren()
end

local function giveHammer(player)
	local template = ServerStorage:FindFirstChild("BonkHammer")
	if template then
		template:Clone().Parent = player.Backpack
	end
end

local function spawnAt(player, spawnPart)
	player:LoadCharacter()
	task.wait(0.2)
	if player.Character then
		player.Character:PivotTo(spawnPart.CFrame + Vector3.new(0, 5, 0))
	end
end

local function removeAlive(player)
	for i, p in alivePlayers do
		if p == player then
			table.remove(alivePlayers, i)
			return
		end
	end
end

local function startRound()
	roundActive = true
	alivePlayers = {}

	local spawns = getSpawns()
	local players = Players:GetPlayers()
	if #spawns == 0 then
		roundActive = false
		return
	end

	for i, player in players do
		spawnAt(player, spawns[(i - 1) % #spawns + 1])
		giveHammer(player)
		table.insert(alivePlayers, player)
	end

	UpdateRound:FireAllClients("round", ROUND_TIME)

	local elapsed = 0
	while elapsed < ROUND_TIME and #alivePlayers > 1 do
		task.wait(1)
		elapsed += 1
		UpdateRound:FireAllClients("round", ROUND_TIME - elapsed)
	end

	local winner = #alivePlayers == 1 and alivePlayers[1].Name or "Personne"
	UpdateRound:FireAllClients("end", winner)
	roundActive = false
end

PlayerDied.OnServerEvent:Connect(function(player)
	if roundActive then
		removeAlive(player)
	end
end)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		local hum = char:WaitForChild("Humanoid")
		hum.Died:Connect(function()
			if roundActive then
				removeAlive(player)
			end
		end)
	end)
end)

task.spawn(function()
	while true do
		UpdateRound:FireAllClients("intermission", INTERMISSION_TIME)
		task.wait(INTERMISSION_TIME)

		if #Players:GetPlayers() >= MIN_PLAYERS then
			startRound()
		else
			UpdateRound:FireAllClients("waiting", MIN_PLAYERS - #Players:GetPlayers())
		end
	end
end)
