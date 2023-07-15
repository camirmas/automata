local width = 128
local height = 128
local starting_num = 2800

local grid = {}
local t = 0
local space_pressed = false
local paused = true

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
        active = false,
        t = 0
    }
end

local function update_cell(c)
    local new_c = create_cell(c.x, c.y)
    new_c.active = c.active
    new_c.alive = c.alive
    new_c.t = c.t

    local neighbors = get_neighbors(c)
    local n_neighbors = #neighbors

    if c.alive and (n_neighbors == 2 or n_neighbors == 3) then
        new_c.t = c.t + 1
    elseif not c.alive and (n_neighbors == 3) then
        new_c.alive = true
        new_c.active = true
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
        c.active = true
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

    t = t + 1
end

function love.keypressed(key)
    if key == "space" then
        paused = not paused
    end
end

function love.draw()
    -- Calculate the scale factors
    local scaleX = love.graphics.getWidth() / width
    local scaleY = love.graphics.getHeight() / height

    -- Apply the scale transformation
    love.graphics.scale(scaleX, scaleY)

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