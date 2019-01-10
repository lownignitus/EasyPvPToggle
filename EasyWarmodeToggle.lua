--[[ 
Title: Easy Warmode Toggle
Author: LownIgnitus
Version: 1.0.0
Desc: Displayable or mouseoverable button for quick easy Warmode flagging
]]

-- Variables
local addon_name = "EasyWarmodeToggle"
local ewtCombat = false
CF = CreateFrame
SLASH_EASYWARMODETOGGLE1 = "/ewt" or "/EWT" 

-- RegisterForEvent table
local ewtEvents_table = {}

ewtEvents_table.eventFrame = CF("Frame");
ewtEvents_table.eventFrame:RegisterEvent("ADDON_LOADED");
ewtEvents_table.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
ewtEvents_table.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED");
ewtEvents_table.eventFrame:SetScript("OnEvent", function(self, event, ...)
	ewtEvents_table.eventFrame[event](self, ...);
end);

function ewtEvents_table.eventFrame:ADDON_LOADED(AddOn)
	if AddOn ~= addon_name then
		return - not addon_name
	end

	-- Unregister ADDON_LOADED
	ewtEvents_table.eventFrame:UnregisterEvent("ADDON_LOADED")

	local defaults = {
		["options"] = {
			["ewtHidden"] = false,
			["ewtMouseOver"] = false,
			["ewtLock"] = true,
			["ewtScale"] = 1,
			["ewtAlpha"] = 0,
			["ewtWarmode"] = false,
		}
	}

	local function ewtSVCheck(src, dst)
		if type(src) ~= "table" then return {} end
		if type(dst) ~= "table" then dst = {} end
		for k, v in pairs(src) do
			if type(v) == "table" then
				dst[k] = ewtSVCheck(v, dst[k])
			elseif type(v) ~= type(dst[k]) then
				dst[k] = v
			end
		end
		return dst
	end

	ewtSettings = ewtSVCheck(defaults, ewtSettings)

	ewtOptionsInit();
	ewtInit();
end

function ewtEvents_table.eventFrame:PLAYER_REGEN_ENABLED( ... )
	if ewtCombat == true then
		ewtCombat = false
	end
end

function ewtEvents_table.eventFrame:PLAYER_REGEN_DISABLED( ... )
	if ewtCombat == false then
		ewtCombat = true
	end
end

