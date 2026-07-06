--[[
    Author: Joseph (@BreakLoop)
    Description: Lists places under a universe and prompts the user to pick one; exits the script if the prompt is cancelled
]]

local Process = require("@lune/process")
local Stdio = require("@lune/stdio")
local ListPlaces = require("./ListPlaces")

return function(UniverseId: number, Prompt: string): ListPlaces.PlaceInfo
	local Places = ListPlaces(UniverseId)

	local Names = {}
	for _, Place in Places do
		table.insert(Names, Place.Name)
	end

	local Index = Stdio.prompt("select", Prompt, Names)
	if not Index then
		Process.exit(1)
	end

	local Selected = Places[Index :: number]
	print(`Selected: {Selected.Name} ({Selected.Id})`)
	return Selected
end
