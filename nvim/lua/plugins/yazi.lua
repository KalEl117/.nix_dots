return {
  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    keys = {
      -- Yazi im Verzeichnis der aktuellen Datei öffnen
      {
        "<leader>e",
        "<cmd>Yazi<cr>",
        desc = "Yazi im aktuellen Dateipfad öffnen",
      },
      -- Yazi im Root-Verzeichnis (CWD) deines Projekts öffnen
      {
        "<leader>E",
        "<cmd>Yazi cwd<cr>",
        desc = "Yazi im Neovim Working Directory öffnen",
      },
      -- Optional: Schneller Wechsel zurück in die letzte Yazi-Session
      {
        "<c-up>",
        "<cmd>Yazi toggle<cr>",
        desc = "Zuletzt geöffnete Yazi-Session fortsetzen",
      },
    },
    opts = {
      -- Startet Yazi automatisch, wenn du Neovim mit einem Ordner öffnest (z. B. `nvim .`)
      open_for_directories = true,
      keymaps = {
        show_help = "<f1>",
      },
    },
  },
}
