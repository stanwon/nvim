-- 窗口分屏
vim.keymap.set('n', 'sl', ':set splitright<cr>:vsplit<cr>', { noremap = true, desc = '右分屏' })
vim.keymap.set('n', 'sh', ':set nosplitright<cr>:vsplit<cr>:set splitright<cr>', { noremap = true, desc = '左分屏' })
vim.keymap.set('n', 'sk', ':set nosplitbelow<cr>:split<cr>:set splitbelow<cr>', { noremap = true, desc = '上分屏' })
vim.keymap.set('n', 'sj', ':set splitbelow<cr>:split<cr>', { noremap = true, desc = '下分屏' })

-- 窗口间移动光标
vim.keymap.set('n', 'gl', ':wincmd l<cr>', { noremap = true, desc = '移到右窗口' })
vim.keymap.set('n', 'gh', ':wincmd h<cr>', { noremap = true, desc = '移到左窗口' })
vim.keymap.set('n', 'gk', ':wincmd k<cr>', { noremap = true, desc = '移到上窗口' })
vim.keymap.set('n', 'gj', ':wincmd j<cr>', { noremap = true, desc = '移到下窗口' })

-- 标签页切换
vim.keymap.set('n', 'th', ':tabprevious<cr>', { noremap = true, desc = '上一个标签页' })
vim.keymap.set('n', 'tl', ':tabnext<cr>', { noremap = true, desc = '下一个标签页' })

-- 代码
vim.keymap.set('n', 'gr', ':lua vim.lsp.buf.references()<cr>', { noremap = true, desc = 'LSP 查找引用' })
vim.keymap.set('n', 'gd', ':lua vim.lsp.buf.definition()<cr>', { noremap = true, desc = 'LSP 跳转定义' })
vim.keymap.set('n', 'gD', ':lua vim.lsp.buf.declaration()<cr>', { noremap = true, desc = 'LSP 跳转声明' })
vim.keymap.set('n', '<leader>fm', ':lua vim.lsp.buf.format()<cr>', { noremap = true, desc = '格式化代码' })

-- 其他
--vim.keymap.set('n', '<leader>j', ':lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())<cr>', { noremap = true, desc = '开关内联提示' })
vim.keymap.set('n', 'S', ':write<cr>', { noremap = true, desc = '保存文件' })
vim.keymap.set('n', 'Q', ':quit<cr>', { noremap = true, desc = '退出' })
vim.keymap.set('n', 's', '<nop>', { noremap = true, desc = '禁用 s（原替换字符）' })
vim.keymap.set('n', 'x', '<nop>', { noremap = true, desc = '禁用 x（原删除字符）' })
vim.keymap.set('n', '<esc>', ':nohlsearch<cr>', { noremap = true, desc = '清除搜索高亮' })

-- 插件
vim.keymap.set('n', '<leader>v', ':ToggleTerm<cr>', { noremap = true, desc = '开关终端' })
