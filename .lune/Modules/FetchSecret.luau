--[[
    Author: Joseph (@BreakLoop)
    Description: Reads a named secret value from the configured .env file
]]

local Fs = require("@lune/fs")
local Config = require("../../project.config")

return function(Key: string): string
	local Contents = Fs.readFile(Config.ENV_FILE_PATH)

	for Line in string.gmatch(Contents, "[^\r\n]+") do
		local K, V = string.match(Line, "^([%w_]+)%s*=%s*(.+)$")
		if V and K == Key then
			return (string.gsub(V, "%s+$", ""))
		end
	end

	error(`Could not find key "{Key}" in {Config.ENV_FILE_PATH}`)
end
