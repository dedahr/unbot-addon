function UnBotTick(bagsFrame, tick)
	-- Check if the last flush tick has been set (greater than 0)
	if (bagsFrame.lastFlushTick > 0) then
		-- Check if the time elapsed since the last flush tick exceeds the allowed wait time
		if ((tick - bagsFrame.lastFlushTick) > bagsFrame.waitFlushTime) then
			-- Reset the last flush tick to 0, indicating the flush process is done
			bagsFrame.lastFlushTick = 0;
			-- Enable all frame flush buttons again
			UnBotEnableAllFrameFlushButton();
		end
	end
end

function UnBotCanFlushInfo(bagsFrame)
	-- Check if the bagsFrame is nil (not initialized or missing)
	if (bagsFrame == nil) then
		-- Return false, indicating that the flush cannot proceed
		return false;
	end

	-- Check if the last flush tick has been set (greater than 0)
	if (bagsFrame.lastFlushTick > 0) then
		-- Return true, indicating that the flush information can be processed
		return true;
	else
		-- Otherwise, return false, as the flush cannot be processed
		return false;
	end
end

function UnBotBagsHeadFrameSetFontText(rece, name, info)
	-- Combine the provided parameters into a formatted text string
	-- Use color codes for formatting:
	-- |cff0000cc -> Blue for 'rece'
	-- |cff00cccc -> Cyan for 'name'
	-- |cffcccccc -> Gray for 'info'
	local text = "|cff0000cc" .. rece .. "|r |cff00cccc" .. name .. "|r - |cffcccccc" .. info .. "|r";

	-- Return the formatted text string
	return text;
end

-- Create a dynamic group of icon buttons
local function CreateIconGroupByParent(fromParent, hheadGap, vheadGap, hnum, vnum, hgap, vgap, size)
	-- Check if the parent frame (fromParent) is nil; if so, return nil since icons cannot be created
	if (fromParent == nil) then
		return nil;
	end

	-- Initialize an empty table to hold the group of icons
	local iconsGroup = {};
	-- Start an index counter for icons
	local iconsIndex = 1;

	-- Loop through the vertical and horizontal number of icons (vnum and hnum)
	for v = 1, vnum do
		for h = 1, hnum do
			-- Create a new button frame for each icon
			local newFrame = CreateFrame("Button", "BGIconsFrame" .. tostring(iconsIndex), fromParent,
				"UnBotBagsButtonTemplate");

			-- Initialize properties for the new frame
			newFrame.bagsIcon = nil; -- Clear the bagsIcon property
			newFrame.iconIndex = -1; -- Set iconIndex to -1 initially

			-- Create and configure the texture for the icon
			newFrame.Icon = newFrame:CreateTexture("BGIcons" .. tostring(iconsIndex), "BACKGROUND");
			newFrame.Icon:SetTexture(fromParent.disableIcon); -- Set the texture to the disabled icon
			newFrame.Icon:SetAllPoints(newFrame);    -- Ensure the texture fills the button frame
			newFrame.Icon:Show();                    -- Show the texture

			-- Set visual attributes for the button frame
			newFrame:SetPushedTexture([[Interface\BUTTONS\UI-Quickslot-Depress]]);    -- Pushed texture appearance
			newFrame:SetHighlightTexture([[Interface\Buttons\UI-Common-MouseHilight]], "ADD"); -- Highlight appearance

			-- Show the button frame
			newFrame:Show();

			-- Calculate the position offsets for the new frame
			local offsetX = hheadGap + (h - 1) * size + hgap * h;
			local offsetY = (vheadGap + (v - 1) * size + vgap * v) * (-1) + 5;
			-- Position the frame relative to the parent frame
			newFrame:SetPoint("TOPLEFT", fromParent, "TOPLEFT", offsetX, offsetY);

			-- Set the index for the current icon and add it to the group
			newFrame.index = iconsIndex;
			iconsGroup[iconsIndex] = newFrame;
			iconsIndex = iconsIndex + 1;

			-- Add a font label to the frame for displaying counts or additional info
			newFrame.countLabel = newFrame:CreateFontString(newFrame:GetName() .. "Count", "OVERLAY");
			newFrame.countLabel:SetFont("Fonts\\FRIZQT__.TTF", 11);             -- Define font and size
			newFrame.countLabel:SetTextColor(0.8, 0, 0.8, 1);                   -- Set font color to purple
			newFrame.countLabel:SetHeight(12);                                  -- Set height for the label
			newFrame.countLabel:SetText(" ");                                   -- Initially set text to empty
			newFrame.countLabel:SetPoint("BOTTOMRIGHT", newFrame, "BOTTOMRIGHT", -2, 2); -- Position label
			newFrame.countLabel:SetJustifyH("RIGHT");                           -- Right justify horizontally
			newFrame.countLabel:SetJustifyV("BOTTOM");                          -- Bottom justify vertically
			newFrame.countLabel:SetShadowColor(0.1, 0.1, 0.1);                  -- Set shadow color
			newFrame.countLabel:SetShadowOffset(1, -1);                         -- Set shadow offset

			-- Define scripts for mouse interactions
			newFrame:SetScript("OnEnter", function() UnBotShowButtonTips(newFrame, fromParent) end); -- On hover, show tips
			newFrame:SetScript("OnLeave", function() GameTooltip:Hide() end);               -- On hover exit, hide tips

			-- On click, execute commands based on the bags item dataIndex
			newFrame:SetScript("OnClick", function(self, button)
				local over = ExecuteCommandByBagsItem(fromParent, newFrame.dataIndex);
				if (over == true and fromParent.afterRemove) then
					RemoveByIndex(fromParent, newFrame.dataIndex); -- Optionally remove the item
				end
			end);

			-- On mouse-up interaction, handle right-click for removal
			newFrame:SetScript("OnMouseUp", function(self, button)
				if (button == "RightButton") then
					RemoveByIndex(fromParent, newFrame.dataIndex); -- Remove item on right-click
				end
			end);
		end
	end

	-- Return the completed group of icons
	return iconsGroup;
