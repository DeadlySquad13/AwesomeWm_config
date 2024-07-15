-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")

-- Default Modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
Modkey = "Mod4"

-- Works nicely in modified hydra implementation but Modkey-only keymappings
-- are now only recognize Super_R - Super_L is fully devoured with hydra.
-- Keymappings with multiple modifiers aka Modkey+Shift work though.
-- local HydraModkey = "Super_R"
local Altkey = "Mod1"
local KEY = {
    left = { "s", "Left" },
    down = { "n", "Down" },
    up = { "m", "Up" },
    right = { "t", "Right" },

    next = { "f", "y" },
    prev = { "p", "\"" },

    minimize = "n",
    maximize = "m",
}


local globalkeys = gears.table.join(
    awful.key({ Modkey, "Control" }, KEY.minimize,
        function()
            local c = awful.client.restore()
            -- Focus restored client
            if c then
                c:emit_signal(
                    "request::activate", "key.unminimize", { raise = true }
                )
            end
        end,
        { description = "restore minimized", group = "client" }),

    -- Prompt (search).
    awful.key({ Altkey }, "s", function() awful.util.spawn("rofi -show combi") end,
        { description = "run prompt", group = "launcher" }),

    awful.key({ Modkey, "Control" }, "x",
        function()
            awful.prompt.run {
                prompt       = "Run Lua code: ",
                textbox      = awful.screen.focused().mypromptbox.widget,
                exe_callback = awful.util.eval,
                history_path = awful.util.get_cache_dir() .. "/history_eval"
            }
        end,
        { description = "lua execute prompt", group = "awesome" }),
    -- Menubar
    awful.key({ Modkey }, "P", function() menubar.show() end,
        { description = "show the menubar", group = "launcher" })
)

-- ### Layout.
local layoutkeys = gears.table.join(
    awful.key({ Modkey, }, "l", function() awful.tag.incmwfact(0.05) end,
        { description = "increase master width factor", group = "layout" }),
    awful.key({ Modkey, }, "h", function() awful.tag.incmwfact(-0.05) end,
        { description = "decrease master width factor", group = "layout" }),
    awful.key({ Modkey, "Shift" }, "h", function() awful.tag.incnmaster(1, nil, true) end,
        { description = "increase the number of master clients", group = "layout" }),
    awful.key({ Modkey, "Shift" }, "l", function() awful.tag.incnmaster(-1, nil, true) end,
        { description = "decrease the number of master clients", group = "layout" }),
    awful.key({ Modkey, "Control" }, "h", function() awful.tag.incncol(1, nil, true) end,
        { description = "increase the number of columns", group = "layout" }),
    awful.key({ Modkey, "Control" }, "l", function() awful.tag.incncol(-1, nil, true) end,
        { description = "decrease the number of columns", group = "layout" }),
    awful.key({ Modkey, }, "space", function() awful.layout.inc(1) end,
        { description = "select next", group = "layout" }),
    awful.key({ Modkey, "Shift" }, "space", function() awful.layout.inc(-1) end,
        { description = "select previous", group = "layout" })
)

-- ## Apps.
local appkeys = gears.table.join(
-- ### Awesome.
    awful.key({ Modkey, "Control" }, "r", awesome.restart,
        { description = "reload awesome", group = "awesome" }),
    awful.key({ Modkey, "Shift" }, "q", awesome.quit,
        { description = "quit awesome", group = "awesome" })
)
local hydra_is_available, hydra = pcall(require, 'awesome-wm-hydra')

