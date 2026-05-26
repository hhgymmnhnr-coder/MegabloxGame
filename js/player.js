// =====================
//  PLAYER - Contrôles & physique
// =====================

class Player {
  constructor(camera, world, domElement) {
    this.camera     = camera;
    this.world      = world;
    this.domElement = domElement;

    // Position & mouvement
    this.pos    = new THREE.Vector3(0, 20, 0);
    this.vel    = new THREE.Vector3();
    this.onGround = false;
    this.speed    = 6;
    this.jumpForce = 9;
    this.gravity  = -22;
    this.height   = 1.8;

    // Caméra
    this.yaw   = 0;   // rotation horizontale
    this.pitch = 0;   // rotation verticale
    this.camOffset = new THREE.Vector3(0, 0.8, 0);

    // Mode 3rd person
    this.thirdPerson = true;
    this.camDistance = 6;

    // Input
    this.keys  = {};
    this.mouse = { dx: 0, dy: 0, left: false, right: false };
    this.pointerLocked = false;

    // Bloc sélectionné
    this.selectedBlock  = BLOCK_TYPES.GRASS;
    this.hotbarIndex    = 0;
    this.hotbarBlocks   = [
      BLOCK_TYPES.GRASS, BLOCK_TYPES.DIRT, BLOCK_TYPES.STONE,
      BLOCK_TYPES.WOOD,  BLOCK_TYPES.BRICK, BLOCK_TYPES.SAND,
      BLOCK_TYPES.SNOW,
    ];

    // Raycaster
    this.raycaster = new THREE.Raycaster();
    this.raycaster.far = 8;

    // Visuel joueur
    this.buildAvatar();

    this.bindEvents();
  }

  buildAvatar() {
    // Corps style Roblox
    const mat = new THREE.MeshLambertMaterial({ color: 0x2255cc });
    const body = new THREE.Mesh(new THREE.BoxGeometry(0.7, 0.9, 0.4), mat);
    body.position.y = 0.45;

    const headMat = new THREE.MeshLambertMaterial({ color: 0xffcc88 });
    const head = new THREE.Mesh(new THREE.BoxGeometry(0.6, 0.6, 0.6), headMat);
    head.position.y = 1.2;

    const legMat = new THREE.MeshLambertMaterial({ color: 0x1a3a88 });
    const legL = new THREE.Mesh(new THREE.BoxGeometry(0.3, 0.8, 0.35), legMat);
    legL.position.set(-0.18, -0.4, 0);
    const legR = new THREE.Mesh(new THREE.BoxGeometry(0.3, 0.8, 0.35), legMat);
    legR.position.set(0.18, -0.4, 0);

    const armMat = new THREE.MeshLambertMaterial({ color: 0x1a66dd });
    const armL = new THREE.Mesh(new THREE.BoxGeometry(0.25, 0.8, 0.35), armMat);
    armL.position.set(-0.5, 0.5, 0);
    const armR = new THREE.Mesh(new THREE.BoxGeometry(0.25, 0.8, 0.35), armMat);
    armR.position.set(0.5, 0.5, 0);

    this.avatarGroup = new THREE.Group();
    this.avatarGroup.add(body, head, legL, legR, armL, armR);

    this.legL = legL; this.legR = legR;
    this.armL = armL; this.armR = armR;
    this.walkAnim = 0;
  }