function ewtOptionsInit()
	local ewtOptions = CF("Frame", nil, InterfaceOptionsFramePanelContainer);
	local panelWidth = InterfaceOptionsFramePanelContainer:GetWidth() -- ~623
	local wideWidth = panelWidth - 40
	ewtOptions:SetWidth(wideWidth)
	ewtOptions:Hide();
	ewtOptions.name = "|cff00ff00Easy Warmode Toggle|r"
	ewtOptionsBG = { edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, edgeSize = 16 }

	-- Special thanks to Ro for inspiration for the overall structure of this options panel (and the title/version/description code)
	local function createfont(fontName, r, g, b, anchorPoint, relativeto, relativePoint, cx, cy, xoff, yoff, text)
		local font = ewtOptions:CreateFontString(nil, "BACKGROUND", fontName)
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
		local checkbox = CF("CheckButton", frameName, ewtOptions, "UICheckButtonTemplate")
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
	local ewtMiscFrame = CF("Frame", ewtMiscFrame, ewtOptions)
	ewtMiscFrame:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -8)
	ewtMiscFrame:SetBackdrop(ewtOptionsBG)
	ewtMiscFrame:SetSize(240, 215)

	local miscTitle = createfont("GameFontNormal", nil, nil, nil, "TOP", ewtMiscFrame, "TOP", 150, 16, 0, -8, "Miscellaneous Options")

	-- Enable Mouseover
	local ewtMouseOverOpt = createcheckbox("Enable Mouseover of Easy Warmode Toggle.", 18, 18, "TOPLEFT", miscTitle, "TOPLEFT", -40, -16, "ewtMouseOverOpt")

	ewtMouseOverOpt:SetScript("OnClick", function(self)
		if ewtMouseOverOpt:GetChecked() == true then
			ewtSettings.options.ewtMouseOver = true
			ewtFrame:SetAlpha(ewtSettings.options.ewtalpha)
			ChatFrame1:AddMessage("Mouseover |cff00ff00enabled|r!")
			--ewtFrame:SetAlpha(0)
		else
			ewtSettings.options.ewtMouseOver = false
			ewtFrame:SetAlpha(1)
			ChatFrame1:AddMessage("Mouseover |cffff0000disabled|r!")
		end
	end)
	-- Scale Frame
	local ewtScaleFrame = CF("Frame", "ewtScaleFrame", ewtOptions)
	ewtScaleFrame:SetPoint("TOPLEFT", ewtMiscFrame, "TOPRIGHT", 8, 0)
	ewtScaleFrame:SetBackdrop(ewtOptionsBG)
	ewtScaleFrame:SetSize(150, 75)

	-- Addon Scale
	local ewtScale = CF("Slider", "ewtScale", ewtScaleFrame, "OptionsSliderTemplate")
	ewtScale:SetSize(120, 16)
	ewtScale:SetOrientation('HORIZONTAL')
	ewtScale:SetPoint("TOP", ewtScaleFrame, "TOP", 0, -25)

	_G[ewtScale:GetName() .. 'Low']:SetText('0.5') -- Sets left side of slider text [default is "Low"]
	_G[ewtScale:GetName() .. 'High']:SetText('1.5') -- Sets right side of slider text [default is "High"]
	_G[ewtScale:GetName() .. 'Text']:SetText('|cffFFCC00Scale|r') -- Sets the title text [top-center of slider]

	ewtScale:SetMinMaxValues(0.5, 1.5)
	ewtScale:SetValueStep(0.05);

	-- Scale Display Editbox
	local ewtScaleDisplay = CF("Editbox", "ewtScaleDisplay", ewtScaleFrame, "InputBoxTemplate")
	ewtScaleDisplay:SetSize(32, 16)
	ewtScaleDisplay:ClearAllPoints()
	ewtScaleDisplay:SetPoint("TOP", ewtScale, "BOTTOM", 0, -10)
	ewtScaleDisplay:SetAutoFocus(false)
	ewtScaleDisplay:SetEnabled(false)
	ewtScaleDisplay:SetText(ewtSettings.options.ewtScale)

	ewtScale:SetScript("OnValueChanged", function(self, value)
		value = floor(value/0.05)*0.05
		ewtFrame:SetScale(value)
		ewtSettings.options.ewtScale = value
		ewtScaleDisplay:SetText(ewtSettings.options.ewtScale)
	--	print(ewtSettings.options.ewtScale)
	end);

	-- Alpha Frame
	local ewtAlphaFrame = CF("Frame", "ewtAlphaFrame", ewtOptions)
	ewtAlphaFrame:SetPoint("TOPLEFT", ewtScaleFrame, "TOPRIGHT", 8, 0)
	ewtAlphaFrame:SetBackdrop(ewtOptionsBG)
	ewtAlphaFrame:SetSize(150, 75)

	-- Skill Helper Alpha
	local ewtAlpha = CF("Slider", "ewtAlpha", ewtAlphaFrame, "OptionsSliderTemplate")
	ewtAlpha:SetSize(120, 16)
	ewtAlpha:SetOrientation('HORIZONTAL')
	ewtAlpha:SetPoint("TOP", ewtAlphaFrame, "TOP", 0, -25)

	_G[ewtAlpha:GetName() .. 'Low']:SetText('0') -- Sets left side of slider text [default is "Low"]
	_G[ewtAlpha:GetName() .. 'High']:SetText('1') -- Sets right side of slider text [default is "High"]
	_G[ewtAlpha:GetName() .. 'Text']:SetText('|cffFFCC00Minimum Alpha|r') -- Sets the title text [top-center of slider]

	ewtAlpha:SetMinMaxValues(0, 1)
	ewtAlpha:SetValueStep(0.05);

	-- Alpha Display Editbox
	local ewtAlphaDisplay = CF("Editbox", "ewtScaleDisplay", ewtAlphaFrame, "InputBoxTemplate")
	ewtAlphaDisplay:SetSize(32, 16)
	ewtAlphaDisplay:ClearAllPoints()
	ewtAlphaDisplay:SetPoint("TOP", ewtAlpha, "BOTTOM", 0, -10)
	ewtAlphaDisplay:SetAutoFocus(false)
	ewtAlphaDisplay:SetEnabled(false)
	ewtAlphaDisplay:SetText(ewtSettings.options.ewtAlpha)

	ewtAlpha:SetScript("OnValueChanged", function(self, value)
		value = floor(value/0.05)*0.05
		ewtSettings.options.ewtAlpha = value
		if ewtSettings.options.ewtMouseOver == true then
			ewtFrame:SetAlpha(ewtSettings.options.ewtAlpha)
		end
		ewtAlphaDisplay:SetText(ewtSettings.options.ewtAlpha)
	--	print(ewtSettings.options.ewtAlpha)
	end);

	ewtOptions.refresh = function()
	--	print("refresh")
		ewtScale:SetValue(ewtSettings.options.ewtScale);
		ewtAlpha:SetValue(ewtSettings.options.ewtAlpha);
	end

	function ewtOptions.okay()
		ewtOptions:Hide();
	end

	function ewtOptions.cancel()
		ewtOptions:Hide();
	end

	function ewtOptions.default()
		ewtReset();
	end

	-- add the Options panel to the Blizzard list
	InterfaceOptions_AddCategory(ewtOptions);
	-- End Skill Helper Options