if hydra_is_available then
    -- ## Apps.
    -- Should be synced with other
    -- [OS configs](https://github.com/DeadlySquad13/Keymappings__AutoHotKey_scripts/blob/main/Keymappings__/apps/apps.ahk)

    appkeys = gears.table.join(appkeys,
        -- Worked with initial implementation of the hydra module. Needed to hold super.
        -- awful.key({ Modkey }, "r", function()
        --     hydra.start({
        --         -- activation_key: The trigger key. This is not a key ID, but a AwesomeWM key name.
        --         -- This must match the key used in your awesome key config to trigger hydra, since
        --         -- it's used to detect when the activation key is released.
        --         activation_key = "r",
        --         ignored_mod = Modkey,
        --         config = app_keymappings,
        --     })
        -- end),

        awful.key({ Modkey }, "r",
            function()
                hydra.start({
                    -- activation_key: The trigger key. This is not a key ID, but a AwesomeWM key name.
                    -- This must match the key used in your awesome key config to trigger hydra, since
                    -- it's used to detect when the activation key is released.
                    activation_key = "r",
                    ignored_mod = Modkey,
                    config = {
                        a = { "open a terminal", function() awful.spawn(terminal) end },
                        t = { "timer", {
                            n = { "next", function() awful.spawn("uairctl next") end },
                            t = { "toggle", function() awful.spawn("uairctl toggle") end },
                        }},
                        i = { "browser", function () awful.spawn(BROWSER) end },
                    },
                })
            end,
            { description = "Apps", group = "hydra" })
    )
end


local screenkeys = gears.table.join(
-- * Focus previous/next.
    awful.key({ Modkey }, KEY.next[2], function() awful.screen.focus_relative(1) end,
        { description = "focus the next screen", group = "screen" }),
    awful.key({ Modkey }, KEY.prev[2], function() awful.screen.focus_relative(-1) end,
        { description = "focus the previous screen", group = "screen" })
)

-- ## Tags.
-- Some are defined via collision in 'Clients (windows)'.
local tagkeys = gears.table.join(
    awful.key({ Modkey, "Shift" }, "r", hotkeys_popup.show_help,
        { description = "show help", group = "awesome" }),
    awful.key({ Modkey, }, KEY.left[2], awful.tag.viewprev,
        { description = "view previous", group = "tag" }),
    awful.key({ Modkey, }, KEY.right[2], awful.tag.viewnext,
        { description = "view next", group = "tag" }),
    awful.key({ Modkey, }, "Escape", awful.tag.history.restore,
        { description = "go back", group = "tag" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    tagkeys = gears.table.join(tagkeys,
        -- View tag only.
        awful.key({ Modkey }, "#" .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    tag:view_only()
                end
            end,
            { description = "view tag #" .. i, group = "tag" }),
        -- Toggle tag display.
        awful.key({ Modkey, "Control" }, "#" .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end,
            { description = "toggle tag #" .. i, group = "tag" }),
        -- Move client to tag.
        awful.key({ Modkey, "Shift" }, "#" .. i + 9,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end,
            { description = "move focused client to tag #" .. i, group = "tag" }),
        -- Toggle tag on focused client.
        awful.key({ Modkey, "Control", "Shift" }, "#" .. i + 9,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:toggle_tag(tag)
                    end
                end
            end,
            { description = "toggle focused client on tag #" .. i, group = "tag" })
    )
end


-- ## Clients (windows).
local client_window_keys = gears.table.join(
-- * Swap with previous/next.
    awful.key({ Modkey, "Shift" }, KEY.next[1], function() awful.client.swap.byidx(1) end,
        { description = "swap with next client by index", group = "client" }),
    awful.key({ Modkey, "Shift" }, KEY.prev[1], function() awful.client.swap.byidx(-1) end,
        { description = "swap with previous client by index", group = "client" }),

    awful.key({ Modkey, }, KEY.next[1],
        function()
            awful.client.focus.byidx(1)
        end,
        { description = "focus next by index", group = "client" }
    ),
    awful.key({ Modkey, }, KEY.prev[1],
        function()
            awful.client.focus.byidx(-1)
        end,
        { description = "focus previous by index", group = "client" }
    ),
    awful.key({ Modkey, }, "w", function() mymainmenu:show() end,
        { description = "show main menu", group = "awesome" }),
    awful.key({ Modkey, }, "u", awful.client.urgent.jumpto,
        { description = "jump to urgent client", group = "client" }),

    awful.key({ Modkey, }, "Tab",
        function()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        { description = "go back", group = "client" })
)

local collision_is_available, collision = pcall(require, "collision")

if collision_is_available then
    collision.settings.swap_across_screen = true
    --[[
    The `Shift` key is usually used for grabbing something
    while the `Control` key is used to max out the effect.

    | Modifier 1 | Modifier 2   | Modifier 3   | Effect                                                |
    | :---------:| :-----------:| :-----------:| :----------------------------------------------------:|
    | `Mod4`     |              |              | Move the focus on the tiled layer                     |
    | `Mod4`     |              | `Control`    | Move the focus on the floating layer                  |
    | `Mod4`     | `Shift`      |              | Move a client in the tiled or floating layer          |
    | `Mod4`     | `Shift`      | `Control`    | Move a floating client to the far side of that screen |
    | `Mod4`     | `Mod1 (Alt)` |              | Increase a floating client size                       |
    | `Mod4`     | `Mod1 (Alt)` | `Shift`      | Reduce a floating client size                         |
    | -----------| -------------| -------------| ------------------------------------------------------|
    |                               Tags functionality:                                                |
    | -----------| -------------| -------------| ------------------------------------------------------|
    | `Control`  | `Mod1 (Alt)` |              | Move to the next/previous tag                         |
    | `Control`  | `Mod4`       | `Mod1 (Alt)` | Move to the next/previous screen                      |
    | `Control`  | `Mod4`       | `Mod1 (Alt)` | + `Shift` Move tag to the next/previous screen        |
    ]]
    collision({
        left = { KEY.left[1] },
        down = { KEY.down[1] },
        up = { KEY.up[1] },
        right = { KEY.right[1] },
    })
else
    -- Note: better implemented in `collision`, left here just as a fallback.
    local client_window_keys = gears.table.join(
        client_window_keys,

        -- * Focus in direction (globally - move even across screens).
        awful.key({ Modkey }, KEY.left[1], function() awful.client.focus.global_bydirection("left") end,
            { description = "focus globally in left direction", group = "client" }),
        awful.key({ Modkey }, KEY.down[1], function() awful.client.focus.global_bydirection("down") end,
            { description = "focus globally in down direction", group = "client" }),
        awful.key({ Modkey }, KEY.up[1], function() awful.client.focus.global_bydirection("up") end,
            { description = "focus globally in up direction", group = "client" }),
        awful.key({ Modkey }, KEY.right[1], function() awful.client.focus.global_bydirection("right") end,
            { description = "focus globally in right direction", group = "client" }),

        -- * Swap in direction (globally - swaps even across screens).
        awful.key({ Modkey, "Shift" }, KEY.left[1], function() awful.client.swap.global_bydirection("left") end,
            { description = "swap globally in left direction", group = "client" }),
        awful.key({ Modkey, "Shift" }, KEY.down[1], function() awful.client.swap.global_bydirection("down") end,
            { description = "swap globally in down direction", group = "client" }),
        awful.key({ Modkey, "Shift" }, KEY.up[1], function() awful.client.swap.global_bydirection("up") end,
            { description = "swap globally in up direction", group = "client" }),
        awful.key({ Modkey, "Shift" }, KEY.right[1], function() awful.client.swap.global_bydirection("right") end,
            { description = "swap globally in right direction", group = "client" })
    )
end


globalkeys = gears.table.join(
    globalkeys,
    screenkeys,
    layoutkeys,
    tagkeys,
    client_window_keys,
    appkeys
)

local clientkeys = gears.table.join(
    awful.key({ Altkey, }, "Return",
        function(c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        { description = "toggle fullscreen", group = "client" }),
    awful.key({ Modkey }, "Return", awful.client.floating.toggle,
        { description = "toggle floating", group = "client" }),

    awful.key({ Modkey }, "x", function(c) c:kill() end,
        { description = "close", group = "client" }),
    awful.key({ Modkey }, "g", function(c) c:swap(awful.client.getmaster()) end,
        { description = "move to master in current layout", group = "client" }),
    awful.key({ Modkey, }, "c", function(c) c:move_to_screen() end,
        { description = "cycle move to screen", group = "client" }),
    -- awful.key({ Modkey, }, "t", function(c) c.ontop = not c.ontop end,
    --     { description = "toggle keep on top", group = "client" }),

    -- * Minimize / maximize.
    awful.key({ Modkey, "Control" }, KEY.minimize,
        function(c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end,
        { description = "minimize", group = "client" }),
    awful.key({ Modkey, "Control" }, KEY.maximize,
        function(c)
            c.maximized = not c.maximized
            c:raise()
        end,
        { description = "(un)maximize", group = "client" }),
    awful.key({ Modkey, "Control", "Shift" }, KEY.maximize,
        function(c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end,
        { description = "(un)maximize vertically", group = "client" }),
    awful.key({ Modkey, "Control", "Shift" }, KEY.maximize,
        function(c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end,
        { description = "(un)maximize horizontally", group = "client" })
)

local clientbuttons = gears.table.join(
    awful.button({}, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
    end),
    awful.button({ Modkey }, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.move(c)
    end),
    awful.button({ Modkey }, 3, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.resize(c)
    end)
)


return {
    globalkeys = globalkeys,
    clientkeys = clientkeys,
    clientbuttons = clientbuttons,
}
