--[[
    Author: Joseph (@BreakLoop)
    Description: Sets up the local development environment by installing dependencies, generating a sourcemap, syncing assets, and serving the project via rojo
]]

local Task = require("@lune/task")
local Config = require("../project.config")
local Execute = require("./Modules/Execute")
local WatchAssets = require("./Modules/WatchAssets")

local SourcemapProjectFile = if Config.FULL_SOURCEMAP then Config.BUILD_PROJECT_FILE else Config.SERVE_PROJECT_FILE

print("→ Starting sourcemap watcher...")
Execute.async("rojo", { "sourcemap", "--watch", SourcemapProjectFile, "--output", "sourcemap.json", "--include-non-scripts" })
print("→ Starting rojo serve...")
Execute.async("rojo", { "serve", Config.SERVE_PROJECT_FILE })
print("→ Starting asset watcher...")
Task.spawn(WatchAssets)

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("  Serving — connect Studio to continue   ")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")
