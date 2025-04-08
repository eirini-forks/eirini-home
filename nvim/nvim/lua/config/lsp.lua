local nvim_lsp = require 'lspconfig'

-- Setup lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- configure diagnostics
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = false,
		underline = true,
		signs = true,
    }
)

local _border = "single"

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover, {
    border = _border
  }
)

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
  vim.lsp.handlers.signature_help, {
    border = _border
  }
)

vim.diagnostic.config{
  float={border=_border},
  signs={
    text = {
        [vim.diagnostic.severity.ERROR] = " ",
        [vim.diagnostic.severity.WARN] = " ",
        [vim.diagnostic.severity.INFO] = " ",
        [vim.diagnostic.severity.HINT] = "",
    },
  },
}

function OpenDiagnosticIfNoFloat()
    for _, winid in pairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.api.nvim_win_get_config(winid).zindex then
            return
        end
    end

    vim.diagnostic.open_float(0, {
        scope = "cursor",
        focusable = false,
        close_events = {
            "CursorMoved",
            "CursorMovedI",
            "BufHidden",
            "InsertCharPre",
            "WinLeave",
        },
    })
end

vim.api.nvim_create_augroup("lsp_diagnostics_hold", { clear = true })
vim.api.nvim_create_autocmd({ "CursorHold" }, {
    pattern = "*",
    callback = OpenDiagnosticIfNoFloat,
    group = "lsp_diagnostics_hold",
})

local on_attach = function(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings
    local opts = { noremap=true, silent=true }
    buf_set_keymap('n', 'K', ':lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('n', 'gd', ':Telescope lsp_definitions<cr>', opts)
    buf_set_keymap('n', 'gr', ':Telescope lsp_references<cr>', opts)
    buf_set_keymap('n', 'gi', ':Telescope lsp_implementations<cr>', opts)
    buf_set_keymap('n', 'gy', ':Telescope lsp_type_definitions<cr>', opts)
    buf_set_keymap('n', 'gs', ':Telescope lsp_document_symbols<CR>', opts)

    buf_set_keymap('n', '<leader>ca', ':lua vim.lsp.buf.code_action()<CR>', opts)
    -- once the range version of code_action is fixed, we can ditch the params below
    buf_set_keymap('v', '<leader>ca', ':lua vim.lsp.buf.code_action({range = { start = {vim.fn.getpos("\'<")[2], 0}, [\'end\'] = {vim.fn.getpos("\'>")[2], 0}}})<CR>', opts)

    buf_set_keymap('n', '<leader>rn', ':lua vim.lsp.buf.rename()<CR>', opts)

    buf_set_keymap('n', '[g', ':lua vim.diagnostic.goto_prev()<CR>', opts)
    buf_set_keymap('n', ']g', ':lua vim.diagnostic.goto_next()<CR>', opts)
    buf_set_keymap('n', '<leader>eb', ":lua require'telescope.builtin'.diagnostics{bufnr = 0}<cr>", opts)
    buf_set_keymap('n', '<leader>ea', ":lua require'telescope.builtin'.diagnostics{severity = 'error'}<cr>", opts)
end

-- Use a loop to conveniently both setup defined servers
-- and map buffer local keybindings when the language server attaches
local servers = { "ts_ls", "bashls" }
for _, lsp in ipairs(servers) do
    nvim_lsp[lsp].setup {
        on_attach = on_attach,
        capabilities = capabilities,
    }
end

nvim_lsp.gopls.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    cmd = { 'gopls', '--remote=auto' },
    settings = {
        gopls = {
            completeUnimported = true,
            staticcheck = true,
            gofumpt = true,
            analyses = {
                nilness = true,
                shadow = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
                unusedvariable = true,
            },
        }
    },
}

function LSP_organize_imports()
    local params = vim.lsp.util.make_range_params()
    params.context = {only = {"source.organizeImports"}}
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
    for _, res in pairs(result or {}) do
        for _, r in pairs(res.result or {}) do
            if r.edit then
                vim.lsp.util.apply_workspace_edit(r.edit, "utf-8")
            else
                vim.lsp.buf.execute_command(r.command)
            end
        end
    end
end
