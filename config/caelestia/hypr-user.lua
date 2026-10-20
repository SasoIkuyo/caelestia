-- Portrait display on the left; main display unchanged.
-- US physical keyboard with Spanish characters on right Alt.
hl.config({ input = { kb_layout = "us", kb_variant = "altgr-intl" } })

-- Super+D uses the default communication workspace toggle (Discord).

hl.monitor({
    output = "desc:HKM DP 0000000000001",
    mode = "1920x1080@165.00Hz",
    position = "-1080x0",
    scale = 1,
    transform = 3,
})

-- One tiled window with a stable internal terminal dashboard.
-- Keep recognized games on the Odyssey, regardless of the focused monitor.
hl.window_rule({
    match = { tag = "game" },
    monitor = "DP-4",
    no_anim = true,
    no_blur = true,
    no_shadow = true,
})

hl.window_rule({
    match = { class = "^unixporn-board$" },
    monitor = "DP-5",
    workspace = "2 silent",
    float = false,
})

-- Open Discord and Steam on their usual workspaces without stealing focus.
-- These user rules override the default special workspace for Discord.
hl.window_rule({
    match = { class = "^discord$" },
    workspace = "3 silent",
})
hl.window_rule({
    match = { class = "^steam$" },
    workspace = "4 silent",
})

hl.on("hyprland.start", function()
    hl.exec_cmd("~/.local/bin/aura --daemon")
    hl.exec_cmd("systemctl --user restart game-wallpaper-pause.service")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_RUNTIME_DIR && systemctl --user restart lock-recovery.service && systemctl --user start app-dev.lizardbyte.app.Sunshine.service")
    hl.exec_cmd("bash ~/.config/unix-dashboard/start.sh")
    hl.exec_cmd("flatpak run com.discordapp.Discord")
    hl.exec_cmd("flatpak run com.valvesoftware.Steam")
end)

-- Center archive extraction and password dialogs on the main screen.
hl.window_rule({
    match = { class = "^org.gnome.FileRoller$", float = true },
    monitor = "DP-4",
    center = true,
})
