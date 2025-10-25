return {
  {
    dir = '~/plugins/present.nvim',
    cond = function()
      return vim.fn.isdirectory(vim.fn.expand '~/plugins/present.nvim') == 1
    end,
  },
  {
    dir = '~/plugins/dev-buck.nvim',
    cond = function()
      return vim.fn.isdirectory(vim.fn.expand '~/plugins/dev-buck.nvim') == 1
    end,
  },
  {
    dir = '~/plugins/buck2.nvim',
    cond = function()
      return vim.fn.isdirectory(vim.fn.expand '~/plugins/buck2.nvim') == 1
    end,
  },
}
