#! /usr/bin/lua

local buildTools = require("buildTools")
local config = require("project")

local deleteTargetFile, deleteBuildDirectory, processSourceFiles, zipSourceFiles, deploy
local function main(profile, target)
	deleteTargetFile()
	deleteBuildDirectory()
	
	if profile then
		if not config.profiles[profile] then
			io.stderr:write(("Unknown profile %s\n"):format(profile))
			io.stderr:write("Available profiles are:\n")
			
			for profileName in pairs(config.profiles) do
				io.stderr:write(("- %s\n"):format(profileName))
			end
			
			return
		end
		
		buildTools.processSourceFiles(config.profiles[profile])
		zipSourceFiles()
		
		if target then
			if not config.targets[target] then
				io.stderr:write(("Unknown target %s\n"):format(target))
				io.stderr:write("Available target are:\n")
				
				for targetName in pairs(config.targets) do
					io.stderr:write(("- %s\n"):format(targetName))
				end
				
				return
			end
			
			config.targets[target].deploy()
		end
	end
end

deleteTargetFile = function()
	return os.remove(("%s.love"):format(config.project.name))
end

deleteBuildDirectory = function()
	for _, file in pairs(buildTools.findFiles("./build")) do
		assert(os.remove(file))
	end
	
	for _, dir in pairs(buildTools.findDirectories("./build")) do
		assert(lfs.rmdir(dir))
	end
end

zipSourceFiles = function()
	return os.execute(([[cd build && zip -r ../%s.love *]]):format(config.project.name))
end

main(...)