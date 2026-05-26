// =====================
//  WORLD - Génération du monde en blocs
// =====================

const BLOCK_TYPES = {
  AIR:   0,
  GRASS: 1,
  DIRT:  2,
  STONE: 3,
  WOOD:  4,
  LEAVES:5,
  SAND:  6,
  WATER: 7,
  BRICK: 8,
  SNOW:  9,
};

const BLOCK_COLORS = {
  [BLOCK_TYPES.GRASS]:  { top: 0x5aad3a, side: 0x7a5230, bottom: 0x7a5230 },
  [BLOCK_TYPES.DIRT]:   { top: 0x7a5230, side: 0x7a5230, bottom: 0x7a5230 },
  [BLOCK_TYPES.STONE]:  { top: 0x888888, side: 0x888888, bottom: 0x888888 },
  [BLOCK_TYPES.WOOD]:   { top: 0xc8a060, side: 0x8b5e20, bottom: 0xc8a060 },
  [BLOCK_TYPES.LEAVES]: { top: 0x2d8a1e, side: 0x2d8a1e, bottom: 0x2d8a1e },
  [BLOCK_TYPES.SAND]:   { top: 0xe8d87a, side: 0xe8d87a, bottom: 0xe8d87a },
  [BLOCK_TYPES.WATER]:  { top: 0x3a7bd5, side: 0x3a7bd5, bottom: 0x3a7bd5 },
  [BLOCK_TYPES.BRICK]:  { top: 0xc1440e, side: 0xc1440e, bottom: 0xc1440e },
  [BLOCK_TYPES.SNOW]:   { top: 0xf0f0f0, side: 0xddeeff, bottom: 0xddeeff },
};

const BLOCK_NAMES = {
  [BLOCK_TYPES.GRASS]:  'Herbe',
  [BLOCK_TYPES.DIRT]:   'Terre',
  [BLOCK_TYPES.STONE]:  'Pierre',
  [BLOCK_TYPES.WOOD]:   'Bois',
  [BLOCK_TYPES.LEAVES]: 'Feuilles',
  [BLOCK_TYPES.SAND]:   'Sable',
  [BLOCK_TYPES.WATER]:  'Eau',
  [BLOCK_TYPES.BRICK]:  'Brique',
  [BLOCK_TYPES.SNOW]:   'Neige',
};

const WORLD_SIZE   = 48;
const WORLD_HEIGHT = 24;
const CHUNK_SIZE   = 8;

class World {
  constructor(scene) {
    this.scene  = scene;
    this.blocks = new Map(); // "x,y,z" -> blockType
    this.meshes = new Map(); // "x,y,z" -> THREE.Mesh
    this.generate();
  }

  // Bruit de Perlin simplifié
  noise2D(x, z) {
    const X = Math.floor(x) & 255;
    const Z = Math.floor(z) & 255;
    const v = Math.sin(X * 127.1 + Z * 311.7) * 43758.5453;
    return v - Math.floor(v);
  }

  smoothNoise(x, z, scale = 1) {
    x *= scale; z *= scale;
    const x0 = Math.floor(x), z0 = Math.floor(z);
    const fx = x - x0, fz = z - z0;
    const u  = fx * fx * (3 - 2 * fx);
    const v  = fz * fz * (3 - 2 * fz);
    return (
      this.noise2D(x0,   z0)   * (1-u) * (1-v) +
      this.noise2D(x0+1, z0)   * u     * (1-v) +
      this.noise2D(x0,   z0+1) * (1-u) * v     +
      this.noise2D(x0+1, z0+1) * u     * v
    );
  }

  heightAt(x, z) {
    const h1 = this.smoothNoise(x, z, 0.05) * 8;
    const h2 = this.smoothNoise(x, z, 0.12) * 4;
    const h3 = this.smoothNoise(x, z, 0.25) * 2;
    return Math.floor(4 + h1 + h2 + h3);
  }

  generate() {
    const half = Math.floor(WORLD_SIZE / 2);
    for (let x = -half; x < half; x++) {
      for (let z = -half; z < half; z++) {
        const h = this.heightAt(x, z);
        for (let y = 0; y <= h; y++) {
          let type;
          if (y === h)            type = BLOCK_TYPES.GRASS;
          else if (y >= h - 3)    type = BLOCK_TYPES.DIRT;
          else                    type = BLOCK_TYPES.STONE;
          this.blocks.set(`${x},${y},${z}`, type);
        }
        // Arbres aléatoires
        if (Math.random() < 0.03 && h > 5) {
          this.placeTree(x, h + 1, z);
        }
      }
    }
    this.buildAllMeshes();
  }

