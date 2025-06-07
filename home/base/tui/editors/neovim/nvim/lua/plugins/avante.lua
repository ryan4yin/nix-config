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
    provider = "openrouter_claude_4",
    cursor_applying_provider = "openrouter_claude_4",
    behaviour = {
      -- auto_suggestions = true,
      enable_cursor_planning_mode = true, -- enable cursor planning mode!
    },
    -- WARNING: Since auto-suggestions are a high-frequency operation and therefore expensive,
    -- currently designating it as `copilot` provider is dangerous because: https://github.com/yetone/avante.nvim/issues/1048
    -- Of course, you can reduce the request frequency by increasing `suggestion.debounce`.
    auto_suggestions_provider = "ollama",
    suggestion = {
      debounce = 750, -- wait for x ms before suggestion
      throttle = 1200, -- wait for at least x ms before the next suggestion
    },
    web_search_engine = {
      provider = "google", -- tavily, serpapi, searchapi, google, kagi, brave, or searxng
      proxy = nil, -- proxy support, e.g., http://127.0.0.1:7890
    },

    providers = {
      ollama = {
        endpoint = "http://192.168.5.100:11434", -- Note that there is no /v1 at the end.
        model = "modelscope.cn/unsloth/Qwen3-30B-A3B-GGUF",
        -- model = "modelscope.cn/unsloth/Qwen3-32B-GGUF",
      },
      -- ==============================================
      -- https://aistudio.google.com/prompts/new_chat
      -- ==============================================
      gemini = {
        api_key_name = "GEMINI_API_KEY",
        model = "gemini-2.5-pro-preview-06-05",
        timeout = 30000, -- Timeout in milliseconds, increase this for reasoning models
        temperature = 0,
        max_completion_tokens = 8192, -- Increase this to include reasoning tokens (for reasoning models)
        --reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
      },
      -- ==============================================
      -- https://openrouter.ai/rankings
      -- ==============================================
      openrouter_claude_4 = {
        __inherited_from = "openai",
        endpoint = "https://openrouter.ai/api/v1",
        api_key_name = "OPENROUTER_API_KEY",
        model = "anthropic/claude-sonnet-4",
      },
      -- ==============================================
      -- https://bailian.console.aliyun.com/?tab=model
      -- ==============================================
      aliyun_qwen3 = {
        __inherited_from = "openai",
        api_key_name = "DASHSCOPE_API_KEY",
        endpoint = "https://dashscope.aliyuncs.com/compatible-mode/v1",
        -- model = "qwen-coder-plus-latest",
        model = "qwen3-235b-a22b",
        -- disable_tools = true,
      },
      aliyun_dpr1 = {
        __inherited_from = "openai",
        api_key_name = "DASHSCOPE_API_KEY",
        endpoint = "https://dashscope.aliyuncs.com/compatible-mode/v1",
        model = "deepseek-r1-0528",
        disable_tools = true,
      },
      -- ==============================================
      -- https://console.volcengine.com/ark/region:ark+cn-beijing/model?feature=&vendor=DeepSeek&view=VENDOR_VIEW
      -- ==============================================
      ark_dpr1 = {
        __inherited_from = "openai",
        api_key_name = "ARK_API_KEY",
        endpoint = "https://ark.cn-beijing.volces.com/api/v3",
        model = "deepseek-r1-250528",
        -- disable_tools = true,
      },
      -- ==============================================
      -- https://cloud.siliconflow.cn/models
      -- ==============================================
      sflow_dpr1 = {
        __inherited_from = "openai",
        api_key_name = "SILICONFLOW_API_KEY",
        endpoint = "https://api.siliconflow.cn/v1",
        model = "Pro/deepseek-ai/DeepSeek-R1",
        -- disable_tools = true,
      },
      -- ==============================================
      -- https://platform.deepseek.com/usage
      -- ==============================================
      dp_coder = {
        __inherited_from = "openai",
        api_key_name = "DEEPSEEK_API_KEY",
        endpoint = "https://api.deepseek.com",
        model = "deepseek-coder",
      },
      -- deepseek chat v3
      dp_chat = {
        __inherited_from = "openai",
        api_key_name = "DEEPSEEK_API_KEY",
        endpoint = "https://api.deepseek.com",
        model = "deepseek-chat",
        -- disable_tools = true,
      },
      -- deepseek r1
      dp_r1 = {
        __inherited_from = "openai",
        api_key_name = "DEEPSEEK_API_KEY",
        endpoint = "https://api.deepseek.com",
        model = "deepseek-reasoner",
        -- disable_tools = true,
      },
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
      -- Make sure to set this up properly if you have lazy=true
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}
