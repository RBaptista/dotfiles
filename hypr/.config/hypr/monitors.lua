-- ~/.config/hypr/monitors.lua
-- Generic monitor setup, plus an optional per-machine layout in
-- hosts/<hostname>.lua (monitors and the workspace rules that pin
-- workspaces to them). Machines without a host file just auto-detect.

-- Failsafe: any monitor not named by a host file gets a sane default
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

local function read_line(path)
    local f = io.open(path)
    if not f then return nil end
    local line = f:read("*l")
    f:close()
    return line
end

local host = (read_line("/etc/hostname") or ""):match("^%s*(.-)%s*$")
local config_home = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")
local host_file = config_home .. "/hypr/hosts/" .. host .. ".lua"

if host ~= "" and read_line(host_file) then
    require("hosts/" .. host)
end
