-- Globals --
TimeSinceLast = 0;
PlayerName = GetUnitName("player") .. "-" .. GetRealmName();
SLASH_NEONSIGN1 = '/neon'; 
IsGuildGroup = nil;
DefaultSettings = {
	["ChannelId"] = 2,
	["ChannelName"] = "Trade",
	["RunInterval"] = 600.0,
	["RecruitmentEnabled"] = true,
	["RecruitmentMessage"] = "<Neon> are looking for new members to bolster our main raiding team. We raid Mon/Thu/Sun 20:00-23:00. For more information or to apply /w me or head over to www.neon-guild.com",
	["ShowDebugMessages"] = false
}

function InitializeNeonSign()
	if NeonOptions == nil then
		TellUser("Didn't find settings. Setting them up...", true);
		NeonOptions = {};
	end
	
	for key, value in pairs(DefaultSettings) do
		if (NeonOptions[key] == nil) then
			NeonOptions[key] = value;
		end
	end
end

function displayHelp() 
	TellUser("- Usage", true);
	print("/neon enable - Enables sending of messages to the specified channel.");
	print("/neon disable - Disables sending of messages to the specified channel.");
	print("/neon sendnow - Sends the recruitment message instantly. Resets the interval.");
	print("/neon interval - Displays the current message sending interval and time remaining until next message.");
	print("/neon interval <seconds> - Changes the message sending interval to the specified number of seconds.");
	print("/neon m <recruitment message> - Changes the recruitment message sent every interval.");
	print("/neon channel <channel number> - Changes the target recruitment channel to the channel number given.");
end

function splitString(srcString)
	words = {};
	index = 0;

	for word in srcString:lower():gmatch("%w+") do 
		words[index] = word;
		index = index + 1;
	end
	
	return words;
end

function TellUser(message, override)
	override = override or false;

	if (override or NeonOptions["ShowDebugMessages"]) then
		prefix = "|cff86e7f0[NeonSign]|r ";
		print(prefix .. message);
	end
end

function SendMessageToChat(message)
	if (NeonOptions["RecruitmentEnabled"] == false) then
		return;
	end
	
	id, name = GetChannelName(NeonOptions["ChannelId"]);
	if (id > 0 and name == NeonOptions["ChannelName"]) then
		SendChatMessage(message, "CHANNEL", nil, id);
	else
		TellUser("Unable to find target chat channel. Message not sent.", true);
	end
end

local function NeonSignOnUpdate(self, elapsed, ...)
	TimeSinceLast = TimeSinceLast + elapsed;
	
	if (TimeSinceLast > NeonOptions["RunInterval"]) then 
		TimeSinceLast = 0 - math.random(1, 20);
		SendMessageToChat(NeonOptions["RecruitmentMessage"]);
	end
end

local function NeonSignOnChatMessageReceived(self, event, message, sender, language, channel)
	msg = message:lower();
	
	if (msg:match("neon") and msg:match("guild") and msg:match("com")) then		
		if (PlayerName == sender) then
			return;
		end
	
		TellUser("Looks like someone else is spamming the chat. Resetting the timer.");
		TimeSinceLast = 0 - math.random(1, 20);
	end
end

local function NeonSignItemLooted(self, event, message, sender, language, channel, target)
	if (IsGuildGroup == false) then
		return;
	end

	zone = GetZoneText();
	boeLooted = "None";
	boes = {};
	
	if (zone == "The Nighthold") then 
		--Nighthold BoEs
		boes = {
			"Aristocrat's Winter Drape",
			"Feathermane Feather Cloak",
			"Cloak of Multitudinous Sheaths",
			"Fashionable Autumn Cloak",
			"Mana-Cord of Deception",
			"Waistclasp of Unethical Power",
			"Vintage Duskwatch Cinch",
			"Gleaming Celestial Waistguard"
		};
	end

	if (zone == "Hellfire Citadel") then
		--Hellfire BoEs
		boes = { 
			"Unhallowed Voidlink Boots", 
			"Girdle of Demonic Wrath", 
			"Cruel Hope Crushers", 
			"Cord of Unhinged Malice", 
			"Cursed Demonchain Belt", 
			"Flayed Demonskin Belt", 
			"Dessicated Soulrender Slippers",
			"Jungle Assassin's Footpads"
		};
	end	
	
	for i, boe in ipairs(boes) do
		if string.match(message, boe) then
			boeLooted = boe;
		end
	end
	
	if (boeLooted ~= "None") then
		SendChatMessage("[NeonSign] " .. target .. " looted a BoE item: " .. boeLooted .. ". Please trade it to Sup, Kcugi, Pix, Chamdor, Spiwits, or Veinlash." , "RAID_WARNING", nil, nil);
	end	
