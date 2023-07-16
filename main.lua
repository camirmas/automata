local width = 128
local height = 128
local starting_num = 2800

local grid = {}
local t = 0
local paused = true
local drawing = false
local updates = {}
local last_game_x = nil
local last_game_y = nil

-- Based on PICO-8
palette = {
    black = {0, 0, 0},
    dark_blue = {29, 43, 83},
    dark_purple = {126, 37, 83},
    dark_green = {0, 135, 81},
    brown = {171, 82, 54},
    dark_gray = {95, 87, 79},
    light_gray = {194, 195, 199},
    white = {255, 241, 232},
    red = {255, 0, 77},
    orange = {255, 163, 0},
    yellow = {255, 236, 39},
    green = {0, 228, 54},
    blue = {41, 173, 255},
    indigo = {131, 118, 156},
    pink = {255, 119, 168},
    peach = {255, 204, 170}
}

local function get_neighbors(c)
    local neighbors = {}

    for dx=-1,1 do
        for dy=-1,1 do
            if not (dx == 0 and dy == 0) then
                if c.x > 0 and c.x < width - 1 and c.y > 0 and c.y < height - 1 then
                    local n = grid[c.x+dx][c.y+dy]
                    if n.alive then
                        table.insert(neighbors, n)
                    end
                end
            end
        end
    end

    return neighbors
end

local function create_cell(x, y)
    return {
        x = x,
        y = y,
        alive = false,
        t = 0
    }
end

local function update_cell(c)
    local new_c = create_cell(c.x, c.y)
    new_c.alive = c.alive
    new_c.t = c.t

    local neighbors = get_neighbors(c)
    local n_neighbors = #neighbors

    if c.alive and (n_neighbors == 2 or n_neighbors == 3) then
        new_c.t = c.t + 1
    elseif not c.alive and (n_neighbors == 3) then
        new_c.alive = true
        new_c.t = 0
    else
        new_c.alive = false
        new_c.t = 0
    end

    return new_c
end

function love.load()
    for x=0,width-1 do
        grid[x] = {}
        for y=0,height-1 do
            grid[x][y] = create_cell(x, y)
        end
    end

    for _=1,starting_num do
        local rx = math.random(width) - 1
        local ry = math.random(height) - 1
        local c = grid[rx][ry]
        c.alive = true
    end

    love.window.setMode(1920/2, 1920/2, {resizable = true})
end

function love.update()
    if t % 10 == 0 and not paused then
        local updates = {}

        for x=0,width-1 do
            for y=0,height-1 do
                local c = grid[x][y]
                updates[{x, y}] = update_cell(c)
            end
        end    

        for coord, u in pairs(updates) do
            grid[coord[1]][coord[2]] = u
        end
    end

    -- Check if the game is paused and the left mouse button is down
    if paused and love.mouse.isDown(1) then
        -- Get the mouse position in window coordinates
        local x, y = love.mouse.getPosition()
        
        -- Convert the mouse position to game coordinates
        local game_x = math.floor(x / scale_x)
        local game_y = math.floor(y / scale_y)

        -- Check if the coordinates are within the game grid
        if game_x >= 0 and game_x < width and game_y >= 0 and game_y < height then
            -- Check if there's a last mouse position
            if last_game_x and last_game_y then
                -- Use Bresenham's line algorithm to fill in all the cells between
                -- the current mouse position and the last mouse position
                local dx = math.abs(game_x - last_game_x)
                local sx = last_game_x < game_x and 1 or -1
                local dy = -math.abs(game_y - last_game_y)
                local sy = last_game_y < game_y and 1 or -1
                local err = dx + dy
                
                while true do
                    -- Set the cell at the current position to alive
                    grid[last_game_x][last_game_y].alive = true
                    
                    -- Break if the current position is the end position
                    if last_game_x == game_x and last_game_y == game_y then
                        break
                    end
                    
                    local e2 = 2 * err
                    if e2 >= dy then
                        err = err + dy
                        last_game_x = last_game_x + sx
                    end
                    if e2 <= dx then
                        err = err + dx
                        last_game_y = last_game_y + sy
                    end
                end
            end

            -- Update the last mouse position
            last_game_x, last_game_y = game_x, game_y
        end
    elseif not love.mouse.isDown(1) then
        -- Clear the last mouse position if the mouse button is not down
        last_game_x, last_game_y = nil, nil
    end

    t = t + 1
end

function love.keypressed(key)
    if key == "space" then
        paused = not paused
    end
end

function love.draw()
    -- Calculate the scale factors
    scale_x = love.graphics.getWidth() / width
    scale_y = love.graphics.getHeight() / height

    -- Apply the scale transformation
    love.graphics.scale(scale_x, scale_y)

    local alive = 0

    -- Now draw everything based on a 128x128 resolution
    for x=0,width-1 do
        for y=0,height-1 do
            local c = grid[x][y]
            if c.alive then
                love.graphics.rectangle("fill", c.x, c.y, 1, 1)
                alive = alive + 1
            end
        end
    end

    -- print("alive: " .. alive)
end