end

function ewtInit()
	local engFact = UnitFactionGroup("player")
	if engFact == "Alliance" then
		ewtFrame.buttonToggle:SetNormalTexture("Interface\\Icons\\achievement_pvp_g_a")
		ewtFrame.buttonToggle:SetPushedTexture("Interface\\Icons\\achievement_pvp_o_a")
		ewtFrame.buttonToggle:SetCheckedTexture("Interface\\Icons\\achievement_pvp_h_a")
	elseif engFact == "Horde" then
		ewtFrame.buttonToggle:SetNormalTexture("Interface\\Icons\\achievement_pvp_g_h")
		ewtFrame.buttonToggle:SetPushedTexture("Interface\\Icons\\achievement_pvp_o_h")
		ewtFrame.buttonToggle:SetCheckedTexture("Interface\\Icons\\achievement_pvp_h_h")
	end

	ewtFrame:SetScale(ewtSettings.options.ewtScale);

	if ewtSettings.options.ewtLock == true then
		ewtFrame:EnableMouse(true)
	else
		ewtFrame:EnableMouse(false)
	end
			
	if ewtSettings.options.ewtHidden == false then
		ewtFrame:Show()
	else
		ewtFrame:Hide()
	end

	if ewtSettings.options.ewtMouseOver == true then
		ewtMouseOverOpt:SetChecked(true)
		ewtFrame:SetAlpha(ewtSettings.options.ewtAlpha)
	else
		ewtMouseOverOpt:SetChecked(false)
	end

	ewtSettings.options.ewtWarmode = C_PvP.IsWarModeActive();

	if ewtSettings.options.ewtWarmode == false then
		ewtFrame.buttonToggle:SetChecked(false)
	else
		ewtFrame.buttonToggle:SetChecked(true)
	end
end

function ewtMouseOverEnter()
	if ewtSettings.options.ewtMouseOver == true then
		ewtFrame:SetAlpha(1);
	end
end

