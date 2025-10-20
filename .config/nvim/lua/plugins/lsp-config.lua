return {
  
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "neovim/nvim-lspconfig",
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
      local mason_lspconfig = require("mason-lspconfig")
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      pcall(function()
        capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
      end)
      mason_lspconfig.setup({
        ensure_installed = { "lua_ls", "ts_ls" },
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("my-lsp-keymaps", { clear = true }),
        callback = function(ev)
          local o = { buffer = ev.buf, silent = true, noremap = true }
          vim.keymap.set("n", "K", vim.lsp.buf.hover, o)
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, o)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, o)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, o)
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, o)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, o)
          vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, o)
          vim.keymap.set("n", "]d", vim.diagnostic.goto_next, o)
          vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, o)
        end,
      })

      local servers = mason_lspconfig.get_installed_servers()
      for _, name in ipairs(servers) do
        local opts = {
          capabilities = capabilities,
        }

        if name == "lua_ls" then
          opts.settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
            },
          }
        end

        vim.lsp.config(name, opts)  
        vim.lsp.enable(name)        
      end
    end,
  },
}

