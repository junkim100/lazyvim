-- Run with: nvim --headless -i NONE -c "luafile tests/bigfile.lua"
local root = vim.fn.fnamemodify(vim.fn.resolve(vim.fn.tempname()), ":p")
vim.fn.mkdir(root, "p")
root = assert(vim.uv.fs_realpath(root))
local failures = {}
local notifications = {}
local notify = vim.notify
vim.notify = function(message, ...)
  notifications[#notifications + 1] = message
  return notify(message, ...)
end
local function check(condition, message)
  if not condition then
    failures[#failures + 1] = message
  end
end
local function open(name, lines)
  local path = root .. "/" .. name
  vim.fn.writefile(lines, path)
  vim.fn.system({ "git", "-C", root, "add", "--", name })
  assert(vim.v.shell_error == 0, "could not track fixture")
  vim.cmd.edit(vim.fn.fnameescape(path))
  vim.wait(100, function()
    return false
  end)
  return vim.api.nvim_get_current_buf()
end
local function minimap_visible()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "neominimap" then
      return true
    end
  end
  return false
end
local function check_large(buf, label)
  check(vim.bo[buf].filetype == "bigfile", label .. ": large-file detection")
  check(vim.wo.wrap == false and vim.wo.linebreak == false, label .. ": expensive wrapping disabled")
  check(vim.bo[buf].syntax == "", label .. ": syntax stays off after scheduled callbacks")
  check(vim.wo.foldmethod == "manual" and vim.wo.foldenable == false, label .. ": folding disabled")
  check(
    vim.b[buf].completion == false and vim.b[buf].autoformat == false,
    label .. ": completion and automatic formatting disabled"
  )
  check(
    vim.bo[buf].undofile == false and vim.bo[buf].undolevels ~= -1,
    label .. ": no persistent undo but editing undo retained"
  )
  check(#vim.lsp.get_clients({ bufnr = buf }) == 0, label .. ": no language server")
  check(vim.treesitter.highlighter.active[buf] == nil, label .. ": no Tree-sitter highlighter")
  check(not require("neominimap.buffer.internal").should_generate_minimap(buf), label .. ": no minimap")
  check(
    vim.wait(1000, function()
      return not minimap_visible()
    end),
    label .. ": minimap sidebar hidden"
  )
  vim.api.nvim_win_set_cursor(0, { 1, 3 })
  vim.api.nvim_exec_autocmds("CursorMoved", { buffer = buf })
  vim.wait(350, function()
    return false
  end)
  check(#require("illuminate.reference").buf_get_references(buf) == 0, label .. ": no word-reference scan")
  check(require("gitsigns").get_hunks(buf) == nil, label .. ": no Git diff attachment")
end
local ok, err = xpcall(function()
  vim.fn.system({ "git", "init", "-q", root })
  assert(vim.v.shell_error == 0, "could not initialize fixture repository")
  -- Exercise normal file detection and scheduled plugin callbacks, without mocking the big-file handler.
  local words = open("words.txt", { "needle needle", "needle" })
  vim.api.nvim_win_set_cursor(0, { 1, 2 })
  vim.api.nvim_exec_autocmds("CursorMoved", { buffer = words })
  check(
    vim.wait(1000, function()
      return #require("illuminate.reference").buf_get_references(words) == 3
    end),
    "ordinary file: word-reference highlighting remains active"
  )
  local row = '{"content":"' .. string.rep("x", 1100) .. '"}'
  local big = open("large.jsonl", vim.fn["repeat"]({ row }, 1600))
  check_large(big, "large file")
  local small = open("small.lua", { "local answer = 42", "return answer" })
  check(
    vim.wait(2000, function()
      return require("gitsigns").get_hunks(small) ~= nil
    end),
    "ordinary tracked file: Git signs remain attached"
  )
  check(vim.bo[small].filetype == "lua", "ordinary file: correct filetype")
  check(vim.wo.wrap and vim.wo.linebreak, "ordinary file: wrapping preserved")
  check(vim.bo[small].undofile and vim.b[small].autoformat ~= false, "ordinary file: undo and formatting preserved")
  check(vim.wait(1000, minimap_visible), "ordinary file: minimap sidebar restored")
  -- Opening an existing large buffer in a new split must keep its inexpensive window settings.
  vim.cmd.sbuffer(big)
  check_large(big, "large buffer in a split")
  vim.cmd.close()
  check(vim.wait(1000, minimap_visible), "ordinary file after closing large split: minimap sidebar restored")
  local long = open("long-line.jsonl", { '{"content":"' .. string.rep("x", 12000) .. '"}' })
  check_large(long, "small file with long line")
  local messages = table.concat(notifications, "\n")
  check(not messages:find("Big file detected", 1, true), "no startup warning requiring acknowledgement")
end, debug.traceback)
if not ok then
  failures[#failures + 1] = err
end
vim.notify = notify
vim.cmd("silent! %bwipeout!")
vim.fn.delete(root, "rf")
if #failures > 0 then
  io.stderr:write(table.concat(failures, "\n") .. "\n")
  vim.cmd("cquit 1")
else
  print("large-file regression checks passed")
  vim.cmd("qa!")
end