function ewtMouseOverLeave()
	if ewtSettings.options.ewtMouseOver == true then
		ewtFrame:SetAlpha(ewtSettings.options.ewtAlpha);
	end
end

function SlashCmdList.EASYWARMODETOGGLE(msg)
	if msg == "hide" then
		ewtToggle()
	elseif msg == "toggle" then
		ewtWarmodeToggle()
	elseif msg == "lock" then
		ewtLocker()
	elseif msg == "options" then
		ewtOption()
	elseif msg == "info" then
		ewtInfo()
	else
		ChatFrame1:AddMessage("|cff71C671" .. addon_name .. " Slash Commands|r")
		ChatFrame1:AddMessage("|cff71C671type /EWT followed by:|r")
		ChatFrame1:AddMessage("|cff71C671  -- hide to toggle the addon hidden state|r")
		ChatFrame1:AddMessage("|cff71C671  -- toggle to toggle Warmode state|r")
		ChatFrame1:AddMessage("|cff71C671  -- lock to toggle locking|r")
		ChatFrame1:AddMessage("|cff71C671  -- options to open addon options|r")
		ChatFrame1:AddMessage("|cff71C671  -- info to view current build information|r")
	end
end

function ewtToggle()
	if ewtCombat == false then
		-- true for it is hidden and false for it isn't hidden
		if ewtSettings.options.ewtHidden == false then
			ewtFrame:Hide()
			ChatFrame1:AddMessage(addon_name .. " |cffff0000hidden|r!")
			ewtSettings.options.ewtHidden = true
		elseif ewtSettings.options.ewtHidden == true then
			ewtFrame:Show()
			ChatFrame1:AddMessage(addon_name .. " |cff00ff00visible|r!")
			ewtSettings.options.ewtHidden = false
		end
	end
end

function ewtWarmodeToggle()
	if ewtCombat == false then
		local flag = C_PvP.IsWarModeActive() -- true = Flagged, false = Not Flagged
		if flag == false then
			if ewtSettings.options.ewtWarmode == false then
				-- nothing
			elseif ewtSettings.options.ewtWarmode == true then
				ewtSettings.options.ewtWarmode = false
			end
		end
		if ewtSettings.options.ewtWarmode == false then
			ewtSettings.options.ewtWarmode = true
			C_PvP.ToggleWarMode(); -- Flag for Warmode
		elseif ewtSettings.options.ewtWarmode == true then
			ewtSettings.options.ewtWarmode = false
			C_PvP.ToggleWarMode(); -- Deflag for Warmode
		end
	end
end

function ewtLocker()
	if ewtCombat == false then
		-- Remember ewtLock is backwards. true for unlocked and false for locked
		if ewtSettings.options.ewtLock == true then
			ewtSettings.options.ewtLock = false
			ewtFrame:EnableMouse(ewtSettings.options.ewtLock)
			ChatFrame1:AddMessage(addon_name .. " |cffff0000locked|r!")
		elseif ewtSettings.options.ewtLock == false then
			ewtSettings.options.ewtLock = true
			ewtFrame:EnableMouse(ewtSettings.options.ewtLock)
			ChatFrame1:AddMessage(addon_name .. " |cff00ff00unlocked|r!")
		end
	end
end

function ewtOption()
	InterfaceOptionsFrame_OpenToCategory("|cff00ff00Easy Warmode Toggle|r");
	InterfaceOptionsFrame_OpenToCategory("|cff00ff00Easy Warmode Toggle|r");
end

function ewtInfo()
	ChatFrame1:AddMessage(GetAddOnMetadata(addon_name, "Title") .. " " .. GetAddOnMetadata(addon_name, "Version"))
	ChatFrame1:AddMessage("Author: " .. GetAddOnMetadata(addon_name, "Author"))
	ChatFrame1:AddMessage("Release Date: " .. GetAddOnMetadata(addon_name, "X-Date"))
end