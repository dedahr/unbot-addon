function UnBotTick(bagsFrame, tick)
	if (bagsFrame.lastFlushTick > 0) then
		if ((tick - bagsFrame.lastFlushTick) > bagsFrame.waitFlushTime) then
			bagsFrame.lastFlushTick = 0;
			UnBotEnableAllFrameFlushButton();
		end
	end
end

function UnBotCanFlushInfo(bagsFrame)
	if (bagsFrame == nil) then
		return false;
	end
	if (bagsFrame.lastFlushTick > 0) then
		return true;
	else
		return false;
	end
end

function UnBotBagsHeadFrameSetFontText(rece, name, info)
	local text = "|cff0000cc" .. rece .. "|r |cff00cccc" .. name .. "|r - |cffcccccc" .. info .. "|r";
	return text;
end

local function CreateIconGroupByParent(fromParent, hheadGap, vheadGap, hnum, vnum, hgap, vgap, size)
	if (fromParent == nil) then
		return nil;
	end

	local iconsGroup = {};
	local iconsIndex = 1;
	for v = 1, vnum do
		for h = 1, hnum do
			local newFrame = CreateFrame("Button", "BGIconsFrame" .. tostring(iconsIndex), fromParent,
				"UnBotBagsButtonTemplate");
			newFrame.bagsIcon = nil;
			newFrame.iconIndex = -1;
			newFrame.Icon = newFrame:CreateTexture("BGIcons" .. tostring(iconsIndex), "BACKGROUND");
			newFrame.Icon:SetTexture(fromParent.disableIcon);
			newFrame.Icon:SetAllPoints(newFrame);
			newFrame.Icon:Show();
			newFrame:SetPushedTexture([[Interface\BUTTONS\UI-Quickslot-Depress]]);
			newFrame:SetHighlightTexture([[Interface\Buttons\UI-Common-MouseHilight]], "ADD");
			newFrame:Show();
			local offsetX = hheadGap + (h - 1) * size + hgap * h;
			local offsetY = (vheadGap + (v - 1) * size + vgap * v) * (-1) + 5;
			newFrame:SetPoint("TOPLEFT", fromParent, "TOPLEFT", offsetX, offsetY);
			newFrame.index = iconsIndex;
			iconsGroup[iconsIndex] = newFrame;
			iconsIndex = iconsIndex + 1;
			newFrame.countLabel = newFrame:CreateFontString(newFrame:GetName() .. "Count", "OVERLAY");
			newFrame.countLabel:SetFont("Fonts\\FRIZQT__.TTF", 11);
			newFrame.countLabel:SetTextColor(0.8, 0, 0.8, 1);
			newFrame.countLabel:SetHeight(12);
			newFrame.countLabel:SetText(" ");
			newFrame.countLabel:SetPoint("BOTTOMRIGHT", newFrame, "BOTTOMRIGHT", -2, 2);
			newFrame.countLabel:SetJustifyH("RIGHT");
			newFrame.countLabel:SetJustifyV("BOTTOM");
			newFrame.countLabel:SetShadowColor(0.1, 0.1, 0.1);
			newFrame.countLabel:SetShadowOffset(1, -1);
			newFrame:SetScript("OnEnter", function() UnBotShowButtonTips(newFrame, fromParent) end);
			newFrame:SetScript("OnLeave", function() GameTooltip:Hide() end);
			newFrame:SetScript("OnClick", function(self, button)
				local over = ExecuteCommandByBagsItem(fromParent, newFrame.dataIndex);
				if (over == true and fromParent.afterRemove) then
					RemoveByIndex(fromParent, newFrame.dataIndex);
				end
			end);
			newFrame:SetScript("OnMouseUp", function(self, button)
				if (button == "RightButton") then
					RemoveByIndex(fromParent, newFrame.dataIndex);
				end
			end);
		end
	end
	return iconsGroup;
end

function UnBotGetCostEnergyText(costType, costValue)
	if (costValue <= 0) then
		return " ";
	end
	if (costType == 0) then
		return "Consume" .. tostring(costValue) .. "Mana"; -- Needs correction
	elseif (costType == 1) then
		return "Consume" .. tostring(costValue) .. "Rage"; -- Needs correction
	elseif (costType == 3) then
		return "Consume" .. tostring(costValue) .. "Energy"; -- Needs correction
	else
		return "Consume" .. tostring(costValue) .. "Resource"; -- Needs correction
	end
end

