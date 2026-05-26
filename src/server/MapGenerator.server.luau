local arena = workspace:WaitForChild("Arena")
local spawns = workspace:WaitForChild("Spawns")
local RunService = game:GetService("RunService")

workspace.FallenPartsDestroyHeight = -100

-- Couleurs thème désert low-poly (inspiré Megabonk)
local C = {
	sand       = BrickColor.new("Bright yellow"),
	sandDark   = BrickColor.new("Nougat"),
	rock       = BrickColor.new("Sand yellow"),
	rockDark   = BrickColor.new("Dark orange"),
	sky        = BrickColor.new("Cyan"),
	accent     = BrickColor.new("Bright orange"),
	glow       = BrickColor.new("Bright red"),
	white      = BrickColor.new("White"),
	green      = BrickColor.new("Bright green"),
	platform   = BrickColor.new("Brick yellow"),
}

local function p(size, pos, color, mat, transparency)
	local part = Instance.new("Part")
	part.Size = size
	part.CFrame = CFrame.new(pos)
	part.BrickColor = color or C.sand
	part.Material = mat or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CastShadow = true
	part.Transparency = transparency or 0
	part.Parent = arena
	return part
end

local function wedge(size, pos, color, rot)
	local w = Instance.new("WedgePart")
	w.Size = size
	w.CFrame = CFrame.new(pos) * CFrame.Angles(0, math.rad(rot or 0), 0)
	w.BrickColor = color or C.sand
	w.Material = Enum.Material.SmoothPlastic
	w.Anchored = true
	w.Parent = arena
	return w
end

local function spawnPt(pos, enabled)
	local s = Instance.new("SpawnLocation")
	s.Size = Vector3.new(4, 0.5, 4)
	s.CFrame = CFrame.new(pos)
	s.BrickColor = C.accent
	s.Material = Enum.Material.Neon
	s.Anchored = true
	s.Enabled = enabled or false
	s.Transparency = enabled and 0.6 or 0.9
	s.Parent = spawns
end

local function cactus(pos)
	local h = 3 + math.random()*3
	local trunk = p(Vector3.new(1.2, h, 1.2), pos + Vector3.new(0, h/2, 0), C.green)
	local arm1 = p(Vector3.new(1.2, 2, 1.2), pos + Vector3.new(2, h*0.6 + 1, 0), C.green)
	local arm1h = p(Vector3.new(1.2, 1.5, 1.2), pos + Vector3.new(3.5, h*0.6, 0), C.green)
	local arm2 = p(Vector3.new(1.2, 1.5, 1.2), pos + Vector3.new(-2, h*0.7, 0), C.green)
	local arm2h = p(Vector3.new(1.2, 1.2, 1.2), pos + Vector3.new(-3, h*0.65, 0), C.green)
end

local function rock(pos, scale)
	scale = scale or 1
	p(Vector3.new(4*scale, 3*scale, 3.5*scale), pos + Vector3.new(0, 1.5*scale, 0), C.rock)
	p(Vector3.new(2.5*scale, 4*scale, 2*scale), pos + Vector3.new(0.5*scale, 2*scale, 0.5*scale), C.rockDark)
	p(Vector3.new(3*scale, 1.5*scale, 2.5*scale), pos + Vector3.new(-0.5*scale, 3.5*scale, 0), C.rock)
end

-- =====================
-- SOL PRINCIPAL (arène désert)
-- =====================
-- Base sablonneuse (top surface = y=4)
p(Vector3.new(90, 8, 90), Vector3.new(0, 0, 0), C.sand)
-- Texture variations (dalles)
for x = -3, 3 do
	for z = -3, 3 do
		if math.random() > 0.6 then
			p(Vector3.new(12, 0.3, 12),
				Vector3.new(x*12 + math.random(-2,2), 0.15, z*12 + math.random(-2,2)),
				C.sandDark)
		end
	end
end

