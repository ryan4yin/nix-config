local prefix = "<Leader>A"
return {
  "yetone/avante.nvim",
  event = "User AstroFile", -- load on file open because Avante manages it's own bindings
  cmd = {
    "AvanteAsk",
    "AvanteBuild",
    "AvanteEdit",
    "AvanteRefresh",
    "AvanteSwitchProvider",
    "AvanteShowRepoMap",
    "AvanteModels",
    "AvanteChat",
    "AvanteChatNew",
    "AvanteToggle",
    "AvanteClear",
    "AvanteFocus",
    "AvanteStop",
  },
  version = false, -- Never set this value to "*"! Never!
  opts = {
    -- add any opts here
    provider = "deepseek_coder",
    ollama = {
      endpoint = "http://127.0.0.1:11434", -- Note that there is no /v1 at the end.
      model = "modelscope.cn/unsloth/Qwen3-30B-A3B-GGUF",
      -- model = "modelscope.cn/unsloth/Qwen3-235B-A22B-GGUF",
    },
    vendors = {
      openrouter_claude_4_7_sonnet = {
        __inherited_from = "openai",
        endpoint = "https://openrouter.ai/api/v1",
        api_key_name = "OPENROUTER_API_KEY",
        model = "anthropic/claude-3.7-sonnet",
      },
      openrouter_gemini_2_flash = {
        __inherited_from = "openai",
        endpoint = "https://openrouter.ai/api/v1",
        api_key_name = "OPENROUTER_API_KEY",
        model = "google/gemini-2.0-flash-001",
      },
      deepseek_coder = {
        __inherited_from = "openai",
        api_key_name = "DEEPSEEK_API_KEY",
        endpoint = "https://api.deepseek.com",
        model = "deepseek-coder",
      },
      -- deepseek chat v3
      deepseek_chat = {
        __inherited_from = "openai",
        api_key_name = "DEEPSEEK_API_KEY",
        endpoint = "https://api.deepseek.com",
        model = "deepseek-chat",
      },
      -- deepseek r1
      deepseek_reasoner = {
        __inherited_from = "openai",
        api_key_name = "DEEPSEEK_API_KEY",
        endpoint = "https://api.deepseek.com",
        model = "deepseek-reasoner",
      },
      aliyun_qwen3 = {
        __inherited_from = "openai",
        api_key_name = "DASHSCOPE_API_KEY",
        endpoint = "https://dashscope.aliyuncs.com/compatible-mode/v1",
        -- model = "qwen-coder-plus-latest",
        model = "qwen3-235b-a22b",
      },
    },
    -- WARNING: Since auto-suggestions are a high-frequency operation and therefore expensive,
    -- currently designating it as `copilot` provider is dangerous because: https://github.com/yetone/avante.nvim/issues/1048
    -- Of course, you can reduce the request frequency by increasing `suggestion.debounce`.
    auto_suggestions_provider = "openrouter_gemini_2_flash",
    suggestion = {
      debounce = 750, -- wait for x ms before suggestion
      throttle = 1200, -- wait for at least x ms before the next suggestion
    },
  },
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = "make",
  -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    { "stevearc/dressing.nvim", optional = true },
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    { "AstroNvim/astrocore", opts = function(_, opts) opts.mappings.n[prefix] = { desc = " Avante" } end },
    --- The below dependencies are optional,
    -- "echasnovski/mini.pick", -- for file_selector provider mini.pick
    "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
    "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
    "ibhagwan/fzf-lua", -- for file_selector provider fzf
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    -- "zbirenbaum/copilot.lua", -- for providers='copilot'
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
        mappings = {
          ask = prefix .. "<CR>",
          edit = prefix .. "e",
          refresh = prefix .. "r",
          focus = prefix .. "f",
          select_model = prefix .. "?",
          stop = prefix .. "S",
          select_history = prefix .. "h",
          toggle = {
            default = prefix .. "t",
            debug = prefix .. "d",
            hint = prefix .. "h",
            suggestion = prefix .. "s",
            repomap = prefix .. "R",
          },
          diff = {
            next = "]c",
            prev = "[c",
          },
          files = {
            add_current = prefix .. ".",
            add_all_buffers = prefix .. "B",
          },
        },
      },
      specs = { -- configure optional plugins
        { "AstroNvim/astroui", opts = { icons = { Avante = "" } } },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}
