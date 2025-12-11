local opts = { noremap = true }

-- split window
vim.keymap.set('n', 'sl', ':set splitright<cr>:vsplit<cr>', opts)
vim.keymap.set('n', 'sh', ':set nosplitright<cr>:vsplit<cr>:set splitright<cr>', opts)
vim.keymap.set('n', 'sk', ':set nosplitbelow<cr>:split<cr>:set splitbelow<cr>', opts)
vim.keymap.set('n', 'sj', ':set splitbelow<cr>:split<cr>', opts)

-- move cursor around the windows
vim.keymap.set('n', 'gl', ':wincmd l<cr>', opts)
vim.keymap.set('n', 'gh', ':wincmd h<cr>', opts)
vim.keymap.set('n', 'gk', ':wincmd k<cr>', opts)
vim.keymap.set('n', 'gj', ':wincmd j<cr>', opts)

-- move cursor around the tabs
vim.keymap.set('n', 'th', ':tabNext<cr>', opts)
vim.keymap.set('n', 'tl', ':tabprevious<cr>', opts)

-- code
vim.keymap.set('n', 'gr', ':lua vim.lsp.buf.references()<cr>', opts)
vim.keymap.set('n', 'gd', ':lua vim.lsp.buf.definition()<cr>', opts)
vim.keymap.set('n', 'gD', ':lua vim.lsp.buf.declaration()<cr>', opts)
vim.keymap.set('n', '<leader>fm', ':lua vim.lsp.buf.format()<cr>', opts)

-- other
vim.keymap.set('n', 'S', ':write<cr>', opts)
vim.keymap.set('n', 'Q', ':quit<cr>', opts)
vim.keymap.set('n', 's', '<nop>', opts)
vim.keymap.set('n', 'x', '<nop>', opts)
vim.keymap.set({ 'n', 'v' }, '<esc>', ':nohlsearch<cr>', opts)

-- plugins
vim.keymap.set('n', '<leader>v', ':ToggleTerm<cr>', opts)
