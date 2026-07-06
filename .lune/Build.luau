--[[
    Author: Joseph (@BreakLoop)
    Description: Builds a place file from the local filetree and publishes to a selected Roblox place
    Requirements: OPEN_CLOUD_KEY in .env with universe-places:write permissions
]]

local Fs = require("@lune/fs")
local Config = require("../project.config")
local AsphaltSync = require("./Modules/AsphaltSync")
local Execute = require("./Modules/Execute")
local PromptForPlace = require("./Modules/PromptForPlace")
local UploadPlace = require("./Modules/UploadPlace")

local SelectedPlace = PromptForPlace(Config.DEV_UNIVERSE_ID, "Select a place to publish to:")

print("→ Installing packages...")
Execute.sync("wally", { "install" })
print("→ Generating sourcemap...")
Execute.sync("rojo", { "sourcemap", Config.SERVE_PROJECT_FILE, "--output", "sourcemap.json" })
if Fs.isDir("Packages") then
	print("→ Applying package types...")
	Execute.sync("wally-package-types", { "--sourcemap", "sourcemap.json", "Packages/" })
end

print("→ Syncing assets...")
AsphaltSync(Config.DEFAULT_ASPHALT_OUTPUT)
print("→ Building place file...")
Execute.sync("rojo", { "build", Config.BUILD_PROJECT_FILE, "--output", Config.BUILD_FILENAME, "--verbose" })
print(`Built project to {Config.BUILD_FILENAME}`)

print("→ Uploading place...")
local PlaceData = Fs.readFile(Config.BUILD_FILENAME)
UploadPlace(Config.DEV_UNIVERSE_ID, SelectedPlace.Id, PlaceData)

print("→ Cleaning up...")
Fs.removeFile(Config.BUILD_FILENAME)
print("Cleaned up build file")
