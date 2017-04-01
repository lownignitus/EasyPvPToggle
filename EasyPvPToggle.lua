--[[ Title: Easy PvP Toggle
	 Author: LownIgnitus
	 Version: 1.0.0
	 Desc: Displayable or mouseoverable button for quick easy PvP flagging]]

-- Variables
local addon_name = "EasyPvPToggle"
CF = CreateFrame
SLASH_EASYPVPTOGGLE1 = "/epvpt" or "/EPvPT"

-- RegisterForEvent table
local eptEvents_table = {}

eptEvents_table.eventFrame = CF("Frame");
eptEvents_table.eventFrame:RegisterEvent("ADDON_LOADED");
eptEvents_table.eventFrame:SetScript("OnEvent", function(self, event, ...)
	eptEvents_table.eventFrame[event](self, ...);
end);

function eptEvents_table.eventFrame:ADDON_LOADED(AddOn)
	if AddOn ~= addon_name then
		return - not addon_name
	end

	-- Unregister ADDON_LOADED
	eptEvents_table.eventFrame:UnregisterEvent("ADDON_LOADED")

	local defaults = {
		["options"] = {
			["eptHidden"] = true,
			["eptMouseOver"] = false,
			["eptLock"] = true,
			["eptScale"] = 1,
			["eptAlpha"] = 0,
			["eptPvP"] = 0,
		}
	}

	local function eptSVCheck(src, dst)
		if type(src) ~= "table" then return {} end
		if type(dst) ~= "table" then dst = {} end
		for k, v in pairs(src) do
			if type(v) == "table" then
				dst[k] = eptSVCheck(v, dst[k])
			elseif type(v) ~= type(dst[k]) then
				dst[k] = v
			end
		end
		return dst
	end

	eptSettings = eptSVCheck(defaults, eptSettings)

	eptOptionsInit();
	eptInit();
end

