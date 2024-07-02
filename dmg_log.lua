-- on screen damage log and floating damage numbers
local character_thicness = {['a'] = 0.0075,['b'] = 0.0075,['c'] = 0.0075,['d'] = 0.0075,['e'] = 0.0075,['f'] = 0.005,['g'] = 0.0075,['h'] = 0.0075,['i'] = 0.005,['j'] = 0.005,['k'] = 0.0075,['l'] = 0.005,['m'] = 0.01,['n'] = 0.0075,['o'] = 0.0075,['p'] = 0.0075,['q'] = 0.0075,['r'] = 0.005,['s'] = 0.005,['t'] = 0.005,['u'] = 0.0075,['v'] = 0.0075,['w'] = 0.01,['x'] = 0.0075,['y'] = 0.0075,['z'] = 0.0075,['A'] = 0.0075,['B'] = 0.0075,['C'] = 0.0075,['D'] = 0.0075,['E'] = 0.0075,['F'] = 0.0075,['G'] = 0.0075,['H'] = 0.01,['I'] = 0.005,['J'] = 0.005,['K'] = 0.0075,['L'] = 0.0075,['M'] = 0.01,['N'] = 0.0075,['O'] = 0.0075,['P'] = 0.0075,['Q'] = 0.01,['R'] = 0.0075,['S'] = 0.0075,['T'] = 0.0075,['U'] = 0.0075,['V'] = 0.0075,['W'] = 0.01,['X'] = 0.0075,['Y'] = 0.0075,['Z'] = 0.0075,['1'] = 0.0075,['2'] = 0.0075,['3'] = 0.0075,['4'] = 0.0075,['5'] = 0.0075,['6'] = 0.0075,['7'] = 0.0075,['8'] = 0.0075,['9'] = 0.0075,['0'] = 0.0075,[':'] = 0.005,['.'] = 0.005,['|'] = 0.005,['/'] = 0.005,['!'] = 0.005,['<'] = 0.005,['>'] = 0.005,[','] = 0.005,['?'] = 0.005,['='] = 0.005,['-'] = 0.005,['+'] = 0.005, [' '] = 0.005}

local enemy_ent = {}
local last_total_hits, curTime = engine.get_total_hits(), globals.curtime()
local text, gradient = render.text, render.gradient

local renderQ, rendering = {}, {}
local dmg_event, floating_numbers = {}, {}

local notifyAmount = gui.new_slider("Amount of notifications", 0, 4)
local fadeDuration = gui.new_slider("Fade duration", 1, 5)
gui.set(fadeDuration, 1)
gui.set(notifyAmount, 1)

function lerp(a, b, t)
    return a + (b - a) * t
end

local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

local function getWordWidth(word)
    local wordWidth = 0
    word = tostring(word)
    for c in word:gmatch"." do
        if(has_value(character_thicness, c)) then wordWidth = wordWidth + character_thicness[c] 
        else wordWidth = wordWidth + character_thicness["?"] end
    end
    return wordWidth
end


local function renderBar(x,y)
    local scale_x, scale_y = x-(0.87*x), y-(0.985*y)
    gradient(x, y, scale_x*-1, scale_y, 159, 152, 222, 255, 159, 152, 222, 0, true)
    gradient(x, y, scale_x, scale_y, 159, 152, 222, 0, 159, 152, 222, 255, false)
end

local function renderLog()
    local amount = gui.get(notifyAmount)
    if(#renderQ > 0) then 
        table.insert(rendering, renderQ[#renderQ])
        table.remove(renderQ, #renderQ)
        rendering[#rendering].exp = curTime + gui.get(fadeDuration)
        if(#rendering > amount) then
            table.remove(rendering, 1)
        end
    end
    if(#rendering <= 0) then return end

    local curTime = globals.curtime();
    local width, height = cheat.get_window_size()

    for i, input in ipairs(rendering) do
        local x, y = width / 2, height / 2
        local spacer = (0.04*y+(i*y*0.04))
        local textString = string.format("%s %s for %d | %d left", input.action, input.playername, input.hitfor, input.left)
        local textWidth = getWordWidth(textString)
        y = y+(0.7*y)-spacer
        renderBar(x,y, alpha)
        x = x-(x*(textWidth/2))
    
        text(x, y, 255, 255, 255, 255, 2, true, textString)

        if (input.exp < curTime) then
            table.remove(rendering, i)
        end
    end
    
end

local function renderNumbers()
    if(#dmg_event > 0) then 
        floating_numbers[#floating_numbers+1] = {player = dmg_event[#dmg_event].enemy, hitfor = dmg_event[#dmg_event].hitfor, alpha = 255, x = 0, y = 0, exp = curTime + 4}
        table.remove(dmg_event, #dmg_event)
    end
    if(#floating_numbers <= 0) then return end

    local local_player = engine.get_local_player()
    local localOrigin = vector(entity.get_origin(local_player))
    local width, height = cheat.get_window_size()

    for i, floating_entry in ipairs(floating_numbers) do
        local player = floating_entry.player
        local dmg_taken = floating_entry.hitfor
        local x, y = floating_entry.x, floating_entry.y
        local alpha = floating_entry.alpha
        local exp = floating_entry.exp
        local sx, sy = width / 2, height / 2


        local enemyOrigin = vector(entity.get_origin(player))
        local distance = localOrigin:dist_to(enemyOrigin)

        local bx, by = utility.world_to_screen(entity.bone_position(player, 6))
        local starting_offset = (by-((25/distance)*sy))

        text(bx+x, starting_offset-y, 207, 203, 242, alpha, 0, true, dmg_taken)

        floating_entry.y = lerp(y, y+(0.01*sy), utility.get_delta_time() * 4)
        if (exp < curTime) then
            table.remove(floating_numbers, i)
        end

        if (exp-3 < curTime) then
            floating_entry.alpha = math.floor(lerp(alpha, 0, utility.get_delta_time()))
        end
    end
end


local function paint()
    
    curTime = globals.curtime()
    local total_hits = engine.get_total_hits()
    local temp_ent = {}
    for i, player in ipairs(entity.get_players()) do
        if(entity.is_enemy(player)) then
            local enemypawn = entity.get_player_pawn(player)
            local health = memory.read_integer(enemypawn + 0x324)
            local playername = entity.get_player_name(player)
            temp_ent[#temp_ent + 1] = { playername, health } 
            for i, enemy in ipairs(enemy_ent) do 
                if(health > enemy[2])then goto continue end
                if(enemy[1] == playername and enemy[2] ~= health and total_hits ~= last_total_hits) then
                    local action = "Hit"
                    if(health <= 0)then
                        action = "Killed"
                    end
                    table.insert(renderQ, {action = action, playername = playername, hitfor = enemy[2]-health, left = health, exp = 0})
                    table.insert(dmg_event, {enemy = player, hitfor = enemy[2]-health})
                    last_total_hits = total_hits
                end
                ::continue::     
            end
        end
    end
    enemy_ent = temp_ent
    if(entity.is_alive(engine.get_local_player())) then
        if(gui.get(notifyAmount) ~= 0) then
            renderLog()
        end
        renderNumbers()
    end
    
end

cheat.set_callback("paint", paint)