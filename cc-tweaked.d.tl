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
local fslib = require("types.fs")
local helplib = require("types.help")
local keyslib = require("types.keys")
local paintutilslib = require("types.paintutils")
local parallellib = require("types.parallel")
local redstonelib = require("types.redstone")
local settingslib = require("types.settings")
local termlib = require("types.term")
local textutilslib = require("types.textutils")
local vectorlib = require("types.vector")
local windowlib = require("types.window")

global colors: colorslib
global colours: colourslib
global fs: fslib
global help: helplib
global keys: keyslib
global paintutils: paintutilslib
global parallel: parallellib
global redstone: redstonelib
global rs: redstonelib
global settings: settingslib
global term: termlib
global textutils: textutilslib
global vector: vectorlib
global window: windowlib

-- Globals defined by the BIOS.
local type CompleteFn = function(string): {string}

global _HOST: string
global _CC_DEFAULT_SETTINGS: string
global sleep: function(time?: number)
global write: function(text: string): integer
global printError: function(...: any)
global read: function(replaceChar?: string, history?: {string}, completeFn?: CompleteFn, default?: string): string
