local cc = require("custom_callbacks")
local events = cc.events


local function test(data)
    local player_name = data[1]
    local dmg_taken = data[2]
    local hp_left = data[3]
    print(string.format("Hit %s for: %d HP Left: %d",player_name, dmg_taken, hp_left))
end

local function round_start(data)
    print(data[1])
end

local function enemy_hit()
    print("enemy hit 2")
end

local debug = cc.set_callback(events.enemy_hit, test)
local debug2 = cc.set_callback(events.round_start, round_start)
local debug3 = cc.set_callback(events.enemy_hit, enemy_hit)
--debug:call_event()
--debug2:call_event()
cc.call_events()