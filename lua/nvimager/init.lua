-- Variables
--------------------------------------------------------------------------------
-- \usepackage{xcolor}
-- \pagecolor{]].."black"..[[}
local texHeader = [[
\documentclass[multi={mymath},border=1pt]{standalone}
% \usepackage{amsmath}
\newenvironment{mymath}{$\displaystyle}{$}

\begin{document}

\begin{mymath}
]]
local texFooter = [[
\end{mymath}

\end{document}
]]

local displaying = 0
local images = {}

-- User's Normal Config
local userConcealLevel = 0
local userConcealCursor = ""

-- Nvimager Options
local title = vim.g["nvimager#title"]
local filler = vim.g["nvimager#filler"]
local dynamicScaler = vim.g["nvimager#dynamictitle"]
local staticScaler = vim.g["nvimager#static_scaler"]

local winId = vim.fn.win_getid(1)
local termWidth = 0
local winrow = 0
local wincol = 0
local topline = 0
local botline = 0
local textoff = 0


-- Helper Functions
--------------------------------------------------------------------------------
local function updateWinInfo()
-- TODO: return table of values instead of using "'global'" variables?
    for i, info in pairs(unpack(vim.fn.getwininfo(winId))) do
        if i == "width" then termWidth = info
        elseif i == "winrow" then winrow = info
        elseif i == "wincol" then wincol = info
        elseif i == "topline" then topline = info
        elseif i == "botline" then botline = info
        elseif i == "textoff" then textoff = info
        end
    end
end

local function drawImage(path, scaler, x, y, width, height)
    return vim.fn.jobstart(string.format( vim.fn.getcwd().."/ueberzug-fifo.sh %s %s %d %d %d %d", path, scaler, x, y, width, height))
end

local function drawImages(images)
    for i = 1,#images,1 do
        local image = images[i]
        image[9] = drawImage(image[2], image[3], image[4], image[5], image[6], image[7])
    end
end

local function clearImage(image)
    -- Delete filler and title
    if image[10]==1 then
        height = image[7] - 1
        row = image[5] + 2
    else height = 0 end
    if title==1 then height = height + 1 end
    vim.fn.cursor(image[5]+(1-image[10])*(image[7]+1)+image[10]*2, 1)
    for j=1,height,1 do vim.api.nvim_del_current_line() end

    -- Delete extmark and close image
    vim.api.nvim_buf_del_extmark(0, vim.api.nvim_create_namespace("nvimage"), image[8])
    vim.fn.jobstop(image[9])
end

local function above(a, b) return a[5]>b[5] end
local function clearImages(images)
    -- Sort reverse row order
    table.sort(images, above)
    for i, image in pairs(images) do
        clearImage(images[i])
    end
end

local function insertText(images)
    local heightOffset = 0
    for i = 1,#images,1 do
        local image = images[i]
        -- Insert Filler
        if image[10] == 1 then
            vim.fn.cursor(image[5]+heightOffset+image[10], image[4]-textoff)
            for i = 1,image[7]-1,1 do vim.api.nvim_put({string.rep("█", image[6]+image[4]-textoff)},"l", true, false) end
        end
        -- Insert Title
        -- TODO: TeX breaks title insertion
        if title==1 then
            if image[10] == 0 then vim.fn.cursor(image[5]+heightOffset+image[7]+image[10], image[4]-textoff) end
            vim.api.nvim_put({string.rep(" ", image[4]-textoff+(image[6]-string.len(name))*image[10]/2)..name}, "l", true, false)
            heightOffset = heightOffset + 1
        end
        if image[10] == 1 then heightOffset = heightOffset + image[7] - 1 end
    end
end

local function updateTextChanged()
    -- TODO: deal with adding links while displaying
    local curpos = vim.fn.getcurpos(vim.fn.win_getid(1))
    local extmarks = vim.api.nvim_buf_get_extmarks(0, vim.api.nvim_create_namespace("nvimage"), 0, -1, {})
    local oldTopline = topline
    updateWinInfo()
    local diff = oldTopline - topline
    local heightOffset = 0
    -- mark(id, row, col)
    -- image(name, path, scaler, x, row, width, height, extId, jobId, static)
    for j, image in pairs(images) do
        local found = false
        for i, mark in pairs(extmarks) do
            local match = vim.fn.matchstr(vim.fn.getline(mark[2]+1-heightOffset), [[\v\[.+\]\(.+\)(\<\!---?.+---?\>)?|\$.+\$]])

            -- if deleted text
            if image[8] == mark[1] and match ~= image[11] then
                -- TODO: Delete static image when filler line is deleted
                image[5] = image[5] - 1
                clearImage(image)
                table.remove(images, j)
                updateTextChanged()

            -- if dynamic or changed position
            -- TODO: better conditions to update dynamics (currently matching all)
            elseif image[8] == mark[1] and (image[10] == 0 or mark[2] ~= image[5]+diff or mark[3]+textoff ~= image[4]) then
                image[4] = mark[3] + textoff
                image[5] = mark[2]
                vim.fn.jobstop(image[9])

                -- if in window
                if mark[2] >= topline-image[7] and mark[2] <= botline then
                    -- set height for dynamic images
                    if image[10] == 0 then
                        vim.fn.cursor(image[5]+2, 1)
                        image[7] = vim.fn.search([[[^\n*]\|\%$]])-image[5]-1
                        if image[7] < 1 then image[7] = 1 end
                    end
                    -- print(image[3], image[4], image[5]-topline+1, image[6], image[7])
                    image[9] = drawImage(image[2], image[3], image[4], image[5]-topline+1, image[6], image[7])
            end end
        end
    end
    vim.fn.setpos(".", curpos)
end
-- ..[[\color{white}]].."\n"
local function createTexPreview(equation, extId)
    local path = os.getenv("XDG_CACHE_HOME").."/nvimager/"
    vim.fn.mkdir(path, "p")
    local file = io.open(path..extId..".tex", "a") -- appends a file named main.txt
    file:write(texHeader..equation.."\n"..texFooter) -- write a bunch of stuff
    io.close(file)
    vim.fn.jobwait({vim.fn.jobstart("pdflatex -output-directory="..path.." "..extId..".tex")}, 1000)
    vim.fn.jobwait({vim.fn.jobstart("convert -density 3000 "..path..extId..".pdf -quality 100 "..path..extId..".jpg")}, 1000)
    return path..extId..".jpg"
end

-- Main Functions
--------------------------------------------------------------------------------
local function init()

    -- Instantiate Other Variables
    updateWinInfo()
    local capturePattern = [[\v\[.+\]\(.+\)(\<\!---?.+---?\>)?|\$.+\$]]
    local dynamicPattern = "%[(.+)%]%(file:(.+)%)"
    local staticPattern = "%[(.+)%]%(file:(.+)%)<%!--[%-]?(.+)--[%-]?>"
    local texPattern = "%$(.+)%$"

    -- Save and set conceal options
    local curpos = vim.fn.getcurpos(vim.fn.win_getid(1))
    userConcealLevel = vim.api.nvim_get_option_value('conceallevel', {})
    userConcealCursor = vim.api.nvim_get_option_value('concealcursor', {})
    vim.api.nvim_command('set conceallevel=2')
    vim.api.nvim_command('set concealcursor=nvic')

    -- Add highlight group patterns
    vim.fn.matchadd("Conceal", capturePattern, 10, -1, {conceal="?"})
    vim.api.nvim_set_hl(0, "NvimagerPlaceholder", {ctermfg=0, ctermbg=0})
    vim.fn.matchadd("NvimagerPlaceholder", "██*$")

    -- TODO: Parse file extensions to decide wether or not to draw
    -- jpg | png | jpeg | webp | gif | avi | mp4 | wmv | dat | 3gp | ogv | mkv | mpg | mpeg | vob |  m2v | mov | webm | mts | m4v | rm  | qt | divx | pdf | epub

    -- For each match in buflines create extmark & add image to table
    local bufLines = vim.fn.getbufline(vim.fn.bufname(), "0", "$")
    for row = 1,#bufLines,1 do
        line = bufLines[row]

        local height = 0
        local match, first, last = unpack(vim.fn.matchstrpos(line, capturePattern))
        if first ~= -1 then
            -- Match Pattern & Extract Image Data
            local static = 0

            -- Static:  (name)[path]<!--widthxheight-->
            if string.match(match, staticPattern) ~= nil then
                static = 1
                name, path, size = string.match(match, staticPattern)
                width, height = string.match(size, "([0-9]+)[xX]([0-9]+)")
                scaler = staticScaler
                extId = vim.api.nvim_buf_set_extmark(0, vim.api.nvim_create_namespace("nvimage"), row-1, first, {})

            -- Dynamic:  (name)[path]
            elseif string.match(match, dynamicPattern) ~= nil then
                vim.fn.cursor(row+1, first)
                height = vim.fn.search([[[^\n*]\|\%$]])-row
                if height == 0 then height = 1 end
                width = termWidth-textoff-first-1
                name, path = string.match(match, dynamicPattern)
                scaler = dynamicScaler
                extId = vim.api.nvim_buf_set_extmark(0, vim.api.nvim_create_namespace("nvimage"), row-1, first, {})

            -- Dynamic LaTeX:  $ equation $
            elseif string.match(match, texPattern) ~= nil then
                name = ""
                vim.fn.cursor(row+1, first)
                height = vim.fn.search([[[^\n*]\|\%$]])-row
                if height == 0 then height = 1 end
                width = termWidth-textoff-first-1
                scaler = "dynamicScaler
                extId = vim.api.nvim_buf_set_extmark(0, vim.api.nvim_create_namespace("nvimage"), row-1, first, {})
                -- TODO: figure out best way to set id for tmp file name
                path = createTexPreview(string.match(match, texPattern), vim.fn.id(extId))

            -- TODO: Static LaTeX
            -- TODO: Add block LaTeX equations
            else
                print("BROKEN PATTERN")
            end
            table.insert(images, {name, path, scaler, first+textoff, row-1, width, height, extId, -1, static, match})
        end
    end


    insertText(images)
    -- print(unpack(curpos))
    vim.fn.cursor(curpos[2], curpos[3])
    drawImages(images)
end

local function clear()
    -- Reset user options
    vim.api.nvim_set_option_value('conceallevel', userConcealLevel, {})
    vim.api.nvim_set_option_value('concealcursor', userConcealCursor, {})

    clearImages(images)
    images = {}
    vim.api.nvim_command('silent !rm -rf /tmp/nvimager')
end


-- Autocommands
--------------------------------------------------------------------------------
local function bufWritePre() if displaying == 1 then clear() end end
vim.api.nvim_create_autocmd(
    { "BufWritePre" },
    { callback = bufWritePre,
      desc = "nvimage clear"})

local function bufWritePost() if displaying == 1 then init() end end
vim.api.nvim_create_autocmd(
    { "BufWritePost" },
    { callback = bufWritePost,
      desc = "nvimage clear"})

-- vim.api.nvim_command('set verbose=9')
vim.api.nvim_create_autocmd(
    { "WinScrolled", "TextChanged", "TextChangedI", "TextChangedP" },
    { callback = updateTextChanged,
      desc = "nvimage update"})


-- Exposed Functions
--------------------------------------------------------------------------------
local function toggle()
    if displaying == 0 then
        init()
        displaying = 1
    else
        clear()
        displaying = 0
    end
end

local function refresh()
    if displaying == 0 then
        init()
        displaying = 1
    else
        clear()
        init()
    end
end

return {
    toggle = toggle,
    refresh = refresh,
}
