local arena = workspace:WaitForChild("Arena")
local spawns = workspace:WaitForChild("Spawns")
local RunService = game:GetService("RunService")

-- Sol statique (Floor dans project.json) : centre y=0, taille y=8, surface = y=4
local FLOOR = 4

workspace.FallenPartsDestroyHeight = -100

local C = {
	sand     = BrickColor.new("Bright yellow"),
	sandDark = BrickColor.new("Nougat"),
	rock     = BrickColor.new("Sand yellow"),
	rockDark = BrickColor.new("Dark orange"),
	accent   = BrickColor.new("Bright orange"),
	glow     = BrickColor.new("Bright red"),
	platform = BrickColor.new("Brick yellow"),
	green    = BrickColor.new("Bright green"),
}

local function p(size, pos, color, mat, tr)
	local part = Instance.new("Part")
	part.Size = size
	part.Position = pos
	part.BrickColor = color or C.sand
	part.Material = mat or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.Transparency = tr or 0
	part.Parent = arena
	return part
end

local function w(size, pos, color, ry)
	local wp = Instance.new("WedgePart")
	wp.Size = size
	wp.CFrame = CFrame.new(pos) * CFrame.Angles(0, math.rad(ry or 0), 0)
	wp.BrickColor = color or C.sandDark
	wp.Material = Enum.Material.SmoothPlastic
	wp.Anchored = true
	wp.Parent = arena
	return wp
end

local function spawn(pos, enabled)
	local s = Instance.new("SpawnLocation")
	s.Size = Vector3.new(4, 0.5, 4)
	s.Position = pos
	s.BrickColor = C.accent
	s.Material = Enum.Material.Neon
	s.Anchored = true
	s.Enabled = enabled or false
	s.Transparency = 0.5
	s.Parent = spawns
end

local function cactus(x, z)
	local y = FLOOR
	local h = 4 + math.random() * 2
	p(Vector3.new(1.2, h, 1.2),     Vector3.new(x, y + h/2, z), C.green)
	p(Vector3.new(1.2, 2.5, 1.2),   Vector3.new(x+2.5, y + h*0.6, z), C.green)
	p(Vector3.new(1.2, 1.5, 1.2),   Vector3.new(x+3.5, y + h*0.6 + 1, z), C.green)
	p(Vector3.new(1.2, 2, 1.2),     Vector3.new(x-2, y + h*0.7, z), C.green)
	p(Vector3.new(1.2, 1.2, 1.2),   Vector3.new(x-3, y + h*0.65 + 0.5, z), C.green)
end

local function rock(x, z, s)
	s = s or 1
	local y = FLOOR
	p(Vector3.new(4*s,3*s,3.5*s),   Vector3.new(x, y+1.5*s, z), C.rock)
	p(Vector3.new(2.5*s,4*s,2*s),   Vector3.new(x+0.5*s, y+2*s, z+0.5*s), C.rockDark)
	p(Vector3.new(3*s,1.5*s,2.5*s), Vector3.new(x-0.3*s, y+3.5*s, z), C.rock)
end

-- Dalles décoratives sol
for x = -3, 3 do
	for z = -3, 3 do
		if math.random() > 0.55 then
			p(Vector3.new(11, 0.4, 11),
				Vector3.new(x*12+math.random(-1,1), FLOOR+0.2, z*12+math.random(-1,1)),
				C.sandDark)
		end
	end
end

-- Bords falaises
for i = 0, 7 do
	local a = i * math.pi/4
	local r = 52
	p(Vector3.new(16, 10, 6), Vector3.new(math.cos(a)*r, FLOOR+1, math.sin(a)*r), C.rockDark)
	p(Vector3.new(8, 14, 4),  Vector3.new(math.cos(a+0.2)*r+2, FLOOR+5, math.sin(a+0.2)*r+2), C.rock)
end

-- Plateformes laterales (niveau 1)
for _, d in {
	{Vector3.new(24,4,24), Vector3.new( 50, FLOOR+14, 0),  C.platform},
	{Vector3.new(24,4,24), Vector3.new(-50, FLOOR+14, 0),  C.platform},
	{Vector3.new(24,4,24), Vector3.new(0, FLOOR+14,  50),  C.platform},
	{Vector3.new(24,4,24), Vector3.new(0, FLOOR+14, -50),  C.platform},
} do
	p(d[1], d[2], d[3])
	p(Vector3.new(d[1].X-2, 0.5, d[1].Z-2), d[2]+Vector3.new(0, d[1].Y/2+0.25, 0), C.sand)
	p(Vector3.new(d[1].X+0.5, 0.6, d[1].Z+0.5), d[2]+Vector3.new(0, d[1].Y/2+0.4, 0), C.accent, Enum.Material.Neon, 0.5)
end

-- Plateformes hautes (coins)
for _, d in {
	{Vector3.new(16,3,16), Vector3.new( 55, FLOOR+28,  55)},
	{Vector3.new(16,3,16), Vector3.new(-55, FLOOR+28,  55)},
	{Vector3.new(16,3,16), Vector3.new( 55, FLOOR+28, -55)},
	{Vector3.new(16,3,16), Vector3.new(-55, FLOOR+28, -55)},
} do
	p(d[1], d[2], C.rock)
	p(Vector3.new(d[1].X-1, 0.4, d[1].Z-1), d[2]+Vector3.new(0, d[1].Y/2+0.2, 0), C.sand)
	p(Vector3.new(d[1].X+0.5, 0.5, d[1].Z+0.5), d[2]+Vector3.new(0, d[1].Y/2+0.3, 0), C.glow, Enum.Material.Neon, 0.6)
