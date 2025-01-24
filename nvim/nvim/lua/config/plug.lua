local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- Allow vim to do tmux stuff, like open panes for the test plugin
    'benmills/vimux',
    -- Syntax highlighting for starlark
    'cappyzawa/starlark.vim',
    -- Add mappings to copy to clipboard - doesn't work over ssh
    'christoomey/vim-system-copy',
    -- Navigate through vim splits seamlessly
    'christoomey/vim-tmux-navigator',
    -- Light and configurable statusline
    {
        'nvim-lualine/lualine.nvim',
        opts = {
            theme = "tokyonight",
            sections = {
                lualine_c = {{ "filename", path = 1 }},
            },
            tabline = {
                lualine_a = {'buffers'},
                lualine_z = {'tabs'}
            }
        },
    },
    {
        'kazhala/close-buffers.nvim',
        config = function()
            require'close_buffers'.setup{}
            vim.keymap.set("n",  "<leader>bd", "<cmd>BDelete this<cr>", {desc = "Delete buffer" })
            vim.keymap.set("n",  "<leader>bD", "<cmd>BDelete! this<cr>", {desc = "Delete buffer!" })
            vim.keymap.set("n",  "<leader>bo", "<cmd>BDelete other<cr>", {desc = "Delete other buffers" })
            vim.keymap.set("n",  "<leader>bn", "<cmd>enew<cr>", {desc = "New buffer" })
        end,
    },
    -- Test runner integration
    'janko/vim-test',
    -- Generates method stubs for implementing an interface
    'josharian/impl',
    -- Outline viewer for vim
    'majutsushi/tagbar',
    -- Show git diff in the sign column
    {
        'lewis6991/gitsigns.nvim',
        config = true,
        opts = {
            signs = {
                add = { text = "+" },
                change = { text = "~" },
                delete = { text = "-" },
                topdelete = { text = "-" },
                changedelete = { text = "/" },
            },
            numhl = true,
            on_attach = function(buffer)
                local gs = package.loaded.gitsigns

                local function map(mode, l, r, desc)
                    vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
                end

                -- stylua: ignore start
                map("n", "]c", gs.next_hunk, "Next Hunk")
                map("n", "[c", gs.prev_hunk, "Prev Hunk")
            end,
        },
    },
    -- Fancy start screen
    'mhinz/vim-startify',
    -- Toggle quickfix and location windows
    'milkypostman/vim-togglelist',
    -- Unobtrusive scratch window
    'mtth/scratch.vim',
    -- Our colorscheme
    {
        'folke/tokyonight.nvim',
        opts = {
            style = "night",
        },
    },
    'rktjmp/lush.nvim',
    -- Config for built-in nvim lsp
    'neovim/nvim-lspconfig',
    -- nvim-cmp and its plugins
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline',
            'quangnguyen30192/cmp-nvim-ultisnips',
        },
    },

    'quangnguyen30192/cmp-nvim-ultisnips',

    -- signature help
    {
        'ray-x/lsp_signature.nvim',
        opts = {
            doc_lines = 0,
            hint_enable = false,
        },
    },

    -- nvim-telescope and dependencies
    {
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        dependencies = {
            {
                'nvim-telescope/telescope-fzf-native.nvim',
                build = 'make',
                config = function()
                    require"telescope".load_extension("fzf")
                end,
            },
            'nvim-lua/plenary.nvim',
        },
    },

    -- use built-in syntax highlighting engine
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "bash",
                    "c",
                    "comment",
                    "css",
                    "dockerfile",
                    "go",
                    "gomod",
                    "gowork",
                    "hcl",
                    "html",
                    "http",
                    "javascript",
                    "json",
                    "lua",
                    "make",
                    "proto",
                    "regex",
                    "ruby",
                    "terraform",
                    "toml",
                    "vim",
                    "vimdoc",
                    "yaml",
                },
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
            })
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        config = function()
            require('nvim-treesitter.configs').setup {
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@class.outer",
                            ["ic"] = "@class.inner",
                        },
                    },
                    swap = {
                        enable = true,
                        swap_next = {
                            ["<leader>sa"] = "@parameter.inner",
                        },
                        swap_previous = {
                            ["<leader>sA"] = "@parameter.inner",
                        },
                    },
                },

            }
        end,
    },

    -- Show context nesting at top of window
    "nvim-treesitter/nvim-treesitter-context",

    {
        "j-hui/fidget.nvim",
        config = true,
        tag = 'legacy',
    },

    {
        "folke/which-key.nvim",
        config = true,
    },

    -- prettier formatting
    {
        'prettier/vim-prettier',
        build = 'npm install',
        ft = {'javascript', 'typescript', 'typescriptreact', 'json', 'markdown'},
        config = function()
            vim.api.nvim_create_autocmd("BufWritePre", {
                pattern = {"*.js", "*.jsx", "*.json", "*.ts", "*.tsx"},
                command = "Prettier",
            })
        end,
    },
    -- Reveal the commit messages under the cursor in a 'popup window'
    'rhysd/git-messenger.vim',
    -- Make hlsearch more useful
    'romainl/vim-cool',
    -- Directory tree explorer
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v2.x",
        keys = {
            { "<C-n>", "<cmd>Neotree toggle reveal=true<cr>", desc = "Toggle NeoTree" },
            { "\\", "<cmd>Neotree toggle reveal=true<cr>", desc = "Toggle NeoTree" },
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
            "MunifTanjim/nui.nvim",
        },
        config = function()
            require("neo-tree").setup({
                close_if_last_window = true,
                filesystem = {
                    filtered_items = {
                        visible = true,
                    },
                    use_libuv_file_watcher = true,
                },
                default_component_configs = {
                    icon = {
                        folder_empty = "󰜌",
                        folder_empty_open = "󰜌",
                    },
                    git_status = {
                        symbols = {
                            renamed   = "󰁕",
                            unstaged  = "󰄱",
                        },
                    },
                },
            })
        end,
    },
    -- Add various code snippets
    {
        'SirVer/ultisnips',
        config = function()
            vim.g.UltiSnipsExpandTrigger = '<C-j>'
        end,
    },
    -- Change case and case-sensitive substitutions
    'tpope/vim-abolish',
    -- Comment stuff out
    'tpope/vim-commentary',
    -- Unix utility commands
    'tpope/vim-eunuch',
    -- Git wrapper
    'tpope/vim-fugitive',
    -- Make . work with tpope's plugins
    'tpope/vim-repeat',
    -- Open selected code in githb in browser
    'tpope/vim-rhubarb',
    -- Provides mappings to easily delete, change and add surroundings (parentheses, brackets, quotes, XML tags, and more) in pairs
    'tpope/vim-surround',
    -- Useful mappings
    'tpope/vim-unimpaired',
    -- Add snippets for Ginkgo BDD testing library for go
    'trayo/vim-ginkgo-snippets',
    'trayo/vim-gomega-snippets',
    'towolf/vim-helm',
    -- Ruby plugin
    'vim-ruby/vim-ruby',
    -- ytt syntax highlighting
    'vmware-tanzu/ytt.vim',
    -- Runs shfmt to auto format the current buffer
    {'z0mbix/vim-shfmt', ft = 'sh' },
    -- Refactoring utility
    {
        "ThePrimeagen/refactoring.nvim",
        dependencies = {
          "nvim-lua/plenary.nvim",
          "nvim-treesitter/nvim-treesitter",
        },
        config = function()
          require("refactoring").setup()
        end,
    },
})
