-- fs.lua
local lfs = require("lfs")
local M = {}

function M.path_exists(path)
	return lfs.attributes(path) ~= nil
end

function M.is_file(path)
	return lfs.attributes(path, "mode") == "file"
end

function M.is_dir(path)
	return lfs.attributes(path, "mode") == "directory"
end

function M.file_type(path)
	return lfs.attributes(path, "mode")
end

function M.expand_tilde(path)
	local home = os.getenv("HOME") or os.getenv("USERPROFILE")
	if not home then
		error("Cannot resolve home directory; $HOME or %USERPROFILE% unset")
	end
	return path:gsub("^~", home)
end

function M.copy(source, destination)
	if M.is_file(source) then
		print(("Copying file %s to %s"):format(source, destination))
		os.execute(string.format('cp "%s" "%s"', source, destination))
	else
		print(("Copying dir  %s to %s"):format(source, destination))
		os.execute(string.format('cp -r "%s" "%s"', source, destination))
	end
end

function M.remove(path)
	if M.path_exists(path) then
		print("Removing " .. path)
		os.execute(string.format('rm -r "%s"', path))
	end
end

return M
