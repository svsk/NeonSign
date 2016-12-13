-- Globals --
RunInterval = 600.0;
TimeSinceLast = 600.0;
RecruitmentMessage = "<Neon> (EN 4/7M, ToV 2/3H) are looking for healers and DPS to bolster our main raiding team. We raid Mon/Thu/Sun 20:00-23:00. For more information or to apply /w me or head over to www.neon-guild.com";
PlayerName = GetUnitName("player") .. "-" .. GetRealmName();
SLASH_NEONSIGN1 = '/neon'; 
IsGuildGroup = nil;

ChannelId = 2;
ChannelName = "Trade - City";
-- ChannelId = 1;
-- ChannelName = "General - Blackrock Foundry";
-- ChannelId = 3;
-- ChannelName = "NeonHealers";

RecruitmentEnabled = true;
ShowMessages = false;

function SlashCmdList.NEONSIGN(msg, editbox)
	cmdList = splitString(msg);	

	if (cmdList[0] == "interval") then
		if (cmdList[1] ~= nil and tonumber(cmdList[1]) ~= nil) then
			RunInterval = tonumber(cmdList[1]);
		end
	
		TellUser("The current interval is " .. RunInterval .. " seconds.", true);
		TellUser("A new message will be sent in " .. math.floor(RunInterval - TimeSinceLast) .. " seconds.", true);
		
		return;
	end
	
	if (cmdList[0] == "enable") then
		TimeSinceLast = 0;
		RecruitmentEnabled = true;
		TellUser("Addon enabled. Will send recruitment message in " .. RunInterval .. " seconds.", true);
		
		return;
	end
	
	if (cmdList[0] == "disable") then
		RecruitmentEnabled = false;
		TellUser("Addon disabled.", true);
		
		return;
	end
	
	if (cmdList[0] == "sendnow") then 
		preState = RecruitmentEnabled;
		RecruitmentEnabled = true;
		SendMessageToChat(RecruitmentMessage);
		TimeSinceLast = 0;
		RecruitmentEnabled = preState;
		
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
		return;
	end
	
	displayHelp();
end

function displayHelp() 
	TellUser("- Usage", true);
	print("/neon enable - Enables sending of messages to the specified channel.");
	print("/neon disable - Disables sending of messages to the specified channel.");
	print("/neon sendnow - Sends the recruitment message instantly. Resets the interval.");
	print("/neon interval - Displays the current message sending interval and time remaining until next message.");
	print("/neon interval <seconds> - Changes the message sending interval to the specified number of seconds.");
	print("");
	print("|cffff0000WARNING|r Any changes to make using these commands are NOT retained upon reloading the UI.")
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

	if (override or ShowMessages) then
		prefix = "|cff86e7f0[NeonSign]|r ";
		print(prefix .. message);
	end
end

function SendMessageToChat(message)
	if (RecruitmentEnabled == false) then
		return;
	end
	
	id, name = GetChannelName(ChannelId);
	if (id > 0 and name == ChannelName) then
		SendChatMessage(message, "CHANNEL", nil, id);
	else
		TellUser("Unable to find Trade Chat. Message not sent.");
	end
end

-- Locals --
local NeonSignFrame = CreateFrame("FRAME", "NeonSignFrame");
local NeonSignDupeListener = CreateFrame("FRAME", "NeonSignDupeListener");
local NeonSignBoEListener = CreateFrame("FRAME", "NeonSignBoEListener");
local NeonSignGroupTypeListener = CreateFrame("FRAME", NeonSignGroupTypeListener);

local function NeonSignOnUpdate(self, elapsed, ...)
	TimeSinceLast = TimeSinceLast + elapsed;
	
	if (TimeSinceLast > RunInterval) then 
		TimeSinceLast = 0 - math.random(1, 20);
		SendMessageToChat(RecruitmentMessage);
	end
end

local function NeonSignOnChatMessageReceived(self, event, message, sender, language, channel, ...)
	msg = message:lower();
	
	if (msg:match("neon") and msg:match("guild") and msg:match("com")) then		
		if (PlayerName == sender) then
			return;
		end
	
		TellUser("Looks like someone else is spamming the chat. Resetting the timer.");
		TimeSinceLast = 0 - math.random(1, 20);
	end
end

local function NeonSignItemLooted(self, event, message, sender, language, channel, target, ...)
	if (GetZoneText() == "Hellfire Citadel" and IsGuildGroup) then
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
		
		boeLooted = "None";
		for i, boe in ipairs(boes) do
			if string.match(message, boe) then
				boeLooted = boe;
			end
		end
		
		if (boeLooted ~= "None") then
			SendChatMessage("[NeonSign] " .. target .. " looted a BoE item: " .. boeLooted .. ". Please trade it to Sup, Pixil, Chamdor, Spiwits or Veinlash." , "RAID_WARNING", nil, nil);
		end		
	end	
end

local function NeonSignGroupStateChanged(self, event, isGuildGroup)
	IsGuildGroup = isGuildGroup;
end

-- Set up event handlers
NeonSignFrame:SetScript("OnUpdate", NeonSignOnUpdate);
NeonSignDupeListener:RegisterEvent("CHAT_MSG_CHANNEL");
NeonSignDupeListener:SetScript("OnEvent", NeonSignOnChatMessageReceived);
NeonSignBoEListener:RegisterEvent("CHAT_MSG_LOOT");
NeonSignBoEListener:SetScript("OnEvent", NeonSignItemLooted);
NeonSignGroupTypeListener:RegisterEvent("GUILD_PARTY_STATE_UPDATED");
NeonSignGroupTypeListener:SetScript("OnEvent", NeonSignGroupStateChanged);