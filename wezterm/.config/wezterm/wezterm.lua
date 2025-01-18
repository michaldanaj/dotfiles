-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
--config.color_scheme = 'AdventureTime'
--config.font = wezterm.font 'JetBrains Mono'
--config.font = wezterm.font 'SauceCodePro Nerd Font Propo'
--config.color_scheme = 'Catppuccin Mocha'
config.color_scheme = 'Chalk (Gogh)'

config.window_background_opacity = 0.95

local act = wezterm.action

--   domyślne przydatne skróty   ---
-- ctrl + shift + z - przełącza pane na pełen ekran
--
config.keys = {
    -- { key = 't', mods = 'ALT', action = wezterm.action.ShowTabNavigator },
    {
        key = '|',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.SplitHorizontal
            { domain = 'CurrentPaneDomain' },
    },
    {
        key = '_',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.SplitVertical
            { domain = 'CurrentPaneDomain' },
    },
    {
        key = 'w',
        mods = 'CTRL',
        action = wezterm.action.CloseCurrentPane
            { confirm = true },
    },
    {
        key = 'W',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.CloseCurrentPane
            { confirm = true },
    },
    { key = 't', mods = 'CTRL',       action = act.SpawnTab 'DefaultDomain', },
    -- Create a new tab in the default domain
    { key = 'T', mods = 'CTRL|SHIFT', action = act.SpawnTab 'CurrentPaneDomain' },
    { key = 'l', mods = 'ALT',        action = wezterm.action.ShowLauncher },
    -- Aby w wezterm było takie przewijanie strony jak w vim, czyli ctrl+f,
    -- ctrl+b, ale równocześnie klawisze były przekazane do vim gdy jest
    -- uruchomiony, potrzebna jest taka jak poniżej konstrukcja
    {
        key = 'f',
        mods = 'CTRL',
        action = wezterm.action_callback(function(win, pane)
            print(pane:is_alt_screen_active())
            if pane:is_alt_screen_active() then
                win:perform_action(wezterm.action.SendKey { key = 'f', mods = 'CTRL' }, pane)
            else
                win:perform_action(wezterm.action.ScrollByPage(1), pane)
            end
        end)
    },
    {
        key = 'b',
        mods = 'CTRL',
        action = wezterm.action_callback(function(win, pane)
            print(pane:is_alt_screen_active())
            if pane:is_alt_screen_active() then
                win:perform_action(wezterm.action.SendKey { key = 'b', mods = 'CTRL' }, pane)
            else
                win:perform_action(wezterm.action.ScrollByPage(-1), pane)
            end
        end)
    },
    -- { key = 'b', mods = 'CTRL', action = act.ScrollByPage(-1) },
    --{ key = 'b', mods = 'CTRL', action = test{key='b', mods='CTRL', action=wezterm.action.ScrollByPage(-1)} },
    --{ key = 'f', mods = 'CTRL', action = act.ScrollByPage(1) },
    { key = 'h', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Left', },
    { key = 'l', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Right', },
    { key = 'k', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Up', },
    { key = 'j', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Down', },
}

-- Spawn a fish shell in login mode
-- config.default_prog = {"C:\\Program Files\\Git\\bin\\bash.exe", '-l' }

wezterm.on('update-right-status', function(window, pane)
    -- Each element holds the text for a cell in a "powerline" style << fade
    local cells = {}

    -- Figure out the cwd and host of the current pane.
    -- This will pick up the hostname for the remote host if your
    -- shell is using OSC 7 on the remote host.
    local cwd_uri = pane:get_current_working_dir()
    if cwd_uri then
        local cwd = ''
        local hostname = ''

        if type(cwd_uri) == 'userdata' then
            -- Running on a newer version of wezterm and we have
            -- a URL object here, making this simple!

            cwd = cwd_uri.file_path
            hostname = cwd_uri.host or wezterm.hostname()
        else
            -- an older version of wezterm, 20230712-072601-f4abf8fd or earlier,
            -- which doesn't have the Url object
            cwd_uri = cwd_uri:sub(8)
            local slash = cwd_uri:find '/'
            if slash then
                hostname = cwd_uri:sub(1, slash - 1)
                -- and extract the cwd from the uri, decoding %-encoding
                cwd = cwd_uri:sub(slash):gsub('%%(%x%x)', function(hex)
                    return string.char(tonumber(hex, 16))
                end)
            end
        end

        -- Remove the domain name portion of the hostname
        local dot = hostname:find '[.]'
        if dot then
            hostname = hostname:sub(1, dot - 1)
        end
        if hostname == '' then
            hostname = wezterm.hostname()
        end

        table.insert(cells, cwd)
        table.insert(cells, hostname)
    end

    -- I like my date/time in this style: "Wed Mar 3 08:14"
    local date = wezterm.strftime '%a %b %-d %H:%M'
    table.insert(cells, date)

    -- An entry for each battery (typically 0 or 1 battery)
    for _, b in ipairs(wezterm.battery_info()) do
        table.insert(cells, string.format('%.0f%%', b.state_of_charge * 100))
    end

    -- The powerline < symbol
    local LEFT_ARROW = utf8.char(0xe0b3)
    -- The filled in variant of the < symbol
    local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

    -- Color palette for the backgrounds of each cell
    local colors = {
        '#3c1361',
        '#52307c',
        '#663a82',
        '#7c5295',
        '#b491c8',
    }

    -- Foreground color for the text across the fade
    local text_fg = '#c0c0c0'

    -- The elements to be formatted
    local elements = {}
    -- How many cells have been formatted
    local num_cells = 0

    -- Translate a cell into elements
    function push(text, is_last)
        local cell_no = num_cells + 1
        table.insert(elements, { Foreground = { Color = text_fg } })
        table.insert(elements, { Background = { Color = colors[cell_no] } })
        table.insert(elements, { Text = ' ' .. text .. ' ' })
        if not is_last then
            table.insert(elements, { Foreground = { Color = colors[cell_no + 1] } })
            table.insert(elements, { Text = SOLID_LEFT_ARROW })
        end
        num_cells = num_cells + 1
    end

    while #cells > 0 do
        local cell = table.remove(cells, 1)
        push(cell, #cells == 0)
    end

    window:set_right_status(wezterm.format(elements))
end)

-- and finally, return the configuration to wezterm
return config
