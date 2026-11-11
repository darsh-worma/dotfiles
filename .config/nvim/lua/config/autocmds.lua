-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Auto-wrap regular text in prose filetypes; elsewhere only comments wrap.
local prose = { markdown = true, text = true, gitcommit = true }
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("user_prose_wrap", { clear = true }),
  callback = function(event)
    if prose[event.match] then
      vim.opt_local.formatoptions:append("t")
    else
      vim.opt_local.formatoptions:remove("t")
    end
  end,
})

-- Save named, editable files after one second without changes.
-- Keep formatting-on-save out of background writes while typing.
local autosave_group = vim.api.nvim_create_augroup("user_autosave", { clear = true })
local pending = {}

local function save_buffer(buf)
  if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_buf_is_loaded(buf) then
    return
  end
  local opts = vim.bo[buf]
  if opts.buftype ~= "" or not opts.modifiable or opts.readonly or not opts.modified then
    return
  end
  if vim.api.nvim_buf_get_name(buf) == "" then
    return
  end
  local ok, err = pcall(vim.api.nvim_buf_call, buf, function()
    vim.cmd("silent noautocmd update")
  end)
  if not ok then
    vim.notify("Autosave failed: " .. tostring(err), vim.log.levels.WARN)
  end
end

vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "TextChangedP" }, {
  group = autosave_group,
  callback = function(event)
    local token = {}
    pending[event.buf] = token
    vim.defer_fn(function()
      if pending[event.buf] == token then
        pending[event.buf] = nil
        save_buffer(event.buf)
      end
    end, 1000)
  end,
})

vim.api.nvim_create_autocmd({ "InsertLeave", "BufLeave" }, {
  group = autosave_group,
  callback = function(event)
    pending[event.buf] = nil
    save_buffer(event.buf)
  end,
})

vim.api.nvim_create_autocmd("FocusLost", {
  group = autosave_group,
  callback = function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      pending[buf] = nil
      save_buffer(buf)
    end
  end,
})

vim.api.nvim_create_autocmd("BufWipeout", {
  group = autosave_group,
  callback = function(event)
    pending[event.buf] = nil
  end,
})
