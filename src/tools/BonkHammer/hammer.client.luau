local tool = script.Parent
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

local COOLDOWN = 0.8
local REACH = 8
local canSwing = true

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

tool.Activated:Connect(function()
	if not canSwing then return end
	canSwing = false

	for _, target in Players:GetPlayers() do
		if target == player then continue end
		local tchar = target.Character
		if not tchar then continue end
		local troot = tchar:FindFirstChild("HumanoidRootPart")
		local thum = tchar:FindFirstChild("Humanoid")
		if not troot or not thum then continue end

		if (troot.Position - rootPart.Position).Magnitude <= REACH then
			local dir = (troot.Position - rootPart.Position).Unit
			local bv = Instance.new("BodyVelocity")
			bv.Velocity = dir * Config.KNOCKBACK_FORCE + Vector3.new(0, 40, 0)
			bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
			bv.Parent = troot
			thum:TakeDamage(Config.HAMMER_DAMAGE)
			game:GetService("Debris"):AddItem(bv, 0.15)
		end
	end

	task.wait(COOLDOWN)
	canSwing = true
end)
