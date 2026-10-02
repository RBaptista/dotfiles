-- ~/.config/hypr/autostart.lua
-- Runs once at startup (was exec-once). Top-level hl.exec_cmd() calls would
-- instead run on every reload.

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprpaper -c ~/.config/hypr/hyprpaper.conf")
    hl.exec_cmd("mako")
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
    hl.exec_cmd("hypridle")
end)
