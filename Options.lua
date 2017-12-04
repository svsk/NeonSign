local addonName, NeonSign = ...

NeonSign.Defaults = {
	["ChannelId"] = 2,
	["ChannelName"] = "Trade",
	["RunInterval"] = 600.0,
	["RecruitmentEnabled"] = true,
	["RecruitmentMessage"] = "<Neon> are looking for new members to bolster our main raiding team. We raid Mon/Thu/Sun 20:00-23:00. For more information or to apply /w me or head over to www.neon-guild.com",
	["ShowDebugMessages"] = false
};

local function OnPrimaryRecruitmentChannelChanged(channelId)
	local channelName = SetPrimaryRecruitmentChannel(channelId);
	NeonSign.OptionsPanel.primaryRecruitmentChannelNameLabel:SetText(" - " .. channelName);
end

NeonSign.OptionsPanel = NeonSign:CreateOptionsPanel();
local optionsPanel = NeonSign.OptionsPanel;
optionsPanel.savedVariablesName = "NeonOptions";
optionsPanel.subtext:SetText("These are som options for NeonSign. I dunno if they'll work...");

optionsPanel.sendMessageButton = optionsPanel:CreateCheckButton("RecruitmentEnabled");
local sendMessageButton = optionsPanel.sendMessageButton;
sendMessageButton:SetPoint("TOPLEFT", optionsPanel.subtext, "BOTTOMLEFT", 2, -15);
sendMessageButton.Text:SetText("Send recruitment messages");

--Recruitment message
optionsPanel.recruitmentMessageLabel = optionsPanel:CreateFontString(nil, nil, "GameFontHighlightSmall");
local recruitmentMessageLabel = optionsPanel.recruitmentMessageLabel;
recruitmentMessageLabel:SetPoint("TOPLEFT", optionsPanel.subtext, "BOTTOMLEFT", 0, -54);
recruitmentMessageLabel:SetPoint("RIGHT", optionsPanel.subtext, "RIGHT", 0, -54);
recruitmentMessageLabel:SetJustifyH("LEFT");
recruitmentMessageLabel:SetText("Recruitment message");

optionsPanel.recruitmentMessageTextArea = optionsPanel:CreateTextArea("RecruitmentMessage");
local recruitmentMessageTextArea = optionsPanel.recruitmentMessageTextArea;
recruitmentMessageTextArea:SetPoint("TOPLEFT", optionsPanel.recruitmentMessageLabel, "BOTTOMLEFT", 0, -15);
recruitmentMessageTextArea:SetPoint("BOTTOMRIGHT", optionsPanel.recruitmentMessageLabel, "BOTTOMRIGHT", 0, -11);
recruitmentMessageTextArea:SetMaxLetters(255);
recruitmentMessageTextArea:SetAutoFocus(false);

--Recruitment message interval
optionsPanel.recruitmentMessageIntervalLabel = optionsPanel:CreateFontString(nil, nil, "GameFontHighlightSmall");
local recruitmentMessageIntervalLabel = optionsPanel.recruitmentMessageIntervalLabel;
recruitmentMessageIntervalLabel:SetPoint("TOPLEFT", optionsPanel.recruitmentMessageTextArea, "BOTTOMLEFT", 0, -30);
recruitmentMessageIntervalLabel:SetPoint("RIGHT", optionsPanel.recruitmentMessageTextArea, "RIGHT", 0, -30);
recruitmentMessageIntervalLabel:SetJustifyH("LEFT");
recruitmentMessageIntervalLabel:SetText("Recruitment message interval (seconds)");

optionsPanel.recruitmentMessageIntervalTextArea = optionsPanel:CreateNumericTextArea("RunInterval");
local recruitmentMessageIntervalTextArea = optionsPanel.recruitmentMessageIntervalTextArea;
recruitmentMessageIntervalTextArea:SetPoint("TOPLEFT", optionsPanel.recruitmentMessageIntervalLabel, "BOTTOMLEFT", 0, -15);
recruitmentMessageIntervalTextArea:SetPoint("BOTTOMRIGHT", optionsPanel.recruitmentMessageIntervalLabel, "BOTTOMRIGHT", 0, -11);
recruitmentMessageIntervalTextArea:SetMaxLetters(5);
recruitmentMessageIntervalTextArea:SetAutoFocus(false);

--Primary Recruitment channel
optionsPanel.recruitmentPrimaryChannelLabel = optionsPanel:CreateFontString(nil, nil, "GameFontHighlightSmall");
local recruitmentPrimaryChannelLabel = optionsPanel.recruitmentPrimaryChannelLabel;
recruitmentPrimaryChannelLabel:SetPoint("TOPLEFT", optionsPanel.recruitmentMessageIntervalTextArea, "BOTTOMLEFT", 0, -30);
recruitmentPrimaryChannelLabel:SetPoint("RIGHT", optionsPanel.recruitmentMessageIntervalTextArea, "RIGHT", 0, -30);
recruitmentPrimaryChannelLabel:SetJustifyH("LEFT");
recruitmentPrimaryChannelLabel:SetText("Primary recruitment channel number");

optionsPanel.recruitmentPrimaryChannelTextArea = optionsPanel:CreateNumericTextArea("ChannelId");
local recruitmentPrimaryChannelTextArea = optionsPanel.recruitmentPrimaryChannelTextArea;
recruitmentPrimaryChannelTextArea:SetPoint("TOPLEFT", optionsPanel.recruitmentPrimaryChannelLabel, "BOTTOMLEFT", 0, -15);
recruitmentPrimaryChannelTextArea:SetPoint("BOTTOMRIGHT", optionsPanel.recruitmentPrimaryChannelLabel, "BOTTOMRIGHT", -500, -11);
recruitmentPrimaryChannelTextArea:SetMaxLetters(2);
recruitmentPrimaryChannelTextArea:SetAutoFocus(false);
recruitmentPrimaryChannelTextArea.OnOptionChange = OnPrimaryRecruitmentChannelChanged;

optionsPanel.primaryRecruitmentChannelNameLabel = optionsPanel:CreateFontString(nil, nil, "GameFontHighlightSmall");
local primaryRecruitmentChannelNameLabel = optionsPanel.primaryRecruitmentChannelNameLabel;
primaryRecruitmentChannelNameLabel:SetPoint("TOPLEFT", optionsPanel.recruitmentPrimaryChannelTextArea, "TOPRIGHT", 5, 2);
primaryRecruitmentChannelNameLabel:SetPoint("RIGHT", optionsPanel.recruitmentPrimaryChannelTextArea, "RIGHT", 500, 0);
primaryRecruitmentChannelNameLabel:SetJustifyH("LEFT");
primaryRecruitmentChannelNameLabel.Refresh = function ()
	NeonSign.OptionsPanel.primaryRecruitmentChannelNameLabel:SetText(" - " .. NeonOptions["ChannelName"]);
end
NeonSign:RegisterControl(primaryRecruitmentChannelNameLabel, optionsPanel)