-- ===========================================
--  Animated Twitch / 7TV Chat Overlay
--  Based on Arsoniv's Non-Animated version
-- ===========================================

local waywall = require("waywall")
local priv    = require("priv")
local utf8    = require("utf8")
local json    = require("dkjson")

-- Remove invisible characters (prevents rendering glitches)
local INVISIBLE_CHARS = {
	[0x200B] = true, [0x200C] = true, [0x200D] = true,
	[0x034F] = true, [0xFE0F] = true,
}
local function strip_invisible(s)
	local t = {}
	for _, c in utf8.codes(s) do
		if not INVISIBLE_CHARS[c] then t[#t+1] = utf8.char(c) end
	end
	return table.concat(t)
end

-- === File helpers ===
local function read_raw_data(filename)
	local file = assert(io.open(filename, "rb"), "failed to open " .. filename)
	local data = file:read("*all"); file:close(); return data
end

local function read_json(filename)
	local file = assert(io.open(filename, "r"), "failed to open " .. filename)
	local data = file:read("*all"); file:close(); return json.decode(data)
end

-- === Config file paths ===
local home = os.getenv("HOME")
local atlas_filename    = home .. "/.config/waywall/atlas.raw"
local emoteset_filename = home .. "/.config/waywall/emoteset.json"

-- === Optional Twitch set, uncomment this and bottom part to download Twitch emote sets. ===
-- local twitch_atlas_filename  = "/home/bunny/.config/waywall/atlas_twitch.raw"
-- local twitch_json_filename   = "/home/bunny/.config/waywall/emoteset_twitch.json"

-- === Chat object factory ===
local function new_chat(channel, x, y, size)
	local CHAT = {
		channel          = channel,
		chat_x           = x,
		chat_y           = y,
		size             = size,
		ls               = 20,    -- line spacing (reccomended 15 minimum to prevent emote clipping)
		emote_h          = 32,    -- emote height (px)
		wrap_width       = 500,   -- Max width in pixels before wrapping
		max_lines        = 20,    -- max visible messages
		messages         = {},
		emote_set        = {},
		emote_atlas      = nil,
		emote_images     = {},
		chat_text        = nil,
		irc_client       = nil,
		has_connected    = false,
		ip               = priv.IRC_IP,
		port             = priv.IRC_PORT,
		username         = priv.IRC_USERNAME,
		token            = priv.IRC_TOKEN,
		message_lifespan = 25000, -- message lifetime (ms)
		self_id          = 0,     -- local id counter
	}

	-- Clear rendered text and emotes
	local function clear_drawables()
		if CHAT.chat_text then CHAT.chat_text:close(); CHAT.chat_text = nil end
		for _, v in ipairs(CHAT.emote_images) do v:close() end
		CHAT.emote_images = {}
	end

	-- Remove a message by ID and redraw
	local function remove_message_by_id(id)
		for i = #CHAT.messages, 1, -1 do
			if CHAT.messages[i]._id == id then
				table.remove(CHAT.messages, i)
				break
			end
		end
		CHAT.redraw()
	end

	-- Schedule message removal
	local function schedule_remove(id)
		if not CHAT.message_lifespan then return end
		waywall.sleep(CHAT.message_lifespan)
		remove_message_by_id(id)
	end

	-- Incremental ID generator
	local function next_id()
		CHAT.self_id = CHAT.self_id + 1
		return tostring(CHAT.self_id)
	end

	-- Redraw chat window
    function CHAT.redraw()
        clear_drawables()
        local text_buf = ""
        local current_global_line = 0 -- Tracks total lines (vertical Y offset)

        for _, msg in ipairs(CHAT.messages) do
            -- 1. Setup the message prefix (User + Color)
            local prefix = "<" .. msg.color .. "FF>" .. msg.user .. "<#FFFFFFFF>: "

            -- 2. Create buffers for the full message and the current line
            local message_body_full = ""
            local current_line_str = prefix -- Used to calculate width of the current line
            local is_first_line = true

            -- 3. Loop through every word in the message (No string.sub truncation)
            for word in msg.text:gmatch("%S+") do
                word = strip_invisible(word)

                -- Determine if this word is an emote
                local e = CHAT.emote_set[word]

                -- Calculate the width this item would add
                local item_pixel_width = 0
                local spacing_before = 3
                local spacing_after = 6
                local emote_spacing_str = "" -- String to push text past emote

                if e then
                    local emote_w = CHAT.emote_h * (e.w / e.h)
                    item_pixel_width = emote_w + spacing_before + spacing_after
                    -- The special spacer tag for waywall text
                    emote_spacing_str = "<+" .. (item_pixel_width) .. ">"
                else
                    -- Calculate text width
                    local adv = waywall.text_advance(word .. " ", CHAT.size)
                    item_pixel_width = adv.x
                end

                -- 4. Check if we need to WRAP
                local current_line_width = waywall.text_advance(current_line_str, CHAT.size).x

                if (current_line_width + item_pixel_width) > CHAT.wrap_width then
                    -- Add newline to the output buffer
                    message_body_full = message_body_full .. "\n"

                    -- Reset the current line tracker
                    -- Note: We remove prefix because subsequent lines don't have the username
                    current_line_str = ""

                    -- Increase vertical counter so emotes know to drop down
                    current_global_line = current_global_line + 1
                    is_first_line = false
                end

                -- 5. Handle Emote Drawing
                if e then
                    -- Re-calculate X position based on the CURRENT wrapped line
                    -- We calculate what the text width is *before* adding this emote
                    local advance = waywall.text_advance(current_line_str, CHAT.size)

                    local emote_h = CHAT.emote_h
                    local emote_w = emote_h * (e.w / e.h)

                    local line_h = CHAT.size + CHAT.ls
                    -- Use current_global_line to find the correct Y height
                    local text_baseline_y = CHAT.chat_y + CHAT.size + current_global_line * line_h
                    local emote_y = text_baseline_y - emote_h / 2 - CHAT.size / 2

                    -- We add chat_x. If it's the first line, the prefix is included in 'advance'.
                    -- If it's a wrapped line, 'advance' is just the words on that new line.
                    local draw_x = advance.x + CHAT.chat_x + spacing_before

                    local img
                    if e.animated then
                        img = waywall.animated_image(e.path, {
                            dst = { x = draw_x, y = emote_y, w = emote_w, h = emote_h },
                        })
                    else
                        img = waywall.image_a({
                            src   = { x = e.x, y = e.y, w = e.w, h = e.h },
                            dst   = { x = draw_x, y = emote_y, w = emote_w, h = emote_h },
                            atlas = CHAT.emote_atlas,
                        })
                    end
                    if img then table.insert(CHAT.emote_images, img) end

                    -- Add the spacer to the string buffers
                    message_body_full = message_body_full .. emote_spacing_str
                    current_line_str = current_line_str .. emote_spacing_str
                else
                    -- Add text to string buffers
                    message_body_full = message_body_full .. word .. " "
                    current_line_str = current_line_str .. word .. " "
                end
            end

            -- Add the finished message to the main buffer
            text_buf = text_buf .. prefix .. message_body_full .. "\n"
            current_global_line = current_global_line + 1
        end

        CHAT.chat_text = waywall.text(text_buf, {
            x = CHAT.chat_x, y = CHAT.chat_y + CHAT.size, size = CHAT.size, ls = CHAT.ls,
        })
    end

	-- IRC message handler
	local function irc_callback(line)
		if not line:match("PRIVMSG") then return end

		local color  = line:match("color=([^;]+)") or "#FFFFFF"
		local user   = line:match("display%-name=([^;]+)") or "unknown"
		local text   = line:match("PRIVMSG #[^:]+:(.+)")
		local msg_id = line:match("id=([^;]+)") or next_id()

		if not text then return end

		table.insert(CHAT.messages, {
			user = user, color = color, text = text, _id = msg_id,
		})
		if #CHAT.messages > CHAT.max_lines then table.remove(CHAT.messages, 1) end
		CHAT.redraw()
		schedule_remove(msg_id)
	end

	-- Send message
	function CHAT:send(message)
		if not self.irc_client then return end
		local id = next_id()
		self.irc_client:send("PRIVMSG #" .. self.channel .. " :" .. message .. "\r\n")

		table.insert(self.messages, {
			user = self.username, color = "#1a7286",
			text = strip_invisible(message), _id = id,
		})
		if #self.messages > self.max_lines then table.remove(self.messages, 1) end
		self.redraw()
		schedule_remove(id)
	end

	-- Initialize connection + load emotes
	function CHAT:open()
		if self.has_connected then return end
		self.has_connected = true
		print("Starting Chat...")

		-- Load 7TV emoteset (primary)
		print("Loading 7TV emote atlas from:", atlas_filename)
		print("Loading 7TV emote set from:", emoteset_filename)
		self.emote_set = read_json(emoteset_filename)
		local atlas_data = read_raw_data(atlas_filename)
		self.emote_atlas = waywall.atlas(2048, atlas_data)

		local count = 0
		for _ in pairs(self.emote_set) do count = count + 1 end
		print("Loaded", count, "7TV emotes")

		-- Twitch emotes (remove the [] and --)
		--[[
		print("Loading Twitch emote atlas from:", twitch_atlas_filename)
		print("Loading Twitch emote set from:", twitch_json_filename)
		self.emote_set_twitch = read_json(twitch_json_filename)
		local twitch_atlas_data = read_raw_data(twitch_atlas_filename)
		self.emote_atlas_twitch = waywall.atlas(2048, twitch_atlas_data)
		local twitch_count = 0
		for _ in pairs(self.emote_set_twitch) do twitch_count = twitch_count + 1 end
		print("Loaded", twitch_count, "Twitch emotes")
		]]

		-- IRC connection
		self.irc_client = waywall.irc_client_create(
			self.ip, self.port, self.username, self.token, irc_callback
		)
		waywall.sleep(3000)
		self.irc_client:send("CAP REQ :twitch.tv/tags twitch.tv/commands\r\n")
		self.irc_client:send("JOIN #" .. self.channel .. "\r\n")
	end

	return CHAT
end

return new_chat