  bindEvents() {
    document.addEventListener('keydown', e => { this.keys[e.code] = true; this.onKeyDown(e); });
    document.addEventListener('keyup',   e => { this.keys[e.code] = false; });
    document.addEventListener('mousemove', e => {
      if (this.pointerLocked) {
        this.mouse.dx += e.movementX;
        this.mouse.dy += e.movementY;
      }
    });
    document.addEventListener('mousedown', e => {
      if (!this.pointerLocked) return;
      if (e.button === 0) this.mouse.left  = true;
      if (e.button === 2) this.mouse.right = true;
    });
    document.addEventListener('mouseup', e => {
      if (e.button === 0) this.mouse.left  = false;
      if (e.button === 2) this.mouse.right = false;
    });
    document.addEventListener('wheel', e => {
      if (!this.pointerLocked) return;
      const dir = e.deltaY > 0 ? 1 : -1;
      this.hotbarIndex = ((this.hotbarIndex + dir) + this.hotbarBlocks.length) % this.hotbarBlocks.length;
      this.selectedBlock = this.hotbarBlocks[this.hotbarIndex];
      updateHotbarUI(this.hotbarIndex);
    });
    document.addEventListener('contextmenu', e => e.preventDefault());
    document.addEventListener('pointerlockchange', () => {
      this.pointerLocked = document.pointerLockElement === this.domElement;
    });
  }

  onKeyDown(e) {
    if (e.code === 'KeyV') {
      this.thirdPerson = !this.thirdPerson;
    }
    if (e.code === 'Digit1') this.selectSlot(0);
    if (e.code === 'Digit2') this.selectSlot(1);
    if (e.code === 'Digit3') this.selectSlot(2);
    if (e.code === 'Digit4') this.selectSlot(3);
    if (e.code === 'Digit5') this.selectSlot(4);
    if (e.code === 'Digit6') this.selectSlot(5);
    if (e.code === 'Digit7') this.selectSlot(6);
  }

  selectSlot(i) {
    this.hotbarIndex   = i;
    this.selectedBlock = this.hotbarBlocks[i];
    updateHotbarUI(i);
  }

  lockPointer() {
    this.domElement.requestPointerLock();
  }

  // Collision AABB simple
  collide(dx, dy, dz) {
    const W = 0.35, H = this.height;
    const px = this.pos.x + dx;
    const py = this.pos.y + dy;
    const pz = this.pos.z + dz;

    const x0 = Math.floor(px - W), x1 = Math.floor(px + W);
    const y0 = Math.floor(py),     y1 = Math.floor(py + H);
    const z0 = Math.floor(pz - W), z1 = Math.floor(pz + W);

    for (let x = x0; x <= x1; x++)
      for (let y = y0; y <= y1; y++)
        for (let z = z0; z <= z1; z++) {
          const t = this.world.getBlock(x, y, z);
          if (t !== BLOCK_TYPES.AIR && t !== BLOCK_TYPES.WATER && t !== BLOCK_TYPES.LEAVES)
            return true;
        }
    return false;
  }

