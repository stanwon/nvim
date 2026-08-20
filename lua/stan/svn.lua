-- SVN 集成：查看文件变动与 diff（零依赖）
-- <leader>ss  SVN 状态树（变动 + unversioned 分区，toggle）
--             目录行回车 = 折叠/展开；文件行回车 = 打开
--             M/D 状态 → BASE 对比；A/? 状态 → 普通打开
--             焦点留在树窗口，关闭后重开恢复光标位置

local function svn_cmd(args)
    local out = vim.fn.system({ "svn", unpack(args) })
    if vim.v.shell_error ~= 0 then
        vim.notify("svn " .. table.concat(args, " ") .. " 失败：\n" .. out, vim.log.levels.ERROR)
        return nil
    end
    return out
end

-- 关闭所有残留的对比视图（BASE 窗口 + diff 模式）
local function close_all_compare()
    vim.cmd("diffoff!")
    for _, w in ipairs(vim.api.nvim_list_wins()) do
        local b = vim.api.nvim_win_get_buf(w)
        if vim.api.nvim_buf_get_name(b):match("^svn://BASE/") then
            pcall(vim.keymap.del, "n", "<Esc>", { buffer = b })
            vim.api.nvim_win_close(w, true)
        end
    end
end

-- 打开文件的 SVN 对比（左 BASE 右工作区），按 <Esc> 退出
local function svn_compare(file)
    close_all_compare()

    local work_buf = vim.api.nvim_get_current_buf()

    local out = vim.fn.system({ "svn", "cat", file })
    if vim.v.shell_error ~= 0 then
        vim.notify("svn cat 失败：\n" .. out, vim.log.levels.ERROR)
        return
    end

    -- 左侧窗口：BASE 版本（只读临时 buffer）
    local base_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(base_buf, 0, -1, false, vim.split(out, "\n", { plain = true }))
    vim.bo[base_buf].buftype = "nofile"
    vim.bo[base_buf].bufhidden = "wipe"
    vim.bo[base_buf].modified = false
    vim.bo[base_buf].filetype = vim.bo[work_buf].filetype
    vim.api.nvim_buf_set_name(base_buf, "svn://BASE/" .. vim.fn.fnamemodify(file, ":t"))
    vim.api.nvim_win_set_buf(0, base_buf)

    -- 右侧窗口：工作区文件
    vim.cmd("rightbelow vnew")
    vim.bo.buflisted = false -- 临时空 buffer 不进 bufferline
    vim.api.nvim_win_set_buf(0, work_buf)

    -- 退出对比：关闭 diff 模式 + 关闭 BASE 窗口 + 清理临时映射
    local function close_svn_diff()
        vim.cmd("diffoff!")
        pcall(vim.keymap.del, "n", "<Esc>", { buffer = work_buf })
        pcall(vim.keymap.del, "n", "<Esc>", { buffer = base_buf })
        if vim.api.nvim_buf_is_valid(base_buf) then
            for _, w in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_get_buf(w) == base_buf and vim.api.nvim_win_is_valid(w) then
                    vim.api.nvim_win_close(w, true)
                end
            end
        end
    end
    vim.keymap.set("n", "<Esc>", close_svn_diff, { buffer = base_buf, desc = "退出 SVN 对比" })
    vim.keymap.set("n", "<Esc>", close_svn_diff, { buffer = work_buf, desc = "退出 SVN 对比" })

    vim.cmd("diffthis")
    vim.cmd("wincmd p")
    vim.cmd("diffthis")
    vim.cmd("wincmd p")
end

-- 把 svn status 输出解析成条目（全部状态，含 unversioned）
local function status_to_items(out)
    local items = {}
    for line in out:gmatch("[^\r\n]+") do
        local status, path = line:match("^(%S)%s+(.+)$")
        if path then
            -- 跳过目录条目（树形结构由文件路径自动推导）
            -- 注意：isdirectory 返回数字 1/0，必须显式比较（0 在 Lua 中是 truthy）
            if vim.fn.isdirectory(path) == 1 then goto continue end
            table.insert(items, { path = path, status = status, text = line })
        end
        ::continue::
    end
    return items
end

