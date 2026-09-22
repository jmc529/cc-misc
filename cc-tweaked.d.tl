-- Global environment definition for CC:Tweaked.
--
-- This file is loaded by `tl` via `global_env_def = "cc-tweaked"` in
-- tlconfig.lua. It declares every global CC:Tweaked injects into the Lua
-- environment; the shape of each API lives in its own declaration file under
-- `types/`, so this file stays a table of contents.
--
-- Note: `os`, `io`, `string`, `table` and `math` are already declared by Teal's
-- standard library and cannot be redeclared here. CC's additions to `os`
-- (`os.pullEvent`, `os.epoch`, ...) are therefore not visible to the type
-- checker.

local colorslib = require("types.colors")
local colourslib = require("types.colours")
local commandslib = require("types.commands")
local disklib = require("types.disk")
local fslib = require("types.fs")
local gpslib = require("types.gps")
local helplib = require("types.help")
local keyslib = require("types.keys")
local paintutilslib = require("types.paintutils")
local parallellib = require("types.parallel")
local peripherallib = require("types.peripheral")
local rednetlib = require("types.rednet")
local redstonelib = require("types.redstone")
local settingslib = require("types.settings")
local termlib = require("types.term")
local textutilslib = require("types.textutils")
local vectorlib = require("types.vector")
local windowlib = require("types.window")

global colors: colorslib
global colours: colourslib
global disk: disklib
global fs: fslib
global gps: gpslib
global help: helplib
global keys: keyslib
global paintutils: paintutilslib
global parallel: parallellib
global peripheral: peripherallib
global rednet: rednetlib
global redstone: redstonelib
global rs: redstonelib
global settings: settingslib
global term: termlib
global textutils: textutilslib
global vector: vectorlib
global window: windowlib

-- Only present on command computers.
global commands: commandslib

-- Globals defined by the BIOS.
local type CompleteFn = function(string): {string}

global _HOST: string
global _CC_DEFAULT_SETTINGS: string
global sleep: function(time?: number)
global write: function(text: string): integer
global printError: function(...: any)
global read: function(replaceChar?: string, history?: {string}, completeFn?: CompleteFn, default?: string): string
