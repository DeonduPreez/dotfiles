-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ Harpoon2 — Quick file navigation for your most-used files              ║
-- ║                                                                        ║
-- ║ Integrations:                                                          ║
-- ║   • harpoon-lualine  — Shows harpoon marks in statusline               ║
-- ║   • Telescope picker — Fuzzy-find through harpoon list with preview    ║
-- ║   • Neo-tree component — Shows harpoon index next to files in tree     ║
-- ║                                                                        ║
-- ║ Docs: https://github.com/ThePrimeagen/harpoon/tree/harpoon2            ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },

    config = function()
      local harpoon = require("harpoon")
      local harpoon_helper = require("helpers.harpoon-helper")
      harpoon:extend({
          LIST_CHANGE = function()
              harpoon_helper.rebuild_harpoon_cache()
          end,
        })

      harpoon:setup({
        settings = {
          -- Save marks when you toggle the UI closed (not just on :w).
          save_on_toggle = true,

          -- Sync marks to disk on every change (add/remove/reorder).
          sync_on_ui_close = true,

          key = function()
                  -- Read .git/HEAD to get the current branch of the repo.
                  -- Falls back to cwd if not in a git repo.
                  local cwd = vim.uv.cwd() or ""
                  local head_file = cwd .. "/.git/HEAD"
                  local f = io.open(head_file, "r")
                  if not f then
                    return cwd
                  end
                  local content = f:read("*l") or ""
                  f:close()
                  -- .git/HEAD looks like "ref: refs/heads/main"
                  local branch = content:match("ref: refs/heads/(.+)")
                  if branch then
                    return cwd .. "-" .. branch
                  end

                  -- Detached HEAD or unusual state — just use cwd
                  return cwd
                end,
            },
      })

      -- ╭────────────────────────────────────────────────────────────────╮
      -- │ Telescope Picker                                               │
      -- │                                                                │
      -- │ Opens your harpoon list in a telescope picker with file        │
      -- │ preview. Better than the built-in harpoon UI when you want     │
      -- │ to see file contents before jumping.                           │
      -- │                                                                │
      -- │ Docs: harpoon2 README "Telescope" section                      │
      -- ╰────────────────────────────────────────────────────────────────╯
      local function harpoon_telescope_picker()
        local conf = require("telescope.config").values
        local harpoon_list = harpoon:list()
        local file_paths = {}
        for _, item in ipairs(harpoon_list.items) do
          table.insert(file_paths, item.value)
        end

        if #file_paths == 0 then
          vim.notify("Harpoon list is empty", vim.log.levels.INFO)
          return
        end

        require("telescope.pickers")
          .new({}, {
            prompt_title = "Harpoon",
            finder = require("telescope.finders").new_table({
              results = file_paths,
            }),
            previewer = conf.file_previewer({}),
            sorter = conf.generic_sorter({}),
          })
          :find()
      end

      -- Store picker on the module so keymaps can reference it without requiring telescope at plugin load time
      harpoon._hp_telescope_picker = harpoon_telescope_picker
    end,

    -- ── Keymaps ─────────────────────────────────────────────────────────
    --   <leader>h*  — Namespaced harpoon operations
    --   g1-9 — Speed aliases for file navigation
    keys = {
      -- ── Group registration ────────────────────────────────────────────
      {
        "<leader>h",
        "",
        desc = "+harpoon",
      },

      -- ── Add / Menu ────────────────────────────────────────────────────
      {
        "<leader>H",
        function() 
          local Path = require("plenary.path")
          local list = require("harpoon"):list()
          local currentbufpath = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())

          local harpoonhelper = require("helpers.harpoon-helper")
          local harpoonindex = harpoonhelper.get_harpoon_index(currentbufpath)
          if harpoonindex then
              list:remove_at(harpoonindex)
              harpoonhelper.rebuild_harpoon_cache()
              return 
          end

          list:add()
          harpoonhelper.rebuild_harpoon_cache()
        end,
        desc = "Harpoon file",
      },
      {
        "<leader>hm",
        function()
          local harpoon = require("harpoon")
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
        desc = "Harpoon: quick menu",
      },

      -- ── Quick Harpoon Navigation (g1,2,3,4,5,6,7,8,9) ──────────────────────────────
      {
        "g1",
        function()
          require("harpoon"):list():select(1)
          -- TODO : All quick navigation need to check if no other buffers except an empty [No Name] Buffer exists,
          -- then delete that buffer similar to how selecting a file in Neo-tree (with current config) closes the empty buffer so I don't have to deal with it.
        end,
        desc = "Harpoon: File 1",
      },
      {
        "g2",
        function()
          require("harpoon"):list():select(2)
        end,
        desc = "Harpoon: File 2",
      },
      {
        "g3",
        function()
          require("harpoon"):list():select(3)
        end,
        desc = "Harpoon: File 3",
      },
      {
        "g4",
        function()
          require("harpoon"):list():select(4)
        end,
        desc = "Harpoon: File 4",
      },
      {
        "g5",
        function()
          require("harpoon"):list():select(5)
        end,
        desc = "Harpoon: File 5",
      },
      {
        "g6",
        function()
          require("harpoon"):list():select(6)
        end,
        desc = "Harpoon: File 6",
      },
      {
        "g7",
        function()
          require("harpoon"):list():select(7)
        end,
        desc = "Harpoon: File 7",
      },
      {
        "g8",
        function()
          require("harpoon"):list():select(8)
        end,
        desc = "Harpoon: File 8",
      },
      {
        "g9",
        function()
          require("harpoon"):list():select(9)
        end,
        desc = "Harpoon: File 9",
      },

      -- ── Prev / Next cycling ───────────────────────────────────────────
      -- Cycle through your harpoon list sequentially.
      {
        "<leader>hp",
        function()
          require("harpoon"):list():prev()
        end,
        desc = "Harpoon: previous file",
      },
      {
        "<leader>hn",
        function()
          require("harpoon"):list():next()
        end,
        desc = "Harpoon: next file",
      },

      -- ── Telescope picker ──────────────────────────────────────────────
      -- Opens harpoon list in telescope with file preview.
      -- Lives under <leader>f (Find group) since it's a search action.
      {
        "<leader>fH",
        function()
          local harpoon = require("harpoon")
          if harpoon._hp_telescope_picker then
            harpoon._hp_telescope_picker()
          end
        end,
        desc = "Find: harpoon marks",
      },
    },
  },

  -- ╭──────────────────────────────────────────────────────────────────────╮
  -- │ harpoon-lualine                                                      │
  -- │                                                                      │
  -- │ Shows your harpoon marks as indicators in the statusline.            │
  -- │ The active file's indicator is highlighted, so you always know       │
  -- │ which harpoon slot you're in (or if you're in an unmarked file).     │
  -- │                                                                      │
  -- │ This plugin is a dependency declaration only — the actual lualine    │
  -- │ component config goes in your lualine setup (ui.lua).                │
  -- │                                                                      │
  -- │ Docs: https://github.com/letieu/harpoon-lualine                      │
  -- ╰──────────────────────────────────────────────────────────────────────╯
  {
    "letieu/harpoon-lualine",
    dependencies = {
      {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
      },
    },
  },
}
