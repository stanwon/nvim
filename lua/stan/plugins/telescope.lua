local M = {
    'nvim-telescope/telescope.nvim',
    tag = 'v0.2.2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    -- 用 lazy.nvim 的 keys 机制触发加载，替换原来 init 里提前 require 的写法
    keys = {
        { '<leader>ff', '<cmd>Telescope find_files<cr>', desc = 'Telescope find files' },
        { '<leader>fg', '<cmd>Telescope live_grep<cr>', desc = 'Telescope live grep' },
        { '<leader>fb', '<cmd>Telescope buffers<cr>', desc = 'Telescope buffers' },
        { '<leader>fh', '<cmd>Telescope help_tags<cr>', desc = 'Telescope help tags' },
        { '<leader>fk', '<cmd>Telescope keymaps<cr>', desc = 'Find keymaps' },
    }
}

return M
