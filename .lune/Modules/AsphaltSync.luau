--[[
    Author: Joseph (@BreakLoop)
    Description: Runs an asphalt sync for the given target. Cloud targets attach OPEN_CLOUD_KEY from the .env file; studio targets do not require it.
]]

local Process = require("@lune/process")
local FetchSecret = require("./FetchSecret")

return function(Target: string)
	local LowerTarget = string.lower(Target)
	assert(LowerTarget == "studio" or LowerTarget == "cloud", `Invalid asphalt target "{Target}"`)

	print(`Syncing assets ({Target})...`)

	local Args = { "sync" }
	if LowerTarget == "cloud" then
		table.insert(Args, "--api-key")
		table.insert(Args, FetchSecret("OPEN_CLOUD_KEY"))
	end
	table.insert(Args, LowerTarget)

	local Result = Process.exec("asphalt", Args)
	assert(Result.ok, Result.stderr)
	print("Assets synced")
end
