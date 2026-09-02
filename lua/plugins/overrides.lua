return {
  -- MOD 6 -- show dotfiles by default in the explorer, file finder, and grep.
  --
  -- snacks defaults `hidden = false`, which hides anything starting with a dot.
  -- That makes the explorer close to useless in a dotfiles repo, and it also hides
  -- .github/, .claude/, .env, and friends in normal projects.
  --
  -- `ignored` stays false on purpose: that one controls GITIGNORED files, and
  -- flipping it floods the picker with .venv/, __pycache__/, and node_modules/.
  -- Press H inside any picker to toggle hidden at runtime.
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = { hidden = true, ignored = false },
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
