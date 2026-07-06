--[[
    Author: Joseph (@BreakLoop)
    Description: Rolls a Roblox asset back to a specified prior version via the Open Cloud API and returns the new version number
]]

local Net = require("@lune/net")
local Process = require("@lune/process")
local Serde = require("@lune/serde")
local FetchSecret = require("./FetchSecret")

return function(AssetId: number, VersionNumber: number): number
	print(`Rolling back asset {AssetId} to version {VersionNumber}`)

	local Response = Net.request({
		url = `https://apis.roblox.com/assets/v1/assets/{AssetId}/versions:rollback`,
		method = "POST",
		headers = {
			["x-api-key"] = FetchSecret("OPEN_CLOUD_KEY"),
			["Content-Type"] = "application/json",
		},
		body = Serde.encode("json", {
			assetVersion = `assets/{AssetId}/versions/{VersionNumber}`,
		}),
	})

	if not Response.ok then
		warn(`\tFailed to rollback [{Response.statusCode}]\n\t{Response.statusMessage}`)
		Process.exit(1)
	end

	local Data = Serde.decode("json", Response.body)
	local NewVersion = tonumber(string.match(Data.path, "versions/(%d+)$")) :: number

	print(`\tRolled back successfully. New version: {NewVersion}`)
	return NewVersion
end