end

function UnBotGetCostEnergyText(costType, costValue)
	-- If the cost value is zero or negative, return an empty string (no cost text)
	if (costValue <= 0) then
		return " ";
	end

	-- Determine the type of resource being consumed based on costType
	if (costType == 0) then
		-- If costType is 0, the resource is Mana
		return "Consume " .. tostring(costValue) .. " Mana"; -- Correct formatting added
	elseif (costType == 1) then
		-- If costType is 1, the resource is Rage
		return "Consume " .. tostring(costValue) .. " Rage"; -- Correct formatting added
	elseif (costType == 3) then
		-- If costType is 3, the resource is Energy
		return "Consume " .. tostring(costValue) .. " Energy"; -- Correct formatting added
	else
		-- For other types of resources, provide a generic resource consumption text
		return "Consume " .. tostring(costValue) .. " Resource"; -- Correct formatting added
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
-- Build and display detailed tooltips dynamically based on the context of the associated frame and its parent properties.
function UnBotShowButtonTips(newFrame, fromParent)
	-- Check if the newFrame has a valid bagsIcon assigned
	if (newFrame.bagsIcon ~= nil) then
		-- Set the tooltip owner to the current frame with a specific anchor point
		GameTooltip:SetOwner(newFrame, "ANCHOR_BOTTOMRIGHT");

		-- Retrieve the itemID from the parent frame's dataGroup using the dataIndex
		local itemID = fromParent.dataGroup[newFrame.dataIndex][2];

		-- Check if the itemID is valid (not nil and greater than 0)
		if (itemID ~= nil and itemID > 0) then
			local needQuery = fromParent.dataGroup[newFrame.dataIndex][5]; -- Check if the item needs a server query

			if (needQuery == false) then
				-- Case for bagType == 1 (assumed to be items)
				if (fromParent.bagsType == 1) then
					GameTooltip:SetHyperlink("item:" .. itemID .. ":0:0:0:0:0:0:0"); -- Display item hyperlink

					-- Add additional information for owned quantity
					if (fromParent.dataGroup[newFrame.dataIndex][7] ~= nil and fromParent.dataGroup[newFrame.dataIndex][7] > 1) then
						GameTooltip:AddLine(" ", 1, 1, 1, 1);
						GameTooltip:AddDoubleLine("Quantity owned:",
							tostring(fromParent.dataGroup[newFrame.dataIndex][7]), 0, 0.8, 0.8, 0.8, 0.8, 0); -- Correct formatting
					end

					-- Case for bagType == 2 (assumed to be spells)
				elseif (fromParent.bagsType == 2) then
					local spellLink = GetSpellLink(itemID); -- Retrieve spell link

					if (spellLink ~= nil) then
						GameTooltip:SetHyperlink(spellLink); -- Display spell hyperlink
					else
						-- If no spell link is available, show spell data
						local spellData = fromParent.dataGroup[newFrame.dataIndex];
						GameTooltip:AddLine(spellData[3], 1, 0, 0, 1);
						GameTooltip:AddDoubleLine(UnBotGetCostEnergyText(spellData[7], spellData[8]),
							tostring(spellData[6]), 1, 1, 1, 0.5, 0.5, 0.5);

						-- Determine casting distance
						local castDis = "";
						if (spellData[10] <= 0) then
							castDis = "Self-cast";
						else
							castDis = tostring(spellData[10]) .. " yards";
						end

						-- Add casting time or instant cast information
						if (spellData[9] <= 0) then
							GameTooltip:AddDoubleLine("Instant", castDis, 0.65, 0.55, 0, 0, 0.8, 0.8);
						else
							GameTooltip:AddDoubleLine("Cast time: " .. tostring(spellData[9] / 1000) .. " second(s)",
								castDis, 0.65, 0.55, 0, 0, 0.8, 0.8); -- Correct formatting
						end
					end
				end
			else
				-- Display message for items requiring a query
				GameTooltip:AddLine(fromParent.dataGroup[newFrame.dataIndex][3], 1, 0, 0, 1);
				GameTooltip:AddLine("This item has not been cached yet. Click Refresh button to query the server.", 1, 0,
					0, 1);
			end

			GameTooltip:AddLine(" ", 1, 1, 1, 1); -- Add spacing

			-- Add command-specific tips based on the parent frame's settings
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
						1); -- Correct formatting
				end
			end

			GameTooltip:AddLine("RMB: Hide", 0.65, 0.55, 0, 1);

			-- Add item ID if the bagsType is spells
			if (fromParent.bagsType == 2) then
				GameTooltip:AddDoubleLine("ID:", tostring(itemID), 0, 0.8, 0.8, 0.8, 0, 0);
			end
		else
			-- Display the bagsIcon directly if itemID is invalid
			GameTooltip:AddLine(newFrame.bagsIcon);
		end

		-- Add additional frame-specific information
		GameTooltip:AddDoubleLine("Index:", tostring(newFrame.iconIndex), 0, 0, 1, 1, 0, 1);
		GameTooltip:AddTexture(fromParent.dataGroup[newFrame.dataIndex][4]); -- Add texture to tooltip
		GameTooltip:Show();                                            -- Display the tooltip
	end
