-- ~/.config/hypr/hosts/laptop.lua
-- Laptop layout: built-in panel + external HDMI monitor.
-- Loaded by monitors.lua when this file is named after the machine's
-- hostname (`hostname`); rename it to hosts/<hostname>.lua on the laptop.

local main   = "eDP-1"
local second = "HDMI-A-1"
-- To match the external monitor regardless of port, set second to its
-- description instead: "desc:<from `hyprctl monitors all`>"

hl.monitor({ output = main,   mode = "1920x1080@120", position = "0x0",    scale = 1.5 })
hl.monitor({ output = second, mode = "1920x1080@60",  position = "1280x0", scale = 1 })

-- Laptop: 1-5, external monitor: 6-10. Persistent so waybar always shows them.
for i = 1, 10 do
    hl.workspace_rule({
        workspace  = tostring(i),
        monitor    = i <= 5 and main or second,
        default    = (i == 1 or i == 6),
        persistent = true,
    })
end
