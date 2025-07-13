local M = {}
local config = {
    max_offset = 10,
    direction = "both",
    jump_first_on_line = true
}

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
    end
end

function M.find_nearest_char(target_char)
    local current_line = vim.fn.line(".")
    local total_lines = vim.fn.line("$")
    local col_start = vim.fn.col(".")
    local current_text = vim.fn.getline(current_line)

    local first_occurence_for_line = string.find(current_text:sub(col_start), target_char, 1, true)
    if first_occurence_for_line then
        vim.api.nvim_win_set_cursor(0, { current_line, col_start + first_occurence_for_line - 2 })

        if config.jump_first_on_line then
            local second_occurence_for_line = string.find(current_text:sub(first_occurence_for_line), target_char, 1, true)
            if (second_occurence_for_line) then
                vim.api.nvim_win_set_cursor(0, { current_line, col_start + second_occurence_for_line - 2 })
            end
        end

        return true
    end

    for offset = 1, config.max_offset do
        if config.direction == "down" or config.direction == "both" then
            local lnum_down = current_line + offset
            if lnum_down <= total_lines then
                local line = vim.fn.getline(lnum_down)
                local char_col = string.find(line, target_char, 1, true)
                if char_col then
                    vim.api.nvim_win_set_cursor(0, { lnum_down, char_col - 1 })
                    return true
                end
            end
        end

        if config.direction == "up" or config.direction == "both" then
            local lnum_up = current_line - offset
            if lnum_up >= 1 then
                local line = vim.fn.getline(lnum_up)
                local char_col = string.find(line, target_char, 1, true)
                if char_col then
                    vim.api.nvim_win_set_cursor(0, { lnum_up, char_col - 1 })
                    return true
                end
            end
        end
    end


    return false
end

return M

