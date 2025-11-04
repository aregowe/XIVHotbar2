local text_formatter = {}
local white = '\\cs(255,255,255)'


local function split_string (input_str)
	local t={}
	for str in string.gmatch(input_str, "([^ ]+)") do
		table.insert(t, str)
	end
	return t
end


-- Optimized: Use table.concat instead of string concatenation to reduce GC pressure (Issue #1)
local function format_description(desc)
	local words = split_string(desc)
	local lines = {}
	local current_line = {}
	local line_length = 0
	
	for _, word in ipairs(words) do
		local word_len = #word + 1 -- +1 for space
		if line_length + word_len > 30 and #current_line > 0 then
			table.insert(lines, table.concat(current_line, " "))
			current_line = {word}
			line_length = word_len
		else
			table.insert(current_line, word)
			line_length = line_length + word_len
		end
	end
	
	if #current_line > 0 then
		table.insert(lines, table.concat(current_line, " "))
	end
	
	return table.concat(lines, "\n") .. "\n"
end


function text_formatter.format_ws_info(database, action, action_target)
	local string_return = ""
	
	if database.ws[(action):lower()] ~= nil then
		local ws = database.ws[(action):lower()]
		local ws_info = {}
		ws_info[1] = string.format("\\cs(255,255,0)[%s]\\cr    \\cs(200,200,255)Target:<%s>\\cr\n", ws.name, action_target) 

		-- Optimized: Build skillchain string more efficiently (Issue #3)
		ws_info[2] = format_description(ws.desc)
		
		local sc_parts = {}
		if ws.sc_a then 
			table.insert(sc_parts, string.format("%s%s%s", database:get_element_color_name(ws.sc_a), ws.sc_a, white))
		end
		if ws.sc_b then 
			table.insert(sc_parts, string.format("%s%s%s", database:get_element_color_name(ws.sc_b), ws.sc_b, white))
		end
		if ws.sc_c then 
			table.insert(sc_parts, string.format("%s%s%s", database:get_element_color_name(ws.sc_c), ws.sc_c, white))
		end
		
		if #sc_parts > 0 then
			ws_info[3] = "SC: " .. table.concat(sc_parts, ", ")
		else
			ws_info[3] = "SC: None"
		end
		if (ws.range == 255) then
			ws_info[4] = "Range: \\cs(200,200,255)Self\\cr "
		else
			ws_info[4] = string.format("Range: \\cs(200,200,255)%.1fy\\cr", ws.range)
		end
		string_return = table.concat(ws_info, "\n")
	end
	return string_return
end


function text_formatter.format_ability_info(database, action, action_target)
	local string_return = ""
	
	if database.ja[(action):lower()] ~= nil then
		local ability = database.ja[(action):lower()]
		local ability_info = {}
		ability_info[1] = string.format("\\cs(255,255,0)[%s]\\cr    Target:\\cs(200,200,255)<%s>\\cr\n", ability.name, action_target) 
		ability_info[2] = format_description(ability.desc)
		if (ability.range == 255) then
			ability_info[3] = "Range: \\cs(200,200,255)Self\\cr "
		else
			ability_info[3] = string.format("Range: \\cs(200,200,255)%.1fy\\cr", ability.range)
		end
		string_return = table.concat(ability_info, " \n")
	end
	return string_return
end


function text_formatter.format_spell_info(database, action, action_target)
	local string_return = ""
	
	if database.ma[(action):lower()] ~= nil then
		local spell = database.ma[(action):lower()]
		local spell_info = {}
		spell_info[1] = string.format("\\cs(255,255,0)[%s]\\cr   Target:\\cs(200,200,255)<%s>\\cr\n", database.ma[(action):lower()].name, action_target) 
		spell_target_cost = {}
		if (spell.range == 255) then
			spell_target_cost[1] = "Range: \\cs(200,200,255)Self\\cr "
		else
			spell_target_cost[1] = string.format("Range: \\cs(200,200,255)%.1fy\\cr", spell.range)
		end
		spell_info[2] = format_description(spell.desc)
		if (database.ma[(action):lower()].mpcost ~= 0) then
			spell_target_cost[2] = string.format("MP Cost: \\cs(0,255,0)%sMP\\cr", database.ma[(action):lower()].mpcost) 
		end
		spell_info[3] = table.concat(spell_target_cost, "    ")
		string_return = table.concat(spell_info, "\n")
	end
	return string_return
end


return text_formatter