--item [2] = spellID
--item [3] = name
--item [4] = texture
--item [6] = rankLV
--item [7] = costType = 0,1,3
--item [8] = costMana
--item [9] = castTime
--item [10] = distance
function UnBotShowButtonTips(newFrame, fromParent)
	if (newFrame.bagsIcon ~= nil) then
		GameTooltip:SetOwner(newFrame, "ANCHOR_BOTTOMRIGHT");
		local itemID = fromParent.dataGroup[newFrame.dataIndex][2];
		if (itemID ~= nil and itemID > 0) then
			local needQuery = fromParent.dataGroup[newFrame.dataIndex][5];
			if (needQuery == false) then
				if (fromParent.bagsType == 1) then
					GameTooltip:SetHyperlink("item:" .. itemID .. ":0:0:0:0:0:0:0");
					if (fromParent.dataGroup[newFrame.dataIndex][7] ~= nil and fromParent.dataGroup[newFrame.dataIndex][7] > 1) then
						GameTooltip:AddLine(" ", 1, 1, 1, 1);
						GameTooltip:AddDoubleLine("Quantity owned：",
							tostring(fromParent.dataGroup[newFrame.dataIndex][7]), 0, 0.8, 0.8, 0.8, 0.8, 0); -- Needs correction
					end
				elseif (fromParent.bagsType == 2) then
					local spellLink = GetSpellLink(itemID);
					if (spellLink ~= nil) then
						GameTooltip:SetHyperlink(spellLink);
					else
						local spellData = fromParent.dataGroup[newFrame.dataIndex];
						GameTooltip:AddLine(spellData[3], 1, 0, 0, 1);
						GameTooltip:AddDoubleLine(UnBotGetCostEnergyText(spellData[7], spellData[8]),
							tostring(spellData[6]), 1, 1, 1, 0.5, 0.5, 0.5);
						local castDis = "";
						if (spellData[10] <= 0) then
							castDis = "Self-cast";
						else
							castDis = tostring(spellData[10]) .. " yards";
						end
						if (spellData[9] <= 0) then
							GameTooltip:AddDoubleLine("Instant", castDis, 0.65, 0.55, 0, 0, 0.8, 0.8);
						else
							GameTooltip:AddDoubleLine("Cast time: " .. tostring(spellData[9] / 1000) .. " second(s)",
								castDis, 0.65, 0.55, 0, 0, 0.8, 0.8); -- Needs correction
						end
					end
				end
			else
				GameTooltip:AddLine(fromParent.dataGroup[newFrame.dataIndex][3], 1, 0, 0, 1);
				GameTooltip:AddLine("This item has not been cached yet. Click Refresh button to query the server.", 1, 0,
					0, 1);
			end
			GameTooltip:AddLine(" ", 1, 1, 1, 1);
			if (fromParent.command ~= nil and fromParent.command ~= "") then
				if (fromParent.bagsType == 1) then
					if (fromParent.command == UnBotExecuteCommand[66]) then -- EQUIP
						GameTooltip:AddLine("LMB: Equip", 0.65, 0.55, 0, 1);
					elseif (tostring(fromParent.command) == UnBotExecuteCommand[65]) then -- DESTROY
						GameTooltip:AddLine("LMB: Discard", 0.65, 0.55, 0, 1);
					elseif (tostring(fromParent.command) == UnBotExecuteCommand[67]) then -- SELL
						GameTooltip:AddLine("LMB: Sell", 0.65, 0.55, 0, 1);
					elseif (tostring(fromParent.command) == UnBotExecuteCommand[68]) then -- USE
						GameTooltip:AddLine("LMB: Use", 0.65, 0.55, 0, 1);
					else
						GameTooltip:AddLine("LMB: Use", 0.65, 0.55, 0, 1);
					end
				elseif (fromParent.bagsType == 2) then
					GameTooltip:AddLine("LMB: Cast", 0.65, 0.55, 0, 1);
				else
					GameTooltip:AddLine("LMB: Let " .. fromParent.target .. " " .. fromParent.activeText, 0.65, 0.55, 0,
						1); -- Needs correction
				end
			end
			GameTooltip:AddLine("RMB: Hide", 0.65, 0.55, 0, 1);
			if (fromParent.bagsType == 2) then
				GameTooltip:AddDoubleLine("ID:", tostring(itemID), 0, 0.8, 0.8, 0.8, 0, 0);
			end
		else
			GameTooltip:AddLine(newFrame.bagsIcon);
		end
		GameTooltip:AddDoubleLine("Index:", tostring(newFrame.iconIndex), 0, 0, 1, 1, 0, 1);
		GameTooltip:AddTexture(fromParent.dataGroup[newFrame.dataIndex][4]);
		GameTooltip:Show();
	end
end

