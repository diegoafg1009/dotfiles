-- Window rules wiki https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- Generic floating position
hl.window_rule({ match = { float = true }, center = true, persistent_size = true })

-- Picture-in-Picture
hl.window_rule({
    match             = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
    float             = true,
    keep_aspect_ratio = true,
    size              = { "max(monitor_w, monitor_h)*0.25", "min(monitor_w, monitor_h)*0.25" },
    pin               = true,
})

-- Gaming
local gamingApps = "^(steam_app.*|gamescope)$"
local gamingWorkspace = "name:gaming"

hl.window_rule({ match = { content = "game" }, workspace = gamingWorkspace })
hl.window_rule({
    match = { xdg_tag = "^(.*game.*)$" },
    workspace = gamingWorkspace,
    fullscreen_state = 2,
    content =
    "game",
    sync_fullscreen = true
})
hl.window_rule({ match = { class = gamingApps }, workspace = gamingWorkspace })
hl.window_rule({ match = { class = "^(steam)$", title = "^(Friends List)$" }, float = true })
hl.window_rule({
    match = { class = "^(steam)$", title = "^(Launching\\.{3})$" },
    float = true,
    center = true,
    workspace =
        gamingWorkspace
})
hl.window_rule({
    match            = {
        class         = gamingApps,
        title         = "^(.+)$",
        initial_title = "negative:^(.*\\\\home\\\\.*)$",
    },
    content          = "game",
    decorate         = false,
    fullscreen_state = 2,
    size             = { "monitor_w", "monitor_h" },
    sync_fullscreen  = true,
})
hl.window_rule({
    match            = {
        class         = "^(steam_app.*)$",
        initial_title = "^$",
    },
    center           = true,
    float            = true,
    fullscreen       = false,
    fullscreen_state = 0,
    workspace        = gamingWorkspace,
})

-- Apps
hl.window_rule({ match = { class = "^(.*\\.exe)$", float = true }, monitor = PRIMARY_MONITOR, center = true, fullscreen_state = 0 })
hl.window_rule({ match = { class = "^(.*[Ll]auncher.*)$" }, float = true, monitor = PRIMARY_MONITOR })
hl.window_rule({ match = { class = "^(vesktop|discord)$" }, monitor = PRIMARY_MONITOR })
hl.window_rule({ match = { class = "^(.*[Cc]alc.*)$" }, float = true, size = { "max(monitor_w, monitor_h)*0.17", "min(monitor_w, monitor_h)*0.43" } })
hl.window_rule({ match = { class = "^(org\\.kde\\.keditfiletype)$" }, float = true })
hl.window_rule({ match = { class = "^(org\\.kde\\.ark)$" }, size = { "max(monitor_w, monitor_h)*0.40", "min(monitor_w, monitor_h)*0.40" } })
hl.window_rule({ match = { class = "^(.*satty.*)$", title = "^(Satty)$" }, min_size = { "max(monitor_w, monitor_h)*0.35", "min(monitor_w, monitor_h)*0.35" }, float = true })
hl.window_rule({ match = { class = "^(dev\\.)?(noctalia\\.Noctalia(\\.Settings)?)$" }, float = true, size = { "monitor_w*0.70", "monitor_h*0.70" } })
hl.window_rule({
    match = {
        class = "^(org\\.kde\\.dolphin)$",
        title =
        "negative:^(Moving.*|Create New.*|Extract.*|Compress.*|Copying.*|Progress.*|Configure.*|Properties.*|Choose\\sApplication.*)$",
    },
    float = true,
    size = { "max(monitor_w, monitor_h)*0.50", "min(monitor_w, monitor_h)*0.55" },
    move = {
        "max(20, min(cursor_x - (window_w*0.50), monitor_w - window_w + 20))", -- X axis clamping
        "max(20, min(cursor_y - 50, monitor_h - window_h + 20))"               -- Y axis clamping
    },
})
hl.window_rule({
    match = { class = "1password" },
    float = true,
    size = { "monitor_w*0.40", "monitor_h*0.40" },
    center = true,
})
hl.window_rule({
    match = { class = "cider" },
    float = true,
    size = { "monitor_w*0.70", "monitor_h*0.70" },
    center = true,
    render_unfocused = true,
})
hl.window_rule({
    name = "cider-miniplayer",
    match = {
        class = "^cider$",
        initial_title = "^Cider - Mini Player$",
    },
    float = true,
    size = { "352", "352" },
    move = {
        "monitor_w-window_w-20",
        "monitor_h-window_h-10",
    },
    no_initial_focus = true,
})
-- Cider miniplayer fix for hyprland
local cider_original_workspace = nil
local cider_main_window = nil

