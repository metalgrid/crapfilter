
function Print(x) return DEFAULT_CHAT_FRAME:AddMessage(x) end

function CrapFilter_OnLoad()

	if (CrapFilterDB == nil) then
		CrapFilterDB = {};
	end

	SLASH_CRAPFILTER1 = "/cf";
	SLASH_CRAPFILTER2 = "/crapfilter";
	SlashCmdList["CRAPFILTER"] = CrapFilter_SlashCommand;

	this:RegisterEvent("CHAT_MSG_WHISPER");
	this:RegisterEvent("CHAT_MSG_CHANNEL");
	this:RegisterEvent("CHAT_MSG_SYSTEM");
	this:RegisterEvent("VARIABLES_LOADED");
	BlizzChatFrame_OnEvent = ChatFrame_OnEvent;
	ChatFrame_OnEvent = CrapFilter_Filter;
end

function CrapFilter_Filter(event)
	if (event == "CHAT_MSG_CHANNEL" or event == "CHAT_MSG_WHISPER") then
		if (CrapFilterDB_Filter(arg1)) then
			return false
		end
	end
	BlizzChatFrame_OnEvent(event, arg1, arg2);
	return true
end

function CrapFilterDB_Filter(message)
	local count = 0

	for i in CrapFilterDB do
		count = count + 1
		if (strfind(message, CrapFilterDB[count])) then
			return true
		end
	end
	return false
end

function CrapFilter_SlashCommand(msg)
	local params = msg;
	local cmd = params;
	local index = strfind(cmd, " ");
	if ( index ) then
		cmd = strsub(cmd, 1, index-1);
		params = strsub(params, index+1);
	else
		params = "";
	end

	if (not cmd) then
		return nil
	end

	if (not params or params == "" or params == " ") then
		cmd = nil
	end

	if cmd == "add" then
		CrapFilterDB_AddPhrase(params)
	elseif cmd == "del" then
		Print("CrapFilter: Removing phrase " .. params);
	elseif cmd == "reset" then
		Print("CrapFilter: Resetting phrase DB");
		CrapFilterDB = {};
	else
		Print("Syntax: /crapfilter (add | remove) <phrase>");
	end
end

function CrapFilter_OnEvent(event)
	if (event == "VARIABLES_LOADED") then
		CrapFilter_VarsLoaded();
	end
end

function CrapFilterDB_AddPhrase(phrase)
	local count = 0
	for i in CrapFilterDB do
		count = count + 1
		if CrapFilterDB[count] == phrase then
			Print("Phrase " .. phrase .. " is already in the filter.")
			return
		end
	end

	CrapFilterDB[count+1] = phrase
	Print("CrapFilter: Adding phrase " .. phrase);
end

function CrapFilter_VarsLoaded()
	local count = 0
	for i in CrapFilterDB do
		count = count + 1
	end
	Print("CrapFilter loaded, " .. count .. " phrases filtered.");
end
