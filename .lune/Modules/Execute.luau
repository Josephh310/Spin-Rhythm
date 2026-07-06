--[[
    Author: Joseph (@BreakLoop)
    Description: Shared helpers for running subprocesses. sync blocks and asserts success; async runs in the background and warns on failure.
]]

local Process = require("@lune/process")
local Task = require("@lune/task")

local function sync(cmd: string, args: { string })
	local Result = Process.exec(cmd, args)
	assert(Result.ok, Result.stderr)
end

local function async(cmd: string, args: { string })
	Task.spawn(function()
		local Result = Process.exec(cmd, args)
		if not Result.ok then
			warn(`{cmd} exited with code {Result.code}\n{Result.stderr}`)
		end
	end)
end

return table.freeze({
	sync = sync,
	async = async,
})