local function CreateBagsTypeOptions(fromParent, checkedIndex)
	if (fromParent == nil or checkedIndex == nil) then
		return nil;
	end
	local newFrame = CreateFrame("CheckButton", fromParent:GetName() .. "BagsType1", fromParent, "UnBotBagsTypeTemplate");
	newFrame.title = newFrame:CreateFontString(newFrame:GetName() .. "Title", "ARTWORK");
	newFrame.title:SetFont("Fonts\\FRIZQT__.TTF", 11);
	newFrame.title:SetTextColor(1.0, 0.8, 0, 1);
	newFrame.title:SetText("View");
	newFrame.title:SetPoint("TOPLEFT", newFrame, "TOPRIGHT", -2, -8);
	newFrame.title:SetShadowColor(0, 0, 0);
	newFrame.title:SetShadowOffset(1, -1);
	newFrame:Show();
	newFrame.parentFrame = fromParent;
	newFrame.command = nil;
	newFrame.afterRemove = false;
	newFrame.parentFrameText = UnBotBagsHeadFrameSetFontText(fromParent.raceName, fromParent.target, "Inventory");
	newFrame:SetPoint("TOPRIGHT", fromParent, "TOPRIGHT", -52, -24 * 1);
	table.insert(fromParent.optionsType, newFrame);
	if (checkedIndex == 1) then
		BagsTypeOptionsClick(newFrame, fromParent, newFrame.afterRemove);
	end

	newFrame = CreateFrame("CheckButton", fromParent:GetName() .. "BagsType2", fromParent, "UnBotBagsTypeTemplate");
	newFrame.title = newFrame:CreateFontString(newFrame:GetName() .. "Title", "ARTWORK");
	newFrame.title:SetFont("Fonts\\FRIZQT__.TTF", 11);
	newFrame.title:SetTextColor(1.0, 0.8, 0, 1);
	newFrame.title:SetText("Equip");
	newFrame.title:SetPoint("TOPLEFT", newFrame, "TOPRIGHT", -2, -8);
	newFrame.title:SetShadowColor(0, 0, 0);
	newFrame.title:SetShadowOffset(1, -1);
	newFrame:Show();
	newFrame.parentFrame = fromParent;
	newFrame.command = UnBotExecuteCommand[66]; -- EQUIP
	newFrame.afterRemove = true;
	newFrame.parentFrameText = UnBotBagsHeadFrameSetFontText(fromParent.raceName, fromParent.target, "Equip item");
	newFrame:SetPoint("TOPRIGHT", fromParent, "TOPRIGHT", -52, -29 * 2 + 13);
	table.insert(fromParent.optionsType, newFrame);
	if (checkedIndex == 2) then
		BagsTypeOptionsClick(newFrame, fromParent, newFrame.afterRemove);
	end

	newFrame = CreateFrame("CheckButton", fromParent:GetName() .. "BagsType3", fromParent, "UnBotBagsTypeTemplate");
	newFrame.title = newFrame:CreateFontString(newFrame:GetName() .. "Title", "ARTWORK");
	newFrame.title:SetFont("Fonts\\FRIZQT__.TTF", 11);
	newFrame.title:SetTextColor(1.0, 0.8, 0, 1);
	newFrame.title:SetText("Discard");
	newFrame.title:SetPoint("TOPLEFT", newFrame, "TOPRIGHT", -2, -8);
	newFrame.title:SetShadowColor(0, 0, 0);
	newFrame.title:SetShadowOffset(1, -1);
	newFrame:Show();
	newFrame.parentFrame = fromParent;
	newFrame.command = UnBotExecuteCommand[65]; -- DESTROY
	newFrame.afterRemove = true;
	newFrame.parentFrameText = UnBotBagsHeadFrameSetFontText(fromParent.raceName, fromParent.target, "Discard item");
	newFrame:SetPoint("TOPRIGHT", fromParent, "TOPRIGHT", -52, -29 * 3 + 21);
	table.insert(fromParent.optionsType, newFrame);
	if (checkedIndex == 3) then
		BagsTypeOptionsClick(newFrame, fromParent, newFrame.afterRemove);
	end

	newFrame = CreateFrame("CheckButton", fromParent:GetName() .. "BagsType4", fromParent, "UnBotBagsTypeTemplate");
	newFrame.title = newFrame:CreateFontString(newFrame:GetName() .. "Title", "ARTWORK");
	newFrame.title:SetFont("Fonts\\FRIZQT__.TTF", 11);
	newFrame.title:SetTextColor(1.0, 0.8, 0, 1);
	newFrame.title:SetText("Sell");
	newFrame.title:SetPoint("TOPLEFT", newFrame, "TOPRIGHT", -2, -8);
	newFrame.title:SetShadowColor(0, 0, 0);
	newFrame.title:SetShadowOffset(1, -1);
	newFrame:Show();
	newFrame.parentFrame = fromParent;
	newFrame.command = UnBotExecuteCommand[67]; -- SELL
	newFrame.afterRemove = true;
	newFrame.parentFrameText = UnBotBagsHeadFrameSetFontText(fromParent.raceName, fromParent.target, "Sell item");
	newFrame:SetPoint("TOPRIGHT", fromParent, "TOPRIGHT", -52, -29 * 4 + 29);
	table.insert(fromParent.optionsType, newFrame);
	if (checkedIndex == 4) then
		BagsTypeOptionsClick(newFrame, fromParent, newFrame.afterRemove);
	end

	newFrame = CreateFrame("CheckButton", fromParent:GetName() .. "BagsType5", fromParent, "UnBotBagsTypeTemplate");
	newFrame.title = newFrame:CreateFontString(newFrame:GetName() .. "Title", "ARTWORK");
	newFrame.title:SetFont("Fonts\\FRIZQT__.TTF", 11);
	newFrame.title:SetTextColor(1.0, 0.8, 0, 1);
	newFrame.title:SetText("Use");
	newFrame.title:SetPoint("TOPLEFT", newFrame, "TOPRIGHT", -2, -9);
	newFrame.title:SetShadowColor(0, 0, 0);
	newFrame.title:SetShadowOffset(1, -1);
	newFrame:Show();
	newFrame.parentFrame = fromParent;
	newFrame.command = UnBotExecuteCommand[68]; -- USE
	newFrame.afterRemove = true;
	newFrame.parentFrameText = UnBotBagsHeadFrameSetFontText(fromParent.raceName, fromParent.target, "Use item");
	newFrame:SetPoint("TOPRIGHT", fromParent, "TOPRIGHT", -52, -29 * 5 + 37);
	table.insert(fromParent.optionsType, newFrame);
	if (checkedIndex == 5) then
		BagsTypeOptionsClick(newFrame, fromParent, newFrame.afterRemove);
	end
