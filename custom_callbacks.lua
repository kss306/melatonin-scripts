--[[
Check out the docs under: https://melatonin.gitbook.io/lua-documentaiton/documentation/extra-api-doc/custom-callbacks
If the script stops working after a update, consider updating it from my github due to changed offsets: https://github.com/kss306/melatonin-scripts/blob/main/custom_callbacks.lua
]]

local custom_callbacks = {}
custom_callbacks.__index = custom_callbacks
local active_callbacks = {}

local function table_contains(tbl, value)
    for i, v in pairs(tbl) do
        if v == value then 
            return true, i
        end
    end
    return false
end

local function send_callback(event, ...)
    if(not event) then return end
    for i, active_cb in ipairs(active_callbacks) do
        if(active_cb.event == event) then
            local cb = active_cb.callback
            if(not cb) then
                active_cb:remove()
                print("Removed callback due to missing function")
                goto continue
            end
            local data = {...}
            cb(data)
            ::continue::
        end
    end
end

local function round_start(self)
    local round_number = 3
    local time_limit = 1200
    send_callback(self, round_number, time_limit)
end

local function round_end(self)
    local round_number = 2
    local winner = "T"
    local reason = 1
    local message = "Terrorist win by detonating the bomb"
    send_callback(self, round_number, winner, reason, message)
end

local function player_hurt(self)
    local player_hit = 2
    local player_damager = 3
    local dmg_taken = 12
    local hp_remain = 88
    local body_part = 3
    send_callback(self, player_hit, player_damager, dmg_taken, hp_remain, body_part)
end

local function item_purchase(self)
    local player = 2
    local item = 2
    local cost = 2500
    send_callback(self, player, item, cost)
end

local function bomb_beginplant(self)
    local player = 4
    local bomb_spot = "A"
    local planted_in = 4
    send_callback(self, player, bomb_spot, planted_in)
end

local function bomb_abortplant(self)
    local player = 4
    local bomb_spot = "A"
    send_callback(self, player, bomb_spot)
end

local function bomb_planted(self)
    local player = 4
    local bomb_site = "A"
    local bomb_timer = 45
    send_callback(self, player, bomb_site, bomb_timer)
end

local function bomb_exploded(self)
    local player = 4
    local bomb_site = "A"
    send_callback(self, player, bomb_site)
end

local function bomb_dropped(self)
    local player = 4
    local bomb = 11
    send_callback(self, player, bomb)
end

local function bomb_pickup(self)
    local player = 5
    send_callback(self, player)
end

local function bomb_begindefuse(self)
    local player = 7
    local bomb_spot = "A"
    local defuse_timer = 5
    local has_kit = true
    send_callback(self, player, bomb_spot, defuse_timer, has_kit)
end

local function bomb_abortdefuse(self)
    local player = 7
    local bomb_spot = "A"
    send_callback(self, player, bomb_spot)
end

local function bomb_defused(self)
    local player = 7
    local bomb_spot = "A"
    local time_left = 0.5
    send_callback(self, player, bomb_spot, time_left)
end

local function player_connected(self)
    local player = 8
    send_callback(self, player)
end

local function player_disconnected(self)
    local player = 8
    send_callback(self, player)
end


function custom_callbacks.set_callback(event, callback)   
    if(not event or not callback) then
        local calledLine = debug.getinfo(2).currentline
        local calledSrc = debug.getinfo(2).short_src
        print(string.format("Event or callback non existing. Error in: %s:%d", calledSrc, calledLine))
        return
    end
    local instance = setmetatable({}, custom_callbacks)
    instance.event = event
    instance.callback = callback
    table.insert(active_callbacks, instance)
    return instance
end

function custom_callbacks:remove()
    local bool, index = table_contains(active_callbacks, self)
    if(bool) then table.remove(active_callbacks, index) end
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
        event = event.event
        if(table_contains(alrdy_ran, event)) then goto continue end
        event(event)
        table.insert(alrdy_ran, event)
        ::continue::
    end
    --print(string.format("Registerd Events: %s", #active_callbacks))
end


custom_callbacks.events = {
    round_start = round_start, --returns {int: round_number, int: time_limit}
    round_end = round_end, -- returns {int: round_number, string: winner, int: reason, string: message}
    player_hurt = player_hurt, -- returns {int: player, int: player_damager, int: dmg_taken, int: hp_left, int: body_part}
    item_purchase = item_purchase, -- returns {int player, string: item, int: cost}
    bomb_beginplant = bomb_beginplant, -- returns {int: player, string: bomb_spot, float: planted_in}
    bomb_abortplant = bomb_abortplant, -- reuturns {int: player, string: bomb_spot} 
    bomb_planted = bomb_planted, -- returns {int: player, string: bomb_spot, float: bomb_timer}
    bomb_exploded = bomb_exploded, -- returns {int: player, string: bomb_spot}
    bomb_dropped = bomb_dropped, -- returns {int: player, int: bomb}
    bomb_pickup = bomb_pickup, -- reuturns {int: player}
    bomb_begindefuse = bomb_begindefuse, -- returns {int: player, string: bomb_spot, float: defuse_timer, bool: has_kit}
    bomb_abortdefuse = bomb_abortdefuse, -- returns {int: player, string: bomb_spot}
    bomb_defused = bomb_defused, -- returns {int: player, string: bomb_spot, float: time_left}
    player_connected = player_connected, -- returens {int: player}
    player_disconnected = player_disconnected -- returns {int: player}
}

return custom_callbacks