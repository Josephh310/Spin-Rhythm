--[[
    Author: Joseph (@BreakLoop)
    Description: Polls a directory tree on an interval and invokes a callback with files that were added, removed, or modified between scans
]]

local Fs = require("@lune/fs")
local Task = require("@lune/task")

type FileMap = { [string]: number }
type OnChangeCallback = (added: { string }, removed: { string }, modified: { string }) -> ()

local function ScanDir(Path: string): FileMap
	local Files: FileMap = {}
	for _, Entry in Fs.readDir(Path) do
		if string.sub(Entry, 1, 1) == "." then
			continue
		end
		local Full = `{Path}/{Entry}`
		if Fs.isDir(Full) then
			for File, ModifiedAt in ScanDir(Full) do
				Files[File] = ModifiedAt
			end
		else
			Files[Full] = Fs.metadata(Full).modifiedAt.unixTimestamp
		end
	end
	return Files
end

return function(Path: string, Interval: number, OnChange: OnChangeCallback)
	local Prev = ScanDir(Path)

	while true do
		Task.wait(Interval)
		local Curr = ScanDir(Path)

		local Added = {}
		local Removed = {}
		local Modified = {}

		for File, ModifiedAt in Curr do
			if not Prev[File] then
				table.insert(Added, File)
			elseif ModifiedAt ~= Prev[File] then
				table.insert(Modified, File)
			end
		end
		for File in Prev do
			if not Curr[File] then
				table.insert(Removed, File)
			end
		end

		if #Added > 0 or #Removed > 0 or #Modified > 0 then
			OnChange(Added, Removed, Modified)
		end

		Prev = Curr
	end
end
