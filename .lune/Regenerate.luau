--[[
    Author: Joseph (@BreakLoop)
    Description: Regenerates the project by syncing assets, installing packages, generating a sourcemap,
                 applying package types, and installing the Rojo plugin.
]]

local Fs = require("@lune/fs")
local Config = require("../project.config")
local AsphaltSync = require("./Modules/AsphaltSync")
local Execute = require("./Modules/Execute")

local SourcemapProjectFile = if Config.FULL_SOURCEMAP then Config.BUILD_PROJECT_FILE else Config.SERVE_PROJECT_FILE

print("→ Syncing assets...")
AsphaltSync(Config.DEFAULT_ASPHALT_OUTPUT)
print("→ Installing packages...")
Execute.sync("wally", { "install" })
print("→ Generating sourcemap...")
Execute.sync("rojo", { "sourcemap", SourcemapProjectFile, "--output", "sourcemap.json" })
if Fs.isDir("Packages") then
	print("→ Applying package types...")
	Execute.sync("wally-package-types", { "--sourcemap", "sourcemap.json", "Packages/" })
end
