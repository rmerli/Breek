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

function M.strip_trailing_slash(path)
	return (path:gsub("(.)/+$", "%1"))
end

-- true for a symlink itself, also when its target is missing
function M.is_link(path)
	return lfs.symlinkattributes(M.strip_trailing_slash(path), "mode") == "link"
end

function M.absolute(path)
	if path:sub(1, 1) == "/" then
		return path
	end
	return lfs.currentdir() .. "/" .. path:gsub("^%./", "")
end

function M.remove(path)
	-- never `rm -r` a symlink: with a trailing slash that deletes the target's contents
	if M.is_link(path) then
		print("Removing link " .. path)
		os.remove(M.strip_trailing_slash(path))
	elseif M.path_exists(path) then
		print("Removing " .. path)
		os.execute(string.format('rm -r "%s"', path))
	end
end

function M.link(source, destination, dry)
	local src = M.strip_trailing_slash(M.absolute(source))
	local dst = M.strip_trailing_slash(destination)

	if M.is_link(dst) then
		if lfs.symlinkattributes(dst, "target") == src then
			print("Already linked " .. dst)
			return
		end
		print("Removing link " .. dst)
		if not dry then
			os.remove(dst)
		end
	elseif M.path_exists(dst) then
		local backup = dst .. ".bak." .. os.date("%Y%m%d%H%M%S")
		print(("Backing up %s to %s"):format(dst, backup))
		if not dry then
			os.rename(dst, backup)
		end
	end

	print(("Linking %s to %s"):format(dst, src))
	if not dry then
		local parent = dst:match("^(.*)/[^/]+$")
		if parent and parent ~= "" then
			os.execute(string.format('mkdir -p "%s"', parent))
		end
		os.execute(string.format('ln -s "%s" "%s"', src, dst))
	end
end

return M
