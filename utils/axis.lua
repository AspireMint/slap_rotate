local current_modname = minetest.get_current_modname()
local path = minetest.get_modpath(current_modname)

local AXIS, LOOK_DIR = dofile(path.."/data/axis.lua")

local util = {}

util.axis_exists = function(axis)
	return not not AXIS[axis]
end

util.get_axis_index = function(axis)
	if not util.axis_exists(axis) then
		error("Are you trying to open new dimension? Not in this universe!")
	end
	return AXIS[axis]
end

util.get_look_dir = function(user)
	local facedir = minetest.dir_to_facedir(user:get_look_dir(), false)
	return LOOK_DIR[facedir]
end

return util
