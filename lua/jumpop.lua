local M = {}
local config = {
    max_offset = 10,
    direction = "both",
    jump_first_on_line = true,
    dev = true
}

local open_close_char_map = {
  ["("] = ")",
  [")"] = "(",
  ["{"] = "}",
  ["}"] = "{",
  ["["] = "]",
  ["]"] = "[",
  ['"'] = '"',
  ["'"] = "'",
  ["`"] = "`",
}

function M.setup(user_config)
    config = vim.tbl_extend("force", config, user_config or {})

    if config.dev then
        vim.keymap.set("n", "<leader>r", function()
            vim.cmd("so")
            vim.cmd("Lazy reload jumpop.nvim")
        end)
    end

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

function find_block(line, start_col, target_char)
    local found_col = string.find(line:sub(start_col), target_char, 1, true)
    if found_col then
        local found_closing = string.find(line:sub(start_col), open_close_char_map[target_char], found_col + 1, true)
        if found_closing then
            return found_col, found_closing
        end
    end

    return nil
end


function M.find_nearest_char(target_char)
    local current_line = vim.fn.line(".")
    local total_lines = vim.fn.line("$")
    local col_start = vim.fn.col(".")
    local current_text = vim.fn.getline(current_line)

    local block_start_col, block_end_col = find_block(current_text, col_start, target_char)
    if block_start_col then
        local first_col = col_start + block_start_col - 2
        vim.api.nvim_win_set_cursor(0, { current_line, first_col })

        if config.jump_first_on_line then
            local second_block, _ = find_block(current_text, block_end_col + 1, target_char)
            if second_block then
                local second_col = block_end_col + second_block - 1
                vim.api.nvim_win_set_cursor(0, { current_line, second_col })
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


-- Test Text:
-- test "test" test "test"
-- test 'test' test 'test'
-- test "
-- test "test" test "
-- test {test} test {test}
-- test (test) test (test)

