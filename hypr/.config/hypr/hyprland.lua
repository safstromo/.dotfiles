-- Hyprland Lua config (migrated from hyprland.conf for Hyprland 0.55.x).
--
-- Reference: https://wiki.hypr.land/Configuring/Start/
-- Example config this is modeled on:
--   https://github.com/hyprwm/Hyprland/blob/main/example/hyprland.lua
--
-- You can split this across files and pull them in with require(), e.g.:
--   require("myColors")   -- ~/.config/hypr/myColors.lua


------------------
---- MONITORS ----
------------------
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/

-- Fallback rule for any unspecified monitor: highest resolution, at 0x0, scale 1.
hl.monitor({ output = "", mode = "highres", position = "0x0", scale = 1 })

-- Laptop display
hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x1440", scale = 2 })


---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "ghostty"
local browser     = "google-chrome-stable"
local fileManager = "ghostty -e yazi"
local menu        = "rofi -show drun"


-------------------
---- AUTOSTART ----
-------------------
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
-- hl.on("hyprland.start", ...) runs these ONCE at launch, not on every reload.

hl.on("hyprland.start", function()
  hl.exec_cmd("wayle panel start & hyprpaper & dunst")
  hl.exec_cmd("systemctl --user start hyprpolkitagent")
  hl.exec_cmd("wl-paste --type text --watch cliphist store")  -- store text
  hl.exec_cmd("wl-paste --type image --watch cliphist store") -- store images
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
-- For usb dock issues
hl.env("AQ_NO_MODIFIERS", "1")
-- Export GTK input method to fix dead keys in Wayland/GTK4 apps
hl.env("GTK_IM_MODULE", "simple")


-----------------------
---- LOOK AND FEEL ----
-----------------------
-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/

hl.config({
  general = {
    gaps_in          = 2,
    gaps_out         = 2,
    border_size      = 1,
    col              = {
      active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
      inactive_border = "rgba(595959aa)",
    },
    -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
    resize_on_border = false,
    -- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before turning this on
    allow_tearing    = false,
    layout           = "dwindle",
  },

  decoration = {
    rounding         = 10,
    -- Change transparency of focused and unfocused windows
    active_opacity   = 1.0,
    inactive_opacity = 1.0,
    shadow           = {
      enabled      = true,
      range        = 4,
      render_power = 3,
      color        = 0xee1a1a1a, -- rgba(1a1a1aee)
    },
    blur             = {
      enabled  = true,
      size     = 3,
      passes   = 1,
      vibrancy = 0.1696,
    },
  },
  animations = {
    enabled = true,
  },
})

-- Bezier curves. See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })

-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- "Smart gaps" / "No gaps when only". Uncomment all if you want them.
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({ name = "no-gaps-wtv1", match = { float = false, workspace = "w[tv1]" }, border_size = 0, rounding = 0 })
-- hl.window_rule({ name = "no-gaps-f1",   match = { float = false, workspace = "f[1]" },   border_size = 0, rounding = 0 })

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
-- NOTE: dwindle.pseudotile was removed in 0.55; pseudotiling is toggled per-window
-- via the `pseudo` dispatcher (bound to SUPER + P below).
hl.config({
  dwindle = {
    preserve_split = true, -- You probably want this
  },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
  master = {
    new_status = "master",
  },
})


----------------
----  MISC  ----
----------------

hl.config({
  misc = {
    force_default_wallpaper = 0,    -- Set to 0 or 1 to disable the anime mascot wallpapers
    focus_on_activate       = true,
    disable_hyprland_logo   = true, -- If true disables the random hyprland logo / anime girl background. :(
  },
})


---------------
---- INPUT ----
---------------

hl.config({
  input = {
    kb_layout    = "us",
    kb_variant   = "altgr-intl",
    kb_model     = "",
    kb_options   = "ctrl:nocaps",
    kb_rules     = "",
    -- To add a second (colemak_dh) layout toggled with alt+shift, use e.g.:
    --   kb_layout  = "us,us",
    --   kb_variant = "altgr-intl,colemak_dh",
    --   kb_options = "ctrl:nocaps,grp:alt_shift_toggle",
    follow_mouse = 2,
    sensitivity  = 0, -- -1.0 - 1.0, 0 means no modification.
    touchpad     = {
      natural_scroll = false,
    },
  },
})

-- Workspace swipe gesture (was commented out / disabled in the original):
-- hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({ name = "epic-mouse-v1", sensitivity = -0.5 })

hl.device({
  name       = "bastard-keyboards-charybdis-nano-(3x5)-splinky",
  kb_layout  = "us",
  kb_variant = "intl",
  kb_options = "",
})

hl.device({
  name       = "bastard-keyboards-skeletyl-elite-c",
  kb_layout  = "us",
  kb_variant = "intl",
  kb_options = "",
})


---------------------
---- KEYBINDINGS ----
---------------------
-- See https://wiki.hypr.land/Configuring/Basics/Binds/ for more

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
-- Open browser on workspace 3 silently, without an open animation
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser, { workspace = "3 silent", no_anim = true }))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + escape", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + M", hl.dsp.exit()) -- quit Hyprland (hyprshutdown is recommended if you use uwsm)
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + U", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + S", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + slash", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())       -- dwindle
hl.bind(mainMod .. " + o", hl.dsp.layout("togglesplit")) -- dwindle
-- NOTE: SUPER + J is also bound to "move focus down" further below. Because both
-- exist, the later bind (move focus) wins. Rename one if you want both to work.

