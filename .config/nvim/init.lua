vim.g.mapleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)


require("vim-options")
require("lazy").setup("plugins")

-- put this after your plugins load (e.g., end of init.lua)
local term_buf, term_win

local function term_escape()
  local keys = vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true)
  vim.api.nvim_feedkeys(keys, "n", false)
end

local function open_term()
  vim.cmd("botright 15split")
  if not (term_buf and vim.api.nvim_buf_is_valid(term_buf)) then
    vim.cmd("terminal")
    term_buf = vim.api.nvim_get_current_buf()
  else
    vim.api.nvim_win_set_buf(0, term_buf)
  end
  term_win = vim.api.nvim_get_current_win()
  vim.cmd("startinsert")
end

local function close_term_win()
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_win_close(term_win, true)
    term_win = nil
  end
end

local function toggle_term()
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    close_term_win()
  else
    open_term()
  end
end

-- Alt+h: toggle (works in normal & terminal)
vim.keymap.set({ "n", "t" }, "<A-h>", function()
  if vim.fn.mode() == "t" then term_escape() end
  toggle_term()
end, { desc = "Toggle bottom terminal", silent = true })

-- Ctrl-j (NORMAL): focus terminal (reuse session), open if needed
vim.keymap.set("n", "<C-j>", function()
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_set_current_win(term_win)
  elseif term_buf and vim.api.nvim_buf_is_valid(term_buf) then
    open_term()                          -- re-show existing terminal buffer
  else
    open_term()                          -- create new terminal
  end
  vim.cmd("startinsert")
end, { desc = "Focus terminal", silent = true })

-- Ctrl-k (TERMINAL): go back to code (up), keep terminal open
vim.keymap.set("t", "<C-k>", function()
  term_escape()
  vim.cmd("wincmd k")                    -- move to the window above
end, { desc = "From terminal → code", silent = true })

