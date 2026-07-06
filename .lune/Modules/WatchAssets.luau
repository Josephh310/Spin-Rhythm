--[[
    Author: Joseph (@BreakLoop)
    Description: Watches the Assets folder for changes and syncs to the configured asphalt target
    Requirements: OPEN_CLOUD_KEY in .env with asset:write permissions (only when target is Cloud)
]]

local Config = require("../../project.config")
local AsphaltSync = require("./AsphaltSync")
local WatchDirectory = require("./WatchDirectory")

return function()
	print(`Watching Assets/ for changes (target: {Config.DEFAULT_ASPHALT_OUTPUT})`)

	WatchDirectory("Assets", 1, function(Added, Removed, Modified)
		for _, File in Added do
			print(`+ {File}`)
		end
		for _, File in Removed do
			print(`- {File}`)
		end
		for _, File in Modified do
			print(`~ {File}`)
		end

		print("Changes detected, syncing assets...")
		AsphaltSync(Config.DEFAULT_ASPHALT_OUTPUT)
		print("Assets synced successfully")
	end)
end