end

-- Dynamically create and configures a series of option buttons (e.g., View, Equip, Discard, Sell, Use)
-- tied to a parent frame. Each button has its unique properties, behavior, and layout adjustments.
local function CreateBagsTypeOptions(fromParent, checkedIndex)
	-- Validate the input arguments; return nil if either is missing
	if (fromParent == nil or checkedIndex == nil) then
		return nil;
	end

	-- Create and configure the first "View" option button
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

	-- Create and configure the second "Equip" option button
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

	-- Create and configure the third "Discard" option button
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

	-- Create and configure the fourth "Sell" option button
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

	-- Create and configure the fifth "Use" option button
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

-- Ensure that only one option in the optionsType group is selected at a time,
-- updating the parent frame's properties to reflect the clicked button's attributes.
function BagsTypeOptionsClick(self, bagsFrame, afterRemove)
	-- Iterate through all options in the parent frame's optionsType list
	for i = 1, #(bagsFrame.optionsType) do
		if (bagsFrame.optionsType[i] ~= self) then
			-- Deselect all buttons except the one that was clicked
			bagsFrame.optionsType[i]:SetChecked(false);
		else
			-- Set the clicked button as selected (checked)
			bagsFrame.optionsType[i]:SetChecked(true);
		end
	end

	-- Update the parent frame's title based on the clicked button's parentFrameText
	bagsFrame.title:SetText(self.parentFrameText);

	-- Assign the command associated with the clicked button to the parent frame
	bagsFrame.command = self.command;

	-- Set the afterRemove property for the parent frame based on the clicked button
	bagsFrame.afterRemove = afterRemove;
end

