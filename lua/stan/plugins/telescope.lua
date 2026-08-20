local M = {
    'nvim-telescope/telescope.nvim',
    tag = 'v0.2.2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    -- 用 lazy.nvim 的 keys 机制触发加载，替换原来 init 里提前 require 的写法
    keys = {
        { '<leader>ff', '<cmd>Telescope find_files<cr>', desc = '查找文件' },
        { '<leader>fg', '<cmd>Telescope live_grep<cr>', desc = '全文搜索' },
        { '<leader>fb', '<cmd>Telescope buffers<cr>', desc = '切换缓冲区' },
        { '<leader>fh', '<cmd>Telescope help_tags<cr>', desc = '搜索帮助文档' },
        { '<leader>fk', '<cmd>Telescope keymaps<cr>', desc = '查找键位' },
    }
}

return M
