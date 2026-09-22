-- Type declarations for the peripherals CC:Tweaked ships with, and for the
-- generic inventory/fluid/energy methods it exposes on modded blocks.
-- https://tweaked.cc/#peripherals
--
-- These are not globals: obtain one by casting a wrapped peripheral, e.g.
--
--     local peripherals = require("types.peripherals")
--     local chest = peripheral.wrap("left") as peripherals.Inventory

local termlib = require("types.term")

local record peripherals
   -- The summary entry returned by `Inventory.list`.
   record ItemStack
      name: string
      count: integer
      nbt: string
   end

   -- `getItemDetail` returns a superset of `ItemStack` whose extra fields
   -- depend on the item, so the uncommon ones are left untyped.
   record ItemDetail
      name: string
      count: integer
      nbt: string
      displayName: string
      maxCount: integer
      damage: integer
      maxDamage: integer
      durability: number
      tags: {string: boolean}
      enchantments: {{string: any}}
      lore: {string}
   end

   record Tank
      name: string
      amount: integer
   end

   -- Any block with an inventory, e.g. a chest or a furnace.
   interface Inventory
      size: function(): integer
      list: function(): {integer: ItemStack}
      getItemDetail: function(slot: integer): ItemDetail
      getItemLimit: function(slot: integer): integer
      pushItems: function(toName: string, fromSlot: integer, limit?: integer, toSlot?: integer): integer
      pullItems: function(fromName: string, fromSlot: integer, limit?: integer, toSlot?: integer): integer
   end

   -- Any block which stores fluids.
   interface FluidStorage
      tanks: function(): {integer: Tank}
      pushFluid: function(toName: string, limit?: integer, fluidName?: string): integer
      pullFluid: function(fromName: string, limit?: integer, fluidName?: string): integer
   end

   -- Any block which stores energy (Forge Energy).
   interface EnergyStorage
      getEnergy: function(): integer
      getEnergyCapacity: function(): integer
   end

   -- Monitors are terminals, so they can be passed to `term.redirect`.
   record Monitor is termlib.Redirect
      setTextScale: function(scale: number)
      getTextScale: function(): number
   end

   interface Modem
      open: function(channel: integer)
      isOpen: function(channel: integer): boolean
      close: function(channel: integer)
      closeAll: function()
      transmit: function(channel: integer, replyChannel: integer, payload: any)
      isWireless: function(): boolean
   end

   -- Wired modems additionally expose the peripherals on their network.
   record WiredModem is Modem
      getNamesRemote: function(): {string}
      isPresentRemote: function(name: string): boolean
      getTypeRemote: function(name: string): string...
      hasTypeRemote: function(name: string, ty: string): boolean
      getMethodsRemote: function(name: string): {string}
      callRemote: function(remoteName: string, method: string, ...: any): any...
      getNameLocal: function(): string
   end

   record DiskDrive
      isDiskPresent: function(): boolean
      getDiskLabel: function(): string
      setDiskLabel: function(label?: string)
      hasData: function(): boolean
      getMountPath: function(): string
      hasAudio: function(): boolean
      getAudioTitle: function(): string | boolean
      playAudio: function()
      stopAudio: function()
      ejectDisk: function()
      getDiskID: function(): integer
   end

   record Printer
      write: function(text: string)
      getCursorPos: function(): integer, integer
      setCursorPos: function(x: integer, y: integer)
      getPageSize: function(): integer, integer
      newPage: function(): boolean
      endPage: function(): boolean
      setPageTitle: function(title?: string)
      getInkLevel: function(): integer
      getPaperLevel: function(): integer
   end

   record Speaker
      playNote: function(instrument: string, volume?: number, pitch?: number): boolean
      playSound: function(name: string, volume?: number, pitch?: number): boolean
      -- `audio` is a list of 8-bit PCM samples, as produced by `cc.audio.dfpwm`.
      playAudio: function(audio: {integer}, volume?: number): boolean
      stop: function()
   end

   record Computer
      turnOn: function()
      shutdown: function()
      reboot: function()
      getID: function(): integer
      isOn: function(): boolean
      getLabel: function(): string
   end

   record CommandBlock
      getCommand: function(): string
      setCommand: function(command: string)
      runCommand: function(): boolean, string
   end

   record RedstoneRelay
      getSides: function(): {string}
      setOutput: function(side: string, on: boolean)
      getOutput: function(side: string): boolean
      getInput: function(side: string): boolean
      setAnalogOutput: function(side: string, value: integer)
      setAnalogueOutput: function(side: string, value: integer)
      getAnalogOutput: function(side: string): integer
      getAnalogueOutput: function(side: string): integer
      getAnalogInput: function(side: string): integer
      getAnalogueInput: function(side: string): integer
      setBundledOutput: function(side: string, output: integer)
      getBundledOutput: function(side: string): integer
      getBundledInput: function(side: string): integer
      testBundledInput: function(side: string, mask: integer): boolean
   end
end

return peripherals
