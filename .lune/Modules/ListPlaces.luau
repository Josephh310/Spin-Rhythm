--[[
    Author: Joseph (@BreakLoop)
    Description: Lists all places under a given Roblox universe, paging through the develop API until exhausted
]]

local Net = require("@lune/net")
local Process = require("@lune/process")
local Serde = require("@lune/serde")

export type PlaceInfo = {
	Name: string,
	Id: number,
}

return function(UniverseId: number): { PlaceInfo }
	print(`Fetching places for universe {UniverseId}`)

	local Places: { PlaceInfo } = {}
	local Cursor: string? = nil

	repeat
		local Url = `https://develop.roblox.com/v1/universes/{UniverseId}/places?limit=100&sortOrder=Asc`
		if Cursor then
			Url ..= `&cursor={Cursor}`
		end

		local Response = Net.request({
			url = Url,
		})

		if not Response.ok then
			warn(`\tFailed to fetch places [{Response.statusCode}]\n\t{Response.statusMessage}`)
			Process.exit(1)
		end

		local Data = Serde.decode("json", Response.body)

		for _, Place in Data.data do
			Places[#Places + 1] = {
				Name = Place.name,
				Id = Place.id,
			}
		end

		Cursor = Data.nextPageCursor
	until not Cursor or Cursor == ""

	return Places
end
