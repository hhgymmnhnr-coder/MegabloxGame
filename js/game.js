// =====================
//  GAME - Boucle principale
// =====================

let scene, camera, renderer, world, player;
let clock, frameId;

function init() {
  // Scene
  scene = new THREE.Scene();
  scene.background = new THREE.Color(0x87ceeb);
  scene.fog = new THREE.Fog(0x87ceeb, 30, 80);

  // Camera
  camera = new THREE.PerspectiveCamera(70, window.innerWidth / window.innerHeight, 0.1, 300);

  // Renderer
  renderer = new THREE.WebGLRenderer({ canvas: document.getElementById('game-canvas'), antialias: true });
  renderer.setSize(window.innerWidth, window.innerHeight);
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
  renderer.shadowMap.enabled = true;
  renderer.shadowMap.type = THREE.PCFSoftShadowMap;

  // Lumières
  const ambient = new THREE.AmbientLight(0xffffff, 0.5);
  scene.add(ambient);

  const sun = new THREE.DirectionalLight(0xfffbe0, 1.2);
  sun.position.set(30, 60, 20);
  sun.castShadow = true;
  sun.shadow.mapSize.width  = 2048;
  sun.shadow.mapSize.height = 2048;
  sun.shadow.camera.near = 0.1;
  sun.shadow.camera.far  = 200;
  sun.shadow.camera.left   = -50;
  sun.shadow.camera.right  =  50;
  sun.shadow.camera.top    =  50;
  sun.shadow.camera.bottom = -50;
  scene.add(sun);

  // Ciel / nuages décoratifs
  const skyGeo  = new THREE.SphereGeometry(200, 16, 8);
  const skyMat  = new THREE.MeshBasicMaterial({ color: 0x87ceeb, side: THREE.BackSide });
  scene.add(new THREE.Mesh(skyGeo, skyMat));

  addClouds();

  // Monde
  world = new World(scene);

  // Joueur
  player = new Player(camera, world, renderer.domElement);
  scene.add(player.avatarGroup);

  // Place le joueur au bon endroit
  const spawnH = world.heightAt(0, 0);
  player.pos.set(0, spawnH + 2, 0);

  // Hotbar UI
  buildHotbarUI();

  // Clock
  clock = new THREE.Clock();

  // Resize
  window.addEventListener('resize', onResize);

  // Bouton Play
  document.getElementById('play-btn').addEventListener('click', () => {
    document.getElementById('overlay').style.display = 'none';
    player.lockPointer();
    animate();
  });
}

function addClouds() {
  const cloudMat = new THREE.MeshBasicMaterial({ color: 0xffffff, transparent: true, opacity: 0.85 });
  for (let i = 0; i < 20; i++) {
    const g = new THREE.Group();
    for (let j = 0; j < 4 + Math.floor(Math.random()*4); j++) {
      const geo = new THREE.BoxGeometry(
        3 + Math.random()*5, 1.5 + Math.random(), 3 + Math.random()*3
      );
      const m = new THREE.Mesh(geo, cloudMat);
      m.position.set((Math.random()-0.5)*8, (Math.random()-0.5)*1.5, (Math.random()-0.5)*6);
      g.add(m);
    }
    g.position.set(
      (Math.random()-0.5) * 150,
      35 + Math.random() * 20,
      (Math.random()-0.5) * 150
    );
    scene.add(g);
  }
}

function animate() {
  frameId = requestAnimationFrame(animate);
  const dt = Math.min(clock.getDelta(), 0.05);

  player.update(dt, world.getAllMeshes());

  // Stats HUD
  document.getElementById('hud-pos').textContent =
    `X:${player.pos.x.toFixed(1)}  Y:${player.pos.y.toFixed(1)}  Z:${player.pos.z.toFixed(1)}`;
  document.getElementById('hud-block').textContent =
    `Bloc: ${BLOCK_NAMES[player.selectedBlock] || '?'}`;
  document.getElementById('hud-view').textContent =
    player.thirdPerson ? '3ème personne (V)' : '1ère personne (V)';

  renderer.render(scene, camera);
}

function onResize() {
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();
  renderer.setSize(window.innerWidth, window.innerHeight);
}

// =====================
//  UI
// =====================

function buildHotbarUI() {
  const hotbar = document.getElementById('hotbar');
  hotbar.innerHTML = '';
  player.hotbarBlocks.forEach((type, i) => {
    const slot = document.createElement('div');
    slot.className = 'hotbar-slot' + (i === player.hotbarIndex ? ' active' : '');
    slot.dataset.index = i;

    const icon = document.createElement('div');
    icon.className = 'block-icon';
    const c = BLOCK_COLORS[type];
    icon.style.background = `#${c.top.toString(16).padStart(6,'0')}`;

    const lbl = document.createElement('div');
    lbl.className = 'block-label';
    lbl.textContent = BLOCK_NAMES[type] || '?';

    slot.appendChild(icon);
    slot.appendChild(lbl);
    slot.addEventListener('click', () => player.selectSlot(i));
    hotbar.appendChild(slot);
  });
}

function updateHotbarUI(activeIndex) {
  document.querySelectorAll('.hotbar-slot').forEach((s, i) => {
    s.classList.toggle('active', i === activeIndex);
  });
  document.getElementById('hud-block').textContent =
    `Bloc: ${BLOCK_NAMES[player.hotbarBlocks[activeIndex]] || '?'}`;
}

// Démarrage
window.addEventListener('DOMContentLoaded', init);