-- Bords / falaises (style low-poly)
for i = 0, 7 do
	local angle = i * math.pi/4
	local r = 52
	p(Vector3.new(16, 8, 6),
		Vector3.new(math.cos(angle)*r, -2, math.sin(angle)*r),
		C.rockDark)
	p(Vector3.new(8, 12, 4),
		Vector3.new(math.cos(angle+0.2)*r+2, 2, math.sin(angle+0.2)*r+2),
		C.rock)
end

-- =====================
-- PLATEFORMES SECONDAIRES
-- =====================
local platData = {
	-- {taille, position, couleur}
	{Vector3.new(24, 4, 24), Vector3.new(50, 14, 0),   C.platform},
	{Vector3.new(24, 4, 24), Vector3.new(-50, 14, 0),  C.platform},
	{Vector3.new(24, 4, 24), Vector3.new(0, 14, 50),   C.platform},
	{Vector3.new(24, 4, 24), Vector3.new(0, 14, -50),  C.platform},
}
for _, d in platData do
	local pl = p(d[1], d[2], d[3])
	-- Surface sablonneuse sur le dessus
	p(Vector3.new(d[1].X-2, 0.5, d[1].Z-2), d[2] + Vector3.new(0, d[1].Y/2+0.25, 0), C.sand)
	-- Bord accent
	p(Vector3.new(d[1].X, 0.8, d[1].Z), d[2] + Vector3.new(0, d[1].Y/2+0.4, 0), C.accent, Enum.Material.Neon, 0.5)
end

-- Plateformes hautes (coins)
local highPlats = {
	{Vector3.new(16, 3, 16), Vector3.new(55, 28, 55)},
	{Vector3.new(16, 3, 16), Vector3.new(-55, 28, 55)},
	{Vector3.new(16, 3, 16), Vector3.new(55, 28, -55)},
	{Vector3.new(16, 3, 16), Vector3.new(-55, 28, -55)},
}
for _, d in highPlats do
	p(d[1], d[2], C.rock)
	p(Vector3.new(d[1].X-1, 0.4, d[1].Z-1), d[2] + Vector3.new(0, d[1].Y/2+0.2, 0), C.sand)
	p(Vector3.new(d[1].X+0.5, 0.6, d[1].Z+0.5), d[2] + Vector3.new(0, d[1].Y/2+0.3, 0), C.glow, Enum.Material.Neon, 0.6)
end

-- =====================
-- OBSTACLES CENTRAUX
-- =====================
-- Tour centrale
p(Vector3.new(8, 18, 8), Vector3.new(0, 9, 0), C.rockDark)
p(Vector3.new(10, 1, 10), Vector3.new(0, 18.5, 0), C.accent)
p(Vector3.new(10, 3, 10), Vector3.new(0, 20, 0), C.platform)
p(Vector3.new(10.5, 0.5, 10.5), Vector3.new(0, 21.75, 0), C.accent, Enum.Material.Neon, 0.4)

-- Rochers décoratifs
rock(Vector3.new(18, 0, 18), 1.2)
rock(Vector3.new(-18, 0, 18), 1)
rock(Vector3.new(18, 0, -18), 0.8)
rock(Vector3.new(-18, 0, -18), 1.1)

-- Dunes triangulaires
for _, d in {
	{Vector3.new(20, 6, 8), Vector3.new(32, 0, 0),  0},
	{Vector3.new(20, 6, 8), Vector3.new(-32, 0, 0), 180},
	{Vector3.new(8, 6, 20), Vector3.new(0, 0, 32),  90},
	{Vector3.new(8, 6, 20), Vector3.new(0, 0, -32), 270},
} do
	wedge(d[1], d[2], C.sandDark, d[3])
end

-- Piliers intermédiaires
for _, pos in {
	Vector3.new(28, 0, 0), Vector3.new(-28, 0, 0),
	Vector3.new(0, 0, 28), Vector3.new(0, 0, -28),
} do
	p(Vector3.new(5, 14, 5), pos + Vector3.new(0, 7, 0), C.rock)
	p(Vector3.new(7, 1.5, 7), pos + Vector3.new(0, 14.75, 0), C.platform)
	p(Vector3.new(7.5, 0.5, 7.5), pos + Vector3.new(0, 15.75, 0), C.accent, Enum.Material.Neon, 0.5)
