local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Events = ReplicatedStorage:WaitForChild("Events")
local UpdateRound = Events:WaitForChild("UpdateRound")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MegabloxGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 60)
frame.Position = UDim2.new(0.5, -150, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.4
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.new(1, 1, 1)
label.Font = Enum.Font.GothamBold
label.TextSize = 22
label.Text = "En attente..."
label.Parent = frame

local killLabel = Instance.new("TextLabel")
killLabel.Size = UDim2.new(0, 200, 0, 40)
killLabel.Position = UDim2.new(0.5, -100, 1, -50)
killLabel.BackgroundTransparency = 1
killLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
killLabel.Font = Enum.Font.GothamBold
killLabel.TextSize = 18
killLabel.Text = ""
killLabel.Parent = screenGui

UpdateRound.OnClientEvent:Connect(function(state, value)
	if state == "round" then
		label.Text = "⏱ " .. value .. "s"
		label.TextColor3 = Color3.new(1, 1, 1)
	elseif state == "intermission" then
		label.Text = "Intermission: " .. value .. "s"
		label.TextColor3 = Color3.fromRGB(200, 200, 200)
	elseif state == "waiting" then
		label.Text = "En attente de " .. value .. " joueur(s)"
		label.TextColor3 = Color3.fromRGB(255, 200, 0)
	elseif state == "end" then
		label.Text = "🏆 " .. value .. " a gagné !"
		label.TextColor3 = Color3.fromRGB(255, 215, 0)
	end
end)

player.CharacterAdded:Connect(function(char)
	local hum = char:WaitForChild("Humanoid")
	hum.Died:Connect(function()
		killLabel.Text = "💀 Tu es éliminé !"
		task.wait(3)
		killLabel.Text = ""
	end)
end)
