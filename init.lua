local FORMSPEC_NAME = "freetouch_edit"

minetest.register_node("freetouch:freetouch", {
	description = "Formspec touch node",
	groups = {cracky=3},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
    meta:set_string("channel", "freetouch")
    meta:set_string("formspec", "size[10,8]")
	end,
	drawtype = "nodebox",
	tiles = {
		"freetouch_back.png",
		"freetouch_back.png",
		"freetouch_back.png",
		"freetouch_back.png",
		"freetouch_back.png",
		"freetouch_front.png"
		},
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.5, -0.5, 0.4, 0.5, 0.5, 0.5 }
		}
	},
  on_punch = function(pos, _, player)
    local meta = minetest.get_meta(pos)
    local fs = meta:get_string("formspec")

    local playername = player:get_player_name()

    local has_freetouch_priv = minetest.check_player_privs(playername, "freetouch")
    if minetest.is_protected(pos, playername) or not has_freetouch_priv then
      return
    end

    local formspec = "size[12,10;]" ..
      "textarea[0.2,0;12,10;fs;Formspec;" .. minetest.formspec_escape(fs) .. "]" ..
      "button_exit[0,9;6,1;remove;Remove]" ..
      "button_exit[6,9;6,1;save;Save]" ..
      ""

    minetest.show_formspec(playername,
      FORMSPEC_NAME .. ";" .. minetest.pos_to_string(pos),
      formspec
    )

  end,
	on_receive_fields = function(pos, _, fields, sender)
    local meta = minetest.get_meta(pos)
    local channel = meta:get_string("channel")
    print(channel)
    digilines.receptor_send(pos, digilines.rules.default, channel, {
      fields = fields,
      pos = pos,
      playername = sender:get_player_name()
    })
  end,
  digiline =  {
    receptor = {}
  },
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local parts = formname:split(";")
	local name = parts[1]
	if name ~= FORMSPEC_NAME then
		return
	end

	local pos = minetest.string_to_pos(parts[2])
	local playername = player:get_player_name()

  local has_freetouch_priv = minetest.check_player_privs(playername, "freetouch")

	if minetest.is_protected(pos, playername) or not has_freetouch_priv then
		return
	end

	if fields.save then
    local meta = minetest.get_meta(pos)
    meta:set_string("formspec", fields.fs)
	end

  if fields.remove then
    minetest.set_node(pos, { name = "air" })
  end
end)

minetest.register_privilege("freetouch", {
  description = "can edit freetouch formspecs",
  give_to_singleplayer = true
})
