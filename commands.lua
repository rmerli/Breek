local fs = require("fs")

local M = {
	config = {},
}

-- Config validation
local function validate_package(pkg_name)
	if M.config.packages[pkg_name] == nil then
		print(" -> Error: package " .. pkg_name .. " does not exist; check config.lua")
		return false
	end
	return true
end

local function is_valid_field(tbl, field)
	if tbl[field] == nil then
		print(" -> Error: Invalid field: " .. field)
		return false
	end
	return true
end

function M.install(pkg_name, dry)
	local cmd_name = "install"
	print("- Installing " .. pkg_name)

	if not validate_package(pkg_name) then
		return
	end
	local pkg = M.config.packages[pkg_name]

	if not is_valid_field(pkg, cmd_name) then
		print("Error: package config does not have command: " .. cmd_name)
		return
	end

	for _, cmd in ipairs(pkg[cmd_name].commands) do
		if dry then
			print("dry run executing -> " .. cmd)
		else
			print(cmd)
			os.execute(cmd)
		end
	end
end

local function loop_packages(callable)
	for _, name in ipairs(M.config.order) do
		callable(name)
	end
end

function M.install_all(args)
	print("Installing all packages\n")

	loop_packages(function(name)
		M.install(name, args.dry)
		print()
	end)
end

function M.configure(pkg_name, dry)
	local cmd_name = "configure"
	print("-> Configuring " .. pkg_name)

	if not validate_package(pkg_name) then
		return
	end
	local pkg = M.config.packages[pkg_name]

	if not is_valid_field(pkg, cmd_name) then
		print("Error: package config does not have command: " .. cmd_name)
		return
	end

	for _, pkg_cfg in ipairs(pkg[cmd_name]) do
		if not is_valid_field(pkg_cfg, "source") or not is_valid_field(pkg_cfg, "destination") then
			return
		end

		local src = fs.expand_tilde(pkg_cfg.source)
		local dst = fs.expand_tilde(pkg_cfg.destination)

		if not fs.path_exists(src) then
			print("Error: source does not exist: " .. src)
			return
		end

		if dry then
			print("Removing " .. dst)
			print("Copying " .. src .. " to " .. dst)
		else
			if fs.path_exists(dst) and fs.file_type(src) == fs.file_type(dst) then
				fs.remove(dst)
			end
			if fs.path_exists(dst) and fs.is_file(dst) and fs.is_dir(src) then
				print("Error: destination exists as file but source is directory: " .. dst)
				return
			end
			fs.copy(src, dst)
		end
	end
end

function M.configure_all(args)
	print("Configuring all packages...\n")

	loop_packages(function(name)
		M.configure(name, args.dry)
		print()
	end)
end

function M.remove_pkg(pkg_name, dry)
	local cmd_name = "remove"
	print("- Removing " .. pkg_name)

	if not validate_package(pkg_name) then
		return
	end
	local pkg = M.config.packages[pkg_name]

	if not is_valid_field(pkg, cmd_name) then
		print("Error: package config does not have command: " .. cmd_name)
		return
	end

	for _, cmd in ipairs(pkg[cmd_name].commands) do
		if dry then
			print("dry run executing -> " .. cmd)
		else
			os.execute(cmd)
		end
	end
end

function M.remove_all(args)
	print("Removing all packages\n")
	loop_packages(function(name)
		M.remove_pkg(name, args.dry)
		print()
	end)
end

return M
