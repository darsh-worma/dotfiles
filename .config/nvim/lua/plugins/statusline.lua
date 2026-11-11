return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      -- Use plain separators and a labeled position instead of percentages.
      opts.options.section_separators = ""
      opts.options.component_separators = "|"
      opts.sections.lualine_y = {
        function()
          return string.format("Line %d of %d", vim.fn.line("."), vim.fn.line("$"))
        end,
      }
      opts.sections.lualine_z = {
        function()
          return os.date("%I:%M %p"):gsub("^0", "")
        end,
      }
    end,
  },
}
