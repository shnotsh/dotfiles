-- Focus defaults for input.kb_layout = "us,ru" (zero-based indices).
-- Caps+Z remains a manual override until the next app/panel focus change.
local russian_apps = {
    ["org.telegram.desktop"] = true,
    ["telegram-desktop"] = true,
    ["telegramdesktop"] = true,
    ["vesktop"] = true,
    ["dev.vencord.vesktop"] = true,
    ["discord"] = true,
    ["discordcanary"] = true,
    ["discordptb"] = true,
    ["com.discordapp.discord"] = true,
}

-- Shell panels can hold keyboard focus without changing the active window.
-- Include Noctalia's focus-grab panels even if their interactivity is zero.
local shell_panels = {
    ["noctalia-panel"] = true,
    ["noctalia-attached-panel"] = true,
    ["noctalia-overview-launcher"] = true,
    ["noctalia-window-switcher"] = true,
}
local open_panels = {}

local function is_keyboard_panel(layer)
    return layer.interactivity > 0 or shell_panels[layer.namespace] == true
end

local function apply_layout()
    local layout = 0
    if next(open_panels) == nil then
        local window = hl.get_active_window()
        if window and russian_apps[window.class:lower()] then
            layout = 1
        end
    end
    -- Run outside the compositor callback; synchronous hyprctl would deadlock.
    hl.exec_cmd("hyprctl switchxkblayout all " .. layout)
end

local generation = 0
local function schedule_layout()
    generation = generation + 1
    local requested = generation
    -- Let focus settle after a layer closes, and coalesce related events.
    hl.timer(function()
        if requested == generation then
            apply_layout()
        end
    end, { timeout = 1, type = "oneshot" })
end

hl.on("window.active", schedule_layout)
hl.on("layer.opened", function(layer)
    if is_keyboard_panel(layer) then
        open_panels[layer.address] = true
        schedule_layout()
    end
end)
hl.on("layer.closed", function(layer)
    if open_panels[layer.address] then
        open_panels[layer.address] = nil
        schedule_layout()
    end
end)
hl.on("config.reloaded", function()
    open_panels = {}
    for _, layer in ipairs(hl.get_layers()) do
        if layer.mapped and is_keyboard_panel(layer) then
            open_panels[layer.address] = true
        end
    end
    schedule_layout()
end)
