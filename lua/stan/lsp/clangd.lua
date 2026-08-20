vim.lsp.enable('clangd')
vim.lsp.config('clangd', {
    cmd = function(dispatchers, config)
        local args = { 'clangd', '--background-index' }
        -- 只在常见构建目录存在 compile_commands.json 时才指定，
        -- 否则交给 clangd 自己探测（Makefile 等项目不受影响）
        local root = vim.fs.root(0, { 'compile_commands.json', 'build', '.git' })
        if root then
            for _, dir in ipairs({ 'build', 'out', 'build/Release', 'build/Debug' }) do
                if vim.uv.fs_stat(root .. '/' .. dir .. '/compile_commands.json') then
                    table.insert(args, '--compile-commands-dir=' .. dir)
                    break
                end
            end
        end
        -- 注意：cmd 为函数时必须返回 rpc client，而不是参数数组
        -- （返回值会被直接赋给 client.rpc，参数数组没有 request 方法会崩溃）
        return vim.lsp.rpc.start(args, dispatchers, {
            cwd = config.cmd_cwd,
            env = config.cmd_env,
            detached = config.detached,
        })
    end,
})
