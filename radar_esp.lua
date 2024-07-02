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
    local x, y = width / 2, height / 2
    return x,y
end

local function renderBody(ent)
    local enemypawn = entity.get_player_pawn(ent)
    local spottedState = memory.read_byte(enemypawn + custom_offsets["m_entitySpottedState"] + custom_offsets["m_bSpotted"])

    if(spottedState == 0) then return end
    local x,y = getScreenXY()
    local local_player = engine.get_local_player()
    local localOrigin = vector(entity.get_origin(local_player))
    local enemyOrigin = vector(entity.get_origin(ent))

    local distance = localOrigin:dist_to(enemyOrigin)
    local hip_upper_x,hip_upper_y = utility.world_to_screen(entity.bone_position(ent,bones["hip_upper"]))
    local hip_lower_x,hip_lower_y = utility.world_to_screen(entity.bone_position(ent,bones["hip_lower"]))
    local stomach_x,stomach_y = utility.world_to_screen(entity.bone_position(ent,bones["stomach"]))
    local chest_x,chest_y = utility.world_to_screen(entity.bone_position(ent,bones["chest"]))
    local chest_upper_x,chest_upper_y = utility.world_to_screen(entity.bone_position(ent,bones["chest_upper"]))
    local head_x,head_y = utility.world_to_screen(entity.bone_position(ent,bones["head"]))

    local shoulder_left_x,shoulder_left_y = utility.world_to_screen(entity.bone_position(ent,bones["shoulder_left"]))
    local elbow_left_x,elbow_left_y = utility.world_to_screen(entity.bone_position(ent,bones["elbow_left"]))
    local wrist_left_x,wrist_left_y = utility.world_to_screen(entity.bone_position(ent,bones["wrist_left"]))
    local hand_left_x,hand_left_y = utility.world_to_screen(entity.bone_position(ent,bones["hand_left"]))

    local shoulder_right_x,shoulder_right_y = utility.world_to_screen(entity.bone_position(ent,bones["shoulder_right"]))
    local elbow_right_x,elbow_right_y = utility.world_to_screen(entity.bone_position(ent,bones["elbow_right"]))
    local wrist_right_x,wrist_right_y = utility.world_to_screen(entity.bone_position(ent,bones["wrist_right"]))
    local hand_right_x,hand_right_y = utility.world_to_screen(entity.bone_position(ent,bones["hand_right"]))

    local leg_left_x,leg_left_y = utility.world_to_screen(entity.bone_position(ent,bones["leg_left"]))
    local knee_left_x,knee_left_y = utility.world_to_screen(entity.bone_position(ent,bones["knee_left"]))
    local foot_left_x,foot_left_y = utility.world_to_screen(entity.bone_position(ent,bones["foot_left"]))

    local leg_right_x,leg_right_y = utility.world_to_screen(entity.bone_position(ent,bones["leg_right"]))
    local knee_right_x,knee_right_y = utility.world_to_screen(entity.bone_position(ent,bones["knee_right"]))
    local foot_right_x,foot_right_y = utility.world_to_screen(entity.bone_position(ent,bones["foot_right"]))

    render.line(hip_upper_x, hip_upper_y, hip_lower_x, hip_lower_y, 255, 255, 255, 255, (x*0.2) / distance)
    render.line(hip_upper_x, hip_upper_y, stomach_x, stomach_y, 255, 255, 255, 255, (x*0.2) / distance)
    render.line(stomach_x, stomach_y, chest_x, chest_y, 255, 255, 255, 255, (x*0.2) / distance)
    render.line(chest_x, chest_y, chest_upper_x, chest_upper_y, 255, 255, 255, 255, (x*0.2) / distance)
    render.line(chest_upper_x, chest_upper_y, head_x, head_y, 255, 255, 255, 255, (x*0.2) / distance)

    render.line(chest_upper_x, chest_upper_y, shoulder_left_x, shoulder_left_y, 255, 255, 255, 255, (x*0.2) / distance)
    render.line(shoulder_left_x, shoulder_left_y, elbow_left_x, elbow_left_y, 255, 255, 255, 255, (x*0.2) / distance)
    render.line(elbow_left_x, elbow_left_y, wrist_left_x, wrist_left_y, 255, 255, 255, 255, (x*0.2) / distance)
    render.line(wrist_left_x, wrist_left_y, hand_left_x, hand_left_y, 255, 255, 255, 255, (x*0.2) / distance)

    render.line(chest_upper_x, chest_upper_y, shoulder_right_x, shoulder_right_y, 255, 255, 255, 255, (x*0.2) / distance)
    render.line(shoulder_right_x, shoulder_right_y, elbow_right_x, elbow_right_y, 255, 255, 255, 255, (x*0.2) / distance)
    render.line(elbow_right_x, elbow_right_y, wrist_right_x, wrist_right_y, 255, 255, 255, 255, (x*0.2) / distance)
    render.line(wrist_right_x, wrist_right_y, hand_right_x, hand_right_y, 255, 255, 255, 255, (x*0.2) / distance)

    render.line(hip_lower_x, hip_lower_y, leg_left_x, leg_left_y, 255, 255, 255, 255, (x*0.2) / distance)
    render.line(leg_left_x, leg_left_y, knee_left_x, knee_left_y, 255, 255, 255, 255, (x*0.2) / distance)
    render.line(knee_left_x, knee_left_y, foot_left_x, foot_left_y, 255, 255, 255, 255, (x*0.2) / distance)

    render.line(hip_lower_x, hip_lower_y, leg_right_x, leg_right_y, 255, 255, 255, 255, (x*0.2) / distance)
    render.line(leg_right_x, leg_right_y, knee_right_x, knee_right_y, 255, 255, 255, 255, (x*0.2) / distance)
    render.line(knee_right_x, knee_right_y, foot_right_x, foot_right_y, 255, 255, 255, 255, (x*0.2) / distance)

    --local bx, by, bx2, by2 = entity.get_bounding_box(ent)
    local ox, oy = utility.world_to_screen(entity.get_origin(ent))
    render.text(ox-(0.009*x), oy, 255, 0, 0, 255, 0, true, "RADAR")
end

local function paint()
    
    for i, player in ipairs(entity.get_players()) do
        if(entity.is_enemy(player) and entity.is_alive(player)) then
            renderBody(player)
        end
    end
end

cheat.set_callback("paint", paint)