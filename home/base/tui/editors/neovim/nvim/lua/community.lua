-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  -- Motion
  { import = "astrocommunity.motion.mini-surround" },
  -- https://github.com/echasnovski/mini.ai
  { import = "astrocommunity.motion.mini-ai" },
  { import = "astrocommunity.motion.flash-nvim" },
  -- Highly experimental plugin that completely replaces
  -- the UI for messages, cmdline and the popupmenu.
  -- { import = "astrocommunity.utility.noice-nvim" },
  { import = "astrocommunity.media.vim-wakatime" },
  { import = "astrocommunity.motion.leap-nvim" },
  { import = "astrocommunity.motion.flit-nvim" },
  { import = "astrocommunity.scrolling.nvim-scrollbar" },
  { import = "astrocommunity.editing-support.todo-comments-nvim" },
  -- Language Support
  ---- Frontend & NodeJS
  { import = "astrocommunity.pack.typescript-all-in-one" },
  { import = "astrocommunity.pack.tailwindcss" },
  { import = "astrocommunity.pack.html-css" },
  { import = "astrocommunity.pack.prisma" },
  { import = "astrocommunity.pack.vue" },
  ---- Configuration Language
  { import = "astrocommunity.pack.markdown" },
  { import = "astrocommunity.pack.json" },
  { import = "astrocommunity.pack.yaml" },
  { import = "astrocommunity.pack.toml" },
  ---- Backend / System
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.go" },
  { import = "astrocommunity.pack.rust" },
  { import = "astrocommunity.pack.python" },
  { import = "astrocommunity.pack.java" },
  { import = "astrocommunity.pack.cmake" },
  { import = "astrocommunity.pack.cpp" },
  -- { import = "astrocommunity.pack.nix" },  -- manually add config for nix, comment this one.
  { import = "astrocommunity.pack.proto" },

  ---- Operation & Cloud Native
  { import = "astrocommunity.pack.terraform" },
  { import = "astrocommunity.pack.bash" },
  { import = "astrocommunity.pack.docker" },
  { import = "astrocommunity.pack.helm" },

  -- colorscheme
  { import = "astrocommunity.colorscheme.catppuccin" },

  -- Lua implementation of CamelCaseMotion, with extra consideration of punctuation.
  { import = "astrocommunity.motion.nvim-spider" },
}
