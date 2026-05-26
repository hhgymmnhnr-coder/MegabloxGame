local tool = script.Parent
local handle = tool:WaitForChild("Handle")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)

local COOLDOWN = 0.8
local REACH = 8
local canSwing = true

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local swingAnim = Instance.new("Animation")
swingAnim.AnimationId = "rbxassetid://507766388"
local animTrack = humanoid:LoadAnimation(swingAnim)
animTrack.Priority = Enum.AnimationPriority.Action

tool.Activated:Connect(function()
	if not canSwing then return end
	canSwing = false

	animTrack:Play()

	for _, target in Players:GetPlayers() do
		if target == player then continue end
		local tchar = target.Character
		if not tchar then continue end
		local troot = tchar:FindFirstChild("HumanoidRootPart")
		local thum = tchar:FindFirstChild("Humanoid")
		if not troot or not thum then continue end

		local dist = (troot.Position - rootPart.Position).Magnitude
		if dist <= REACH then
			local direction = (troot.Position - rootPart.Position).Unit
			local knockback = direction * Config.KNOCKBACK_FORCE + Vector3.new(0, 40, 0)

			local bv = Instance.new("BodyVelocity")
			bv.Velocity = knockback
			bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
			bv.Parent = troot

			thum:TakeDamage(Config.HAMMER_DAMAGE)

			game:GetService("Debris"):AddItem(bv, 0.15)

			local Events = ReplicatedStorage:FindFirstChild("Events")
			if Events then
				local PlayerDied = Events:FindFirstChild("PlayerDied")
				if thum.Health <= 0 and PlayerDied then
					PlayerDied:FireServer()
				end
			end
		end
	end

	task.wait(COOLDOWN)
	canSwing = true
end)
