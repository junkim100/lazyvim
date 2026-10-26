return {
  -- MOD 6 -- show dotfiles by default in the explorer, file finder, and grep.
  --
  -- snacks defaults `hidden = false`, which hides anything starting with a dot.
  -- That makes the explorer close to useless in a dotfiles repo, and it also hides
  -- .github/, .claude/, .env, and friends in normal projects.
  --
  -- Show gitignored files and directories in the explorer as well.
  -- File finding and grep still respect ignore rules to keep results focused.
  -- Press H in the explorer to toggle hidden files, or I to toggle ignored files.
  {
    "folke/snacks.nvim",
    opts = {
      -- MOD 24 -- keep large logs inexpensive to display, including JSONL records with megabyte-long lines.
      bigfile = {
        notify = false,
        setup = function(ctx)
          if vim.fn.exists(":NoMatchParen") ~= 0 then
            vim.cmd.NoMatchParen()
          end
          Snacks.util.wo(0, {
            wrap = false,
            linebreak = false,
            foldmethod = "manual",
            foldenable = false,
            statuscolumn = "",
            conceallevel = 0,
          })
          -- Replace the default setup: it schedules syntax highlighting to turn back on after detection.
          vim.bo[ctx.buf].syntax = ""
          vim.bo[ctx.buf].undofile = false
          vim.b[ctx.buf].completion = false
          vim.b[ctx.buf].autoformat = false
          vim.b[ctx.buf].minianimate_disable = true
          vim.b[ctx.buf].minihipatterns_disable = true
          vim.treesitter.stop(ctx.buf)
        end,
      },
      -- MOD 22 -- delete directly after confirmation on every machine.
      -- System Trash is unavailable on mounts such as NHN's /upstg.
      explorer = { trash = false },
      picker = {
        sources = {
          explorer = { hidden = true, ignored = true },
          files = { hidden = true, ignored = false },
          grep = { hidden = true, ignored = false },
        },
      },
    },
  },
  {
    "RRethy/vim-illuminate",
    opts = function(_, opts)
      -- MOD 24 -- the built-in cutoff counts lines, so huge JSONL records can still trigger full-buffer regex scans.
      local defaults = require("illuminate.config").get_raw().filetypes_denylist
      opts.filetypes_denylist = vim.list_extend(vim.deepcopy(opts.filetypes_denylist or defaults), { "bigfile" })
      if opts.large_file_overrides then
        opts.large_file_overrides.filetypes_denylist =
          vim.list_extend(opts.large_file_overrides.filetypes_denylist or {}, { "bigfile" })
      end
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = function(_, opts)
      -- MOD 24 -- reject large buffers before Gitsigns starts diffing; preserve LazyVim's ordinary-buffer mappings.
      local on_attach = opts.on_attach
      opts.on_attach = function(buf)
        if vim.bo[buf].filetype == "bigfile" then
          return false
        end
        if on_attach then
          return on_attach(buf)
        end
      end
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      -- bootstrap-mason.lua owns installer-time provisioning and filters tools
      -- by available runtimes. Avoid racing LazyVim's startup installer.
      if vim.env.LAZY_MASON_BOOTSTRAP == "1" then
        opts.ensure_installed = {}
      end
    end,
  },
}
