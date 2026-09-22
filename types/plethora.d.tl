-- Type declarations for Plethora Peripherals, a CC:Tweaked add-on mod.
-- https://plethora.madefor.cc/
--
-- Plethora exposes its functionality through two peripherals, the neural
-- interface (worn by a player) and the manipulator (a block). Both expose the
-- methods of whichever modules are currently installed, so a single record
-- with every module's methods is the closest thing Teal can express; guard at
-- runtime with `hasModule` as the Plethora examples do:
--
--    local modules = peripheral.find("neuralInterface") as plethora.ModuleHost
--    if not modules.hasModule("plethora:sensor") then error("no sensor", 0) end
--
-- Plethora's metadata tables are open and vary by entity, item and block (they
-- gain fields from whichever mods are installed). The records below declare
-- the fields Plethora itself always provides; cast to `{string: any}` to reach
-- mod-specific extras.

local record plethora
   -- Position relative to the module host, in blocks.
   record Position
      x: number
      y: number
      z: number
   end

   record ItemMeta
      name: string
      count: integer
      rawName: string
      displayName: string
      damage: integer
      maxDamage: integer
      maxCount: integer
      nbtHash: string
      tags: {string: boolean}
      enchantments: {{string: any}}
   end

   -- An item reference returned by, for instance, `getMetaOwner().heldItem`.
   -- The reference stays live: `getMetadata` re-reads the current item.
   record ItemReference
      getMetadata: function(): ItemMeta
   end

   record FoodMeta
      food: integer
      saturation: number
      hungry: boolean
   end

   -- Returned for each entity by `sense()`. `id` is the entity's UUID and
   -- `key` its registry name (e.g. "minecraft:fishing_bobber").
   record EntityMeta
      x: number
      y: number
      z: number
      id: string
      key: string
      name: string
      displayName: string
      motionX: number
      motionY: number
      motionZ: number
      pitch: number
      pitch_: number
      yaw: number
      health: number
      maxHealth: number
      isAlive: boolean
      isElytraFlying: boolean
      isBurning: boolean
      isSneaking: boolean
      isSprinting: boolean
      food: FoodMeta
      heldItem: ItemReference
      heldItemSlot: integer
      armor: {string: ItemMeta}
      potionEffects: {{string: any}}
   end

   -- A block returned by the block scanner. Blocks are returned in a flat
   -- array covering the scanned cube; `x`, `y` and `z` are relative offsets.
   record BlockMeta
      x: integer
      y: integer
      z: integer
      name: string
      metadata: integer
      state: {string: any}
      -- Present for blocks with a block entity (chests, signs, ...).
      contents: {string: any}
   end

   -- Plethora's inventory wrapper, as returned by the introspection module.
   -- It is a superset of CC's generic inventory methods.
   interface Inventory
      size: function(): integer
      list: function(): {integer: ItemMeta}
      getItemMeta: function(slot: integer): ItemMeta
      getItemDetail: function(slot: integer): ItemMeta
      getItemLimit: function(slot: integer): integer
      pushItems: function(toName: string, fromSlot: integer, limit?: integer, toSlot?: integer): integer
      pullItems: function(fromName: string, fromSlot: integer, limit?: integer, toSlot?: integer): integer
      drop: function(slot: integer, limit?: integer, direction?: string): integer
      suck: function(slot?: integer, limit?: integer): integer
      -- Equipment/player inventories only: eat or otherwise use the item.
      consume: function(slot: integer): boolean, string
   end

   -- Objects drawn on the 2D overlay canvas. Every object supports removal and
   -- movement; the rest of the setters depend on the object kind, so they are
   -- gathered here rather than split into one record per shape.
   record CanvasObject
      remove: function()
      getPosition: function(): number, number
      setPosition: function(x: number, y: number)
      getColor: function(): integer
      getColour: function(): integer
      setColor: function(colour: integer)
      setColour: function(colour: integer)
      getAlpha: function(): integer
      setAlpha: function(alpha: integer)
      getText: function(): string
      setText: function(text: string)
      getSize: function(): number
      setSize: function(size: number)
      getScale: function(): number
      setScale: function(scale: number)
      getLineWidth: function(): number
      setLineWidth: function(width: number)
      getObjectSize: function(): number, number
      setObjectSize: function(width: number, height: number)
      getItem: function(): string
      setItem: function(item: string, damage?: integer, nbt?: string)
      getDepth: function(): number
      setDepth: function(depth: number)
   end

   -- The 2D canvas drawn over the player's view by the overlay glasses.
   -- Positions are `{x, y}` pairs and colours are 32-bit RGBA integers.
   record Canvas
      clear: function()
      getSize: function(): number, number
      getObject: function(id: integer): CanvasObject
      getObjects: function(): {integer: CanvasObject}
      addRectangle: function(x: number, y: number, width: number, height: number, colour?: integer): CanvasObject
      addLine: function(start: {number}, finish: {number}, thickness?: number, colour?: integer): CanvasObject
      addDot: function(position: {number}, colour?: integer, size?: number): CanvasObject
      addText: function(position: {number}, text: string, colour?: integer, size?: number): CanvasObject
      addTriangle: function(p1: {number}, p2: {number}, p3: {number}, colour?: integer): CanvasObject
      addPolygon: function(...: {number}): CanvasObject
      addLines: function(...: {number}): CanvasObject
      addItem: function(position: {number}, item: string, damage?: integer, scale?: number): CanvasObject
      addGroup: function(position: {number}): Canvas
   end

   record Canvas3DObject
      remove: function()
      getPosition: function(): number, number, number
      setPosition: function(x: number, y: number, z: number)
      getColor: function(): integer
      getColour: function(): integer
      setColor: function(colour: integer)
      setColour: function(colour: integer)
      getAlpha: function(): integer
      setAlpha: function(alpha: integer)
      getText: function(): string
      setText: function(text: string)
      getScale: function(): number
      setScale: function(scale: number)
      getRotation: function(): number
      setRotation: function(rotation: number)
      getDepthTested: function(): boolean
      setDepthTested: function(tested: boolean)
   end

   -- A canvas rendered in world space, anchored to the glasses' wearer.
   record Canvas3D
      clear: function()
      getObject: function(id: integer): Canvas3DObject
      getObjects: function(): {integer: Canvas3DObject}
      recentre: function(position?: {number})
      create: function(position?: {number}): Canvas3D
      addBox: function(x: number, y: number, z: number, width?: number, height?: number, depth?: number, colour?: integer): Canvas3DObject
      addLine: function(start: {number}, finish: {number}, thickness?: number, colour?: integer): Canvas3DObject
      addFrame: function(position: {number}): Canvas3D
      addItem: function(position: {number}, item: string, damage?: integer, scale?: number): Canvas3DObject
   end

   -- The methods common to the neural interface and the manipulator: whichever
   -- modules are installed contribute their methods to the same table.
   interface ModuleHost
      hasModule: function(module: string): boolean
      getModuleData: function(module: string): {string: any}
      listModules: function(): {string}

      -- plethora:sensor
      sense: function(): {integer: EntityMeta}
      getMetaByID: function(id: string): EntityMeta
      getMetaByName: function(name: string): EntityMeta

      -- plethora:scanner
      scan: function(): {integer: BlockMeta}
      getBlockMeta: function(x: integer, y: integer, z: integer): BlockMeta

      -- plethora:introspection
      getID: function(): string
      getName: function(): string
      getMetaOwner: function(): EntityMeta
      getInventory: function(): Inventory
      getEquipment: function(): Inventory
      getEnder: function(): Inventory

      -- plethora:kinetic
      launch: function(yaw: number, pitch: number, power: number)
      walk: function(x: number, y: number, z: number): boolean, string
      look: function(yaw: number, pitch: number)
      use: function(duration?: number, hand?: string): string
      swing: function(): boolean, string
      disableAI: function()

      -- plethora:laser
      fire: function(yaw: number, pitch: number, potency: number)

      -- plethora:glasses
      canvas: function(): Canvas
      canvas3d: function(): Canvas3D

      -- plethora:chat / plethora:chat_creative
      say: function(message: string)
      tell: function(message: string)
      capture: function(pattern: string)
      uncapture: function(pattern: string)
   end

   -- The neural interface worn by a player, found with
   -- `peripheral.find("neuralInterface")`.
   record NeuralInterface is ModuleHost
   end

   -- The manipulator block, found with `peripheral.find("manipulator")`.
   record Manipulator is ModuleHost
   end
end

return plethora
