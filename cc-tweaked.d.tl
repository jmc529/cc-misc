-- Global environment definition for CC:Tweaked.
--
-- This file is loaded by `tl` via `global_env_def = "cc-tweaked"` in
-- tlconfig.lua. It declares every global CC:Tweaked injects into the Lua
-- environment; the shape of each API lives in its own declaration file under
-- `types/`, so this file stays a table of contents.
--
-- Note: `os`, `io`, `string`, `table` and `math` are already declared by Teal's
-- standard library and cannot be redeclared here. CC's additions to `os`
-- (`os.pullEvent`, `os.epoch`, ...) live in `types/ccos.d.tl` instead, and a
-- file that needs them starts with `local os = _G.os as ccos`.

local chatboxlib = require("types.chatbox")
local colorslib = require("types.colors")
local colourslib = require("types.colours")
local commandslib = require("types.commands")
local disklib = require("types.disk")
local fslib = require("types.fs")
local gpslib = require("types.gps")
local helplib = require("types.help")
local httplib = require("types.http")
local keyslib = require("types.keys")
local multishelllib = require("types.multishell")
local paintutilslib = require("types.paintutils")
local parallellib = require("types.parallel")
local peripherallib = require("types.peripheral")
local pocketlib = require("types.pocket")
local rednetlib = require("types.rednet")
local redstonelib = require("types.redstone")
local settingslib = require("types.settings")
local shelllib = require("types.shell")
local termlib = require("types.term")
local textutilslib = require("types.textutils")
local turtlelib = require("types.turtle")
local vectorlib = require("types.vector")
local windowlib = require("types.window")

global colors: colorslib
global colours: colourslib
global disk: disklib
global fs: fslib
global gps: gpslib
global help: helplib
global http: httplib
global keys: keyslib
global paintutils: paintutilslib
global parallel: parallellib
global peripheral: peripherallib
global rednet: rednetlib
global redstone: redstonelib
global rs: redstonelib
global settings: settingslib
global shell: shelllib
global term: termlib
global textutils: textutilslib
global vector: vectorlib
global window: windowlib

-- Only present on turtles.
global turtle: turtlelib

-- Only present on pocket computers.
global pocket: pocketlib

-- Only present on advanced computers, under the advanced shell.
global multishell: multishelllib

-- Only present on command computers.
global commands: commandslib

-- Only present next to a licensed SwitchCraft chatbox.
global chatbox: chatboxlib

-- Type-only namespaces. These have no runtime value: they are exposed as
-- global types so source files can refer to `peripherals.Inventory`,
-- `plethora.NeuralInterface` or `ccos` in casts without a `require` that
-- would survive into the generated Lua and fail in-game.
local ccoslib = require("types.ccos")
local peripheralslib = require("types.peripherals")
local plethoralib = require("types.plethora")
local sc3lib = require("types.sc3")

global type ccos = ccoslib
global type peripherals = peripheralslib
global type plethora = plethoralib
global type sc3 = sc3lib

-- Globals defined by the BIOS.
local type CompleteFn = function(string): {string}

global _HOST: string
global _CC_DEFAULT_SETTINGS: string
global sleep: function(time?: number)
global write: function(text: string): integer
global printError: function(...: any)
global read: function(replaceChar?: string, history?: {string}, completeFn?: CompleteFn, default?: string): string
