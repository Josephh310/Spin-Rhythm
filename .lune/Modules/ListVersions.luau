--[[
    Author: Joseph (@BreakLoop)
    Description: Lists historical versions of an asset via the Roblox Open Cloud API, paginating up to a configurable limit
]]

local Net = require("@lune/net")
local Process = require("@lune/process")
local Serde = require("@lune/serde")
local FetchSecret = require("./FetchSecret")

export type VersionInfo = {
	VersionNumber: number,
	CreateTime: string,
}

return function(AssetId: number, MaxResults: number?): { VersionInfo }
	print(`Fetching versions for asset {AssetId}`)

	local Versions: { VersionInfo } = {}
	local PageToken: string? = nil
	local Limit = MaxResults or 50

	repeat
		local Url = `https://apis.roblox.com/assets/v1/assets/{AssetId}/versions?maxPageSize=50`
		if PageToken then
			Url ..= `&pageToken={PageToken}`
		end

		local Response = Net.request({
			url = Url,
			headers = {
				["x-api-key"] = FetchSecret("OPEN_CLOUD_KEY"),
			},
		})

		if not Response.ok then
			warn(`\tFailed to fetch versions [{Response.statusCode}]\n\t{Response.statusMessage}`)
			Process.exit(1)
		end

		local Data = Serde.decode("json", Response.body)

		for _, Version in Data.assetVersions do
			Versions[#Versions + 1] = {
				VersionNumber = tonumber(string.match(Version.path, "versions/(%d+)$")) :: number,
				CreateTime = Version.createTime,
			}

			if #Versions >= Limit then
				break
			end
		end

		PageToken = Data.nextPageToken
	until not PageToken or PageToken == "" or #Versions >= Limit

	return Versions
end