end

-- Tour centrale
p(Vector3.new(8,22,8),    Vector3.new(0, FLOOR+11, 0), C.rockDark)
p(Vector3.new(10,1,10),   Vector3.new(0, FLOOR+22.5, 0), C.accent)
p(Vector3.new(10,3,10),   Vector3.new(0, FLOOR+24, 0), C.platform)
p(Vector3.new(11,0.5,11), Vector3.new(0, FLOOR+25.75, 0), C.accent, Enum.Material.Neon, 0.4)

-- Piliers intermédiaires
for _, pos in {
	Vector3.new(28,0,0), Vector3.new(-28,0,0),
	Vector3.new(0,0,28), Vector3.new(0,0,-28),
} do
	p(Vector3.new(5,14,5), pos+Vector3.new(0, FLOOR+7, 0), C.rock)
	p(Vector3.new(7,1.5,7), pos+Vector3.new(0, FLOOR+14.75, 0), C.platform)
	p(Vector3.new(7.5,0.5,7.5), pos+Vector3.new(0, FLOOR+15.75, 0), C.accent, Enum.Material.Neon, 0.5)
end

-- Dunes
for _, d in {
	{Vector3.new(22,7,9),  Vector3.new( 32, FLOOR+3.5, 0),   0},
	{Vector3.new(22,7,9),  Vector3.new(-32, FLOOR+3.5, 0), 180},
	{Vector3.new(9,7,22),  Vector3.new(0, FLOOR+3.5,  32),  90},
	{Vector3.new(9,7,22),  Vector3.new(0, FLOOR+3.5, -32), 270},
} do
	w(d[1], d[2], C.sandDark, d[3])
end

-- Rochers
rock( 18, 18, 1.2)
rock(-18, 18, 1.0)
rock( 18,-18, 0.9)
rock(-18,-18, 1.1)

-- Cactus
for _, c in {
	{38,12},{-38,-12},{12,-38},{-12,38},
	{-38,12},{38,-12},{-12,-38},{12,38},
} do
	cactus(c[1], c[2])
end

-- Ambiance désert
local L = game:GetService("Lighting")
L.Ambient         = Color3.fromRGB(80, 60, 40)
L.OutdoorAmbient  = Color3.fromRGB(180, 140, 80)
L.Brightness      = 3
L.TimeOfDay       = "14:00:00"
L.FogColor        = Color3.fromRGB(255, 200, 120)
L.FogEnd          = 600

local atm = Instance.new("Atmosphere")
atm.Density  = 0.25
atm.Color    = Color3.fromRGB(255, 175, 90)
atm.Decay    = Color3.fromRGB(200, 120, 50)
atm.Glare    = 0.5
atm.Haze     = 1.5
atm.Parent   = L

local cc = Instance.new("ColorCorrectionEffect")
cc.Saturation = 0.2
cc.Contrast   = 0.1
cc.TintColor  = Color3.fromRGB(255, 235, 190)
cc.Parent     = L

-- Spawns de round
for _, pos in {
	Vector3.new(22, FLOOR+2, 0),   Vector3.new(-22, FLOOR+2, 0),
	Vector3.new(0, FLOOR+2, 22),   Vector3.new(0, FLOOR+2, -22),
	Vector3.new(50, FLOOR+18, 0),  Vector3.new(-50, FLOOR+18, 0),
	Vector3.new(0, FLOOR+18, 50),  Vector3.new(0, FLOOR+18, -50),
	Vector3.new(55, FLOOR+31, 55), Vector3.new(-55, FLOOR+31, 55),
	Vector3.new(55, FLOOR+31,-55), Vector3.new(-55, FLOOR+31,-55),
} do
	spawn(pos, false)
end

-- Plateformes mobiles
local moving = {}
for _, d in {
	{Vector3.new(16,2.5,16), Vector3.new(0,  FLOOR+40, 70),  Vector3.new(0,0,28),  0.5, 0},
	{Vector3.new(16,2.5,16), Vector3.new(70, FLOOR+40, 0),   Vector3.new(28,0,0),  0.4, 1},
	{Vector3.new(16,2.5,16), Vector3.new(-70,FLOOR+40, 0),   Vector3.new(28,0,0),  0.6, 2},
	{Vector3.new(12,2,12),   Vector3.new(0,  FLOOR+22, 0),   Vector3.new(0,10,0),  0.8, 3},
} do
	local mp = p(d[1], d[2], C.glow, Enum.Material.Neon, 0.1)
	p(Vector3.new(d[1].X-1, 0.5, d[1].Z-1), d[2]+Vector3.new(0, d[1].Y/2+0.25, 0), C.accent)
	table.insert(moving, {part=mp, origin=d[2], range=d[3], speed=d[4], off=d[5]*1.2})
end

RunService.Heartbeat:Connect(function()
	local t = tick()
	for _, m in moving do
		m.part.CFrame = CFrame.new(m.origin + m.range * math.sin(t*m.speed + m.off))
	end
end)

print("[Megablox] Map desert loaded ✓")
