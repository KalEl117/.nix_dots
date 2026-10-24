// Lua dispatchers hide their command behind an opaque __lua ID. The binding
// description carries the readable action, then a newline and its command.
function luaString(value) {
  return '"' + value.replace(/[\\"\x00-\x1f]/g, character =>
    "\\" + character.charCodeAt(0).toString().padStart(3, "0")) + '"';
}

function invocation(binding) {
  if (binding.dispatcher === "__lua") {
    if (!binding.description) return [];
    return ["hyprctl", "eval", "hl.dispatch(assert(desktop_keybind_actions["
      + luaString(binding.description) + "], 'Tastenkürzel nicht registriert; Hyprland-Konfiguration neu laden'))"];
  }
  return binding.dispatcher
    ? ["hyprctl", "dispatch", binding.dispatcher, binding.arg || ""] : [];
}

function shortcut(binding) {
  const names = {
    Return: "Enter", Space: "Leertaste", Escape: "Esc", Print: "Druck",
    Period: ".", mouse_down: "Mausrad runter", mouse_up: "Mausrad hoch",
    "mouse:272": "Linke Maustaste", "mouse:273": "Rechte Maustaste",
    XF86AudioRaiseVolume: "Lauter", XF86AudioLowerVolume: "Leiser",
    XF86AudioMute: "Stumm", XF86AudioMicMute: "Mikrofon stumm",
    XF86MonBrightnessUp: "Heller", XF86MonBrightnessDown: "Dunkler",
    XF86AudioNext: "Nächster Titel", XF86AudioPrev: "Vorheriger Titel",
    XF86AudioPlay: "Play", XF86AudioPause: "Pause"
  };
  const modifiers = [[64, "Super"], [4, "Ctrl"], [8, "Alt"], [1, "Shift"]]
    .filter(m => binding.modmask & m[0]).map(m => m[1]);
  return modifiers.concat([names[binding.key] || binding.key || ("Code " + binding.keycode)]).join(" + ");
}

function rows(bindings) {
  return bindings.map(binding => {
    const description = (binding.description || "").split("\n");
    const lua = binding.dispatcher === "__lua";
    const command = description.slice(1).join("\n") || (lua ? "" : (binding.arg || ""));
    const action = description[0] || (lua ? "Lua-Aktion ohne Beschreibung" : (binding.dispatcher || "Unbekannte Aktion"));
    const keys = shortcut(binding);
    const submap = binding.submap ? " · " + binding.submap : "";
    return {
      label: action,
      shortcut: keys + submap,
      invocation: invocation(binding),
      detail: keys + submap + (command ? " · " + command : ""),
      search: [action, keys, command, binding.key, binding.submap, lua ? "" : binding.dispatcher].join(" ")
    };
  });
}

function matches(row, query) {
  const haystack = [row.label || "", row.detail || "", row.search || ""].join(" ").toLocaleLowerCase();
  return query.trim().toLocaleLowerCase().split(/\s+/).every(word => haystack.includes(word));
}
