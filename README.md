# Neovim 配置快捷键速查

> 配置文件：`~/.config/nvim`（lazy.nvim + 模块化结构）
> Leader 键：`<Space>`（空格）
> 生成日期：2026-08-20

---

## 一、全局键位（`lua/stan/keymaps.lua`）

### 窗口 / 标签页

| 键位 | 作用 |
|------|------|
| `sl` | 右分屏（vsplit） |
| `sh` | 左分屏（vsplit） |
| `sk` | 上分屏（split） |
| `sj` | 下分屏（split） |
| `gl` | 光标移到右窗口 |
| `gh` | 光标移到左窗口 |
| `gk` | 光标移到上窗口 |
| `gj` | 光标移到下窗口 |
| `th` | 上一个标签页 |
| `tl` | 下一个标签页 |

### 代码 / 编辑

| 键位 | 作用 |
|------|------|
| `gd` | LSP 跳转定义 |
| `gD` | LSP 跳转声明 |
| `gr` | LSP 查看引用 |
| `<leader>fm` | LSP 格式化当前文件 |
| `S` | 保存文件（`:write`） |
| `Q` | 退出（`:quit`） |
| `<Esc>` | 清除搜索高亮（`nohlsearch`） |

> 注意：`s`、`x` 已映射为 `<nop>`（禁用），`S` 用于保存。

---

## 二、插件快捷键

### 🚀 Telescope — 查找（`lua/stan/plugins/telescope.lua`）

| 键位 | 作用 |
|------|------|
| `<leader>ff` | 查找文件 |
| `<leader>fg` | 全文搜索（live grep） |
| `<leader>fb` | 切换缓冲区 |
| `<leader>fh` | 搜索帮助文档 |

### 🩹 Trouble — 诊断 / 列表（`lua/stan/plugins/trouble.lua`）

| 键位 | 作用 |
|------|------|
| `<leader>xx` | 所有诊断列表 |
| `<leader>xX` | 当前缓冲区诊断 |
| `<leader>xL` | 位置列表（location list） |
| `<leader>xQ` | 快速修复列表（quickfix） |
| `<leader>cs` | 符号列表（symbols） |
| `<leader>cl` | LSP 跳转记录（定义/引用等） |

### 🌳 Gitsigns — Git 操作（`lua/stan/plugins/gitsigns.lua`，buffer 内生效）

| 键位 | 模式 | 作用 |
|------|------|------|
| `]c` | n | 下一个 hunk |
| `[c` | n | 上一个 hunk |
| `<leader>hs` | n / v | 暂存 hunk（v 模式=暂存选中区域） |
| `<leader>hr` | n / v | 还原 hunk（v 模式=还原选中区域） |
| `<leader>hS` | n | 暂存整个文件 |
| `<leader>hR` | n | 还原整个文件 |
| `<leader>hp` | n | 预览 hunk |
| `<leader>hi` | n | 内联预览 hunk |
| `<leader>hb` | n | 行级 blame 信息 |
| `<leader>hd` | n | diff 当前文件 |
| `<leader>hD` | n | 与 HEAD~1 diff |
| `<leader>hQ` | n | 所有 hunk 加入 quickfix |
| `<leader>hq` | n | 当前文件 hunk 加入 quickfix |
| `<leader>tb` | n | 开关当前行 blame |
| `<leader>tw` | n | 开关单词级 diff |
| `ih` | v / o | 选中整个 hunk 的文本对象 |

### 📁 Yazi — 文件管理（`lua/stan/plugins/yazi.lua`）

| 键位 | 模式 | 作用 |
|------|------|------|
| `<leader>-` | n / v | 在当前文件位置打开 Yazi |
| `<leader>cw` | n | 在 nvim 工作目录打开 |
| `<C-up>` | n | 恢复上次的 Yazi 会话 |

### 🧘 其他插件

| 键位 | 插件 | 作用 | 位置 |
|------|------|------|------|
| `<leader>lg` | LazyGit | 打开 LazyGit | `plugins/lazygit.lua` |
| `<leader>a` | Aerial | 开关符号侧边栏 | `plugins/aerial.lua` |
| `<leader><space>` | Zen | 开关专注模式 | `plugins/zen.lua` |
| `<leader>v` | ToggleTerm | 开关终端 | `keymaps.lua` |
| `<Tab>` | Blink | 补全：插入下一个候选 | `plugins/blink.lua` |
| `<S-Tab>` | Blink | 补全：上一个候选 | `plugins/blink.lua` |

---

## 三、自动行为

> 无（启动 nvim 不再自动打开 Yazi；如需文件管理按 `<leader>-` 手动打开）

---

## 四、备忘：快捷键前缀速查

| 前缀 | 类别 |
|------|------|
| `<leader>h*` | Git 操作（Gitsigns） |
| `<leader>x*` | 诊断 / 列表（Trouble） |
| `<leader>c*` | 符号 / LSP 跳转（Trouble） |
| `<leader>f*` | 查找（Telescope） |
| `<leader>t*` | 开关类（blame / word-diff） |
| `g*` | LSP 跳转 + 窗口移动 |
| `s*` | 分屏 |

---

## 五、配置结构（`~/.config/nvim`）

```
init.lua                 # 入口：加载 lazy + options + keymaps + LSP + personal
lua/stan/
├── load_lazy.lua        # lazy.nvim 引导 + import
├── options.lua          # vim 选项
├── keymaps.lua          # 全局键位
├── personal.lua         # colorscheme + VimEnter 行为
├── ai.lua               # ⚠️ 已禁用（<S-Tab> 与 blink.cmp 冲突）
├── lsp/                 # LSP 配置（clangd / lua_ls / cmake）
└── plugins/             # 插件 spec（新增插件 = 往这里丢文件）
```

> 插件启用状态：lazy.nvim 会自动加载 `lua/stan/plugins/` 下所有文件。
> 新增插件：在 `plugins/` 目录新建一个返回 spec 的 `.lua` 文件即可，无需修改其他文件。
