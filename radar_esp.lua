-- draws esp of enemies if spotted by teammates regardless of esp settings like enable or visible

local custom_offsets = {
    ["m_entitySpottedState"] = 0x2288,
    ["m_bSpotted"] = 0x8
}

local bones = {
    ["hip_lower"] = 1,
    ["hip_upper"] = 2,
    ["stomach"] = 3,
    ["chest"] = 4,
    ["chest_upper"] = 5,
    ["head"] = 6,
    ["neck"] = 7,
    ["shoulder_left"] = 8,
    ["elbow_left"] = 9,
    ["wrist_left"] = 10,
    ["hand_left"] = 11,
    ["shoulder_right"] = 13,
    ["elbow_right"] = 14,
    ["wrist_right"] = 15,
    ["hand_right"] = 16,
    ["center"] = 18,
    ["leg_left"] = 22,
    ["knee_left"] = 23,
    ["foot_left"] = 24,
    ["leg_right"] = 25,
    ["knee_right"] = 26,
    ["foot_right"] = 27,
    ["origin"] = 28
}

local function getScreenXY()
    local width, height = cheat.get_window_size()
    return width / 2, height / 2
end

local function getBoneScreenPositions(ent)
    local positions = {}
    for bone_name, bone_id in pairs(bones) do
        positions[bone_name] = utility.world_to_screen(entity.bone_position(ent, bone_id))
    end
    return positions
end

local function drawLines(bone_pairs, positions)
    local thickness = (screen_center_x * 0.2) / distance
    for _, pair in ipairs(bone_pairs) do
        local x1, y1 = positions[pair[1]][1], positions[pair[1]][2]
        local x2, y2 = positions[pair[2]][1], positions[pair[2]][2]
        render.line(x1, y1, x2, y2, 255, 255, 255, 255, thickness)
    end
end

local function renderBody(ent, screen_center_x)
    local enemypawn = entity.get_player_pawn(ent)
    local spottedState = memory.read_byte(enemypawn + custom_offsets["m_entitySpottedState"] + custom_offsets["m_bSpotted"])

    if spottedState == 0 then return end

    local x,y = getScreenXY()
    local local_player = engine.get_local_player()
    local localOrigin = vector(entity.get_origin(local_player))
    local enemyOrigin = vector(entity.get_origin(ent))
    local distance = localOrigin:dist_to(enemyOrigin)

    local positions = getBoneScreenPositions(ent)

    local body_bones = {
        {"hip_upper", "hip_lower"},
        {"hip_upper", "stomach"},
        {"stomach", "chest"},
        {"chest", "chest_upper"},
        {"chest_upper", "head"}
    }

    local left_arm_bones = {
        {"chest_upper", "shoulder_left"},
        {"shoulder_left", "elbow_left"},
        {"elbow_left", "wrist_left"},
        {"wrist_left", "hand_left"}
    }

    local right_arm_bones = {
        {"chest_upper", "shoulder_right"},
        {"shoulder_right", "elbow_right"},
        {"elbow_right", "wrist_right"},
        {"wrist_right", "hand_right"}
    }

    local left_leg_bones = {
        {"hip_lower", "leg_left"},
        {"leg_left", "knee_left"},
        {"knee_left", "foot_left"}
    }

    local right_leg_bones = {
        {"hip_lower", "leg_right"},
        {"leg_right", "knee_right"},
        {"knee_right", "foot_right"}
    }

    drawLines(body_bones, positions)
    drawLines(left_arm_bones, positions)
    drawLines(right_arm_bones, positions)
    drawLines(left_leg_bones, positions)
    drawLines(right_leg_bones, positions)

    local origin_screen = utility.world_to_screen(entity.get_origin(ent))
    render.text(origin_screen[1] - (0.009 * screen_center_x), origin_screen[2], 255, 0, 0, 255, 0, true, "RADAR")
end

local function paint()
    for i, player in ipairs(entity.get_players()) do
        if entity.is_enemy(player) and entity.is_alive(player) then
            renderBody(player, screen_center_x)
        end
    end
end

cheat.set_callback("paint", paint)