end

local function NeonSignGroupStateChanged(self, event, isGuildGroup)
	IsGuildGroup = isGuildGroup;
end

function HandleEvent(self, event, arg1, arg2, arg3, arg4, arg5, ...)
	if event == "ADDON_LOADED" and arg1 == "NeonSign" then 
		InitializeNeonSign();
	elseif event == "CHAT_MSG_CHANNEL" then
		NeonSignOnChatMessageReceived(self, event, arg1, arg2, arg3, arg4);
	elseif event == "CHAT_MSG_LOOT" then
		NeonSignItemLooted(self, event, arg1, arg2, arg3, arg4, arg5);
	elseif event == "GUILD_PARTY_STATE_UPDATED" then
		NeonSignGroupStateChanged(self, event, arg1);
	end
end

-- Frames --
local NeonSignFrame = CreateFrame("FRAME", "NeonSignFrame");
local NeonSignEventListener = CreateFrame("FRAME", "NeonSignEventListener");

-- Set up event handlers
NeonSignEventListener:SetScript("OnEvent", HandleEvent);
NeonSignEventListener:RegisterEvent("ADDON_LOADED");
NeonSignEventListener:RegisterEvent("CHAT_MSG_CHANNEL");
NeonSignEventListener:RegisterEvent("CHAT_MSG_LOOT");
NeonSignEventListener:RegisterEvent("GUILD_PARTY_STATE_UPDATED");
NeonSignFrame:SetScript("OnUpdate", NeonSignOnUpdate);


-- Slash command stuff --
function SlashCmdList.NEONSIGN(msg, editbox)
	cmdList = splitString(msg);	

	if (cmdList[0] == "interval") then
		if (cmdList[1] ~= nil and tonumber(cmdList[1]) ~= nil) then
			NeonOptions["RunInterval"] = tonumber(cmdList[1]);
		end
	
		TellUser("The current interval is " .. NeonOptions["RunInterval"] .. " seconds.", true);
		TellUser("A new message will be sent in " .. math.floor(NeonOptions["RunInterval"] - TimeSinceLast) .. " seconds.", true);
		
		return;
	end
	
	if (cmdList[0] == "enable") then
		TimeSinceLast = 0;
		NeonOptions["RecruitmentEnabled"] = true;
		TellUser("Addon enabled. Will send recruitment message in " .. NeonOptions["RunInterval"] .. " seconds.", true);
		
		return;
	end
	
	if (cmdList[0] == "disable") then
		NeonOptions["RecruitmentEnabled"] = false;
		TellUser("Addon disabled.", true);
		
		return;
	end
	
	if (cmdList[0] == "sendnow") then 
		preState = NeonOptions["RecruitmentEnabled"];
		NeonOptions["RecruitmentEnabled"] = true;
		SendMessageToChat(NeonOptions["RecruitmentMessage"]);
		TimeSinceLast = 0;
		NeonOptions["RecruitmentEnabled"] = preState;
		
		return;
	end
	
	if (cmdList[0] == "isguildgroup") then
		if (IsGuildGroup ~= nil) then
			TellUser("IsGuildGroup = " .. tostring(IsGuildGroup) .. " (Debug)", true);
		else
			TellUser("IsGuildGroup = nil (Debug)", true);
		end
		
		return;
	end
	
	if (cmdList[0] == "channel") then
		id, name = GetChannelName(tonumber(cmdList[1]));
		NeonOptions["ChannelId"] = id;
		NeonOptions["ChannelName"] = name;
		
		TellUser("Target recruitment channel is now " .. tostring(id) .. " - " .. name, true);
		return;
	end
	
	if (cmdList[0] == "debug") then
		NeonOptions["ShowDebugMessages"] = not NeonOptions["ShowDebugMessages"];
		TellUser("Debug mode: " .. tostring(NeonOptions["ShowDebugMessages"]), true);
		return;
	end
	
	if (cmdList[0] == "m") then
		local message = msg:gsub("^m ", "");
		NeonOptions["RecruitmentMessage"] = message;
		TellUser("Recruitment message updated!", true);
		return;
	end
	
	displayHelp();
end