hl.bind(mainMod .. " + W",
  hl.dsp.exec_cmd([[rofi -dmenu -p "Websearch ->" | xargs -I{} xdg-open https://google.com/search?q={}]]))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("/home/eox/.dotfiles/hypr/.config/hypr/random-wallpaper.sh"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd([[cliphist list | rofi -dmenu | cliphist decode | wl-copy]]))

-- Toggle the built-in laptop keyboard on/off.
-- NOTE: these call `hyprctl keyword` at runtime. If that no longer behaves under a
-- pure Lua config, the Lua-native alternatives are `hyprctl eval '...'` or hl.device.
hl.bind(mainMod .. " + SHIFT + Y",
  hl.dsp.exec_cmd(
    [[hyprctl keyword "device[at-translated-set-2-keyboard]:enabled" false && notify-send "Laptop keyboard off"]]))
hl.bind(mainMod .. " + Y",
  hl.dsp.exec_cmd(
    [[hyprctl keyword "device[at-translated-set-2-keyboard]:enabled" true && notify-send "Laptop keyboard on"]]))

-- Move focus with mainMod + h/l/k/j
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]  (key 0 -> workspace 10)
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
  local key = i % 10 -- 10 maps to key 0
  hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
-- hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
-- hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Resize active window with SUPER + CTRL + h/l/k/j
hl.bind(mainMod .. " + CTRL + L", hl.dsp.window.resize({ x = 30, y = 0, relative = true }))
hl.bind(mainMod .. " + CTRL + H", hl.dsp.window.resize({ x = -30, y = 0, relative = true }))
hl.bind(mainMod .. " + CTRL + K", hl.dsp.window.resize({ x = 0, y = -30, relative = true }))
hl.bind(mainMod .. " + CTRL + J", hl.dsp.window.resize({ x = 0, y = 30, relative = true }))

-- Swap active window with SUPER + SHIFT + h/l/k/j
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.swap({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.swap({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.swap({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.swap({ direction = "d" }))

-- Laptop multimedia keys for volume and LCD brightness (locked + repeating)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),
  { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
  { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
  { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), { locked = true, repeating = true })

-- Requires playerctl (locked)
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Screenshot
hl.bind("Print",
  hl.dsp.exec_cmd([[grim -g "$(slurp -d)" - | tee ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png | wl-copy]]))

-- Laptop lid switch: disable eDP-1 when closed, re-enable when opened.
-- switch:on = lid closed, switch:off = lid open.
-- hl.bind("switch:on:Lid Switch", function()
--   hl.monitor({ output = "eDP-1", disabled = true })
-- end, { locked = true })
-- hl.bind("switch:off:Lid Switch", function()
--   -- 1. Re-enable the monitor with specific settings
--   hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x1440", scale = 1, disabled = false })
-- end, { locked = true })
--
-- Laptop lid switch. Logic lives in lid.sh:
--  - close: disable eDP-1 only in clamshell (external monitor present);
--           undocked, logind suspends and lid.sh does nothing.
--  - open:  re-enable eDP-1.
-- Resume-from-suspend is handled by hypridle's after_sleep_cmd (lid.sh resume),
-- which fires on logind's resume signal AFTER the DRM backend is awake,
-- avoiding the switch:off race (see hyprwm/Hyprland#3403).
local lidScript = "/home/eox/.dotfiles/hypr/.config/hypr/lid.sh"

hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd(lidScript .. " close"), { locked = true })
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd(lidScript .. " open"), { locked = true })
--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- Disable animations for IntelliJ IDEA
hl.window_rule({
  name    = "no-anim-intellij",
  match   = { class = "^(jetbrains-idea)$" },
  no_anim = true,
})

-- Run impala in a centered float (from waybar)
hl.window_rule({
  name   = "float-impala",
  match  = { class = "impala-floating" },
  float  = true,
  size   = { 800, 500 },
  center = true,
})

-- Ignore maximize requests from all apps. You'll probably like this.
hl.window_rule({
  name           = "suppress-maximize-events",
  match          = { class = ".*" },
  suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
  name     = "fix-xwayland-drags",
  match    = {
    class      = "^$",
    title      = "^$",
    xwayland   = true,
    float      = true,
    fullscreen = false,
    pin        = false,
  },
  no_focus = true,
})
