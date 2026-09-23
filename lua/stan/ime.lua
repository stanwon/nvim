-- 远程 nvim 输入法自动切换（配合 Windows 端 im-server.ps1 使用）
-- 原理：SSH 反向端口转发 4455 -> Windows 本地监听服务
-- 行为：
--   离开插入/命令行模式（按 Esc）-> 切回英文 (1033)
--   进入插入模式 -> 不做任何切换（保持当前输入法）

local BRIDGE_URL = os.getenv("IME_BRIDGE_URL") or "http://127.0.0.1:4455"
local EN_US = "1033" -- en-US；若你的英文键盘语言不是 1033，用 im-select.exe 查一下改这里
local DEBUG_FILE = "/tmp/ime_debug.log"

-- 调试日志（排查问题时用）
local function dbg(...)
  local parts = {}
  for _, v in ipairs({ ... }) do
    parts[#parts + 1] = type(v) == "string" and v or vim.inspect(v)
  end
  local f = io.open(DEBUG_FILE, "a")
  if f then
    f:write(os.date("%H:%M:%S") .. " " .. table.concat(parts, " ") .. "\n")
    f:close()
  end
end

local function http_get(path)
  -- --noproxy '*' 很重要: 若服务器配置了 http_proxy 环境变量，访问 127.0.0.1 也会被代理拦截
  local out = vim.fn.system("curl -s --noproxy '*' --max-time 2 " .. BRIDGE_URL .. "/" .. path)
  local raw = out or ""
  -- 兼容两种响应：标准 HTTP（curl 只保留 body）或旧版桥接（BOM+完整响应头被当作 body）
  -- 从响应头结束后提取正文；提取不到就当全量是正文
  local body = raw:match("\r\n\r\n(.*)$") or raw
  -- 去掉空白和 UTF-8 BOM(\239\187\191)
  local clean = body:gsub("[%s\r\n\239\187\191]", "")
  dbg("GET /" .. path .. " raw=" .. vim.inspect(raw) .. " clean=" .. vim.inspect(clean))
  return clean
end

local function set_im(im)
  dbg("SET /" .. im)
  vim.fn.system("curl -s --noproxy '*' --max-time 2 -o /dev/null " .. BRIDGE_URL .. "/set/" .. im)
end

local function is_en(im)
  return im == EN_US
end

-- 离开插入/命令行模式：切回英文
local function on_leave(event)
  local im = http_get("get")
  if im == "" then
    dbg(event, "get failed, skip")
    return
  end
  if is_en(im) then
    dbg(event, "im=", im, "already EN, nothing to do")
    return
  end
  set_im(EN_US)
  dbg(event, "im=", im, "switched to EN")
end

local group = vim.api.nvim_create_augroup("ImeSwitch", { clear = true })
vim.api.nvim_create_autocmd({ "InsertLeave", "CmdlineLeave" }, {
  group = group,
  callback = function(e)
    on_leave(e.event)
  end,
})
