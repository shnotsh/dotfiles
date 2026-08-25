-- Monitor wiki https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Example: output can be found with hyprctl monitors. Edit variables.lua for the monitor outputs instead of here directly

hl.monitor({
     output    = "HDMI-A-1",
     mode      = "2560x1440@165",
     position  = "0x0",
     scale     = "1",
 })

 hl.monitor({
	output = "eDP-1",
	mode = "preferred",
	position = "0x0",
	scale = "1",
	mirror = "HDMI-A-1",
})

 hl.monitor({
	output = "DP-1",
	mode = "1920x1200@75",
	position = "2560x0",
	scale = "1",
})
