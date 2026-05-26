local arena = workspace:WaitForChild("Arena")
local spawnsFolder = workspace:WaitForChild("Spawns")

local function makePart(size, position, color, anchored)
	local p = Instance.new("Part")
	p.Size = size
	p.Position = position
	p.BrickColor = BrickColor.new(color)
	p.Anchored = anchored ~= false
	p.Material = Enum.Material.SmoothPlastic
	p.Parent = arena
	return p
end

local function makeSpawn(position)
	local s = Instance.new("SpawnLocation")
	s.Size = Vector3.new(4, 1, 4)
	s.Position = position
	s.Anchored = true
	s.Enabled = false
	s.BrickColor = BrickColor.new("Bright yellow")
	s.Parent = spawnsFolder
end

-- Plateforme principale
makePart(Vector3.new(80, 4, 80), Vector3.new(0, 0, 0), "Medium stone grey")

-- Plateformes secondaires
local platforms = {
	{Vector3.new(20, 4, 20), Vector3.new(50, 10, 0)},
	{Vector3.new(20, 4, 20), Vector3.new(-50, 10, 0)},
	{Vector3.new(20, 4, 20), Vector3.new(0, 10, 50)},
	{Vector3.new(20, 4, 20), Vector3.new(0, 10, -50)},
	{Vector3.new(12, 4, 12), Vector3.new(50, 20, 50)},
	{Vector3.new(12, 4, 12), Vector3.new(-50, 20, -50)},
}

for _, data in platforms do
	makePart(data[1], data[2], "Light grey")
end

-- Obstacles centre
makePart(Vector3.new(6, 8, 6),  Vector3.new(20, 6, 0),   "Bright red")
makePart(Vector3.new(6, 8, 6),  Vector3.new(-20, 6, 0),  "Bright blue")
makePart(Vector3.new(6, 8, 6),  Vector3.new(0, 6, 20),   "Bright green")
makePart(Vector3.new(6, 8, 6),  Vector3.new(0, 6, -20),  "Bright yellow")
makePart(Vector3.new(10, 12, 4), Vector3.new(0, 8, 0),   "Medium stone grey")

-- Spawns
local spawnPositions = {
	Vector3.new(30, 5, 0),
	Vector3.new(-30, 5, 0),
	Vector3.new(0, 5, 30),
	Vector3.new(0, 5, -30),
	Vector3.new(50, 15, 0),
	Vector3.new(-50, 15, 0),
	Vector3.new(0, 15, 50),
	Vector3.new(0, 15, -50),
}

for _, pos in spawnPositions do
	makeSpawn(pos)
end

print("[Megablox] Map générée")