-- Construct a dynamic UI with features such as buttons for page navigation, a filter box for input,
-- and a refresh button, all integrated within the given parent frame
local function CreateOptionByParent(fromParent, flushFunc, bagType)
	-- Validate the parent frame argument; return nil if it's not provided
	if (fromParent == nil) then
		return nil;
	end

	-- Create and configure the title for the parent frame
	fromParent.title = fromParent:CreateFontString(fromParent:GetName() .. "Title", "ARTWORK");
	fromParent.title:SetFont("Fonts\\FRIZQT__.TTF", 12);
	fromParent.title:SetTextColor(1.0, 1.0, 1.0, 1);
	fromParent.title:SetText(UnBotBagsHeadFrameSetFontText(fromParent.raceName, fromParent.target, fromParent.activeText));
	fromParent.title:SetPoint("TOPLEFT", fromParent, "TOPLEFT", 6, -6);
	fromParent.title:SetShadowColor(0, 0, 0);
	fromParent.title:SetShadowOffset(1, -1);

	-- Add page display text to the parent frame
	fromParent.page = fromParent:CreateFontString(fromParent:GetName() .. "Page", "ARTWORK");
	fromParent.page:SetFont("Fonts\\FRIZQT__.TTF", 11);
	fromParent.page:SetTextColor(1.0, 1.0, 1.0, 1);
	fromParent.page:SetText("0-0");
	fromParent.page:SetPoint("CENTER", fromParent, "BOTTOMLEFT", 82, 18);
	fromParent.page:SetShadowColor(0, 0, 0);
	fromParent.page:SetShadowOffset(1, -1);

	-- Create a filter box for bagType == 0
	if bagType == 0 then
		-- Label for the filter box
		local label = fromParent:CreateFontString("FilterLabel", "ARTWORK", "GameFontNormal");
		label:SetPoint("TOPLEFT", fromParent, "TOPLEFT", 260, -7);
		--label:SetText("Filter:  ______________________________");
		label:SetText("Filter:");
		label:SetTextColor(0.0, 1.0, 0.0, 1.0);

		-- Configure the filter box
		local filterBox = CreateFrame("EditBox", "FilterBox", fromParent)
		filterBox:SetPoint("TOPLEFT", fromParent, "TOPLEFT", 300, -3)
		filterBox:SetSize(200, 20) -- Set size for the input box
		filterBox:SetAutoFocus(false) -- Prevent it from auto-focusing on creation

		-- Set the font for the text inside the EditBox
		filterBox:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE") -- Set font path, size, and style
		filterBox:SetTextColor(1, 1, 1, 1)                -- Set the text color (white in this case)

		-- Apply a border using SetBackdrop
		filterBox:SetBackdrop({
			bgFile = nil,                               -- No background file
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", -- Border texture
			tile = false,
			tileSize = 0,
			edgeSize = 12,                               -- Edge size controls border thickness
			insets = { left = 0, right = 0, top = 0, bottom = 0 } 
		})
		filterBox:SetBackdropBorderColor(1.0, 0.8, 0, 1.0) -- Golden border color
		filterBox:SetBackdropColor(0, 0, 0, 0)           -- Transparent background

		-- Hook into the parent frame's OnShow event to set focus dynamically
		fromParent:HookScript("OnShow", function()
			filterBox:SetFocus() -- Set focus when the parent frame is shown
		end)

		-- Scripts for text input handling
		filterBox:SetScript("OnTextChanged", function(self)
			local filterText = self:GetText()
			UnBotFilterIcons(filterText, fromParent) -- Pass the entered text to the filter function
		end)
		filterBox:SetScript("OnEnterPressed", function(self)
			self:ClearFocus() -- Clear focus when pressing Enter
		end)
		filterBox:SetScript("OnEscapePressed", function(self)
			self:SetText("") -- Clear the input box text
			self:ClearFocus() -- Remove focus when pressing Escape
		end)
	end

	-- Create "Previous Page" button
	local newFrame = CreateFrame("Button", "BGIconsFramePrev", fromParent, "UnBotBagsButtonTemplate");
	newFrame.Icon = newFrame:CreateTexture("BGIconsPrev", "BACKGROUND");
	newFrame.Icon:SetTexture([[Interface\BUTTONS\UI-SpellbookIcon-PrevPage-Up]]);
	newFrame.Icon:SetAllPoints(newFrame);
	newFrame.Icon:Show();
	newFrame:SetPushedTexture([[Interface\BUTTONS\UI-SpellbookIcon-PrevPage-Down]]);
	newFrame:SetHighlightTexture([[Interface\Buttons\UI-Common-MouseHilight]], "ADD");
	newFrame:Show();
	newFrame:SetPoint("BOTTOMLEFT", fromParent, "BOTTOMLEFT", 4, 3);
	newFrame.parentFrame = fromParent;
	newFrame:SetScript("OnClick", function() PickPrevOrNextButton(fromParent, true); end);
	newFrame:SetSize(28, 28);

	-- Create "Next Page" button
	newFrame = CreateFrame("Button", "BGIconsFrameNext", fromParent, "UnBotBagsButtonTemplate");
	newFrame.Icon = newFrame:CreateTexture("BGIconsNext", "BACKGROUND");
	newFrame.Icon:SetTexture([[Interface\BUTTONS\UI-SpellbookIcon-NextPage-Up]]);
	newFrame.Icon:SetAllPoints(newFrame);
	newFrame.Icon:Show();
	newFrame:SetPushedTexture([[Interface\BUTTONS\UI-SpellbookIcon-NextPage-Down]]);
	newFrame:SetHighlightTexture([[Interface\Buttons\UI-Common-MouseHilight]], "ADD");
	newFrame:Show();
	newFrame:SetPoint("BOTTOMLEFT", fromParent, "BOTTOMLEFT", 134, 3);
	newFrame.parentFrame = fromParent;
	newFrame:SetScript("OnClick", function() PickPrevOrNextButton(fromParent, false); end);
	newFrame:SetSize(28, 28);

	-- Create "Refresh" button
	newFrame = CreateFrame("Button", "BagsFrameFlush" .. fromParent:GetName(), fromParent, "UIPanelButtonTemplate");
	newFrame:SetText("Refresh");
	newFrame:SetWidth(56);
	newFrame:SetHeight(24);
	newFrame:Show();
	newFrame:SetPoint("BOTTOMLEFT", fromParent, "BOTTOMLEFT", 188, 6);
	newFrame:SetScript("OnClick", function()
		if flushFunc ~= nil then
			flushFunc(fromParent, fromParent.command);
			UnBotDisableAllFrameFlushButton();
		end
	end);

	-- Create "Close" button
	local closeFrame = CreateFrame("Button", "BGIconsFrameClose", fromParent, "UIPanelCloseButton");
	closeFrame:SetWidth(32);
	closeFrame:SetHeight(32);
	closeFrame:Show();
	closeFrame:SetPoint("TOPRIGHT", fromParent, "TOPRIGHT", 3, 3);
	closeFrame:SetScript("OnClick", function()
		RemoveFromUnBotFrame(fromParent);
		fromParent:Hide();
		fromParent:SetParent(nil);
	end);

	-- -- Enable keyboard interaction for the parent frame
	-- fromParent:EnableKeyboard(true);

	-- -- Set a script to handle keypress events
	-- fromParent:SetScript("OnKeyDown", function(self, key)
		-- if key == "ESCAPE" then
			-- if closeFrame:IsShown() then
				-- closeFrame:Click(); -- Simulate a mouse click on the close button
			-- end
		-- end
	-- end);
