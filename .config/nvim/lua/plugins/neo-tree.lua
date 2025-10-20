return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  config = function ()
    -- Toggle/reveal like you had
    vim.keymap.set('n', '<C-N>', ':Neotree filesystem reveal left toggle<CR>')

    -- Helper: focus Neo-tree if it exists; otherwise open it
    local function focus_neotree()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == "neo-tree" then
          vim.api.nvim_set_current_win(win)
          return
        end
      end
      vim.cmd("Neotree filesystem reveal left")
    end

    -- Helper: focus first non-neo-tree window (usually your code)
    local function focus_code()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype ~= "neo-tree" then
          vim.api.nvim_set_current_win(win)
          return
        end
      end
    end

    -- Ctrl+h -> focus file tree
    vim.keymap.set('n', '<C-h>', focus_neotree, { desc = "Focus Neo-tree" })

    -- Ctrl+l -> focus code window
    vim.keymap.set('n', '<C-l>', focus_code, { desc = "Focus code window" })
  end
}

