local apps = require("lua.programs")

local main_mod = "SUPER"

-- Let the shortcut menu invoke the same dispatchers as the physical bindings.
_G.desktop_keybind_actions = {}

-- Hyprland exposes Lua dispatchers as "__lua <id>". Publish the action and
-- command through description so menus can search the actual binding.
local function described_bind(keys, dispatcher, description, options)
  local opts = {}
  for key, value in pairs(options or {}) do
    opts[key] = value
  end
  opts.description = description
  _G.desktop_keybind_actions[description] = dispatcher
  hl.bind(keys, dispatcher, opts)
end

local function bind(keys, dispatcher, description, options)
  described_bind(main_mod .. " + " .. keys, dispatcher, description, options)
end

local function run(keys, command, description)
  bind(keys, hl.dsp.exec_cmd(command), description .. "\n" .. command)
end

-- Zwischenablage und Screenshots
run("SHIFT + V", "qs -c desktop ipc call menu toggle clipboard", "Zwischenablage öffnen (Cliphist)")
run(
  "Print",
  [=[grim -g "$(slurp)" - | swappy -f - - && notify-send "Screenshot bearbeitet" "Das Bild wurde in deinem Bilder-Ordner abgelegt." --icon=screenshot]=],
  "Screenshot: Bereich auswählen und bearbeiten"
)
run(
  "SHIFT + Print",
  [=[grim ~/Pictures/Screenshots/$(date +'%Y-%m-%d_%H-%M-%S').png && notify-send "Screenshot" "Bild wurde im Screenshots-Ordner gespeichert!" --icon=screenshot]=],
  "Screenshot: gesamten Bildschirm speichern"
)
run(
  "CTRL + Print",
  [=[grim -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" - | swappy -f - && notify-send "Screenshot bearbeitet" "Fenster-Screenshot wurde erfolgreich gespeichert." --icon=screenshot]=],
  "Screenshot: aktives Fenster bearbeiten"
)

-- Schwebende Terminal-Helfer
run("CTRL + A", "kitty --class wiremix-term -e wiremix", "Wiremix: Audio-Mixer öffnen")
run("CTRL + T", "kitty --class btop-term -e btop", "Btop: Systemmonitor öffnen")
run("SHIFT + CTRL + Y", "kitty --class yazi-term -e yazi", "Yazi: schwebenden Dateimanager öffnen")

-- Programme
run("Return", apps.terminal, "Kitty: Terminal öffnen")
run("SHIFT + B", apps.browser, "Brave: Browser öffnen")
run("SHIFT + ALT + B", apps.browserprivat, "Brave: privates Browserfenster öffnen")
run("SHIFT + E", apps.gmail, "Gmail: E-Mail öffnen")
run("SHIFT + ALT + E", apps.proton, "Proton: E-Mail öffnen")
run("SHIFT + A", apps.chatgpt, "ChatGPT öffnen")
run("SHIFT + K", apps.keep, "Google Keep: Notizen öffnen")
run("SHIFT + C", apps.calendar, "Google Kalender öffnen")
run("SHIFT + Y", apps.youtube, "YouTube öffnen")
run("SHIFT + M", apps.youtubemusic, "YouTube Music öffnen")
run("SHIFT + W", apps.whatsapp, "WhatsApp öffnen")
run("SHIFT + N", apps.neovim, "Neovim: Editor öffnen")
run("SHIFT + ALT + A", apps.codex, "Codex TUI öffnen")
run("SHIFT + CTRL + A", apps.opencode, "OpenCode TUI öffnen")
run("SHIFT + P", apps.photo, "Google Fotos öffnen")
run("CTRL + Y", apps.yazi, "Yazi: Dateimanager öffnen")
run("CTRL + K", "qs -c desktop ipc call menu toggle keybinds", "Tastenkürzel: Übersicht öffnen")
run("SHIFT + Period", apps.onepassword .. " --class 1password", "1Password: Passwortmanager öffnen")

-- System und Fenster
run("CTRL + ALT + Escape", "systemctl suspend", "System: Bereitschaft / Standby")
run("X", "qs -c desktop ipc call power toggle", "Powermenü: Ein-/Ausschalten, Neustart, Sperren …")
bind("W", hl.dsp.window.close(), "Fenster schließen")
run(
  "SHIFT + Escape",
  "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'",
  "Sitzung beenden / abmelden"
)
run("SHIFT + F", apps.fileManager, "Thunar: Dateimanager öffnen")
bind("V", hl.dsp.window.float(), "Fenster: Floating-Modus umschalten")
bind("F", hl.dsp.window.fullscreen(), "Fenster: Vollbild umschalten")
run("Space", apps.menu, "Anwendungen: App-Menü öffnen")
bind("P", hl.dsp.window.pseudo(), "Fenster: Pseudotiling umschalten")
run("CTRL + L", "hyprlock", "Bildschirm sperren")

-- Fokus bewegen
bind("H", hl.dsp.focus({ direction = "l" }), "Fensterfokus nach links bewegen")
bind("L", hl.dsp.focus({ direction = "r" }), "Fensterfokus nach rechts bewegen")
bind("K", hl.dsp.focus({ direction = "u" }), "Fensterfokus nach oben bewegen")
bind("J", hl.dsp.focus({ direction = "d" }), "Fensterfokus nach unten bewegen")

-- Workspaces wechseln und Fenster dorthin verschieben
for i = 1, 10 do
  local key = i % 10
  bind(tostring(key), hl.dsp.focus({ workspace = i }), "Zu Workspace " .. i .. " wechseln")
  bind("SHIFT + " .. key, hl.dsp.window.move({ workspace = i }), "Fenster zu Workspace " .. i .. " verschieben")
end

-- Special Workspace (Scratchpad)
bind("S", hl.dsp.workspace.toggle_special("magic"), "Scratchpad: Spezial-Workspace magic ein-/ausblenden")
bind("SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }), "Fenster ins Scratchpad magic verschieben")

-- Durch bestehende Workspaces scrollen
bind("mouse_down", hl.dsp.focus({ workspace = "e+1" }), "Zum nächsten Workspace wechseln")
bind("mouse_up", hl.dsp.focus({ workspace = "e-1" }), "Zum vorherigen Workspace wechseln")

-- Fenster mit der Maus bewegen und skalieren
bind("mouse:272", hl.dsp.window.drag(), "Fenster mit der Maus verschieben", { mouse = true })
bind("mouse:273", hl.dsp.window.resize(), "Fenstergröße mit der Maus ändern", { mouse = true })

-- Ohne SUPER; gemeinsame Optionen kopieren, damit jede Beschreibung erhalten bleibt.
local function media(keys, command, description, options)
  described_bind(keys, hl.dsp.exec_cmd(command), description .. "\n" .. command, options)
end

-- Lautstärke und Helligkeit: wiederholen und im Lock-Screen erlauben
local repeat_locked = { locked = true, repeating = true }
media("XF86AudioRaiseVolume", "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+", "Lautstärke erhöhen", repeat_locked)
media("XF86AudioLowerVolume", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-", "Lautstärke verringern", repeat_locked)
media(
  "XF86AudioMute",
  "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle",
  "Lautsprecher stummschalten / einschalten",
  repeat_locked
)
media(
  "XF86AudioMicMute",
  "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle",
  "Mikrofon stummschalten / einschalten",
  repeat_locked
)
media("XF86MonBrightnessUp", "brightnessctl -e4 -n2 set 5%+", "Bildschirmhelligkeit erhöhen", repeat_locked)
media("XF86MonBrightnessDown", "brightnessctl -e4 -n2 set 5%-", "Bildschirmhelligkeit verringern", repeat_locked)

-- Medien-Tasten im Lock-Screen erlauben
local locked = { locked = true }
media("XF86AudioNext", "playerctl next", "Medien: nächster Titel", locked)
media("XF86AudioPause", "playerctl play-pause", "Medien: Wiedergabe / Pause", locked)
media("XF86AudioPlay", "playerctl play-pause", "Medien: Wiedergabe / Pause", locked)
media("XF86AudioPrev", "playerctl previous", "Medien: vorheriger Titel", locked)
