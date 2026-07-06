--[[
    Author: Joseph (@BreakLoop)
    Description: Publishes raw place data to a specific universe and place via the Roblox Open Cloud API
]]

local Net = require("@lune/net")
local Process = require("@lune/process")
local Serde = require("@lune/serde")
local FetchSecret = require("./FetchSecret")

return function(UniverseId: number, PlaceId: number, PlaceData: buffer | string)
	print(`Publishing place {PlaceId} to universe {UniverseId}`)

	local Response = Net.request({
		url = `https://apis.roblox.com/universes/v1/{UniverseId}/places/{PlaceId}/versions?versionType=Published`,
		method = "POST",
		headers = {
			["x-api-key"] = FetchSecret("OPEN_CLOUD_KEY"),
			["Content-Type"] = "application/octet-stream",
		},
		body = PlaceData,
	})

	if not Response.ok then
		if Response.statusCode == 409 then
			warn("\tFailed to publish: please exit your Team Create session before publishing.")
		else
			warn(`\tFailed to publish place [{Response.statusCode}]\n\t{Response.statusMessage}`)
		end
		Process.exit(1)
	end

	local Data = Serde.decode("json", Response.body)
	print(`\tPublished as version {Data.versionNumber}`)

	return Data.versionNumber
end
