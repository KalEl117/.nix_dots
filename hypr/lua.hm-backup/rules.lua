-- Fenster- & Workspace-Regeln

hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })

hl.window_rule({
	name = "no-gaps-wtv1",
	match = { float = false, workspace = "w[tv1]" },
	border_size = 0,
	rounding = 0,
})

hl.window_rule({
	name = "no-gaps-f1",
	match = { float = false, workspace = "f[1]" },
	border_size = 0,
	rounding = 0,
})

hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },
	suppress_event = "maximize",
})

hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true,
})

hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },
	move = "20 monitor_h-120",
	float = true,
})

local floating_windows = {
	{ class = "wiremix-term", size = { 1200, 800 } },
	{ class = "btop-term", size = { 1200, 800 } },
	{ class = "yazi-term", size = { 1200, 800 } },
	{ class = "1password", size = { 1200, 800 } },
	{ class = "imv", size = { 1200, 800 } },
	{ class = "mpv", size = { 1200, 800 } },
	{ class = "peazip", size = { 1400, 900 } },
}

for _, rule in ipairs(floating_windows) do
	hl.window_rule({
		match = { class = rule.class },
		float = true,
		center = true,
		size = rule.size,
	})
end
