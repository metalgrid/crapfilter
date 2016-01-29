--[[
    CrapFilter
    Copyright (C) 2016  Iskren Hadzhinedev

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
]]--

local help = {
	"Syntax: /crapfilter <command> [arguments]",
	"Commands:",
	"add <phrase> - Adds a phrase to the filter",
	"del <phrase> - Deletes a phrase from the filter",
	"list  - Displays the content of the filter",
	"stats - Shows amount of blocked messages and phrases",
	"reset - Resets the filter and statistics",
	"enable - Enables chat filtering",
	"disable - Disables chat filtering"
}

local function Print(x, skip)
	local prefix = "CrapFilter: "
	if (skip) then
		prefix = ""
	end
	return DEFAULT_CHAT_FRAME:AddMessage(prefix .. x)
end

function CrapFilter_OnLoad()

	-- Database initializers
	if (CrapFilterDB == nil) then CrapFilterDB = {} end
	if (CrapFilterDB.phrases == nil) then CrapFilterDB.phrases = {} end
	if (CrapFilterDB.enabled == nil) then CrapFilterDB.enabled = 1 end

	-- Slash command registry
	SLASH_CRAPFILTER1 = "/cf"
	SLASH_CRAPFILTER2 = "/crapfilter"
	SlashCmdList["CRAPFILTER"] = CrapFilter_SlashCommand

	-- Subscribe to events
	this:RegisterEvent("CHAT_MSG_WHISPER")
	this:RegisterEvent("CHAT_MSG_CHANNEL")
	this:RegisterEvent("CHAT_MSG_SYSTEM")
	this:RegisterEvent("VARIABLES_LOADED")

	-- Override chat frame events
	BlizzChatFrame_OnEvent = ChatFrame_OnEvent
	ChatFrame_OnEvent = CrapFilter_ChatFrame_Override
end

function CrapFilter_Stats()
	Print((CrapFilterDB.enabled and "Enabled" or "Disabled"))
	Print("Filtering " .. table.getn(CrapFilterDB.phrases) .. " phrases")
end

function CrapFilter_ChatFrame_Override(event)
	if CrapFilterDB.enabled and (event == "CHAT_MSG_CHANNEL" or event == "CHAT_MSG_WHISPER") then
		local message = arg1
		local name = arg2
		if (CrapFilter_Filter(message)) then
			return false
		end
	end
	BlizzChatFrame_OnEvent(event, message, name)
	return true
end

function CrapFilter_Filter(message)
	local msg = string.lower(message)
	for index, keyword in CrapFilterDB.phrases do
		if (string.find(msg, string.lower(keyword))) then
			return true
		end
	end
	return false
end

function CrapFilter_SlashCommand(message)
	-- Separate command from arguments (if any)
	local paramstr = message
	local cmd = paramstr
	local index = strfind(cmd, " ")
	if (index) then
		cmd = strsub(cmd, 1, index-1)
		paramstr = strsub(paramstr, index+1)
	else
		paramstr = ""
	end

	if (not cmd) then
		return nil
	end
	-- Handle commands
	if cmd == "add" then CrapFilter_AddPhrase(paramstr)
	elseif cmd == "del" then CrapFilter_DelPhrase(paramstr)
	elseif cmd == "reset" then CrapFilter_Reset()
	elseif cmd == "stats" then CrapFilter_Stats()
	elseif cmd == "list" then CrapFilter_List()
	elseif cmd == "enable" then CrapFilter_Toggle(true)
	elseif cmd == "disable" then CrapFilter_Toggle(false)
	else CrapFilter_Help() end
end

function CrapFilter_OnEvent(event)
	if (event == "VARIABLES_LOADED") then
		CrapFilter_Stats()
	end
end

function CrapFilter_AddPhrase(phrase)
	if (strlen(phrase) == 0) then
		return
	end

	phrase = string.lower(phrase)

	for index, keyword in CrapFilterDB.phrases do
		if keyword == phrase then
			Print("Phrase " .. phrase .. " is already in the filter.")
			return
		end
	end

	table.insert(CrapFilterDB.phrases, phrase)
	Print("Adding phrase " .. phrase)
end

function CrapFilter_DelPhrase(phrase)
	if (strlen(phrase) == 0) then
		return
	end
	phrase = string.lower(phrase)

	for index, keyword in CrapFilterDB.phrases do
		if keyword == phrase then
			table.remove(CrapFilterDB.phrases, index)
			Print("Removing phrase " .. phrase)
		end
	end
end

function CrapFilter_Reset()
	CrapFilterDB = {}
	CrapFilterDB.phrases = {}
	CrapFilterDB.enabled = 1
	Print("AddOn reset")
end

function CrapFilter_List()
	Print("Filtered phrases:")
	for index, keyword in CrapFilterDB.phrases do
		Print(keyword, true)
	end
end

function CrapFilter_Help()
	Print("Help")
	for index, helpline in help do
		Print(helpline)
	end
end

function CrapFilter_Toggle(state)
	CrapFilterDB.enabled = state
	Print(state and "enabled" or "disabled")
end