  placeTree(x, y, z) {
    const trunkH = 3 + Math.floor(Math.random() * 2);
    for (let i = 0; i < trunkH; i++) {
      this.blocks.set(`${x},${y+i},${z}`, BLOCK_TYPES.WOOD);
    }
    for (let dx = -2; dx <= 2; dx++) {
      for (let dz = -2; dz <= 2; dz++) {
        for (let dy = trunkH - 1; dy <= trunkH + 1; dy++) {
          if (Math.abs(dx) + Math.abs(dz) + Math.abs(dy - trunkH) < 4)
            this.blocks.set(`${x+dx},${y+dy},${z+dz}`, BLOCK_TYPES.LEAVES);
        }
      }
    }
  }

  getBlock(x, y, z) {
    return this.blocks.get(`${x},${y},${z}`) || BLOCK_TYPES.AIR;
  }

  setBlock(x, y, z, type) {
    const key = `${x},${y},${z}`;
    if (type === BLOCK_TYPES.AIR) {
      this.blocks.delete(key);
      if (this.meshes.has(key)) {
        this.scene.remove(this.meshes.get(key));
        this.meshes.get(key).geometry.dispose();
        this.meshes.delete(key);
      }
    } else {
      this.blocks.set(key, type);
      this.buildMesh(x, y, z, type);
    }
    // Rebuild neighbours (pour les faces cachées)
    for (const [dx,dy,dz] of [[1,0,0],[-1,0,0],[0,1,0],[0,-1,0],[0,0,1],[0,0,-1]]) {
      const nb = this.getBlock(x+dx, y+dy, z+dz);
      if (nb !== BLOCK_TYPES.AIR) this.buildMesh(x+dx, y+dy, z+dz, nb);
    }
  }

  isOpaque(x, y, z) {
    const t = this.getBlock(x, y, z);
    return t !== BLOCK_TYPES.AIR && t !== BLOCK_TYPES.WATER;
  }

  buildMesh(x, y, z, type) {
    const key = `${x},${y},${z}`;
    if (this.meshes.has(key)) {
      this.scene.remove(this.meshes.get(key));
      this.meshes.get(key).geometry.dispose();
      this.meshes.delete(key);
    }
    // Faces visibles uniquement
    const faces = [
      { dir: [0,1,0],  name: 'top' },
      { dir: [0,-1,0], name: 'bottom' },
      { dir: [1,0,0],  name: 'side' },
      { dir: [-1,0,0], name: 'side' },
      { dir: [0,0,1],  name: 'side' },
      { dir: [0,0,-1], name: 'side' },
    ].filter(f => !this.isOpaque(x+f.dir[0], y+f.dir[1], z+f.dir[2]));

    if (faces.length === 0) return;

    const colors = BLOCK_COLORS[type] || BLOCK_COLORS[BLOCK_TYPES.STONE];
    const geo    = new THREE.BoxGeometry(1, 1, 1);
    const mats   = [
      new THREE.MeshLambertMaterial({ color: colors.side }),   // +X
      new THREE.MeshLambertMaterial({ color: colors.side }),   // -X
      new THREE.MeshLambertMaterial({ color: colors.top }),    // +Y
      new THREE.MeshLambertMaterial({ color: colors.bottom }), // -Y
      new THREE.MeshLambertMaterial({ color: colors.side }),   // +Z
      new THREE.MeshLambertMaterial({ color: colors.side }),   // -Z
    ];
    if (type === BLOCK_TYPES.WATER) mats.forEach(m => { m.transparent = true; m.opacity = 0.7; });
    if (type === BLOCK_TYPES.LEAVES) mats.forEach(m => { m.transparent = true; m.opacity = 0.85; });

    const mesh = new THREE.Mesh(geo, mats);
    mesh.position.set(x + 0.5, y + 0.5, z + 0.5);
    mesh.castShadow    = true;
    mesh.receiveShadow = true;
    mesh.userData = { blockPos: { x, y, z }, blockType: type };
    this.scene.add(mesh);
    this.meshes.set(key, mesh);
  }

  buildAllMeshes() {
    for (const [key, type] of this.blocks) {
      const [x, y, z] = key.split(',').map(Number);
      this.buildMesh(x, y, z, type);
    }
  }

  getAllMeshes() {
    return [...this.meshes.values()];
  }
}