end

-- =====================
-- CACTUS DÉCORATIFS
-- =====================
for _, pos in {
	Vector3.new(38, 0, 12), Vector3.new(-38, 0, -12),
	Vector3.new(12, 0, -38), Vector3.new(-12, 0, 38),
	Vector3.new(50, 16, 14), Vector3.new(-50, 16, -14),
	Vector3.new(14, 16, 50), Vector3.new(-14, 16, -50),
} do
	cactus(pos)
end

-- =====================
-- ÉCLAIRAGE AMBIANCE
-- =====================
local lighting = game:GetService("Lighting")
lighting.Ambient = Color3.fromRGB(80, 60, 40)
lighting.OutdoorAmbient = Color3.fromRGB(180, 140, 80)
lighting.Brightness = 3
lighting.TimeOfDay = "14:00:00"
lighting.FogColor = Color3.fromRGB(255, 200, 120)
lighting.FogEnd = 500

local atmosphere = Instance.new("Atmosphere")
atmosphere.Density = 0.3
atmosphere.Offset = 0.1
atmosphere.Color = Color3.fromRGB(255, 180, 100)
atmosphere.Decay = Color3.fromRGB(200, 120, 50)
atmosphere.Glare = 0.5
atmosphere.Haze = 1.8
atmosphere.Parent = lighting

local sun = Instance.new("ColorCorrectionEffect")
sun.Brightness = 0.05
sun.Contrast = 0.1
sun.Saturation = 0.2
sun.TintColor = Color3.fromRGB(255, 230, 180)
sun.Parent = lighting

-- =====================
-- SPAWNS
-- =====================
-- Spawn lobby central (enabled = joueurs spawent ici par défaut)
spawnPt(Vector3.new(0, 6, 0), true)

-- Spawns de round (disabled, activés par le server)
for _, pos in {
	Vector3.new(22, 6, 0),  Vector3.new(-22, 6, 0),
	Vector3.new(0, 6, 22),  Vector3.new(0, 6, -22),
	Vector3.new(50, 20, 0), Vector3.new(-50, 20, 0),
	Vector3.new(0, 20, 50), Vector3.new(0, 20, -50),
	Vector3.new(55, 34, 55), Vector3.new(-55, 34, 55),
	Vector3.new(55, 34, -55), Vector3.new(-55, 34, -55),
} do
	spawnPt(pos, false)
end

-- =====================
-- PLATEFORMES MOBILES
-- =====================
local moving = {}

local mobileData = {
	{Vector3.new(16, 2.5, 16), Vector3.new(0, 36, 70),  Vector3.new(0,0,30), 0.5},
	{Vector3.new(16, 2.5, 16), Vector3.new(70, 36, 0),  Vector3.new(30,0,0), 0.4},
	{Vector3.new(16, 2.5, 16), Vector3.new(-70, 36, 0), Vector3.new(30,0,0), 0.6},
	{Vector3.new(12, 2, 12),   Vector3.new(0, 22, 0),   Vector3.new(0,8,0),  0.8},
}

for _, d in mobileData do
	local mp = p(d[1], d[2], C.glow, Enum.Material.Neon, 0.1)
	p(Vector3.new(d[1].X-1, 0.5, d[1].Z-1), d[2] + Vector3.new(0, d[1].Y/2+0.25, 0), C.accent)
	table.insert(moving, {part=mp, origin=d[2], range=d[3], speed=d[4], offset=math.random()*math.pi*2})
end

RunService.Heartbeat:Connect(function()
	local t = tick()
	for _, m in moving do
		local s = math.sin(t * m.speed + m.offset)
		m.part.CFrame = CFrame.new(m.origin + m.range * s)
	end
end)

print("[Megablox] Desert map loaded")
