--Globals
local global_frame, gobal_seconds = globals.framecount(), globals.realtime()
local fps_list, boxes = {}, {}
local textWidth = 0
-- references
local text, gradient, new_checkbox, gui_get = render.text, render.gradient, gui.new_checkbox, gui.get
local NAME, UPDATE, VALUE, RED, GREEN, BLUE, X = 1, 2, 3, 4, 5, 6, 7
--individual char thicness
local character_thicness = {['a'] = 0.0075,['b'] = 0.0075,['c'] = 0.0075,['d'] = 0.0075,['e'] = 0.0075,['f'] = 0.005,['g'] = 0.0075,['h'] = 0.0075,['i'] = 0.005,['j'] = 0.005,['k'] = 0.0075,['l'] = 0.005,['m'] = 0.01,['n'] = 0.0075,['o'] = 0.0075,['p'] = 0.0075,['q'] = 0.0075,['r'] = 0.005,['s'] = 0.005,['t'] = 0.005,['u'] = 0.0075,['v'] = 0.0075,['w'] = 0.01,['x'] = 0.0075,['y'] = 0.0075,['z'] = 0.0075,['A'] = 0.0075,['B'] = 0.0075,['C'] = 0.0075,['D'] = 0.0075,['E'] = 0.0075,['F'] = 0.0075,['G'] = 0.0075,['H'] = 0.01,['I'] = 0.005,['J'] = 0.005,['K'] = 0.0075,['L'] = 0.0075,['M'] = 0.01,['N'] = 0.0075,['O'] = 0.0075,['P'] = 0.0075,['Q'] = 0.01,['R'] = 0.0075,['S'] = 0.0075,['T'] = 0.0075,['U'] = 0.0075,['V'] = 0.0075,['W'] = 0.01,['X'] = 0.0075,['Y'] = 0.0075,['Z'] = 0.0075,['1'] = 0.0075,['2'] = 0.0075,['3'] = 0.0075,['4'] = 0.0075,['5'] = 0.0075,['6'] = 0.0075,['7'] = 0.0075,['8'] = 0.0075,['9'] = 0.0075,['0'] = 0.0075,[':'] = 0.005,['.'] = 0.005,['|'] = 0.005,['/'] = 0.005,['!'] = 0.005,['<'] = 0.005,['>'] = 0.005,[','] = 0.005,['?'] = 0.005,['='] = 0.005,['-'] = 0.005,['+'] = 0.005, [' '] = 0.005}
-- ui
local staticToggle = new_checkbox("[FPS Bar] Static position")
--get screensize
local function getScreenXY()
    local width, height = cheat.get_window_size()
    local x, y = width / 2, height / 2
    return x,y
end
--update the text color
local function updateColor(box, r, g, b)
	box[RED] = r
	box[GREEN] = g
	box[BLUE] = b
end
--update the text values
local function updateValue(box, val)
	box[VALUE] = val
end
--render the bottom gradient bar
local function renderBar(x,y)
    local scale_x, scale_y = x-(0.771*x), y-(0.985*y)
    gradient(x, y*2-(0.025*(y*2)), scale_x*-1, scale_y, 159, 152, 222, 255, 159, 152, 222, 0, true)
    gradient(x, y*2-(0.025*(y*2)), scale_x, scale_y, 159, 152, 222, 0, 159, 152, 222, 255, false)
end
--calculate the fps with globals.realtime und globals.framecount // Nicht optimal, frames können nicht unter 64 gehen wegen tickrate
local function calcFPS(box)
    local new_sec = globals.realtime()
    if(new_sec < gobal_seconds + 1) then return end
    gobal_seconds = new_sec

    local fps = math.floor(globals.framecount() - global_frame)
    global_frame = globals.framecount()
    if(#fps_list < 5) then table.insert(fps_list, fps) end

    updateValue(box, fps)
end
-- calculate the frame variation from the average of the last 5 framerate samples and the latest framerate
local function calcVar(box)
    local var = 0
    if(#fps_list < 5) then return var end
    local fps_sum = 0
    for i, fps in ipairs(fps_list) do
        fps_sum = fps_sum + fps
    end
    local avg = fps_sum/#fps_list
    var = math.floor(fps_list[#fps_list] - avg)
    fps_list = {}

    if var < 0 then
		updateColor(box, 255, 60, 80)
        var = var*-1
	else
		updateColor(box, 159, 152, 222)
	end

    updateValue(box, var)
end
--calculate the player velocity
local function calcSpeed(box)
    local local_player = engine.get_local_player()
    local speed = math.floor(entity.get_velocity(local_player)+0.1)
    updateValue(box, speed)
end
--get the width of a word using the character_thicness
local function getWordWidth(word)
    local wordWidth = 0
    word = tostring(word)
    for c in word:gmatch"." do
        wordWidth = wordWidth + character_thicness[c]
    end
    return wordWidth
end
--paint function
local function paint()
    local x,y = getScreenXY()
    local xpadding = 0.02
    local lastWidth = 0
    local fullWidht = 0
    local static = gui_get(staticToggle)
    renderBar(x,y)
    x = x-(x*(textWidth/2))
	for i, box in ipairs(boxes) do
        local nameWidth = getWordWidth(box[NAME])
        local valueWidth = getWordWidth(box[VALUE])
        if(lastWidth ~= 0) then x = x+(lastWidth*x)+(xpadding*x) end
        if(box[X] ~= 0 and static) then x = box[X] end
		box[UPDATE](box)
        text(x, y*2-(0.018*(y*2)), 255, 255, 255, 255, 2, true, tostring(box[NAME]))
        text(x+(nameWidth*x), y*2-(0.018*(y*2)), box[RED], box[GREEN], box[BLUE], 255, 2, true, tostring(box[VALUE]))
        lastWidth = nameWidth + valueWidth
        fullWidht = fullWidht + lastWidth
        if(not static) then box[X] = x end
	end
    if(fullWidht ~= textWidth) then textWidth = fullWidht + ((#boxes-1)*xpadding) end
end
--textbox handler
local function add_box(name, functioncall, r, g, b)
	boxes[#boxes + 1] = { name, functioncall, 0, r, g, b, 0}
end
--boxes that need to be drawn. modular so own functions can be added
add_box("FPS ", calcFPS, 159, 152, 222)
add_box("VAR ", calcVar, 159, 152, 222)
add_box("SPEED ", calcSpeed, 159, 152, 222)
--cheat callbacks
cheat.set_callback("paint", paint)

--made by @e.f.306
--https://github.com/kss306/melatonin-scripts