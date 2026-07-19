return {
  {
    "folke/snacks.nvim",
    opts = {
      -- Deine bisherige Explorer-Deaktivierung
      explorer = { enabled = false },

      -- NEU: Das Dashboard anpassen
      dashboard = {
        preset = {
          -- Hier fügst du dein eigenes ASCII-Logo ein
          header = [[
	                                                                     
	       ████ ██████           █████      ██                     
	      ███████████             █████                             
	      █████████ ███████████████████ ███   ███████████   
	     █████████  ███    █████████████ █████ ██████████████   
	    █████████ ██████████ █████████ █████ █████ ████ █████   
	  ███████████ ███    ███ █████████ █████ █████ ████ █████  
	 ██████  █████████████████████ ████ █████ █████ ████ ██████ 
         ]],
        },
      },
    },
    keys = {
      -- Deine deaktivierten Keymaps von vorhin
      { "<leader>e", false },
      { "<leader>E", false },
    },
  },
}