end

function PickPrevOrNextButton(parentFrame, isPrev)
	if parentFrame == nil then
		return
	end

	if isPrev then
		-- Navigate to the previous page
		if parentFrame.currentPage > 1 then
			parentFrame.currentPage = parentFrame.currentPage - 1
		end
	else
		-- Navigate to the next page
		if parentFrame.currentPage < math.ceil(#(parentFrame.dataGroup) / parentFrame.pageCount) then
			parentFrame.currentPage = parentFrame.currentPage + 1
		end
	end

	-- Refresh the frame to reflect the new page
	UpdateUnBotBagsFramePage(parentFrame)
end

-- Dynamically create a customizable frame that represents a collection of icons or items
function CreateIconsByUnBotBagsFrame(checkedIndex, name, bagType, afterRemove, datas, target, race, activeText, flushFunc,
									 command, getFunc)
	-- Validate if the frame can be added based on the given name
	if (CanAddToUnBotFrame(name) == false) then
		return nil;
	end

	-- Create the main frame
	local bagsFrame = CreateFrame("Frame", name, UIParent, "UnBotBagsFrame");
	-- Create the header frame
	local bagsHead = CreateFrame("Frame", bagsFrame:GetName() .. "Head", bagsFrame, "UnBotBagsFrameHeadFrame");
	bagsHead:Show();

	-- Set frame sizes based on bagType
	if (bagType == 1) then -- Bag list frame size
		bagsFrame:SetSize(830, 458);
		bagsHead:SetSize(830, 26);
	else -- All icons list frame size
		bagsFrame:SetSize(730, 458);
		bagsHead:SetSize(730, 26);
	end

	-- Assign various properties to the bagsFrame
	bagsFrame.bagsType = bagType;                                                      -- Define the type of bag (e.g., items or icons)
	bagsFrame.bgIconsGroup = CreateIconGroupByParent(bagsFrame, 5, 32, 18, 10, 0, 0, 40); -- Generate group of icons

	-- Set data group based on inputs or flush function
	if (bagsFrame.flushFunc ~= nil or datas == nil) then
		bagsFrame.dataGroup = {};
	else
		bagsFrame.dataGroup = datas; -- Use provided data if available
	end

	-- Additional frame properties
	bagsFrame.afterRemove = afterRemove;
	bagsFrame.target = target;
	bagsFrame.raceName = race;
	bagsFrame.activeText = activeText;
	bagsFrame.flushFunc = flushFunc;
	bagsFrame.getFunc = getFunc;

	-- Create options for the frame
	CreateOptionByParent(bagsFrame, flushFunc, bagType);

	-- If bagType is 1, create specific options for bag types
	if (bagType == 1) then
		CreateBagsTypeOptions(bagsFrame, checkedIndex);
	end

	-- Update the frame's page content
	UpdateUnBotBagsFramePage(bagsFrame);
	bagsFrame:Show(); -- Display the frame

	-- Register an event (e.g., for handling whispers)
	bagsFrame:RegisterEvent("CHAT_MSG_WHISPER");

	-- Add the frame to UnBot's management system
	AddToUnBotFrame(bagsFrame, name);

	-- Execute flush function if available
	if (bagsFrame.flushFunc ~= nil) then
		bagsFrame.flushFunc(bagsFrame, command);
		UnBotDisableAllFrameFlushButton(); -- Temporarily disable all flush buttons
	end

	-- Adjust the frame's scale according to configuration
	bagsFrame:SetScale(UnBotScaleConfig);

	-- Return the created bags frame
	return bagsFrame;
end

-- Close all the frames in the UnBotFrame.ShowedBags list by hiding them and removing their parent references,
-- ensuring they are no longer displayed or managed
function UnBotCloseAllBagsFrame()
	-- Loop through all frames in the ShowedBags list
	for i = 1, #(UnBotFrame.ShowedBags) do
		-- Hide the current bag frame to make it invisible
		UnBotFrame.ShowedBags[i]:Hide();
		-- Detach the current bag frame from its parent
		UnBotFrame.ShowedBags[i]:SetParent(nil);
	end

	-- Clear the ShowedBags list to remove all references
	UnBotFrame.ShowedBags = {};

	-- UnBotFrame.currentRecvLinkFrame = nil;
end

-- Pagination: The function calculates which items to display on the current page (startIndex).
-- Icon Management: For each slot on the page, it either sets the icon/label or clears them if the data is unavailable.
-- Dynamic Page Count: It computes the total pages (overIndex) based on the data size and items per page.
-- Label Update: Updates the page display with the current page and total pages.
function UpdateUnBotBagsFramePage(bagsFrame)
	-- If the frame is nil (does not exist), exit the function
	if (bagsFrame == nil) then
		return;
	end

	-- Calculate the starting index for the current page
	local startIndex = (bagsFrame.currentPage - 1) * bagsFrame.pageCount + 1;
	local groupIndex = 1;

	-- Loop through the items on the current page
	for i = startIndex, startIndex + bagsFrame.pageCount - 1 do
		-- If the current index exceeds the available data or no retrieval function is defined
		if (i > #(bagsFrame.dataGroup) or bagsFrame.getFunc == nil) then
			-- Set the icon texture to the disabled icon
			bagsFrame.bgIconsGroup[groupIndex].Icon:SetTexture(bagsFrame.disableIcon);
			-- Clear the associated properties for this icon
			bagsFrame.bgIconsGroup[groupIndex].bagsIcon = nil;
			bagsFrame.bgIconsGroup[groupIndex].iconIndex = 0;
			bagsFrame.bgIconsGroup[groupIndex].countLabel:SetText(" ");
		else
			-- Retrieve the icon and name for the current item using getFunc
			local icon, name = bagsFrame.getFunc(bagsFrame, i);
			bagsFrame.bgIconsGroup[groupIndex].Icon:SetTexture(icon);
			bagsFrame.bgIconsGroup[groupIndex].bagsIcon = name;
			bagsFrame.bgIconsGroup[groupIndex].iconIndex = bagsFrame.dataGroup[i][1];

			-- Display the quantity if applicable (for bagsType 1 with a quantity greater than 1)
			if (bagsFrame.bagsType == 1 and bagsFrame.dataGroup[i][7] ~= nil and bagsFrame.dataGroup[i][7] > 1) then
				bagsFrame.bgIconsGroup[groupIndex].countLabel:SetText(tostring(bagsFrame.dataGroup[i][7]));
			else
				bagsFrame.bgIconsGroup[groupIndex].countLabel:SetText(" ");
			end
		end

		-- Set the data index for the current group item
		bagsFrame.bgIconsGroup[groupIndex].dataIndex = i;
		groupIndex = groupIndex + 1; -- Move to the next group index
	end

	-- Calculate the total number of pages required
	local overIndex = math.ceil((#(bagsFrame.dataGroup)) / bagsFrame.pageCount);
	if (overIndex == 0) then
		overIndex = 1; -- Ensure at least one page is displayed
	end

	-- Update the page display text with the current page and total pages
	bagsFrame.page:SetText("Page " .. tostring(bagsFrame.currentPage) .. " of " .. tostring(overIndex));
end

-- Validation: Ensures the bagsFrame is valid and the index is within the range of the dataGroup.
-- Command Execution: Handles specific commands (e.g., SELL) with tailored conditions for items and spells.
-- Vendor Check for SELL: Verifies that a vendor is targeted and the item is sellable before proceeding.
-- Data Refresh: Provides a framework for refreshing uncached items, though the code is commented out for now.
-- Feedback: Uses chat messages and notifications for user feedback in different scenarios.
function ExecuteCommandByBagsItem(bagsFrame, index)
	-- Validate the input arguments to ensure the frame exists and the index is within bounds
	if (bagsFrame == nil or index < 1 or index > #(bagsFrame.dataGroup)) then
		return false; -- Return false if the validation fails
	end

	-- Check if a command exists and is not empty
	if (bagsFrame.command ~= nil and bagsFrame.command ~= "") then
		-- Special handling for the "SELL" command
		if (bagsFrame.command == UnBotExecuteCommand[67]) then -- SELL
			-- Ensure a vendor is targeted
			local targetName = UnitName("target");
			if (targetName == nil or targetName == "") then
				DisplayInfomation("You have no vendor targeted.");
				return false; -- Return false if no vendor is targeted
			end

			-- Check if the item is unsellable
			local itemSellPrice = bagsFrame.dataGroup[index][8];
			if (itemSellPrice == 0) then
				DisplayInfomation("Item is unsellable.");
				return false; -- Return false if the item cannot be sold
			end
		end

		-- Handling for "ITEMS" bag type
		if (bagsFrame.bagsType == 1) then        -- ITEMS
			local itemID = bagsFrame.dataGroup[index][2]; -- Retrieve the item ID
			local itemLink;
			-- Retrieve detailed item information
			_, itemLink, _, _, _, _, _, _, _, _, itemSellPrice = GetItemInfo(tostring(itemID));
			-- Send the command with the item's link via whisper chat
			SendChatMessage(bagsFrame.command .. itemLink, "WHISPER", nil, bagsFrame.target);

			-- Handling for "SPELLS" bag type
		elseif (bagsFrame.bagsType == 2) then    -- SPELLS
			local itemID = bagsFrame.dataGroup[index][2]; -- Retrieve the spell ID
			-- Send the command with the spell ID via whisper chat
			SendChatMessage(bagsFrame.command .. tostring(itemID), "WHISPER", nil, bagsFrame.target);
		end

		-- If no specific command is defined
	else
		-- Specific handling for "ITEMS" bag type
		if (bagsFrame.bagsType == 1) then
			-- Check if the item is flagged for refresh
			if (bagsFrame.dataGroup[index][5] == true) then -- FLAGGED FOR REFRESH
				local itemID = bagsFrame.dataGroup[index][2]; -- Retrieve the item ID

				-- Query the server for uncached item data (commented out here)
				--GameTooltip:SetHyperlink("item:" .. itemID .. ":0:0:0:0:0:0:0");
				--UpdateUnBotBagsFramePage(bagsFrame);
			end
		end
	end

	-- Return true to indicate the function executed successfully
	return true;
end

function RemoveByIndex(bagsFrame, index)
	-- Validate the input arguments to ensure the frame exists and the index is within bounds
	if (bagsFrame == nil or index < 1 or index > #(bagsFrame.dataGroup)) then
		return; -- Exit the function if the validation fails
	end

	-- Remove the item from the dataGroup table at the specified index
	table.remove(bagsFrame.dataGroup, index);

	-- Update the bags frame page after the removal to reflect the changes
	UpdateUnBotBagsFramePage(bagsFrame);
end

function FlushItemsToBags(bagsFrame, command)
	-- Validate the bagsFrame argument to ensure it exists
	if (bagsFrame == nil) then
		return; -- Exit the function if the frame is nil
	end

	-- Reset the data group for the frame
	bagsFrame.dataGroup = {};

	-- Assign the command to the frame or set it to an empty string if nil
	if (command ~= nil) then
		bagsFrame.command = command;
	else
		bagsFrame.command = "";
	end

	-- Update the frame's page contents to reflect the cleared data
	UpdateUnBotBagsFramePage(bagsFrame);

	-- Send a whisper message based on the type of bagsFrame
	if (bagsFrame.bagsType == 1) then  -- Bag type "items"
		SendChatMessage("c", "WHISPER", nil, bagsFrame.target);
	elseif (bagsFrame.bagsType == 2) then -- Bag type "spells"
		SendChatMessage("spells", "WHISPER", nil, bagsFrame.target);
	end

	-- Set the last flush tick to the current time
	bagsFrame.lastFlushTick = GetTime();
end

function GetIconFunc(bagsFrame, index)
	-- Retrieve the icon path using the GetIconPathByIndex function and the first element of the data group
	local icon = GetIconPathByIndex(bagsFrame.dataGroup[index][1]);

	-- Retrieve the name using the same function (assuming icon and name are derived from the same source)
	local name = GetIconPathByIndex(bagsFrame.dataGroup[index][1]);

	-- Return the retrieved icon path and name
	return icon, name;
end

function GetItemFunc(bagsFrame, index)
	-- Validate the index to ensure it is within the bounds of the dataGroup table
	if (index < 1 or index > #(bagsFrame.dataGroup)) then
		return nil, nil; -- Return nil values if the index is invalid
	end

	-- Retrieve the icon from the fourth element of the dataGroup at the given index
	local icon = bagsFrame.dataGroup[index][4];

	-- Retrieve the name from the third element of the dataGroup at the given index
	local name = bagsFrame.dataGroup[index][3];

	-- Return the icon and name
	return icon, name;
end

function IsFilterInfo(info)
	-- Check if the string "equipment" exists in the input 'info'
	local f1, f2 = string.find(info, "equipment");
	if (f1 ~= nil or f2 ~= nil) then
		print("equipment"); -- Print "equipment" if found
		return true;  -- Return true if "equipment" is detected
	end

	-- Check if the string "discard" exists in the input 'info'
	f1, f2 = string.find(info, "discard");
	if (f1 ~= nil or f2 ~= nil) then
		print("discard"); -- Print "discard" if found
		return true; -- Return true if "discard" is detected
	end

	-- Check if the string "sell" exists in the input 'info'
	f1, f2 = string.find(info, "sell");
	if (f1 ~= nil or f2 ~= nil) then
		print("sell"); -- Print "sell" if found
		return true; -- Return true if "sell" is detected
	end

	-- Check if the string "use" exists in the input 'info'
	f1, f2 = string.find(info, "use");
	if (f1 ~= nil or f2 ~= nil) then
		print("use"); -- Print "use" if found
		return true; -- Return true if "use" is detected
	end

	-- If none of the target strings are found, return false
	return false;
end

-- Parsie item quantity information from strings that follow a specific format, such as "[ItemName]x10"
function GetItemCountByLink(info)
	-- Find the position of the closing bracket "]" in the input string
	local x1, x2 = string.find(info, "]");
	if (x1 == nil or x2 == nil) then
		-- If no closing bracket is found, return a default count of 1
		return 1;
	end

	-- Find the position of "x" after the closing bracket "]"
	local numIndex1, numIndex2 = string.find(info, "x", x2);
	if (numIndex1 == nil or numIndex2 == nil) then
		-- If "x" is not found, return a default count of 1
		return 1;
	end

	-- Extract the numeric value following "x" using string.match
	local count = string.match(info, "%d+", numIndex2);

	-- Convert the extracted value to a number and return it
	return tonumber(count);
end

function RecvOnceItemToBags(bagsFrame, info)
	-- Validate the bagsFrame argument to ensure it exists
	if (bagsFrame == nil) then
		return; -- Exit the function if the frame is nil
	end

	-- Validate the info argument to ensure it is provided
	if (info == nil) then
		return; -- Exit the function if info is nil
	end

	-- Check if the input string contains "Hitem:"
	local i1, i2 = string.find(info, "Hitem:");
	if (i1 == nil and i2 == nil) then
		return; -- Exit if "Hitem:" is not found
	end

	-- Get the item count from the info string
	local itemCount = GetItemCountByLink(info);
	if (itemCount == nil) then
		itemCount = 1; -- Default item count to 1 if nil
	end

	-- Extract the item ID from the info string
	local itemID = tonumber(string.match(info, "%d+", i2));

	-- Variables for item properties
	local texture;
	local name;
	local itemQuality;
	local itemSellPrice;

	-- Retrieve item properties using GetItemInfo
	name, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, texture, itemSellPrice =
		GetItemInfo(info);

	local needQuery = false; -- Flag to determine if item needs server query

	-- Handle cases where name or texture information is unavailable
	if (name == nil or texture == nil) then
		-- Query the server for item data using GameTooltip
		GameTooltip:SetHyperlink("item:" .. itemID .. ":0:0:0:0:0:0:0");

		-- Default fallback values
		name = info;                                   -- Use the raw info string as the name
		texture = "Interface\\Icons\\INV_Misc_QuestionMark"; -- Placeholder icon
		needQuery = true;                              -- Mark the item for query
	end

	-- Create an item table with the gathered properties
	local item = {
		[1] = 0,      -- Placeholder index
		[2] = itemID, -- Item ID
		[3] = name,   -- Item name
		[4] = texture, -- Item texture (icon)
		[5] = needQuery, -- Query flag
		[6] = itemQuality, -- Item quality
		[7] = itemCount, -- Item count
		[8] = itemSellPrice -- Item sell price
	};

	-- Add the item table to the bagsFrame's dataGroup
	table.insert(bagsFrame.dataGroup, item);

	-- Update the item index within the dataGroup
	item[1] = #(bagsFrame.dataGroup);

	-- Update the frame's page to reflect the new item
	UpdateUnBotBagsFramePage(bagsFrame);
end

function RecvMuchSpellToBags(bagsFrame, info)
	-- Validate the bagsFrame argument to ensure it exists
	if (bagsFrame == nil) then
		return; -- Exit the function if the frame is nil
	end

	-- Validate the info argument and check if it contains "Hspell:"
	local i1, i2 = string.find(info, "Hspell:");
	if (i1 == nil or i2 == nil) then
		return; -- Exit if "Hspell:" is not found
	end

	-- Split the info string into parts starting from the position of "Hspell:"
	local textList = UnBotSplit(string.sub(info, i2), "Hspell:");
	local ids = {};

	-- Extract numerical spell IDs from the text list
	for i = 1, #textList do
		local idText = tonumber(string.match(textList[i], "%d+"));
		if (idText ~= nil) then
			table.insert(ids, tonumber(idText)); -- Add valid IDs to the ids table
		end
	end

	-- Process each spell ID and retrieve spell details
	for i = 1, #ids do
		local spellID = ids[i];
		-- Fetch spell details using GetSpellInfo
		local name, rankLV, texture, costMana, un3, costType, castTime, un6, distance = GetSpellInfo(spellID);

		if (name ~= nil) then
			-- Default to a normal icon if no texture is available
			if (texture == nil) then
				texture = bagsFrame.normalIcon;
			end

			-- Create a spell table with all relevant details
			local spell = {
				[1] = 0,      -- Placeholder index
				[2] = spellID, -- Spell ID
				[3] = name,   -- Spell name
				[4] = texture, -- Spell texture (icon)
				[5] = false,  -- Not flagged for query
				[6] = rankLV, -- Rank level of the spell
				[7] = tonumber(costType), -- Cost type (0, 1, 3)
				[8] = tonumber(costMana), -- Mana cost
				[9] = tonumber(castTime), -- Cast time
				[10] = tonumber(distance) -- Distance
			};

			-- Add the spell to the bagsFrame's dataGroup
			table.insert(bagsFrame.dataGroup, spell);
			-- Update the index for the spell within the dataGroup
			spell[1] = #(bagsFrame.dataGroup);
		else
			-- Display an error message if spell details cannot be retrieved
			DisplayInfomation("Recv spell id " .. tostring(spellID) .. " error.");
		end
	end

	-- Refresh the frame page to reflect the updated data
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
		-- Restore the original page
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

	-- Save the current page before applying a filter (only if not already saved)
	if not bagsFrame.originalPage then
		bagsFrame.originalPage = bagsFrame.currentPage
	end

	filterText = string.lower(filterText) -- Case-insensitive matching
	local filteredDataGroup = {}

	-- Apply filtering logic
	for i, texturePath in ipairs(UnBotCommandIconsPath) do
		if string.find(string.lower(texturePath), filterText) then
			table.insert(filteredDataGroup, { [1] = i }) -- Wrap index for compatibility
		end
	end

	-- Update dataGroup with filtered results
	bagsFrame.dataGroup = filteredDataGroup

	-- Reset to the first page for filtered results
	bagsFrame.currentPage = 1

	-- Refresh the frame dynamically
	UpdateUnBotBagsFramePage(bagsFrame)
end
