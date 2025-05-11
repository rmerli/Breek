local success, config = pcall(require, "config")

if not success then
	error("Configuration file is missing, please create a config.lua next to breek ")
end

if type(config) ~= "table" then
	error("Invalid configuration, config.lua needs to return a table")
end

local commands = require("commands")
commands.config = config

local argparse = require("argparse")
local parser = argparse("breek", "An example CLI tool.")

-- CLI definition
parser:argument("command", "Command to run [install, remove, configure]")
parser:argument("package", "{package name} or all")
parser:flag("-d --dry", "show actions without executing them")

local args = parser:parse()

if args.command == "install" then
	if args.package == "all" then
		commands.install_all(args)
	else
		commands.install(args.package, args.dry)
	end
elseif args.command == "remove" then
	if args.package == "all" then
		commands.remove_all(args)
	else
		commands.remove_pkg(args.package, args.dry)
	end
elseif args.command == "configure" then
	if args.package == "all" then
		commands.configure_all(args)
	else
		commands.configure(args.package, args.dry)
	end
else
	print("Error: commands [install, remove, configure]")
end
