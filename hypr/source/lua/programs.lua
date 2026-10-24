-- Standardanwendungen & App-Variablen
local M = {}

M.terminal = "kitty"
M.fileManager = "thunar"
M.menu = "qs -c desktop ipc call menu toggle apps"
M.browser = "brave"
M.browserprivat = "brave --incognito"
M.gmail = "brave --app=https://mail.google.com"
M.proton = "brave --app=https://mail.proton.me"
M.gemini = "brave --app=https://gemini.google.com"
M.chatgpt = "brave --app=https://chatgpt.com"
M.keep = "brave --app=https://keep.google.com"
M.photo = "brave --app=https://photo.google.com"
M.calendar = "brave --app=https://calendar.google.com"
M.whatsapp = "brave --app=https://web.whatsapp.com"
M.youtube = "brave --app=https://www.youtube.com"
M.youtubemusic = "brave --app=https://music.youtube.com"
M.neovim = "kitty -e nvim"
M.btop = "kitty -e btop"
M.codex = "kitty -e codex"
M.opencode = "kitty -e opencode"
M.yazi = "kitty -e yazi"
M.onepassword = "1password"

return M