function eptOptionsInit()
	local eptOptions = CF("Frame", nil, InterfaceOptionsFramePanelContainer);
	local panelWidth = InterfaceOptionsFramePanelContainer:GetWidth() -- ~623
	local wideWidth = panelWidth - 40
	eptOptions:SetWidth(wideWidth)
	eptOptions:Hide();
	eptOptions.name = "|cff00ff00Easy PvP Toggle|r"
	eptOptionsBG = { edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, edgeSize = 16 }

	-- Special thanks to Ro for inspiration for the overall structure of this options panel (and the title/version/description code)
	local function createfont(fontName, r, g, b, anchorPoint, relativeto, relativePoint, cx, cy, xoff, yoff, text)
		local font = eptOptions:CreateFontString(nil, "BACKGROUND", fontName)
		font:SetJustifyH("LEFT")
		font:SetJustifyV("TOP")
		if type(r) == "string" then -- r is text, not position
			text = r
		else
			if r then
				font:SetTextColor(r, g, b, 1)
			end
			font:SetSize(cx, cy)
			font:SetPoint(anchorPoint, relativeto, relativePoint, xoff, yoff)
		end
		font:SetText(text)
		return font
	end

	-- Special thanks to Hugh & Simca for checkbox creation 
	local function createcheckbox(text, cx, cy, anchorPoint, relativeto, relativePoint, xoff, yoff, frameName, font)
		local checkbox = CF("CheckButton", frameName, eptOptions, "UICheckButtonTemplate")
		checkbox:SetPoint(anchorPoint, relativeto, relativePoint, xoff, yoff)
		checkbox:SetSize(cx, cy)
		local checkfont = font or "GameFontNormal"
		checkbox.text:SetFontObject(checkfont)
		checkbox.text:SetText(" " .. text)
		return checkbox
	end
	--GameFontNormalHuge GameFontNormalLarge 
	local title = createfont("SystemFont_OutlineThick_WTF", GetAddOnMetadata(addon_name, "Title"))
	title:SetPoint("TOPLEFT", 16, -16)
	local ver = createfont("SystemFont_Huge1", GetAddOnMetadata(addon_name, "Version"))
	ver:SetPoint("BOTTOMLEFT", title, "BOTTOMRIGHT", 4, 0)
	local date = createfont("GameFontNormalLarge", "Version Date: " .. GetAddOnMetadata(addon_name, "X-Date"))
	date:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	local author = createfont("GameFontNormal", "Author: " .. GetAddOnMetadata(addon_name, "Author"))
	author:SetPoint("TOPLEFT", date, "BOTTOMLEFT", 0, -8)
	local website = createfont("GameFontNormal", "Website: " .. GetAddOnMetadata(addon_name, "X-Website"))
	website:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -8)
	local desc = createfont("GameFontHighlight", GetAddOnMetadata(addon_name, "Notes"))
	desc:SetPoint("TOPLEFT", website, "BOTTOMLEFT", 0, -8)

	-- Misc Options Frame
	local eptMiscFrame = CF("Frame", EPTMiscFrame, eptOptions)
	eptMiscFrame:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -8)
	eptMiscFrame:SetBackdrop(eptOptionsBG)
	eptMiscFrame:SetSize(240, 215)

	local miscTitle = createfont("GameFontNormal", nil, nil, nil, "TOP", eptMiscFrame, "TOP", 150, 16, 0, -8, "Miscellaneous Options")

	-- Enable Mouseover
	local eptMouseOverOpt = createcheckbox("Enable Mouseover of Easy PvP Toggle.", 18, 18, "TOPLEFT", miscTitle, "TOPLEFT", -40, -16, "eptMouseOverOpt")

	eptMouseOverOpt:SetScript("OnClick", function(self)
		if eptMouseOverOpt:GetChecked() == true then
			eptSettings.options.eptMouseOver = true
			eptFrame:SetAlpha(eptSettings.options.eptalpha)
			ChatFrame1:AddMessage("Mouseover |cff00ff00enabled|r!")
			--eptFrame:SetAlpha(0)
		else
			eptSettings.options.eptMouseOver = false
			eptFrame:SetAlpha(1)
			ChatFrame1:AddMessage("Mouseover |cffff0000disabled|r!")
		end
	end)
	-- Scale Frame
	local eptScaleFrame = CF("Frame", "EPTScaleFrame", eptOptions)
	eptScaleFrame:SetPoint("TOPLEFT", eptMiscFrame, "TOPRIGHT", 8, 0)
	eptScaleFrame:SetBackdrop(eptOptionsBG)
	eptScaleFrame:SetSize(150, 75)

	-- Addon Scale
	local eptScale = CF("Slider", "EPTScale", eptScaleFrame, "OptionsSliderTemplate")
	eptScale:SetSize(120, 16)
	eptScale:SetOrientation('HORIZONTAL')
	eptScale:SetPoint("TOP", eptScaleFrame, "TOP", 0, -25)

	_G[eptScale:GetName() .. 'Low']:SetText('0.5') -- Sets left side of slider text [default is "Low"]
	_G[eptScale:GetName() .. 'High']:SetText('1.5') -- Sets right side of slider text [default is "High"]
	_G[eptScale:GetName() .. 'Text']:SetText('|cffFFCC00Scale|r') -- Sets the title text [top-center of slider]

	eptScale:SetMinMaxValues(0.5, 1.5)
	eptScale:SetValueStep(0.05);

	-- Scale Display Editbox
	local eptScaleDisplay = CF("Editbox", "EPTScaleDisplay", eptScaleFrame, "InputBoxTemplate")
	eptScaleDisplay:SetSize(32, 16)
	eptScaleDisplay:ClearAllPoints()
	eptScaleDisplay:SetPoint("TOP", eptScale, "BOTTOM", 0, -10)
	eptScaleDisplay:SetAutoFocus(false)
	eptScaleDisplay:SetEnabled(false)
	eptScaleDisplay:SetText(eptSettings.options.eptScale)

	eptScale:SetScript("OnValueChanged", function(self, value)
		value = floor(value/0.05)*0.05
		eptFrame:SetScale(value)
		eptSettings.options.eptScale = value
		eptScaleDisplay:SetText(eptSettings.options.eptScale)
	--	print(eptSettings.options.eptScale)
	end);

	-- Alpha Frame
	local eptAlphaFrame = CF("Frame", "EPTAlphaFrame", eptOptions)
	eptAlphaFrame:SetPoint("TOPLEFT", eptScaleFrame, "TOPRIGHT", 8, 0)
	eptAlphaFrame:SetBackdrop(eptOptionsBG)
	eptAlphaFrame:SetSize(150, 75)

	-- Skill Helper Alpha
	local eptAlpha = CF("Slider", "EPTAlpha", eptAlphaFrame, "OptionsSliderTemplate")
	eptAlpha:SetSize(120, 16)
	eptAlpha:SetOrientation('HORIZONTAL')
	eptAlpha:SetPoint("TOP", eptAlphaFrame, "TOP", 0, -25)

	_G[eptAlpha:GetName() .. 'Low']:SetText('0') -- Sets left side of slider text [default is "Low"]
	_G[eptAlpha:GetName() .. 'High']:SetText('1') -- Sets right side of slider text [default is "High"]
	_G[eptAlpha:GetName() .. 'Text']:SetText('|cffFFCC00Minimum Alpha|r') -- Sets the title text [top-center of slider]

	eptAlpha:SetMinMaxValues(0, 1)
	eptAlpha:SetValueStep(0.05);

	-- Alpha Display Editbox
	local eptAlphaDisplay = CF("Editbox", "EPTScaleDisplay", eptAlphaFrame, "InputBoxTemplate")
	eptAlphaDisplay:SetSize(32, 16)
	eptAlphaDisplay:ClearAllPoints()
	eptAlphaDisplay:SetPoint("TOP", eptAlpha, "BOTTOM", 0, -10)
	eptAlphaDisplay:SetAutoFocus(false)
	eptAlphaDisplay:SetEnabled(false)
	eptAlphaDisplay:SetText(eptSettings.options.eptAlpha)

	eptAlpha:SetScript("OnValueChanged", function(self, value)
		value = floor(value/0.05)*0.05
		eptSettings.options.eptAlpha = value
		if eptSettings.options.eptMouseOver == true then
			eptFrame:SetAlpha(eptSettings.options.eptAlpha)
		end
		eptAlphaDisplay:SetText(eptSettings.options.eptAlpha)
	--	print(eptSettings.options.eptAlpha)
	end);

	eptOptions.refresh = function()
	--	print("refresh")
		eptScale:SetValue(eptSettings.options.eptScale);
		eptAlpha:SetValue(eptSettings.options.eptAlpha);
	end

	function eptOptions.okay()
		eptOptions:Hide();
	end

	function eptOptions.cancel()
		eptOptions:Hide();
	end

	function eptOptions.default()
		eptReset();
	end

	-- add the Options panel to the Blizzard list
	InterfaceOptions_AddCategory(eptOptions);
	-- End Skill Helper Options