end

function BagsTypeOptionsClick(self, bagsFrame, afterRemove)
	for i = 1, #(bagsFrame.optionsType) do
		if (bagsFrame.optionsType[i] ~= self) then
			bagsFrame.optionsType[i]:SetChecked(false);
		else
			bagsFrame.optionsType[i]:SetChecked(true);
		end
	end
	bagsFrame.title:SetText(self.parentFrameText);
	bagsFrame.command = self.command;
	bagsFrame.afterRemove = afterRemove;
end

local function CreateOptionByParent(fromParent, flushFunc, bagType)
	if (fromParent == nil) then
		return nil
	end

	-- Title for the frame
	fromParent.title = fromParent:CreateFontString(fromParent:GetName() .. "Title", "ARTWORK")
	fromParent.title:SetFont("Fonts\\FRIZQT__.TTF", 12)
	fromParent.title:SetTextColor(1.0, 1.0, 1.0, 1)
	fromParent.title:SetText(UnBotBagsHeadFrameSetFontText(fromParent.raceName, fromParent.target, fromParent.activeText))
	fromParent.title:SetPoint("TOPLEFT", fromParent, "TOPLEFT", 6, -6)
	fromParent.title:SetShadowColor(0, 0, 0)
	fromParent.title:SetShadowOffset(1, -1)

	-- Page text display
	fromParent.page = fromParent:CreateFontString(fromParent:GetName() .. "Page", "ARTWORK")
	fromParent.page:SetFont("Fonts\\FRIZQT__.TTF", 11)
	fromParent.page:SetTextColor(1.0, 1.0, 1.0, 1)
	fromParent.page:SetText("0-0")
	fromParent.page:SetPoint("CENTER", fromParent, "BOTTOMLEFT", 82, 18)
	fromParent.page:SetShadowColor(0, 0, 0)
	fromParent.page:SetShadowOffset(1, -1)
	-- Filter txt box
	if bagType == 0 then
		-- Label
		local label = fromParent:CreateFontString(fromParent:GetName() .. "FilterLabel", "ARTWORK", "GameFontNormal")
		label:SetPoint("TOPLEFT", fromParent, "TOPLEFT", 260, -7)
		label:SetText("Filter:  ______________________________")
		label:SetTextColor(0.0, 1.0, 0.0, 1.0)
		--Filter box
		local filterBox = CreateFrame("EditBox", fromParent:GetName() .. "FilterBox", fromParent, "UnBotInputBoxTemplate")
		filterBox:SetPoint("TOPLEFT", fromParent, "TOPLEFT", 300, 0)
		filterBox:SetAutoFocus(false) -- Prevent it from auto-focusing on creation.
		-- Hook into the parent frame's OnShow event to set focus dynamically
		fromParent:HookScript("OnShow", function()
			filterBox:SetFocus() -- Set focus when the parent frame is shown
		end)
		filterBox:SetScript("OnTextChanged", function(self)
			local filterText = self:GetText()
			UnBotFilterIcons(filterText, fromParent)
		end)
		filterBox:SetScript("OnEnterPressed", function(self)
			self:ClearFocus()
		end)
		filterBox:SetScript("OnEscapePressed", function(self)
			self:SetText("") -- Clears the text inside the input box
			self:ClearFocus() -- Removes focus from the input box
		end)
	end
	-- Previous Page Button
	local newFrame = CreateFrame("Button", "BGIconsFramePrev", fromParent, "UnBotBagsButtonTemplate")
	newFrame.Icon = newFrame:CreateTexture("BGIconsPrev", "BACKGROUND")
	newFrame.Icon:SetTexture([[Interface\BUTTONS\UI-SpellbookIcon-PrevPage-Up]])
	newFrame.Icon:SetAllPoints(newFrame)
	newFrame.Icon:Show()
	newFrame:SetPushedTexture([[Interface\BUTTONS\UI-SpellbookIcon-PrevPage-Down]])
	newFrame:SetHighlightTexture([[Interface\Buttons\UI-Common-MouseHilight]], "ADD")
	newFrame:Show()
	newFrame:SetPoint("BOTTOMLEFT", fromParent, "BOTTOMLEFT", 4, 3)
	newFrame.parentFrame = fromParent
	newFrame:SetScript("OnClick", function() PickPrevOrNextButton(fromParent, true) end)
	newFrame:SetSize(28, 28)

	-- Next Page Button
	newFrame = CreateFrame("Button", "BGIconsFrameNext", fromParent, "UnBotBagsButtonTemplate")
	newFrame.Icon = newFrame:CreateTexture("BGIconsNext", "BACKGROUND")
	newFrame.Icon:SetTexture([[Interface\BUTTONS\UI-SpellbookIcon-NextPage-Up]])
	newFrame.Icon:SetAllPoints(newFrame)
	newFrame.Icon:Show()
	newFrame:SetPushedTexture([[Interface\BUTTONS\UI-SpellbookIcon-NextPage-Down]])
	newFrame:SetHighlightTexture([[Interface\Buttons\UI-Common-MouseHilight]], "ADD")
	newFrame:Show()
	newFrame:SetPoint("BOTTOMLEFT", fromParent, "BOTTOMLEFT", 134, 3)
	newFrame.parentFrame = fromParent
	newFrame:SetScript("OnClick", function() PickPrevOrNextButton(fromParent, false) end)
	newFrame:SetSize(28, 28)

	-- Refresh Button
	newFrame = CreateFrame("Button", "BagsFrameFlush" .. fromParent:GetName(), fromParent, "UIPanelButtonTemplate")
	newFrame:SetText("Refresh")
	newFrame:SetWidth(56)
	newFrame:SetHeight(24)
	newFrame:Show()
	newFrame:SetPoint("BOTTOMLEFT", fromParent, "BOTTOMLEFT", 188, 6)
	newFrame:SetScript("OnClick", function()
		if flushFunc ~= nil then
			flushFunc(fromParent, fromParent.command)
			UnBotDisableAllFrameFlushButton()
		end
	end)

	-- Close Button
	local closeFrame = CreateFrame("Button", "BGIconsFrameClose", fromParent, "UIPanelCloseButton")
	closeFrame:SetWidth(32)
	closeFrame:SetHeight(32)
	closeFrame:Show()
	closeFrame:SetPoint("TOPRIGHT", fromParent, "TOPRIGHT", 3, 3)
	closeFrame:SetScript("OnClick", function()
		RemoveFromUnBotFrame(fromParent)
		fromParent:Hide()
		fromParent:SetParent(nil)
	end)

	-- Make the fromParent respond to keypresses
	fromParent:EnableKeyboard(true)

	-- Set a script to handle keypress events
	fromParent:SetScript("OnKeyDown", function(self, key)
		if key == "ESCAPE" then
			if closeFrame:IsShown() then
				closeFrame:Click() -- Simulate a mouse click on the close button
			end
		end
	end)
