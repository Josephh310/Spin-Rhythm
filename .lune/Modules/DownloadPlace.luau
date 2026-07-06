--[[
    Author: Joseph (@BreakLoop)
    Description: Downloads a Roblox place by id via the asset delivery API and returns it as a deserialized DataModel
]]

local Net = require("@lune/net")
local Process = require("@lune/process")
local Roblox = require("@lune/roblox")
local Serde = require("@lune/serde")
local FetchSecret = require("./FetchSecret")

return function(PlaceId: number): Roblox.DataModel
	print(`Retrieving place {PlaceId}`)

	local Response = Net.request({
		url = `https://apis.roblox.com/asset-delivery-api/v1/assetId/{PlaceId}`,
		headers = {
			["x-api-key"] = FetchSecret("OPEN_CLOUD_KEY"),
		},
	})

	if not Response.ok then
		warn(`\tFailed to fetch map place [{Response.statusCode}]\n\t{Response.statusMessage}`)
		Process.exit(1)
	end

	local ResponseTable = Serde.decode("json", Response.body)

	local Place = Net.request({
		url = ResponseTable.location,
	})

	if not Place.ok then
		warn(`\tFailed to fetch map place [{Place.statusCode}]\n\t{Place.statusMessage}`)
		Process.exit(1)
	end

	return Roblox.deserializePlace(Place.body)
end
