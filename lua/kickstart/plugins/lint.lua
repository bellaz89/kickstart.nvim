return {

  { -- Linting
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'

      lint.linters.clang_opencl = {
        name = 'clang_opencl',
        cmd = 'clang',
        stdin = true,
        args = {
          '-x',
          'cl', -- treat input as OpenCL C
          '-cl-std=CL1.2', -- or CL2.0 if you target that
          '-fsyntax-only',
          '-Wall',
          '-Wextra',
          '-Xclang',
          '-finclude-default-header', -- include OpenCL built-ins
          '-fno-caret-diagnostics',
          '-fno-color-diagnostics',
          '-', -- read from stdin
        },
        stream = 'stderr',
        ignore_exitcode = true,
        parser = require('lint.parser').from_errorformat(
          table.concat({
            '%f:%l:%c: %trror: %m',
            '%f:%l:%c: %t%*[^:]: %m',
            '%f:%l: %trror: %m',
            '%f:%l: %t%*[^:]: %m',
          }, ','),
          {
            -- optional defaults (“skeleton”) for each diagnostic:
            source = 'clang', -- label shown in diagnostics
            -- severity = vim.diagnostic.severity.WARN, -- default if %t isn’t present
          }
        ),
      }

      lint.linters_by_ft = {
        markdown = { 'markdownlint' },
        vhdl = { 'vsg' },
        lua = { 'luacheck' },
        bash = { 'bash' },
        json = { 'jsonlint' },
        rst = { 'vale' },
        yaml = { 'yamllint' },
        xml = { 'vale' },
        adoc = { 'vale' },
        tcl = { 'nagelfar' },
        verilog = { 'verilator' },
        opencl = { 'clang_opencl' },
      }

      -- Create autocommand which carries out the actual linting
      -- on the specified events.
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          -- Only run the linter in buffers that you can modify in order to
          -- avoid superfluous noise, notably within the handy LSP pop-ups that
          -- describe the hovered symbol using Markdown.
          if vim.opt_local.modifiable:get() then
            lint.try_lint()
          end
        end,
      })
    end,
  },
}
