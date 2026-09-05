return {
  "ibhagwan/fzf-lua",
  -- optional for icon support
  dependencies = { "nvim-tree/nvim-web-devicons" },
  -- or if using mini.icons/mini.nvim
  -- dependencies = { "echasnovski/mini.icons" },
  opts = {
    files = {
      -- Incluye la bandera '--hidden' y excluye la carpeta interna de git
      cmd = "rg --files --hidden --glob '!.git'",
    },
  },
}
