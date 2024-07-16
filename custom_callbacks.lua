local custom_callbacks = {}
custom_callbacks.__index = custom_callbacks
local active_callbacks = {}

local function table_contains(tbl, value)
    for i, v in pairs(tbl) do
        if v == value then 
            return true
        end
    end
    return false
end

local function send_callback(event, ...)
    if(not event) then return end
    for i, active_cb in ipairs(active_callbacks) do
        if(active_cb.event == event) then
            local cb = active_cb.callback
            local data = {...}
            cb(data)
        end
    end
end

local function round_start()
    local event = round_start
    local round_number = 3
    send_callback(event, round_number)
end

local function round_end()
    local event = round_end
    local round_number = 2
    send_callback(event, round_number)
end

local function enemy_hit()
    local event = enemy_hit
    local dmg_taken = 12
    local hp_remain = 88
    local player_name = "Peter"
    send_callback(event, player_name, dmg_taken, hp_remain)
end

local function bomb_beginplant()
    print("bomb begin plant")
end

local function bomb_abortplant()
    print("bomb plant aborted")
end

local function bomb_planted()
    print("Bomb planted")
end

local function bomb_dropped()
    print("bomb dropped")
end

local function bomb_begindefuse()
    print("defuse begins")
end

local function bomb_abortdefuse()
    print("defuse stopped")
end

local function player_connected()
    print("player connected")
end


function custom_callbacks.set_callback(event, callback)
    if(not event or not callback) then
        print(string.format("Event or Callback non existing"))
        return
    end
    local instance = setmetatable({}, custom_callbacks)
    instance.event = event
    instance.callback = callback
    table.insert(active_callbacks, instance)
    return instance
end

function custom_callbacks.callback_count()
    return #active_callbacks
end

function custom_callbacks:call_event()
    self.event()
end

function custom_callbacks.call_events()
    local alrdy_ran = {}
    for i, event in ipairs(active_callbacks) do
        if(table_contains(alrdy_ran, event.event)) then goto continue end
        event.event()
        table.insert(alrdy_ran, event.event)
        ::continue::
    end
    print(string.format("Registerd Events: %s", #active_callbacks))
end




custom_callbacks.events = {
    round_start = round_start, --returns new round int
    round_end = round_end, -- returns passed round int
    enemy_hit = enemy_hit, -- returns player name, damage taken and hp left
    bomb_beginplant = bomb_beginplant, -- returens seconds as int till planted
    bomb_abortplant = bomb_abortplant,
    bomb_planted = bomb_planted, -- returns bomb spot and planter pawn
    bomb_dropped = bomb_dropped,
    bomb_begindefuse = bomb_begindefuse, -- returns defuser pawn and time till defused as int
    bomb_abortdefuse = bomb_abortdefuse,
    player_connected = player_connected -- returens player pawn
}

return custom_callbacks