#! /usr/bin/lua

local buildTools = require("buildTools")
local config = require("project")

local deleteTargetFile, deleteBuildDirectory, processSourceFiles, zipSourceFiles, deploy
local function main(profile, target)
	deleteTargetFile(profile)
	deleteBuildDirectory(profile)
	
	if profile then
		buildTools.ensurePathExists(("./build/%s"):format(profile))

		if not config.profiles[profile] then
			io.stderr:write(("Unknown profile %s\n"):format(profile))
			io.stderr:write("Available profiles are:\n")
			
			for profileName in pairs(config.profiles) do
				io.stderr:write(("- %s\n"):format(profileName))
			end
			
			return
		end

		buildTools.processSourceFiles(config.profiles[profile], profile)
		zipSourceFiles(profile)

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

deleteTargetFile = function(profile)
	return os.remove(("%s_%s.love"):format(config.project.name, profile))
end

deleteBuildDirectory = function(profile)
	if not lfs.attributes(("./build/%s"):format(profile)) then
		return
	end

	for _, file in pairs(buildTools.findFiles(("./build/%s"):format(profile))) do
		assert(os.remove(file))
	end

	for _, dir in pairs(buildTools.findDirectories(("./build/%s"):format(profile))) do
		assert(lfs.rmdir(dir))
	end
end

zipSourceFiles = function(profile)
	return os.execute(([[cd build/%s && zip -r ../../%s_%s.love *]]):format(profile, config.project.name, profile))
end

main(...)