  update(dt, worldMeshes) {
    // --- Rotation caméra ---
    const sens = 0.002;
    this.yaw   -= this.mouse.dx * sens;
    this.pitch -= this.mouse.dy * sens;
    this.pitch  = Math.max(-Math.PI/2 + 0.05, Math.min(Math.PI/2 - 0.05, this.pitch));
    this.mouse.dx = 0;
    this.mouse.dy = 0;

    // Direction de mouvement
    const forward = new THREE.Vector3(-Math.sin(this.yaw), 0, -Math.cos(this.yaw));
    const right   = new THREE.Vector3( Math.cos(this.yaw), 0, -Math.sin(this.yaw));

    let moveX = 0, moveZ = 0;
    if (this.keys['KeyW'] || this.keys['ArrowUp'])    { moveX += forward.x; moveZ += forward.z; }
    if (this.keys['KeyS'] || this.keys['ArrowDown'])  { moveX -= forward.x; moveZ -= forward.z; }
    if (this.keys['KeyA'] || this.keys['ArrowLeft'])  { moveX -= right.x;   moveZ -= right.z; }
    if (this.keys['KeyD'] || this.keys['ArrowRight']) { moveX += right.x;   moveZ += right.z; }

    const len = Math.sqrt(moveX*moveX + moveZ*moveZ);
    if (len > 0) { moveX /= len; moveZ /= len; }

    this.vel.x = moveX * this.speed;
    this.vel.z = moveZ * this.speed;

    // Saut
    if ((this.keys['Space']) && this.onGround) {
      this.vel.y   = this.jumpForce;
      this.onGround = false;
    }

    // Gravité
    this.vel.y += this.gravity * dt;

    // Appliquer mouvement avec collision
    const dx = this.vel.x * dt;
    const dy = this.vel.y * dt;
    const dz = this.vel.z * dt;

    if (!this.collide(dx, 0, 0)) this.pos.x += dx;
    else this.vel.x = 0;

    if (!this.collide(0, dy, 0)) {
      this.pos.y += dy;
      this.onGround = false;
    } else {
      if (this.vel.y < 0) this.onGround = true;
      this.vel.y = 0;
    }

    if (!this.collide(0, 0, dz)) this.pos.z += dz;
    else this.vel.z = 0;

    // Respawn si tombe
    if (this.pos.y < -10) {
      this.pos.set(0, 20, 0);
      this.vel.set(0, 0, 0);
    }

    // Animation marche
    const moving = Math.abs(moveX) + Math.abs(moveZ) > 0;
    if (moving && this.onGround) {
      this.walkAnim += dt * 8;
      const swing = Math.sin(this.walkAnim) * 0.5;
      this.legL.rotation.x  =  swing;
      this.legR.rotation.x  = -swing;
      this.armL.rotation.x  = -swing;
      this.armR.rotation.x  =  swing;
    } else {
      this.legL.rotation.x = this.legR.rotation.x = 0;
      this.armL.rotation.x = this.armR.rotation.x = 0;
    }

    // Avatar position & rotation
    if (this.avatarGroup) {
      this.avatarGroup.position.copy(this.pos);
      this.avatarGroup.rotation.y = this.yaw;
    }

    // --- Caméra ---
    const headPos = this.pos.clone().add(this.camOffset);
    if (this.thirdPerson) {
      const camDir = new THREE.Vector3(
        -Math.sin(this.yaw) * Math.cos(this.pitch),
        Math.sin(this.pitch),
        -Math.cos(this.yaw) * Math.cos(this.pitch)
      ).normalize();
      this.camera.position.copy(headPos).addScaledVector(camDir, -this.camDistance);
      this.camera.position.y = Math.max(this.camera.position.y, 0.5);
      this.camera.lookAt(headPos);
    } else {
      this.camera.position.copy(headPos);
      this.camera.rotation.order = 'YXZ';
      this.camera.rotation.y     = this.yaw;
      this.camera.rotation.x     = this.pitch;
    }

    // --- Raycasting ---
    if (this.mouse.left || this.mouse.right) {
      this.doRaycast(worldMeshes);
      this.mouse.left = this.mouse.right = false;
    }
  }

  doRaycast(meshes) {
    const dir = new THREE.Vector3(
      -Math.sin(this.yaw) * Math.cos(this.pitch),
      Math.sin(this.pitch),
      -Math.cos(this.yaw) * Math.cos(this.pitch)
    ).normalize();

    // En 3rd person, rayon depuis les yeux
    const origin = this.pos.clone().add(this.camOffset);
    this.raycaster.set(origin, dir);
    const hits = this.raycaster.intersectObjects(meshes);
    if (hits.length === 0) return;

    const hit   = hits[0];
    const bdata = hit.object.userData.blockPos;
    if (!bdata) return;

    if (this.mouse.left) {
      // Casser
      this.world.setBlock(bdata.x, bdata.y, bdata.z, BLOCK_TYPES.AIR);
    } else {
      // Placer
      const n = hit.face.normal;
      const nx = bdata.x + Math.round(n.x);
      const ny = bdata.y + Math.round(n.y);
      const nz = bdata.z + Math.round(n.z);
      // Ne pas placer dans le joueur
      const px = Math.floor(this.pos.x), py = Math.floor(this.pos.y), pz = Math.floor(this.pos.z);
      if (nx === px && (ny === py || ny === py+1) && nz === pz) return;
      this.world.setBlock(nx, ny, nz, this.selectedBlock);
    }
  }
}
