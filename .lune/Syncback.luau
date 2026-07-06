--[[
    Author: Joseph (@BreakLoop)
    Description: Fetches a selected place under the dev universe from Roblox and syncs it back to the filesystem using rojo
    Requirements: OPEN_CLOUD_KEY in .env with legacy-asset:manage permissions
]]

local Fs = require("@lune/fs")
local Process = require("@lune/process")
local Roblox = require("@lune/roblox")
local Config = require("../project.config")
local DownloadPlace = require("./Modules/DownloadPlace")
local PromptForPlace = require("./Modules/PromptForPlace")

local SelectedPlace = PromptForPlace(Config.DEV_UNIVERSE_ID, "Select a place to sync back from:")

print("→ Downloading place...")
local PlaceData = DownloadPlace(SelectedPlace.Id)
print("→ Serializing place...")
Fs.writeFile(Config.SYNCBACK_FILENAME, Roblox.serializePlace(PlaceData))

print("→ Running syncback...")
local Result = Process.exec("rojo", { "syncback", Config.BUILD_PROJECT_FILE, "--input", Config.SYNCBACK_FILENAME, "--non-interactive" })
assert(Result.ok, Result.stderr)

print("→ Cleaning up...")
Fs.removeFile(Config.SYNCBACK_FILENAME)
print("Cleaned up place file")