end

function eptToggle()
	 
end

function eptInit()
	eptFrame:SetScale(eptSettings.options.eptScale);

	if eptSettings.options.eptLock == true then
		eptFrame:EnableMouse(true)
	else
		eptFrame:EnableMouse(false)
	end
			
	if eptSettings.options.eptHidden == false then
		eptFrame:Show()
	else
		eptFrame:Hide()
	end

	if eptSettings.options.eptMouseOver == true then
		eptMouseOverOpt:SetChecked(true)
		eptFrame:SetAlpha(eptSettings.options.eptAlpha)
	else
		eptMouseOverOpt:SetChecked(false)
	end

	if eptSettings.options.eptPvP == 0 then
		eptFrame.buttonToggle:SetChecked(false)
	else
		eptFrame.buttonToggle:SetChecked(true)
	end
end

function eptMouseOverEnter()
	if eptSettings.options.eptMouseOver == true then
		eptFrame:SetAlpha(1);
	end
end

function eptMouseOverLeave()
	if eptSettings.options.eptMouseOver == true then
		eptFrame:SetAlpha(eptSettings.options.eptAlpha);
	end
end

function SlashCmdList.EASYPVPTOGGLE(msg)
	if msg == "toggle" then
		eptToggle()
	elseif msg == "pvp" then
		eptPvPToggle()
	elseif msg == "lock" then
		eptLocker()
	elseif msg == "options" then
		eptOption()
	elseif msg == "info" then
		eptInfo()
	else
		ChatFrame1:AddMessage("|cff71C671" .. addon_name .. " Slash Commands|r")
		ChatFrame1:AddMessage("|cff71C671type /EPvPT followed by:|r")
		ChatFrame1:AddMessage("|cff71C671  -- toggle to toggle the addon hidden state|r")
		ChatFrame1:AddMessage("|cff71C671  -- pvp to toggle PvP flag state|r")
		ChatFrame1:AddMessage("|cff71C671  -- lock to toggle locking|r")
		ChatFrame1:AddMessage("|cff71C671  -- options to open addon options|r")
		ChatFrame1:AddMessage("|cff71C671  -- info to view current build information|r")
	end
