return {
  -- Mason komplett deaktivieren, da NixOS die Binaries bereitstellt
  {
    "mason-org/mason.nvim",
    enabled = false,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    enabled = false,
  },
}
