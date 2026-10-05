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