end

function eptToggle()
	-- true for it is hidden and false for it isn't hidden
	if eptSettings.options.eptHidden == false then
		eptFrame:Hide()
		ChatFrame1:AddMessage(addon_name .. " |cffff0000hidden|r!")
		eptSettings.options.eptHidden = true
	elseif eptSettings.options.eptHidden == true then
		eptFrame:Show()
		ChatFrame1:AddMessage(addon_name .. " |cff00ff00visible|r!")
		eptSettings.options.eptHidden = false
	end
end

function eptPvPToggle()
	local flag = GetPVPDesired() -- true = Flagged, false = Not Flagged
	if flag == false then
		if eptSettings.options.eptPvP == 0 then
			-- nothing
		elseif eptSettings.options.eptPvP == 1 then
			eptSettings.options.eptPvP = 0
		end
	end
	if eptSettings.options.eptPvP == 0 then
		eptSettings.options.eptPvP = 1
		SetPVP(1); -- Flag for PvP
	elseif eptSettings.options.eptPvP == 1 then
		eptSettings.options.eptPvP = 0
		SetPVP(0); -- Deflag for PvP
	end
end

function eptLocker()
	-- Remember eptLock is backwards. true for unlocked and false for locked
	if eptSettings.options.eptLock == true then
		eptSettings.options.eptLock = false
		eptFrame:EnableMouse(eptSettings.options.eptLock)
		ChatFrame1:AddMessage(addon_name .. " |cffff0000locked|r!")
	elseif eptSettings.options.eptLock == false then
		eptSettings.options.eptLock = true
		eptFrame:EnableMouse(eptSettings.options.eptLock)
		ChatFrame1:AddMessage(addon_name .. " |cff00ff00unlocked|r!")
	end
end

function eptOption()
	InterfaceOptionsFrame_OpenToCategory("|cff00ff00Easy PvP Toggle|");
	InterfaceOptionsFrame_OpenToCategory("|cff00ff00Easy PvP Toggle|r");
end

function eptInfo()
	ChatFrame1:AddMessage(GetAddOnMetadata(addon_name, "Title") .. " " .. GetAddOnMetadata(addon_name, "Version"))
	ChatFrame1:AddMessage("Author: " .. GetAddOnMetadata(addon_name, "Author"))
	ChatFrame1:AddMessage("Release Date: " .. GetAddOnMetadata(addon_name, "X-Date"))
end