local function is_cider_main(window)
    return window
        and window.class == "cider"
        and window.initial_title == "Cider"
end

local function is_cider_miniplayer(window)
    return window
        and window.class == "cider"
        and window.initial_title == "Cider - Mini Player"
end

-- When the MiniPlayer opens:
-- save the main Cider window's workspace and hide it.
hl.on("window.open", function(window)
    if not is_cider_miniplayer(window) then
        return
    end

    local cider_windows = hl.get_windows({ class = "cider" })

    for _, cider_window in ipairs(cider_windows) do
        if is_cider_main(cider_window) then
            cider_main_window = cider_window
            cider_original_workspace = cider_window.workspace

            hl.dispatch(hl.dsp.window.move({
                workspace = "special:cider-hidden",
                window = cider_window,
                follow = false,
            }))

            break
        end
    end
end)

-- When the MiniPlayer is destroyed:
-- restore the main Cider window to its original workspace.
hl.on("window.close", function(window)
    if not is_cider_miniplayer(window) then
        return
    end

    if cider_main_window and cider_original_workspace then
        hl.dispatch(hl.dsp.window.move({
            workspace = cider_original_workspace,
            window = cider_main_window,
            follow = false,
        }))

        hl.dispatch(hl.dsp.focus({
            window = cider_main_window,
        }))
    end

    cider_main_window = nil
    cider_original_workspace = nil
end)

--

-- Opacity Overrides
local terminals = "^(kitty|ghostty|[Kk]onsole|Alacritty|gnome-terminal|xfce[0-9]?-terminal)$"

hl.window_rule({ match = { class = "^(firefox|zen)$" }, opacity = "1.0 override" })
hl.window_rule({ match = { class = terminals }, opacity = "1.0 override" }) -- Override opacity in favor of terminal settings for opacity. If your terminal doesn't support transparency, you can remove this rule.
hl.window_rule({
    match = { class = "^(mpv|org.kde.haruna|.*plex.*|org\\.kde\\.gwenview|.*vlc.*)$" },
    opacity =
    "1.0 override"
})

-- Float Utility Windows
local floatApps = {
    { class = "^(kvantummanager|qt[56]ct|nwg-look)$" },
    { class = "^(org.pulseaudio.pavucontrol|blueman-manager|nm-applet|nm-connection-editor)$" },
    { title = "^(Winetricks.*|Protontricks.*)$" },
}
for _, m in ipairs(floatApps) do hl.window_rule({ match = m, float = true }) end

-- Float Common Modals
local modalMatches = {
    { title = "^(Open|Authentication Required|Add Folder to Workspace|Choose Files|Save As|Confirm to replace files|File Operation Progress)$" },
    { initial_title = "^(Open File)$" },
    { class = "^([Xx]dg-desktop-portal-gtk)$" },
    { title = "^(File Upload|Choose wallpaper|Library)(.*)$" },
    { class = "^(.*dialog.*)$" },
    { title = "^(.*dialog.*)$" },
    { class = "^(hyprland-share-picker)$" },
}
for _, m in ipairs(modalMatches) do hl.window_rule({ match = m, float = true }) end

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
