import xml.etree.ElementTree as ET
import uuid, math, random

random.seed(42)

def uid(): return "RBX" + uuid.uuid4().hex[:32].upper()

root = ET.Element("roblox", {
    "xmlns:xmime": "http://www.w3.org/2005/05/xmlmime",
    "xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance",
    "xsi:noNamespaceSchemaLocation": "http://www.roblox.com/roblox.xsd",
    "version": "4"
})

# Single top-level Model wrapping everything
model = ET.SubElement(root, "Item", {"class":"Model","referent":uid()})
model_props = ET.SubElement(model,"Properties")
ET.SubElement(model_props,"string",{"name":"Name"}).text = "Arena"
container = model  # all parts go here

parts = []

FLOOR = 4

def col(r,g,b): return f"{r/255:.3f} {g/255:.3f} {b/255:.3f}"

COLORS = {
    "sand":     col(255,200,80),
    "sandDark": col(180,130,60),
    "rock":     col(200,175,120),
    "rockDark": col(160,100,40),
    "accent":   col(255,140,0),
    "glow":     col(220,50,50),
    "platform": col(210,185,100),
    "green":    col(40,160,40),
    "white":    col(240,240,240),
    "pink":     col(220,80,180),
}

def make_part(name, x, y, z, sx, sy, sz, color="sand", mat="SmoothPlastic", tr=0, anchor=True):
    item = ET.SubElement(container, "Item", {"class":"Part","referent":uid()})
    props = ET.SubElement(item,"Properties")
    ET.SubElement(props,"string",{"name":"Name"}).text = name
    ET.SubElement(props,"bool",{"name":"Anchored"}).text = str(anchor).lower()
    ET.SubElement(props,"bool",{"name":"CastShadow"}).text = "true"
    ET.SubElement(props,"float",{"name":"Transparency"}).text = str(tr)
    s = ET.SubElement(props,"CoordinateFrame",{"name":"CFrame"})
    ET.SubElement(s,"X").text=str(x); ET.SubElement(s,"Y").text=str(y); ET.SubElement(s,"Z").text=str(z)
    for k,v in [("R00","1"),("R01","0"),("R02","0"),("R10","0"),("R11","1"),("R12","0"),("R20","0"),("R21","0"),("R22","1")]:
        ET.SubElement(s,k).text=v
    sz_el = ET.SubElement(props,"Vector3",{"name":"size"})
    ET.SubElement(sz_el,"X").text=str(sx); ET.SubElement(sz_el,"Y").text=str(sy); ET.SubElement(sz_el,"Z").text=str(sz)
    c3 = ET.SubElement(props,"Color3",{"name":"Color"})
    ET.SubElement(c3,"R").text=COLORS[color].split()[0]
    ET.SubElement(c3,"G").text=COLORS[color].split()[1]
    ET.SubElement(c3,"B").text=COLORS[color].split()[2]
    ET.SubElement(props,"token",{"name":"Material"}).text = {
        "SmoothPlastic":"256","Neon":"288","SandStone":"1104"
    }.get(mat,"256")
    parts.append(item)
    return item

def spawn(x,y,z,enabled=False):
    item = ET.SubElement(container,"Item",{"class":"SpawnLocation","referent":uid()})
    props = ET.SubElement(item,"Properties")
    ET.SubElement(props,"string",{"name":"Name"}).text="Spawn"
    ET.SubElement(props,"bool",{"name":"Anchored"}).text="true"
    ET.SubElement(props,"bool",{"name":"Enabled"}).text=str(enabled).lower()
    ET.SubElement(props,"float",{"name":"Transparency"}).text="0.5"
    s=ET.SubElement(props,"CoordinateFrame",{"name":"CFrame"})
    ET.SubElement(s,"X").text=str(x);ET.SubElement(s,"Y").text=str(y);ET.SubElement(s,"Z").text=str(z)
    for k,v in [("R00","1"),("R01","0"),("R02","0"),("R10","0"),("R11","1"),("R12","0"),("R20","0"),("R21","0"),("R22","1")]:
        ET.SubElement(s,k).text=v
    sz=ET.SubElement(props,"Vector3",{"name":"size"})
    ET.SubElement(sz,"X").text="4";ET.SubElement(sz,"Y").text="0.5";ET.SubElement(sz,"Z").text="4"
    c3=ET.SubElement(props,"Color3",{"name":"Color"})
    ET.SubElement(c3,"R").text="1.0";ET.SubElement(c3,"G").text="0.55";ET.SubElement(c3,"B").text="0.0"

# ---- SOL ----
make_part("Floor", 0, 0, 0, 90, 8, 90, "sand")
for i in range(30):
    x = random.randint(-4,4)*12 + random.randint(-2,2)
    z = random.randint(-4,4)*12 + random.randint(-2,2)
    make_part("Tile", x, FLOOR+0.2, z, 10, 0.4, 10, "sandDark")

