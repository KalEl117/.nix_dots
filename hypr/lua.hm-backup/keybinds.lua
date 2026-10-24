local apps = require("lua.programs")

local main_mod = "SUPER"

local function bind(keys, dispatcher, options)
	hl.bind(main_mod .. " + " .. keys, dispatcher, options)
end

-- Zwischenablage und Screenshots
bind("SHIFT + V", hl.dsp.exec_cmd([=[cliphist list | rofi -dmenu -p "Clipboard" | cliphist decode | wl-copy]=]))
bind(
	"Print",
	hl.dsp.exec_cmd(
		[=[grim -g "$(slurp)" - | swappy -f - - && notify-send "Screenshot bearbeitet" "Das Bild wurde in deinem Bilder-Ordner abgelegt." --icon=screenshot]=]
	)
)
bind(
	"SHIFT + Print",
	hl.dsp.exec_cmd(
		[=[grim ~/Pictures/Screenshots/$(date +'%Y-%m-%d_%H-%M-%S').png && notify-send "Screenshot" "Bild wurde im Screenshots-Ordner gespeichert!" --icon=screenshot]=]
	)
)
bind(
	"CTRL + Print",
	hl.dsp.exec_cmd(
		[=[grim -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" - | swappy -f - && notify-send "Screenshot bearbeitet" "Fenster-Screenshot wurde erfolgreich gespeichert." --icon=screenshot]=]
	)
)

-- Schwebende Terminal-Helfer
bind("CTRL + A", hl.dsp.exec_cmd("kitty --class wiremix-term -e wiremix"))
bind("CTRL + T", hl.dsp.exec_cmd("kitty --class btop-term -e btop"))
bind("SHIFT + CTRL + Y", hl.dsp.exec_cmd("kitty --class yazi-term -e yazi"))

-- Programme
bind("Return", hl.dsp.exec_cmd(apps.terminal))
bind("SHIFT + B", hl.dsp.exec_cmd(apps.browser))
bind("SHIFT + ALT + B", hl.dsp.exec_cmd(apps.browserprivat))
bind("SHIFT + E", hl.dsp.exec_cmd(apps.gmail))
bind("SHIFT + A", hl.dsp.exec_cmd(apps.gemini))
bind("SHIFT + K", hl.dsp.exec_cmd(apps.keep))
bind("SHIFT + C", hl.dsp.exec_cmd(apps.calendar))
bind("SHIFT + Y", hl.dsp.exec_cmd(apps.youtube))
bind("SHIFT + M", hl.dsp.exec_cmd(apps.youtubemusic))
bind("SHIFT + W", hl.dsp.exec_cmd(apps.whatsapp))
bind("SHIFT + N", hl.dsp.exec_cmd(apps.neovim))
bind("SHIFT + P", hl.dsp.exec_cmd(apps.photo))
bind("CTRL + Y", hl.dsp.exec_cmd(apps.yazi))
bind("CTRL + K", hl.dsp.exec_cmd("~/.config/hypr/scripts/keybinds.sh"))
bind("SHIFT + Period", hl.dsp.exec_cmd(apps.onepassword .. " --class 1password"))

-- System und Fenster
bind("CTRL + ALT + Escape", hl.dsp.exec_cmd("systemctl suspend"))
bind("W", hl.dsp.window.close())
bind(
	"SHIFT + Escape",
	hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")
)
bind("SHIFT + F", hl.dsp.exec_cmd(apps.fileManager))
bind("V", hl.dsp.window.float())
bind("F", hl.dsp.window.fullscreen())
bind("Space", hl.dsp.exec_cmd(apps.menu))
bind("P", hl.dsp.window.pseudo())
bind("CTRL + L", hl.dsp.exec_cmd("hyprlock"))

-- Fokus bewegen
bind("H", hl.dsp.focus({ direction = "l" }))
bind("L", hl.dsp.focus({ direction = "r" }))
bind("K", hl.dsp.focus({ direction = "u" }))
bind("J", hl.dsp.focus({ direction = "d" }))

-- Workspaces wechseln und Fenster dorthin verschieben
for i = 1, 10 do
	local key = i % 10
	bind(tostring(key), hl.dsp.focus({ workspace = i }))
	bind("SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special Workspace (Scratchpad)
bind("S", hl.dsp.workspace.toggle_special("magic"))
bind("SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Durch bestehende Workspaces scrollen
bind("mouse_down", hl.dsp.focus({ workspace = "e+1" }))
bind("mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Fenster mit der Maus bewegen und skalieren
bind("mouse:272", hl.dsp.window.drag(), { mouse = true })
bind("mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Lautstärke und Helligkeit: bei gedrückter Taste wiederholen und im Lock-Screen erlauben
local repeat_locked = { locked = true, repeating = true }
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), repeat_locked)
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), repeat_locked)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), repeat_locked)
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), repeat_locked)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), repeat_locked)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), repeat_locked)

-- Medien-Tasten im Lock-Screen erlauben
local locked = { locked = true }
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), locked)
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), locked)
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), locked)
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), locked)
