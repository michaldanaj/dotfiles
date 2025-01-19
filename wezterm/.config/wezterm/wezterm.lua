-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.font = wezterm.font("MesloLGS NF")
--config.font = wezterm.font 'JetBrains Mono'
--config.font = wezterm.font 'SauceCodePro Nerd Font Propo'

--config.color_scheme = 'Catppuccin Mocha'
--config.color_scheme = "Chalk (Gogh)"
--config.color_scheme = 'AdventureTime'
config.color_scheme = "Tokyo Night"

config.window_background_opacity = 0.95

local act = wezterm.action

--   domyślne przydatne skróty   ---
-- ctrl + shift + z - przełącza pane na pełen ekran
--
config.keys = {
	-- { key = 't', mods = 'ALT', action = wezterm.action.ShowTabNavigator },
	{
		key = "|",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "_",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "w",
		mods = "CTRL",
		action = wezterm.action.CloseCurrentPane({ confirm = true }),
	},
	{
		key = "W",
		mods = "CTRL|SHIFT",
		action = wezterm.action.CloseCurrentPane({ confirm = true }),
	},
	{ key = "t", mods = "CTRL", action = act.SpawnTab("DefaultDomain") },
	-- Create a new tab in the default domain
	{ key = "T", mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "l", mods = "ALT", action = wezterm.action.ShowLauncher },
	-- Aby w wezterm było takie przewijanie strony jak w vim, czyli ctrl+f,
	-- ctrl+b, ale równocześnie klawisze były przekazane do vim gdy jest
	-- uruchomiony, potrzebna jest taka jak poniżej konstrukcja
	{
		key = "f",
		mods = "CTRL",
		action = wezterm.action_callback(function(win, pane)
			print(pane:is_alt_screen_active())
			if pane:is_alt_screen_active() then
				win:perform_action(wezterm.action.SendKey({ key = "f", mods = "CTRL" }), pane)
			else
				win:perform_action(wezterm.action.ScrollByPage(1), pane)
			end
		end),
	},
	{
		key = "b",
		mods = "CTRL",
		action = wezterm.action_callback(function(win, pane)
			print(pane:is_alt_screen_active())
			if pane:is_alt_screen_active() then
				win:perform_action(wezterm.action.SendKey({ key = "b", mods = "CTRL" }), pane)
			else
				win:perform_action(wezterm.action.ScrollByPage(-1), pane)
			end
		end),
	},
	-- { key = 'b', mods = 'CTRL', action = act.ScrollByPage(-1) },
	--{ key = 'b', mods = 'CTRL', action = test{key='b', mods='CTRL', action=wezterm.action.ScrollByPage(-1)} },
	--{ key = 'f', mods = 'CTRL', action = act.ScrollByPage(1) },
	{ key = "h", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Left") },
	{ key = "l", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Right") },
	{ key = "k", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Up") },
	{ key = "j", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Down") },
}

-- Spawn a fish shell in login mode
-- config.default_prog = {"C:\\Program Files\\Git\\bin\\bash.exe", '-l' }

-- and finally, return the configuration to wezterm
return config