# ---- BORDS ----
for i in range(8):
    a = i * math.pi/4
    r = 52
    make_part("Cliff", math.cos(a)*r, FLOOR+1, math.sin(a)*r, 16, 10, 6, "rockDark")
    make_part("CliffB", math.cos(a+0.2)*r+2, FLOOR+5, math.sin(a+0.2)*r+2, 8, 14, 4, "rock")

# ---- PLATEFORMES LATERALES ----
for x,z in [(50,0),(-50,0),(0,50),(0,-50)]:
    make_part("Platform", x, FLOOR+14, z, 24, 4, 24, "platform")
    make_part("PlatSurf", x, FLOOR+16.25, z, 22, 0.5, 22, "sand")
    make_part("PlatEdge", x, FLOOR+16.5, z, 24.5, 0.6, 24.5, "accent", "Neon", 0.5)

# ---- PLATEFORMES HAUTES COINS ----
for x,z in [(55,55),(-55,55),(55,-55),(-55,-55)]:
    make_part("HighPlat", x, FLOOR+28, z, 16, 3, 16, "rock")
    make_part("HighSurf", x, FLOOR+29.7, z, 15, 0.4, 15, "sand")
    make_part("HighEdge", x, FLOOR+30.0, z, 16.5, 0.5, 16.5, "glow", "Neon", 0.6)

# ---- TOUR CENTRALE ----
make_part("TowerBase",  0, FLOOR+11, 0, 8, 22, 8, "rockDark")
make_part("TowerRing",  0, FLOOR+22.5, 0, 10, 1, 10, "accent")
make_part("TowerTop",   0, FLOOR+24, 0, 10, 3, 10, "platform")
make_part("TowerGlow",  0, FLOOR+25.75, 0, 11, 0.5, 11, "accent", "Neon", 0.4)

# ---- PILIERS ----
for x,z in [(28,0),(-28,0),(0,28),(0,-28)]:
    make_part("Pillar",     x, FLOOR+7, z, 5, 14, 5, "rock")
    make_part("PillarTop",  x, FLOOR+14.75, z, 7, 1.5, 7, "platform")
    make_part("PillarGlow", x, FLOOR+15.75, z, 7.5, 0.5, 7.5, "accent", "Neon", 0.5)

# ---- DUNES ----
for x,z,sx,sz in [(32,0,22,9),(-32,0,22,9),(0,32,9,22),(0,-32,9,22)]:
    make_part("Dune", x, FLOOR+3.5, z, sx, 7, sz, "sandDark")

# ---- ROCHERS ----
for x,z,s in [(18,18,1.2),(-18,18,1.0),(18,-18,0.9),(-18,-18,1.1)]:
    make_part("Rock1", x, FLOOR+1.5*s, z, 4*s, 3*s, 3.5*s, "rock")
    make_part("Rock2", x+0.5*s, FLOOR+2*s, z+0.5*s, 2.5*s, 4*s, 2*s, "rockDark")
    make_part("Rock3", x-0.3*s, FLOOR+3.5*s, z, 3*s, 1.5*s, 2.5*s, "rock")

# ---- CACTUS ----
for cx,cz in [(38,12),(-38,-12),(12,-38),(-12,38),(-38,12),(38,-12),(-12,-38),(12,38)]:
    h = 4 + random.random()*2
    y = FLOOR
    make_part("CacTrunk", cx, y+h/2, cz, 1.2, h, 1.2, "green")
    make_part("CacArm1",  cx+2.5, y+h*0.6, cz, 1.2, 2.5, 1.2, "green")
    make_part("CacArm1H", cx+3.5, y+h*0.6+1, cz, 1.2, 1.5, 1.2, "green")
    make_part("CacArm2",  cx-2, y+h*0.7, cz, 1.2, 2, 1.2, "green")
    make_part("CacArm2H", cx-3, y+h*0.65+0.5, cz, 1.2, 1.2, 1.2, "green")

# ---- PLATEFORMES MOBILES (statiques au centre) ----
make_part("MovPlat1", 0,  FLOOR+40, 70, 16, 2.5, 16, "glow", "Neon", 0.1)
make_part("MovPlat2", 70, FLOOR+40, 0,  16, 2.5, 16, "glow", "Neon", 0.1)
make_part("MovPlat3",-70, FLOOR+40, 0,  16, 2.5, 16, "glow", "Neon", 0.1)
make_part("MovPlat4", 0,  FLOOR+22, 0,  12, 2,   12, "glow", "Neon", 0.1)

# ---- SPAWNS ----
spawn(0, FLOOR+2, 0, True)
for x,z in [(22,0),(-22,0),(0,22),(0,-22),(50,0),(-50,0),(0,50),(0,-50),(55,55),(-55,55),(55,-55),(-55,-55)]:
    spawn(x, FLOOR+18 if abs(x)>30 or abs(z)>30 else FLOOR+2, z, False)

tree = ET.ElementTree(root)
ET.indent(tree, space="  ")
tree.write("src/world/Arena.rbxmx", encoding="unicode", xml_declaration=True)
print(f"Arena.rbxmx generated with {len(parts)} parts")
