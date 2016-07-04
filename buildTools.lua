local lfs = require("lfs")

local buildTools = {}

local processFile, getOutputFile, ensurePathExists
function buildTools.processSourceFiles(profile)
	local allFiles = buildTools.findFiles("src")

	for _, file in pairs(allFiles) do
		local outFile = getOutputFile(file)
		ensurePathExists(outFile)

		if file:match("%.lua$") then
			local f = assert(io.open(outFile, "w"))
			f:write(processFile(file, profile))
			f:close()
		else
			assert(os.execute(("cp %s %s"):format(file, outFile)))
		end
	end
end

function buildTools.findFiles(path)
	local files = {}

	for file in lfs.dir(path) do
		if not file:match("^%.") then
			local filePath = path .. "/" .. file
			if lfs.attributes(filePath, "mode") == "directory" then
				local subFiles = buildTools.findFiles(filePath)
				for i, subFile in ipairs(subFiles) do
					table.insert(files, subFile)
				end
			else
				table.insert(files, filePath)
			end
		end
	end

	return files
end

function buildTools.findDirectories(path)
	local directories = {}
	
	for file in lfs.dir(path) do
		if not file:match("%.") then
			local filePath = path .. "/" .. file
			if lfs.attributes(filePath, "mode") == "directory" then
				local subDirectories = buildTools.findDirectories(filePath)
				for i, subDirectory in ipairs(subDirectories) do
					table.insert(directories, subDirectory)
				end
				table.insert(directories, filePath)
			end
		end
	end
	
	return directories
end

getOutputFile = function(input)
	return input:gsub("src/", "build/", 1)
end

local commentOut
processFile = function(file, profile)
	local f = io.open(file)
	local content = f:read("*a")
	f:close()
	
	return (content:gsub("(%-%-if (.-)\n.-%-%-endif)",
		function (codeblock, condition)
			local chunk = assert(load(("return %s"):format(condition), "chunk", "t", profile.defines))
			if chunk() then
				print(condition, "= true in", file)
				return codeblock
			else
				print(condition, "= false in", file)
				return commentOut(codeblock)
			end
		end))
end

local getLineBreak
commentOut = function(text)
	local lineBreak = getLineBreak(text)
	
	return text:gsub(("%s([^\r\n]+)"):format(lineBreak), 
		function(line)
			if line:match("--endif") then
				return lineBreak .. line
			else
				return lineBreak .. "--" .. line
			end
		end)
end

getLineBreak = function(sample)
	return sample:find("\r\n")
		and "\r\n"
		or  sample:find("\r")
			and "\r"
			or  "\n"
end

ensurePathExists = function(filePath)
	local dirPath = filePath:match("^(.+)/[^/]*")
	local checkedPath = ""
	for dirSpec in dirPath:gmatch("[^/]+/?") do
		checkedPath = checkedPath .. dirSpec
		lfs.mkdir(checkedPath)
	end
end

return buildTools