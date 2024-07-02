-- port of skeet lua, traces local player
local trailData = {};

local enable = gui.new_checkbox("Enable")
local segmentEXP = gui.new_slider("Exp time", 1, 100)
local lineSize = gui.new_slider("Line Size", 1, 100)
local rainbow = gui.new_checkbox("Rainbow")


local function getFadeRGB(seed, speed)
	local r = math.floor(math.sin((globals.realtime() + seed) * speed) * 127 + 128)
	local g = math.floor(math.sin((globals.realtime() + seed) * speed + 2) * 127 + 128)
	local b = math.floor(math.sin((globals.realtime() + seed) * speed + 4) * 127 + 128)
	return r, g, b;
end

cheat.set_callback('paint', function()

	local lp = engine.get_local_player();
	if (entity.is_alive(lp) and gui.get(enable)) then
		local curTime = globals.curtime();
		local curOrigin = vector(entity.get_origin(lp));
		if (trailData.lastOrigin == nil) then
			trailData.lastOrigin = curOrigin;
		end
		local dist = curOrigin:dist_to(trailData.lastOrigin);
		if (trailData.trailSegments == nil) then
			trailData.trailSegments = {};
		end
		if (dist ~= 0) then
			local x, y, z = entity.get_origin(lp);
			local trailSegment = { pos = curOrigin, exp = curTime + gui.get(segmentEXP) * 0.1, x = x, y = y, z = z };
			table.insert(trailData.trailSegments, trailSegment);
		end
		trailData.lastOrigin = curOrigin;
		for i = #trailData.trailSegments, 1, -1 do
			if (trailData.trailSegments[i].exp < curTime) then
				table.remove(trailData.trailSegments, i);
			end
		end
		for i, segment in ipairs(trailData.trailSegments) do
			local x, y = utility.world_to_screen(segment.x, segment.y, segment.z)
			local seed = 0;
			if (gui.get(rainbow)) then
			    seed = i;
			end
			if (x ~= nil and y ~= nil) then
				local r, g, b = getFadeRGB(seed, 10 * 0.1)
				if (not gui.get(rainbow)) then
					r, g, b = 255, 255, 255
				end
				if (i < #trailData.trailSegments) then
					local segment2 = trailData.trailSegments[i + 1]
					local x2, y2 = utility.world_to_screen(segment2.x, segment2.y, segment2.z)
					if (x2 ~= nil and y2 ~= nil) then
						for i = 1, gui.get(lineSize) do
							render.line(x + i, y + i, x2 + i, y2 + i, r, g, b, 255, 1)
						end
					end
				end
			end
		end
	end
end)