end

function PickPrevOrNextButton(bagsFrame, pn)
	if (bagsFrame == nil or bagsFrame.dataGroup == nil) then
		return;
	end
	local firstIndex = 1;
	local overIndex = math.ceil((#(bagsFrame.dataGroup)) / bagsFrame.pageCount);
	if (overIndex == 0) then
		overIndex = 1;
	end
	if (pn == true) then
		if (bagsFrame.currentPage > firstIndex) then
			bagsFrame.currentPage = bagsFrame.currentPage - 1;
			UpdateUnBotBagsFramePage(bagsFrame);
		end
	else
		if (bagsFrame.currentPage < overIndex) then
			bagsFrame.currentPage = bagsFrame.currentPage + 1;
			UpdateUnBotBagsFramePage(bagsFrame);
		end
	end
end

function CreateIconsByUnBotBagsFrame(checkedIndex, name, bagType, afterRemove, datas, target, race, activeText, flushFunc,
									 command, getFunc)
	if (CanAddToUnBotFrame(name) == false) then
		return nil;
	end
	local bagsFrame = CreateFrame("Frame", name, UIParent, "UnBotBagsFrame");
	local bagsHead = CreateFrame("Frame", bagsFrame:GetName() .. "Head", bagsFrame, "UnBotBagsFrameHeadFrame");
	bagsHead:Show();
	if (bagType == 1) then -- Bag list frame size
		bagsFrame:SetSize(830, 458);
		bagsHead:SetSize(830, 26);
	else --All Icons list frame size
		bagsFrame:SetSize(730, 458);
		bagsHead:SetSize(730, 26);
	end
	bagsFrame.bagsType = bagType;
	bagsFrame.bgIconsGroup = CreateIconGroupByParent(bagsFrame, 5, 32, 18, 10, 0, 0, 40);
	if (bagsFrame.flushFunc ~= nil or datas == nil) then
		bagsFrame.dataGroup = {};
	else
		bagsFrame.dataGroup = datas;
	end
	bagsFrame.afterRemove = afterRemove;
	bagsFrame.target = target;
	bagsFrame.raceName = race;
	bagsFrame.activeText = activeText;
	bagsFrame.flushFunc = flushFunc;
	bagsFrame.getFunc = getFunc;
	CreateOptionByParent(bagsFrame, flushFunc, bagType);
	if (bagType == 1) then
		CreateBagsTypeOptions(bagsFrame, checkedIndex);
	end
	UpdateUnBotBagsFramePage(bagsFrame);
	bagsFrame:Show();
	bagsFrame:RegisterEvent("CHAT_MSG_WHISPER");

	AddToUnBotFrame(bagsFrame, name);
	if (bagsFrame.flushFunc ~= nil) then
		bagsFrame.flushFunc(bagsFrame, command);
		UnBotDisableAllFrameFlushButton();
	end

	bagsFrame:SetScale(UnBotScaleConfig);

	return bagsFrame;
end

function UnBotCloseAllBagsFrame()
	for i = 1, #(UnBotFrame.ShowedBags) do
		UnBotFrame.ShowedBags[i]:Hide();
		UnBotFrame.ShowedBags[i]:SetParent(nil);
	end
	UnBotFrame.ShowedBags = {};
	--UnBotFrame.currentRecvLinkFrame = nil;
end

function UpdateUnBotBagsFramePage(bagsFrame)
	if (bagsFrame == nil) then
		return;
	end

	local startIndex = (bagsFrame.currentPage - 1) * bagsFrame.pageCount + 1;
	local groupIndex = 1;
	for i = startIndex, startIndex + bagsFrame.pageCount - 1 do
		if (i > #(bagsFrame.dataGroup) or bagsFrame.getFunc == nil) then
			bagsFrame.bgIconsGroup[groupIndex].Icon:SetTexture(bagsFrame.disableIcon);
			bagsFrame.bgIconsGroup[groupIndex].bagsIcon = nil;
			bagsFrame.bgIconsGroup[groupIndex].iconIndex = 0;
			bagsFrame.bgIconsGroup[groupIndex].countLabel:SetText(" ");
		else
			local icon, name = bagsFrame.getFunc(bagsFrame, i);
			bagsFrame.bgIconsGroup[groupIndex].Icon:SetTexture(icon);
			bagsFrame.bgIconsGroup[groupIndex].bagsIcon = name;
			bagsFrame.bgIconsGroup[groupIndex].iconIndex = bagsFrame.dataGroup[i][1];
			if (bagsFrame.bagsType == 1 and bagsFrame.dataGroup[i][7] ~= nil and bagsFrame.dataGroup[i][7] > 1) then
				bagsFrame.bgIconsGroup[groupIndex].countLabel:SetText(tostring(bagsFrame.dataGroup[i][7]));
			else
				bagsFrame.bgIconsGroup[groupIndex].countLabel:SetText(" ");
			end
		end
		bagsFrame.bgIconsGroup[groupIndex].dataIndex = i;
		groupIndex = groupIndex + 1;
	end
	local overIndex = math.ceil((#(bagsFrame.dataGroup)) / bagsFrame.pageCount);
	if (overIndex == 0) then
		overIndex = 1;
	end
	bagsFrame.page:SetText("Page " .. tostring(bagsFrame.currentPage) .. " of " .. tostring(overIndex));
end

function ExecuteCommandByBagsItem(bagsFrame, index)
	if (bagsFrame == nil or index < 1 or index > #(bagsFrame.dataGroup)) then
		return false;
	end
	if (bagsFrame.command ~= nil and bagsFrame.command ~= "") then
		if (bagsFrame.command == UnBotExecuteCommand[67]) then -- SELL
			local targetName = UnitName("target");
			if (targetName == nil or targetName == "") then
				DisplayInfomation("You have no vendor targeted.");
				return false;
			end
			-- CHECK IF ITEM IS UNSELLABLE
			local itemSellPrice = bagsFrame.dataGroup[index][8];
			if (itemSellPrice == 0) then
				DisplayInfomation("Item is unsellable.");
				return false;
			end
		end
		if (bagsFrame.bagsType == 1) then -- ITEMS
			local itemID = bagsFrame.dataGroup[index][2];
			-- local itemName = bagsFrame.dataGroup[index][3];
			local itemLink
			_, itemLink, _, _, _, _, _, _, _, _, itemSellPrice = GetItemInfo(tostring(itemID));

			SendChatMessage(bagsFrame.command .. itemLink, "WHISPER", nil, bagsFrame.target);
		elseif (bagsFrame.bagsType == 2) then -- SPELLS
			local itemID = bagsFrame.dataGroup[index][2];
			SendChatMessage(bagsFrame.command .. tostring(itemID), "WHISPER", nil, bagsFrame.target);
		end
	else
		if (bagsFrame.bagsType == 1) then
			if (bagsFrame.dataGroup[index][5] == true) then --FLAGGED FOR REFRESH
				local itemID = bagsFrame.dataGroup[index][2];

				-- QUERY SERVER FOR NOT CACHEDD ITEM
				--GameTooltip:SetHyperlink("item:"..itemID..":0:0:0:0:0:0:0");				
				--UpdateUnBotBagsFramePage(bagsFrame);				
			end
		end
	end
	return true;
end

function RemoveByIndex(bagsFrame, index)
	if (bagsFrame == nil or index < 1 or index > #(bagsFrame.dataGroup)) then
		return;
	end
	table.remove(bagsFrame.dataGroup, index);
	UpdateUnBotBagsFramePage(bagsFrame);
end

function FlushItemsToBags(bagsFrame, command)
	if (bagsFrame == nil) then
		return;
	end

	--UnBotFrame.currentRecvLinkFrame = bagsFrame:GetName();
	bagsFrame.dataGroup = {};
	if (command ~= nil) then
		bagsFrame.command = command;
	else
		bagsFrame.command = "";
	end
	UpdateUnBotBagsFramePage(bagsFrame);
	if (bagsFrame.bagsType == 1) then
		SendChatMessage("c", "WHISPER", nil, bagsFrame.target);
	elseif (bagsFrame.bagsType == 2) then
		SendChatMessage("spells", "WHISPER", nil, bagsFrame.target);
	end
	bagsFrame.lastFlushTick = GetTime();
end

function GetIconFunc(bagsFrame, index)
	local icon = GetIconPathByIndex(bagsFrame.dataGroup[index][1]);
	local name = GetIconPathByIndex(bagsFrame.dataGroup[index][1]);
	return icon, name;
end

function GetItemFunc(bagsFrame, index)
	if (index < 1 or index > #(bagsFrame.dataGroup)) then
		return nil, nil;
	end
	local icon = bagsFrame.dataGroup[index][4];
	local name = bagsFrame.dataGroup[index][3];
	return icon, name;
end

function IsFilterInfo(info)
	local f1, f2 = string.find(info, "equipment");
	if (f1 ~= nil or f2 ~= nil) then
		print("equipment");
		return true;
	end

	f1, f2 = string.find(info, "discard");
	if (f1 ~= nil or f2 ~= nil) then
		print("discard");
		return true;
	end

	f1, f2 = string.find(info, "sell");
	if (f1 ~= nil or f2 ~= nil) then
		print("sell");
		return true;
	end

	f1, f2 = string.find(info, "use");
	if (f1 ~= nil or f2 ~= nil) then
		print("use");
		return true;
	end

	return false;
end

function GetItemCountByLink(info)
	local x1, x2 = string.find(info, "]");
	if (x1 == nil or x2 == nil) then
		return 1;
	end
	local numIndex1, numIndex2 = string.find(info, "x", x2);
	if (numIndex1 == nil or numIndex2 == nil) then
		return 1;
	end
	local count = string.match(info, "%d+", numIndex2);
	return tonumber(count);
end

function RecvOnceItemToBags(bagsFrame, info)
	if (bagsFrame == nil) then
		return;
	end

	if (info == nil) then
		return;
	end
	--if (UnBotFrame.currentRecvLinkFrame == nil or UnBotFrame.currentRecvLinkFrame ~= bagsFrame:GetName()) then
	--	return;
	--end

	--if (IsFilterInfo(info) == true) then
	--return;
	--end

	local i1, i2 = string.find(info, "Hitem:");

	if (i1 == nil and i2 == nil) then
		return;
	end

	local itemCount = GetItemCountByLink(info);

	if (itemCount == nil) then
		itemCount = 1;
	end

	local itemID = tonumber(string.match(info, "%d+", i2));

	local texture;
	local name;
	local itemQuality;
	local itemSellPrice;
	name, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, texture, itemSellPrice =
		GetItemInfo(info);
	local needQuery = false;

	if (name == nil or texture == nil) then
		--QueryItem
		GameTooltip:SetHyperlink("item:" .. itemID .. ":0:0:0:0:0:0:0");
		--
		--local itemQ = Item:CreateFromItemID(itemID)
		--name, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, texture = GetItemInfo(itemQ);
		--
		name = info;
		texture = "Interface\\Icons\\INV_Misc_QuestionMark";
		--texture = GetItemIcon(itemID);
		needQuery = true;
	end


	local item = {
		[1] = 0,
		[2] = itemID,
		[3] = name,
		[4] = texture,
		[5] = needQuery,
		[6] = itemQuality,
		[7] = itemCount,
		[8] = itemSellPrice
	};
	table.insert(bagsFrame.dataGroup, item);
	item[1] = #(bagsFrame.dataGroup);
	--DisplayInfomation("Recv itemIndex "..tostring(item[1])..",item "..tostring(item[2])..",name "..tostring(item[3])..",icon "..tostring(item[4])..",itemLink "..tostring(itemLink)..",itemQuality "..tostring(itemQuality));

	UpdateUnBotBagsFramePage(bagsFrame);
end

function RecvMuchSpellToBags(bagsFrame, info)
	if (bagsFrame == nil) then
		return;
	end
	--item [2] = spellID
	--item [3] = name
	--item [4] = texture
	--item [6] = rankLV
	--item [7] = costType = 0,1,3
	--item [8] = costMana
	--item [9] = castTime
	--item [10] = distance
	--if (UnBotFrame.currentRecvLinkFrame == nil or UnBotFrame.currentRecvLinkFrame ~= bagsFrame:GetName()) then
	--	return;
	--end
	local i1, i2 = string.find(info, "Hspell:");
	if (i1 == nil or i2 == nil) then
		return;
	end

	local textList = UnBotSplit(string.sub(info, i2), "Hspell:");
	local ids = {};
	for i = 1, #textList do
		local idText = tonumber(string.match(textList[i], "%d+"));
		if (idText ~= nil) then
			table.insert(ids, tonumber(idText));
		end
	end
	for i = 1, #ids do
		local spellID = ids[i];
		local name, rankLV, texture, costMana, un3, costType, castTime, un6, distance = GetSpellInfo(spellID);
		if (name ~= nil) then
			if (texture == nil) then
				texture = bagsFrame.normalIcon;
			end
			local spell = {
				[1] = 0,
				[2] = spellID,
				[3] = name,
				[4] = texture,
				[5] = false,
				[6] = rankLV,
				[7] = tonumber(
					costType),
				[8] = tonumber(costMana),
				[9] = tonumber(castTime),
				[10] = tonumber(distance)
			};
			table.insert(bagsFrame.dataGroup, spell);
			spell[1] = #(bagsFrame.dataGroup);
		else
			DisplayInfomation("Recv spell id " .. tostring(spellID) .. " error.");
		end
	end

	UpdateUnBotBagsFramePage(bagsFrame);
end

function UnBotFilterIcons(filterText, bagsFrame)
	-- Validate the bagsFrame
	if not bagsFrame then
		DEFAULT_CHAT_FRAME:AddMessage("Error: Frame is missing!")
		return
	end

	-- Handle filter clearing
	if not filterText or filterText == "" then
		--DEFAULT_CHAT_FRAME:AddMessage("Filter cleared, restoring original page.")

		-- Restore the original page, fallback to page 1 if originalPage is missing
		bagsFrame.currentPage = bagsFrame.originalPage or 1

		-- Reset originalPage (to avoid holding onto outdated values)
		bagsFrame.originalPage = nil

		-- Reset dataGroup to display all icons
		bagsFrame.dataGroup = {}
		for i = 1, #UnBotCommandIconsPath do
			table.insert(bagsFrame.dataGroup, { [1] = i })
		end

		-- Refresh the frame
		UpdateUnBotBagsFramePage(bagsFrame)
		return
	end

	-- Save the current page before applying a filter
	bagsFrame.originalPage = bagsFrame.currentPage

	filterText = string.lower(filterText) -- Case-insensitive matching
	local filteredDataGroup = {}

	-- Apply filtering logic
	for i, texturePath in ipairs(UnBotCommandIconsPath) do
		if string.find(string.lower(texturePath), filterText) then
			table.insert(filteredDataGroup, { [1] = i }) -- Wrap index for compatibility
		end
	end

	-- Debug filtered results
	--DEFAULT_CHAT_FRAME:AddMessage("Filtered Icons Count: " .. #filteredDataGroup)

	-- Update dataGroup with filtered results
	bagsFrame.dataGroup = filteredDataGroup

	-- Reset to the first page for filtered results
	bagsFrame.currentPage = 1

	-- Refresh the frame dynamically
	UpdateUnBotBagsFramePage(bagsFrame)
end
