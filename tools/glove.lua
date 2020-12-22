local current_modname = minetest.get_current_modname()
local path = minetest.get_modpath(current_modname)

local AXIS, LOOK_DIR = dofile(path.."/data/axis.lua")
local axis_util = dofile(path.."/utils/axis.lua")
local node_util = dofile(path.."/utils/node.lua")
local paramtype_util = dofile(path.."/utils/paramtype.lua")
local rotate_util = dofile(path.."/utils/rotate.lua")

local TOOL_NAME = "glove"

local get_new_rotation = function(paramtype, axis, origin, angle)
    local count = rotate_util.get_repetition(angle)
    local rotation = origin
    for i=1,count do
        rotation = rotate_util.rotate(paramtype, axis, rotation)
    end
    return rotation
end

local handler = function(itemstack, user, pointed_thing, look_dir)
	if pointed_thing.type ~= "node" then
		return
	end
	
	local pos = pointed_thing.under
	
	if not node_util.can_interact(user, pos) then
		return itemstack
	end
	
	local node = minetest.get_node(pos)
	
	if not rotate_util.can_rotate(node) then
		return itemstack
	end

	local ndef = minetest.registered_nodes[node.name]
	local rotation = node.param2 % paramtype_util.get_mask(ndef.paramtype2)
	local angle = -90*look_dir.polarity
	local axis_index = look_dir.perpendicular_axis_index
	local new_rotation = get_new_rotation(ndef.paramtype2, axis_index, rotation, angle)
	local param2_supplement = node.param2 - rotation
	node.param2 = new_rotation + param2_supplement
	minetest.swap_node(pos, node)
	return itemstack
end

minetest.register_tool(current_modname..":"..TOOL_NAME, {
	description = "Glove\n"
		.."left-click rotates node horizontally\n"
		.."right-click rotates node vertically",
	inventory_image = "leather_glove.png^[transformFXR90",
	groups = {tool = 1},
	on_use = function(itemstack, user, pointed_thing)
		return handler(itemstack, user, pointed_thing, LOOK_DIR.y)
	end,
	on_place = function(itemstack, user, pointed_thing)
		local look_dir = axis_util.get_look_dir(user)
		return handler(itemstack, user, pointed_thing, look_dir)
	end,
})


minetest.register_craft({
	output = current_modname..":"..TOOL_NAME,
	recipe = {
		{"group:wool"},
		{"group:stick"}
	}
})

return 
