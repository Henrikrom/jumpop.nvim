local M = {}
local config = { max_offset = 10 }

function M.setup(user_config)
    config = vim.tbl_extend("force", config, user_config or {})
    vim.keymap.set("n", "<leader>ci", function()
        M.ci_nearest_multiline()
    end)
end

function M.ci_nearest_multiline()
    local char = vim.fn.nr2char(vim.fn.getchar())

    if type(char) == "number" then
        char = vim.fn.nr2char(char)
    end

    local found = M.find_nearest_char(char)

    if found then
        vim.api.nvim_feedkeys("ci" .. char, "n", false)
    else
        vim.notify("Character '" .. char .. "' not found nearby.", vim.log.levels.WARN)
    end
end

function M.find_nearest_char(target_char)
    local current_line = vim.fn.line(".")
    local total_lines = vim.fn.line("$")
    local col_start = vim.fn.col(".")
    local current_text = vim.fn.getline(current_line)
    local col = string.find(current_text:sub(col_start), target_char, 1, true)
    if col then
        vim.api.nvim_win_set_cursor(0, { current_line, col_start + col - 2 })
        return true
    end

    for offset = 1, config.max_offset do
        for _, lnum in ipairs({ current_line + offset, current_line - offset }) do
            if lnum >= 1 and lnum <= total_lines then
                local line = vim.fn.getline(lnum)
                local char_col = string.find(line, target_char, 1, true)
                if char_col then
                    vim.api.nvim_win_set_cursor(0, { lnum, char_col - 1 })
                    return true
                end
            end
        end
    end

    return false
end

return M

