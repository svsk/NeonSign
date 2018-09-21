local addonName, NeonSign = ...

-- Globals --
TimeSinceLast = 0;
PlayerName = GetUnitName("player") .. "-" .. GetRealmName();
SLASH_NEONSIGN1 = '/neon'; 
IsGuildGroup = nil;

function InitializeNeonSign()
	NeonSign:UpdateOptions("NeonOptions", NeonSign.Defaults, false); 
end

function displayHelp() 
	TellUser("- Usage", true);
	print("/neon open - Opens the NeonSign GUI.");
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

function escapeLuaPattern(srcString)
	local matches =
	{
		["^"] = "%^";
		["$"] = "%$";
		["("] = "%(";
		[")"] = "%)";
		["%"] = "%%";
		["."] = "%.";
		["["] = "%[";
		["]"] = "%]";
		["*"] = "%*";
		["+"] = "%+";
		["-"] = "%-";
		["?"] = "%?";
	}

	return (srcString:gsub(".", matches))
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
	
	if (msg:match("neon.gg") or msg:match("neon-guild.com")) then		
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

	if (zone == "Tomb of Sargeras") then
		--Tomb of Sargeras BoEs
		boes = {
			"Spiked Terrorwake Greatboots",
			"Fel-Flecked Grips",
			"Soul-Rattle Ribcage",
			"Diadem of the Highborne",
			"Acolyte's Abandoned Footwraps",
			"Sash of the Unredeemed",
			"Treads of Violent Intrusion",
			"Cord of Pilfered Rosaries",
			"Treads of Panicked Escape",
			"Pristine Moon-Wrought Clasp",
			"Wakening Horror Spaulders",
			"Girdle of the Crumbling Sanctum"
		};
	end

	if (zone == "Antorus, the Burning Throne") then
		--Antorus BoEs
		boes = {
			"Gloves of Abhorrent Strategies",
			"Cuffs of the Viridian Flameweavers",
			"Corrupted Mantle of the Felseekers",
			"Leggings of the Sable Stalkers",
			"Sinuous Kerapteron Bindings",
			"Felflame Inferno Shoulderpads",
			"Horror Fiend-Scale Breastplate",
			"Wristguards of Ominous Forging",
			"Greaves of the Felblade Defenders",
			"Impenetrable Garothi Breastplate",
			"Wristguards of the Dark Keepers",
			"Hulking Demolisher Legplates"
		};
	end

	if (zone == "Uldir") then
		--Uldir BoEs
		boes = {
			"Bloody Experimenter's Wraps",
			"Spellbound Specimen Handlers",
			"Splatterguards",
			"Antiseptic Specimen Handlers",
			"Reinforced Test Subject Shackles",
			"Iron-Grip Specimen Handlers",
			"Crushproof Vambraces",
			"Fluid-Resistant Specimen Handlers"
		};
	end
	
	for i, boe in ipairs(boes) do
		if string.match(message, escapeLuaPattern(boe)) then
			boeLooted = boe;
		end
	end
	
	channel = "RAID_WARNING";

	if (boeLooted ~= "None") then
		local officers = GetOfficers();
		SendChatMessage("[NeonSign] " .. target .. " looted a BoE item: " .. boeLooted .. ". Please trade it to an officer (".. table.concat(officers, ", ") ..")." , channel, nil, nil);
	end	
end

local function NeonSignGroupStateChanged(self, event, isGuildGroup)
	IsGuildGroup = isGuildGroup;
end

function GetOfficers()
	local officers = {};
	local memberNum = GetNumGuildMembers();

	for i = 1, memberNum do
		local fullName, rank, rankIndex = GetGuildRosterInfo(i);

		if (rank == "Officer" or rank == "Guild Leader") then
			noRealmName = fullName:match("([^,]+)-([^,]+)");
			table.insert(officers, noRealmName);
		end
	end

	return officers;
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
		channelName = SetPrimaryRecruitmentChannel(cmdList[1]);
		TellUser("Target recruitment channel is now " .. cmdList[1] .. " - " .. channelName, true);
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

function SetPrimaryRecruitmentChannel(channelId)
	id, name = GetChannelName(tonumber(channelId));
	NeonOptions["ChannelId"] = id;
	NeonOptions["ChannelName"] = name;

	return name;
end