-- 构建一组条目的树形行（目录行带 dir_path 用于折叠）
local function build_tree_lines(items)
    local root = {}
    for _, item in ipairs(items) do
        local parts = vim.split(item.path, "/")
        local node = root
        for i = 1, #parts - 1 do
            node[parts[i]] = node[parts[i]] or {}
            node = node[parts[i]]
        end
        node[parts[#parts]] = item
    end

    local lines = {} -- { indent, label, path?, status?, is_dir?, dir_path? }
    local function walk(node, indent, dir_path)
        local keys = vim.tbl_keys(node)
        table.sort(keys)
        for _, k in ipairs(keys) do
            local v = node[k]
            if v.path then
                table.insert(lines, { indent = indent, label = k, path = v.path, status = v.status })
            else
                local dp = dir_path == "" and k or (dir_path .. "/" .. k)
                table.insert(lines, { indent = indent, label = k .. "/", is_dir = true, dir_path = dp })
                walk(v, indent + 1, dp)
            end
        end
    end
    walk(root, 0, "")
    return lines
end

-- 构建分区行：变动区 + 未版本控制区
local function build_sections(items)
    local changed, unversioned = {}, {}
    for _, item in ipairs(items) do
        if item.status == "?" then
            table.insert(unversioned, item)
        else
            table.insert(changed, item)
        end
    end

    local lines = {} -- { indent, label, path?, status?, is_dir?, is_section? }
    if #changed > 0 then
        table.insert(lines, { is_section = true, label = string.format("─ 变动 (%d) ─", #changed) })
        for _, l in ipairs(build_tree_lines(changed)) do table.insert(lines, l) end
    end
    if #unversioned > 0 then
        table.insert(lines, { is_section = true, label = string.format("─ 未版本控制 (%d) ─", #unversioned) })
        for _, l in ipairs(build_tree_lines(unversioned)) do table.insert(lines, l) end
    end
    return lines
end

-- 统计目录行后面的子行数（遇到 indent <= 目录或 section 停止）
local function count_children(lines, idx)
    local dir = lines[idx]
    local count = 0
    for j = idx + 1, #lines do
        local l = lines[j]
        if l.is_section then break end
        if (l.indent or 0) <= (dir.indent or 0) then break end
        count = count + 1
    end
    return count
end

-- SVN 树高亮命名空间与颜色组（everforest 色板）
local svn_ns = vim.api.nvim_create_namespace("svn_tree")
local groups_ready = false
local function ensure_groups()
    if groups_ready then return end
    groups_ready = true
    local function set(name, fg, extra)
        local opts = { fg = fg }
        if extra then for k, v in pairs(extra) do opts[k] = v end end
        vim.api.nvim_set_hl(0, name, opts)
    end
    set("SvnStatusM", "#dbbc7f")              -- 修改：黄
    set("SvnStatusA", "#a7c080")              -- 新增：绿
    set("SvnStatusD", "#e67e80")              -- 删除：红
    set("SvnStatusQ", "#9da9a0")              -- 未版本控制：灰
    set("SvnDir", "#7fbbb3")                  -- 目录：蓝
    set("SvnSection", "#9da9a0", { italic = true }) -- 分区标题：灰斜体
end

local status_group = {
    M = "SvnStatusM",
    A = "SvnStatusA",
    D = "SvnStatusD",
    ["?"] = "SvnStatusQ",
}

-- 获取 nvim-web-devicons（未加载时先 lazy 加载）
local devicons
local function get_devicons()
    if devicons then return devicons end
    local ok, mod = pcall(require, "nvim-web-devicons")
    if not ok then
        pcall(function() require("lazy").load({ plugins = { "nvim-web-devicons" } }) end)
        ok, mod = pcall(require, "nvim-web-devicons")
    end
    devicons = ok and mod or nil
    return devicons
end

-- 重绘树 buffer（应用折叠状态 + 文件图标）
local function render_tree(buf)
    local lines = vim.b[buf].tree_lines
    local folded = vim.b[buf].tree_folded or {}
    local icons = get_devicons()

    local visible = {} -- 可见行的原索引
    local skip = 0
    for i, l in ipairs(lines) do
        if skip > 0 then
            skip = skip - 1
        else
            table.insert(visible, i)
            if l.is_dir and folded[l.dir_path] then
                skip = count_children(lines, i)
            end
        end
    end

    local buflines = {}
    for _, i in ipairs(visible) do
        local l = lines[i]
        if l.is_section then
            table.insert(buflines, l.label)
        else
            local prefix = string.rep("  ", l.indent)
            local marker = ""
            local icon = ""
            if l.is_dir then
                marker = folded[l.dir_path] and "▸ " or "▾ "
                icon = "\u{f07b} " -- 文件夹图标
                table.insert(buflines, prefix .. marker .. icon .. l.label)
            elseif icons then
                local ext = l.label:match("%.([^%.]+)$") or ""
                icon = (icons.get_icon(l.label, ext) or "\u{f016}") .. " " -- 文件图标
                -- 状态字母在图标前：`M  readme.md`
                table.insert(buflines, prefix .. (l.status or " ") .. "  " .. icon .. l.label)
            else
                table.insert(buflines, prefix .. (l.status or " ") .. "  " .. l.label)
            end
        end
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, buflines)
    vim.b[buf].tree_visible = visible

    -- 高亮：分区标题 / 目录 / 状态列（状态字母在行首缩进之后）
    ensure_groups()
    vim.api.nvim_buf_clear_namespace(buf, svn_ns, 0, -1)
    for row, i in ipairs(visible) do
        local l = lines[i]
        if l.is_section then
            vim.api.nvim_buf_add_highlight(buf, svn_ns, "SvnSection", row - 1, 0, -1)
        elseif l.is_dir then
            vim.api.nvim_buf_add_highlight(buf, svn_ns, "SvnDir", row - 1, 0, -1)
        elseif l.status then
            local g = status_group[l.status]
            if g then
                local start = string.rep("  ", l.indent):len() -- 缩进的字节长度
                vim.api.nvim_buf_add_highlight(buf, svn_ns, g, row - 1, start, start + #l.status)
            end
        end
    end
end

-- 左侧树形窗口显示 SVN 列表
local function open_tree(title, items, compare_on_enter)
    if #items == 0 then
        vim.notify("SVN 无匹配条目", vim.log.levels.INFO)
        return
    end

    local lines = build_sections(items)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.b[buf].tree_lines = lines
    vim.b[buf].tree_folded = {}
    vim.b[buf].tree_visible = {}

    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].modified = false
    vim.api.nvim_buf_set_name(buf, title)

    -- 左侧窗口打开（:new 的临时空 buffer 设为 unlisted，不进 bufferline）
    vim.cmd("vertical topleft new")
    vim.bo.buflisted = false
    vim.api.nvim_win_set_buf(0, buf)
    vim.cmd("vertical resize 40")

    render_tree(buf)

    -- 回车：目录 = 折叠/展开；文件 = 打开（焦点留在树）
    vim.keymap.set("n", "<CR>", function()
        local cur = vim.api.nvim_get_current_buf()
        local idx = (vim.b[cur].tree_visible or {})[vim.fn.line(".")]
        local l = idx and vim.b[cur].tree_lines[idx]
        if not l then return end

        if l.is_dir then
            -- 注意：vim.b[buf] 的表修改必须写回（直接改索引不保留）
            local folded = vim.b[cur].tree_folded
            folded[l.dir_path] = not folded[l.dir_path]
            vim.b[cur].tree_folded = folded
            render_tree(cur)
        elseif l.path then
            -- 先清理旧对比，再在主窗口打开
            close_all_compare()
            vim.cmd("wincmd l")
            vim.cmd("edit " .. vim.fn.fnameescape(l.path))
            if compare_on_enter and l.status ~= "A" and l.status ~= "?" then
                svn_compare(l.path)
            end
            -- 焦点回到树窗口（j/k 继续浏览）
            for _, w in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w)):match("SVN") then
                    vim.api.nvim_set_current_win(w)
                    break
                end
            end
        end
    end, { buffer = true, desc = "打开文件/折叠目录" })

    -- Esc：关闭列表（关窗口 + 删 buffer）
    vim.keymap.set("n", "<Esc>", function()
        local b = vim.api.nvim_get_current_buf()
        vim.cmd("q")
        pcall(vim.api.nvim_buf_delete, b, { force = true })
    end, { buffer = true, desc = "关闭列表" })

    -- 光标：恢复上次位置，否则定位到第一个文件行（用可见行映射）
    local target = vim.g.svn_tree_cursor
    local target_line
    if target then
        for vi, i in ipairs(vim.b[buf].tree_visible) do
            if vim.b[buf].tree_lines[i].path == target then
                target_line = vi
                break
            end
        end
    end
    if not target_line then
        for vi, i in ipairs(vim.b[buf].tree_visible) do
            if vim.b[buf].tree_lines[i].path then
                target_line = vi
                break
            end
        end
    end
    if target_line then
        vim.api.nvim_win_set_cursor(0, { target_line, 0 })
    end
end

-- toggle 打开/关闭树（记住光标位置）
local function open_or_toggle_tree(title, items, compare_on_enter)
    for _, w in ipairs(vim.api.nvim_list_wins()) do
        local b = vim.api.nvim_win_get_buf(w)
        local name = vim.api.nvim_buf_get_name(b)
        if name:match("SVN") then
            -- 已打开：toggle 关闭，记住光标所在文件
            local lines = vim.b[b].tree_lines or {}
            local idx = (vim.b[b].tree_visible or {})[vim.fn.line(".")]
            local cur = idx and lines[idx] or nil
            vim.g.svn_tree_cursor = cur and cur.path or nil
            vim.api.nvim_win_close(w, true)
            pcall(vim.api.nvim_buf_delete, b, { force = true })
            return true
        end
    end
    if #items == 0 then
        vim.notify("SVN 无匹配条目", vim.log.levels.INFO)
        return false
    end
    open_tree(title, items, compare_on_enter)
    return false
end

-- SVN 状态树（变动 + unversioned 分区，toggle）
vim.keymap.set("n", "<leader>ss", function()
    local out = svn_cmd({ "status" })
    if not out then return end

    local items = status_to_items(out)
    local changed, unversioned = 0, 0
    for _, it in ipairs(items) do
        if it.status == "?" then
            unversioned = unversioned + 1
        else
            changed = changed + 1
        end
    end
    local title = string.format("SVN Status (%d 变动, %d 未版本控制)", changed, unversioned)
    local closed = open_or_toggle_tree(title, items, true)
    if closed then return end
    if #items == 0 then
        vim.notify("SVN 工作区无变动", vim.log.levels.INFO)
    end
end, { noremap = true, desc = "SVN 状态树" })
