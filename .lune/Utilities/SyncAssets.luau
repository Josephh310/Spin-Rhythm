--[[
    Author: Joseph (@BreakLoop)
    Description: Syncs all assets to a user-selected asphalt target, overriding DEFAULT_ASPHALT_OUTPUT
    Requirements: OPEN_CLOUD_KEY in .env with asset:write permissions (only when target is Cloud)
]]

local Process = require("@lune/process")
local Stdio = require("@lune/stdio")
local AsphaltSync = require("../Modules/AsphaltSync")

local Targets = { "Studio", "Cloud" }

local SelectedIndex = Stdio.prompt("select", "Select a sync target:", Targets)
if not SelectedIndex then
	Process.exit(1)
end

local SelectedTarget = Targets[SelectedIndex :: number]
print(`Selected target: {SelectedTarget}`)

AsphaltSync(SelectedTarget)
print("Assets synced successfully")
