-- example config

local order = {
	"wezterm",
	"neovim",
	"tmux",
}

local packages = {
	wezterm = {
		configure = {
			{
				source = "./wezterm",
				destination = "~/.config/wezterm/",
			},
		},
		install = {
			commands = { "yay -S wezterm-git --noconfirm --answerclean=None --answerdiff=None --answeredit=None" },
		},
		remove = {
			commands = {
				"yay -R wezterm-git ",
			},
		},
	},
	tmux = {
		configure = {
			{
				source = "tmux",
				destination = "~/.config/tmux/",
			},
		},
		install = {
			commands = { "sudo pacman -S tmux --noconfirm --needed" },
		},
		remove = {
			commands = {
				"sudo pacman -R tmux",
				"rm -r ~/.config/tmux/",
			},
		},
	},
	neovim = {
		configure = {
			{
				source = "neovim/nvim",
				destination = "~/.config/nvim/",
			},
		},
		install = {
			commands = { "./neovim/install.sh" },
		},
		remove = {
			commands = {
				"rm ~/.local/bin/nvim",
				"rm -r ~/.config/nvim/",
			},
		},
	},
}

return {
	order = order,
	packages = packages,
}
