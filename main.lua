local state = ya.sync(function(st)
	return st
end)

local add_file_data = ya.sync(function(st, file_path, size, count, is_dir)
	if not st.file_data then st.file_data = {} end
	st.file_data[file_path] = { size = size, count = count, is_dir = is_dir }
	ui.render()
end)

local remove_file_data = ya.sync(function(st, file_path)
	if st.file_data then st.file_data[file_path] = nil end
end)

local function setup(st)
	if Yatline ~= nil then
		Yatline.coloreds.get["selected-files-size"] = function()
			local current_state = state()
			if not current_state.file_data then current_state.file_data = {} end

			local new_selection = {}
			for _, url in pairs(cx.active.selected) do
				new_selection[tostring(url)] = true
			end

			if not next(new_selection) then
				for path in pairs(current_state.file_data) do
					remove_file_data(path)
				end
				return nil
			end

			for path in pairs(current_state.file_data) do
				if not new_selection[path] then remove_file_data(path) end
			end

			for path in pairs(new_selection) do
				if current_state.file_data[path] == nil then
					-- Mark as loading immediately to prevent duplicate spawns on every render
					current_state.file_data[path] = false
					ya.emit("plugin", { st._id, ya.quote(path, true) })
				end
			end

			local total_size, total_count, has_directory = 0, 0, false
			for _, data in pairs(current_state.file_data) do
				if data then  -- false = still loading, skip
					total_size = total_size + data.size
					total_count = total_count + data.count
					if data.is_dir then has_directory = true end
				end
			end

			if total_size == 0 then return {} end

			local size_str = ya.readable_size(total_size)
			local text = has_directory
				and string.format(" %d files, %s ", total_count, size_str)
				or string.format(" %s ", size_str)
			return { { text, "blue" } }
		end
	end
end

local function entry(st, job)
	local file_path = job.args[1]

	-- Don't bail on non-zero exit: du returns 1 on permission-denied subdirs but still outputs a total
	local size_output = Command("du"):arg("-sb"):arg(file_path):output()
	if not size_output then return end

	local size = tonumber(size_output.stdout:match("^(%d+)"))
	if not size then return end

	local count, is_dir = 1, false

	local stat_output = Command("stat"):arg("-c"):arg("%F"):arg(file_path):output()
	if stat_output and stat_output.status.success then
		if stat_output.stdout:match("^%s*(.-)%s*$") == "directory" then
			is_dir = true
			local count_output = Command("sh")
				:arg("-c")
				:arg(string.format("find %s -type f 2>/dev/null | wc -l", ya.quote(file_path, true)))
				:output()
			if count_output and count_output.status.success then
				count = tonumber(count_output.stdout:match("%d+")) or 0
			end
		end
	end

	add_file_data(file_path, size, count, is_dir)
end

return { setup = setup, entry = entry }
