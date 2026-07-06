--[[
    Author: Joseph (@BreakLoop)
    Description: Allows you to revert a selected place to a previous recent version
    Requirements: OPEN_CLOUD_KEY in .env with asset:read and asset:write permissions
]]

local Process = require("@lune/process")
local Stdio = require("@lune/stdio")
local Config = require("../../project.config")
local ListVersions = require("../Modules/ListVersions")
local PromptForPlace = require("../Modules/PromptForPlace")
local RollbackVersion = require("../Modules/RollbackVersion")

local SelectedPlace = PromptForPlace(Config.DEV_UNIVERSE_ID, "Select a place to revert:")

local Versions = ListVersions(SelectedPlace.Id)
if #Versions == 0 then
	warn("No versions found for this place.")
	return
end

local VersionLabels = {}
for _, Version in Versions do
	local Date = string.gsub(Version.CreateTime, "T", " ")
	Date = string.gsub(Date, "Z$", "")
	table.insert(VersionLabels, `v{Version.VersionNumber} — {Date}`)
end

local VersionIndex = Stdio.prompt("select", "Select a version to revert to:", VersionLabels)
if not VersionIndex then
	Process.exit(1)
end

local SelectedVersion = Versions[VersionIndex :: number]
local Confirm = Stdio.prompt("confirm", `Revert {SelectedPlace.Name} to version {SelectedVersion.VersionNumber}?`)
if not Confirm then
	print("Cancelled.")
	return
end

RollbackVersion(SelectedPlace.Id, SelectedVersion.VersionNumber)
