-- Managed by chezmoi

-- Pull in the wezterm API
local wezterm = require 'wezterm'
-- Pull in the action API for more concise keybindings
local act = wezterm.action

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which allows for
-- more fine-grained control over overrides. This is a future-proof way
-- to declare your config.
if wezterm.config_builder then
  config = wezterm.config_builder()
end

--====================================================================--
-- Aesthetics
--====================================================================--
config.color_scheme = 'Catppuccin Mocha'
config.font_size = 16.0

-- Use wezterm.font_with_fallback to ensure icons from your Nerd Font render correctly.
-- It will try fonts in order until it finds one that can render a given character.
config.font = wezterm.font_with_fallback({
  -- Primary font for code and text
  'JetBrains Mono',
  -- Fallback for icons, symbols, etc. You installed this in your Brewfile.
  'Symbols Nerd Font Mono',
})

-- For a clean, minimal look. The window can still be resized from the edges.
config.window_decorations = 'RESIZE'

-- Opacity and Blur settings
config.window_background_opacity = 1.0 -- Fully opaque for better readability
config.macos_window_background_blur = 30


--====================================================================--
-- Functionality
--====================================================================--
-- Disable the default tab bar. We'll use keybindings for tab/pane management.
config.enable_tab_bar = false

-- Keep the shell status updated
config.status_update_interval = 1000


--====================================================================--
-- Keybindings
--====================================================================--
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
  -- Send "CTRL-a" to the terminal when pressed twice
  { key = 'a', mods = 'LEADER|CTRL', action = act.SendString '\x01' },

  -- Pane Splitting
  { key = '"', mods = 'LEADER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '%', mods = 'LEADER', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },

  -- Pane Navigation
  { key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
  { key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },
  { key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
  { key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
  { key = 'x', mods = 'LEADER', action = act.CloseCurrentPane { confirm = true } },

  -- Tab Management
  { key = 'c', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'n', mods = 'LEADER', action = act.ActivateTabRelative(1) },
  { key = 'p', mods = 'LEADER', action = act.ActivateTabRelative(-1) },
  { key = 'q', mods = 'LEADER', action = act.CloseCurrentTab { confirm = true } },

  -- [!] Hot-Reload Configuration
  {
    key = 'r',
    mods = 'LEADER',
    action = wezterm.action_callback(function(window, pane)
      wezterm.reload_configuration()
      window:toast_notification('WezTerm', 'Configuration Reloaded!', nil, 3000)
    end),
  },

  { key = 'f', mods = 'CTRL', action = act.ToggleFullScreen },
  { key = '\'', mods = 'CTRL', action = act.ClearScrollback 'ScrollbackAndViewport' },
}


--====================================================================--
-- Mouse Bindings
--====================================================================--
config.mouse_bindings = {
  -- Ctrl-click will open the link under the mouse cursor
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = wezterm.action.OpenLinkAtMouseCursor,
  },
}


return config
