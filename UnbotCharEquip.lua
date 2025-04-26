local chatListenerMainBag = nil -- Global declaration ensures it persists across

local playerT = ""
-- Define the mapping for slots
local slotMap = {
    ["INVTYPE_HEAD"] = 1,
    ["INVTYPE_NECK"] = 2,
    ["INVTYPE_SHOULDER"] = 3,
    ["INVTYPE_CHEST"] = 4,
    ["INVTYPE_WAIST"] = 5,
    ["INVTYPE_LEGS"] = 6,
    ["INVTYPE_FEET"] = 7,
    ["INVTYPE_WRIST"] = 8,
    ["INVTYPE_HAND"] = 9,
    ["INVTYPE_FINGER"] = 10,
    ["INVTYPE_TRINKET"] = 12,
    ["INVTYPE_BACK"] = 14,
    ["INVTYPE_WEAPON"] = 15,
    ["INVTYPE_SHIELD"] = 16,
    ["INVTYPE_2HWEAPON"] = 15,
    ["INVTYPE_RANGED"] = 17,
    ["INVTYPE_RANGEDRIGHT"] = 17,
    ["INVTYPE_OFFHAND"] = 16,
    ["INVTYPE_MAINHAND"] = 15
}
local itemData = {}

-- Define slot names
local slotNames = {
    [1] = "Head",
    [2] = "Neck",
    [3] = "Shoulder",
    [4] = "Shirt",
    [5] = "Chest",
    [6] = "Waist",
    [7] = "Legs",
    [8] = "Feet",
    [9] = "Wrist",
    [10] = "Hands",
    [11] = "Finger 1",
    [12] = "Finger 2",
    [13] = "Trinket 1",
    [14] = "Trinket 2",
    [15] = "Back",
    [16] = "Main Hand",
    [17] = "Off Hand",
    [18] = "Ranged"
}

-- Table to store wearable items by rows
local wearableItems = {}

-- We don't want to requery on every eq change
local equipmentLoaded = false
-- Table to store temporary affected slots on swap
local equipmentTable = {}
tempSlots = {}

--Dubug functions, not used
local function PrintTableContents(label, tbl)
    print(label)
    if tbl then
        for key, value in pairs(tbl) do
            print("  ", key, value)
        end
    else
        print("  Table is nil")
    end
end

--Fill equipment table from inspect unit
local function PrepareEquipmentTable()
    if not equipmentLoaded then
        for slotID = 1, 18 do
            if slotID ~= 4 then -- Skip Shirt slot (Slot ID 4)
                --GameTooltip:SetInventoryItem(playerT, slotID) -- Force tooltip cache
                local itemLink = GetInventoryItemLink(playerT, slotID)
                local itemTexture = GetInventoryItemTexture(playerT, slotID)
                local itemID = itemLink and string.match(itemLink, "Hitem:(%d+):")

                --print(itemLink, itemTexture, itemID) -- Debug output
                equipmentTable[slotID] = {
                    itemID = itemID,
                    itemLink = itemLink,
                    itemTexture = itemTexture,
                }
            end
        end
        -- Load the equipment data only once
        equipmentLoaded = true
    end

    return equipmentTable
end

--Refresh main frame content (left char side)
local function RefreshMainFrameContent()
    -- Prepare equipment data
    equipmentData = PrepareEquipmentTable()

    -- Populate equipment slots dynamically
    for slotID, slotData in pairs(equipmentData) do
        -- Retrieve the pre-created slot
        local slot = content.slots[slotID]

        if slot then
            -- Update the slot's icon
            slot.icon:SetTexture(slotData.itemTexture or "Interface/Icons/INV_Misc_QuestionMark")

            -- Update the slot's item text
            slot.itemText:GetFontString():SetText(slotData.itemLink or "Empty")

            -- Update slot-specific data for functionality
            slot.itemLink = slotData.itemLink -- Update the tooltip's itemLink
            slot.itemID = slotData.itemID     -- Store the itemID for reference

            -- Update tooltip functionality
            slot.itemText:SetScript("OnEnter", function(self)
                if slot.itemLink then
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetHyperlink(slot.itemLink)
                    GameTooltip:Show()
                end
            end)
            slot.itemText:SetScript("OnLeave", function() GameTooltip:Hide() end)

            -- Update right-click unequip action
            slot.itemText:SetScript("OnClick", function(self, button)
                if UnBotTargetInspectFrame and UnBotTargetInspectFrame:IsShown() then
                    if button == "LeftButton" and slot.itemLink then
                        local itemID = slot.itemID
                        tempSlots[slotID] = {
                            itemID = tonumber(itemID),
                            itemLink = slot.itemLink,
                            itemTexture = GetItemIcon(itemID),
                        }
                        -- Send unequip command to playerbot
                        SendChatMessage("ue " .. slot.itemLink, "WHISPER", nil, UnitName(playerT))
                        updateFrame:Show()
                        -- Reset the slot dynamically when unequipped
                        slot.icon:SetTexture("Interface/Icons/INV_Misc_QuestionMark")
                        slot.itemText:GetFontString():SetText("Empty")
                        slot.itemLink = nil
                        slot.itemID = nil

                        -- Clear the equipmentTable for this slot
                        equipmentTable[slotID] = nil
                        --print("Slot " .. slotID .. " cleared in equipmentTable.")
                    end
                end
            end)
        end
    end

    -- Reset unused slots (if not in equipmentData)
    for slotID, slot in pairs(content.slots) do
        if not equipmentData[slotID] then
            -- Reset icon to default texture
            slot.icon:SetTexture("Interface/Icons/INV_Misc_QuestionMark")
            slot.itemText:GetFontString():SetText("Empty")
            slot.itemLink = nil
            slot.itemID = nil
        end
    end
end

--Refresh Bag frame with new content
local function UpdateBagFrame(message, bagFrame)
    -- Validate the input message
    if not message or message == "" then
        print("Error: Message is nil or empty")
        return
    end

    -- Parse the incoming message and populate wearableItems
    for i = 1, 17 do
        wearableItems[i] = {} -- Each row has up to 5 slots
    end

    -- Extract item IDs from the message
    for itemID in string.gmatch(message, "|Hitem:(%d+):") do
        local numericItemID = tonumber(itemID)

        -- Fetch item data
        local itemName, itemLink, _, _, _, _, _, _, itemEquipLoc = GetItemInfo(numericItemID)

        if itemLink and slotMap[itemEquipLoc] then
            local rowIndex = slotMap[itemEquipLoc]
            local row = wearableItems[rowIndex]

            -- Add items to the corresponding row, up to 5 slots per row
            if #row < 5 then
                table.insert(row, {
                    itemLink = itemLink,
                    itemName = itemName,
                    itemEquipLoc = itemEquipLoc
                })
            end
        else
            -- Attempt to cache uncached items (optional)
            GameTooltip:SetHyperlink("item:" .. numericItemID)
        end
    end

    for rowIndex, row in ipairs(wearableItems) do
        local rowText = "Row " .. rowIndex .. ": "
        for colIndex, itemData in ipairs(row) do
            if itemData.itemLink then
                rowText = rowText .. "[" .. itemData.itemLink .. "] "
            else
                rowText = rowText .. "[Empty] "
            end
        end
    end

    -- Update the existing slots
    for rowIndex = 1, 17 do
        local row = wearableItems[rowIndex] or {}

        for colIndex = 1, 5 do
            local slotIndex = (rowIndex - 1) * 5 + colIndex -- Unique index for each slot
            itemData = row[colIndex] or {}                  -- Use empty data if no item exists

            -- Reference the existing slot
            local slot = bagFrame.slots[slotIndex]
            if slot then
                -- Update the slot texture
                local slotTexture = slot:GetRegions() -- Retrieve the slot's existing texture
                if itemData.itemLink then
                    --print("Found item in bag: ", itemData.itemLink)
                    local _, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(itemData.itemLink)
                    if itemTexture then
                        slotTexture:SetTexture(itemTexture)                             -- Use item texture
                    else
                        slotTexture:SetTexture("Interface/Icons/INV_Misc_QuestionMark") -- Default for uncached items
                    end

                    -- Update tooltip functionality
                    --local itemID = string.match(itemData.itemLink, "Hitem:(%d+):")
                    local capturedItemLink = itemData and itemData.itemLink -- Capture the link for this specific slot
                    slot:SetScript("OnEnter", function(self)
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        if capturedItemLink then
                            --print("Setting hyperlink for: ", capturedItemLink)
                            GameTooltip:SetHyperlink(capturedItemLink)
                        else
                            GameTooltip:AddLine("Empty Slot")
                        end
                        GameTooltip:Show()
                    end)
                    slot:SetScript("OnLeave", function(self)
                        GameTooltip:Hide()
                    end)

                    -- Add left-click functionality
                    slot:SetScript("OnMouseUp", function(self, button)
                        if button == "LeftButton" then
                            -- Reset highlight effect
                            slotTexture:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
                            slotTexture:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)

                            -- Retrieve slotID from the slot object
                            local slotID = self.slotID
                            if not slotID then
                                print("Error: slotID is not defined for this slot.")
                                return
                            end

                            -- Handle item slot
                            if capturedItemLink then
                                local itemID = string.match(capturedItemLink, "Hitem:(%d+):")
                                if itemID then
                                    -- Send equip command to playerbot
                                    SendChatMessage("e " .. capturedItemLink, "WHISPER", nil, UnitName(playerT))
                                    updateFrame:Show()
                                    -- Push the updated slot data back into equipmentTable
                                    if tempSlots[slotID] then
                                        --PrintTableContents("Before Push Back - tempSlots[slotID]:", tempSlots[slotID])
                                        equipmentTable[slotID] = tempSlots[slotID] -- Push back the data
                                        tempSlots[slotID] = nil                    -- Remove from temporary storage
                                        --PrintTableContents("After Push Back - equipmentTable[slotID]:", equipmentTable[slotID])
                                        --print("Successfully equipped item in slotID:", slotID)
                                    else
                                        -- Debug for missing tempSlots data
                                        --print("No data found in tempSlots for slotID:", slotID)

                                        -- Recreate the item using slot data as a fallback
                                        --print("Slot Data for Recreation - itemID:", slot.itemID, "itemLink:", slot.itemLink)
                                        equipmentTable[slotID] = {
                                            itemID = tonumber(itemID),                 -- Use slot.itemID as fallback
                                            itemLink = select(2, GetItemInfo(itemID)), -- Dynamically fetch item link
                                            itemTexture = GetItemIcon(itemID),         -- Fetch item texture dynamically
                                        }

                                        -- Debug recreated item
                                        --PrintTableContents("Recreated item in equipmentTable[slotID]:", equipmentTable[slotID])
                                        --print("Item recreated successfully for slotID:", slotID)
                                    end
                                else
                                    print("Error: Unable to parse itemID from itemLink.")
                                end
                            else
                                -- Handle empty slot case
                                print("No item data available for slotID:", slotID)
                            end
                        end
                    end)
                else
                    -- Reset to default texture for empty slots
                    slotTexture:SetTexture("Interface/Buttons/UI-EmptySlot")

                    -- Reset tooltip
                    slot:SetScript("OnEnter", function(self)
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:AddLine("Empty Slot")
                        GameTooltip:Show()
                    end)
                    slot:SetScript("OnLeave", function(self)
                        GameTooltip:Hide()
                    end)

                    -- Add right-click functionality for empty slots
                    slot:SetScript("OnMouseUp", function(self, button)
                        if button == "LeftButton" then
                            -- Handle any additional actions for empty slots here
                        end
                    end)
                end
            end
        end
    end

    updateFrame:Hide()
end

--Main frame (Start)
function ToggleCharacterFrame()
    -- Check if the target is a player
    if not UnitIsPlayer("target") then
        print("The selected target is not a player!")
        return
    end
    -- Can't target yoursself
    if UnitIsUnit("target", "player") then
        print("Can't target yourself!")
        return
    end

    playerT = UnitName("target")
    -- Forces data retrieval for the target
    NotifyInspect(playerT)

    -- Ensure frame exists on 1st run
    if not UnBotTargetInspectFrame then
        -- Create the main frame (only once)
        UnBotTargetInspectFrame = CreateFrame("Frame", "UnBotTargetInspectFrame", UIParent)
        UnBotTargetInspectFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")
        UnBotTargetInspectFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
        UnBotTargetInspectFrame:SetScript("OnEvent", function(self, event, unit)
            if event == "UNIT_INVENTORY_CHANGED" then
                if unit == "target" then
                    --print("Inventory has changed for", playerT)
                    ToggleCharacterFrame() -- Refresh the frame when inventory changes
                end
            elseif event == "PLAYER_TARGET_CHANGED" then
                print("Target changed!")
                -- Check if there is a valid target
                local targetName = UnitName("target")
                if not targetName or UnitIsUnit("target", "player") or not UnitIsPlayer("target") then
                    print("Wrong target selected!") -- Unified message for invalid targets
                    equipmentLoaded = false
                    equipmentTable = {}
                    tempSlots = {}
                    UnBotTargetInspectFrame:UnregisterEvent("PLAYER_TARGET_CHANGED")
                    UnBotTargetInspectFrame:UnregisterEvent("UNIT_INVENTORY_CHANGED")
                    UnBotTargetInspectFrame:Hide()
                    return
                end
                equipmentLoaded = false
                equipmentTable = {}
                tempSlots = {}
                -- Ensure we are listening for the new target's inventory changes
                UnBotTargetInspectFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")
                ToggleCharacterFrame() -- Refresh UI as needed
            end
        end)

        UnBotTargetInspectFrame:SetSize(650, 785)
        UnBotTargetInspectFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
        UnBotTargetInspectFrame:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        UnBotTargetInspectFrame:SetBackdropColor(0, 0, 0, 1)

        -- Add close button
        local closeButton = CreateFrame("Button", nil, UnBotTargetInspectFrame, "UIPanelCloseButton")
        closeButton:SetPoint("TOPRIGHT", UnBotTargetInspectFrame, "TOPRIGHT")
        closeButton:SetScript("OnClick", function()
            equipmentLoaded = false -- Reset the equipmentLoaded flagg
            equipmentTable = {}
            tempSlots = {}
            UnBotTargetInspectFrame:UnregisterEvent("PLAYER_TARGET_CHANGED")
            UnBotTargetInspectFrame:UnregisterEvent("UNIT_INVENTORY_CHANGED")
            UnBotTargetInspectFrame:Hide()
        end)

        -- Title and labels
        local titleText = UnBotTargetInspectFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        titleText:SetPoint("TOP", UnBotTargetInspectFrame, "TOP", 0, -10)
        UnBotTargetInspectFrame.titleText = titleText

        local classText = UnBotTargetInspectFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        classText:SetPoint("TOP", titleText, "BOTTOM", 0, -10)
        UnBotTargetInspectFrame.classText = classText

        local levelText = UnBotTargetInspectFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        levelText:SetPoint("TOP", classText, "BOTTOM", 0, -5)
        UnBotTargetInspectFrame.levelText = levelText

        local leftLabel = UnBotTargetInspectFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        leftLabel:SetPoint("TOP", UnBotTargetInspectFrame, "TOP", -250, -50)
        leftLabel:SetText("Player equipment")

        local rightLabel = UnBotTargetInspectFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        rightLabel:SetPoint("TOP", UnBotTargetInspectFrame, "TOP", 150, -50)
        rightLabel:SetText("Items in bags")

        -- Create the "Updating..." frame
        updateFrame = CreateFrame("Frame", "UpdateFrame", UnBotTargetInspectFrame)
        updateFrame:SetSize(250, 150)
        updateFrame:SetPoint("CENTER", UnBotTargetInspectFrame, "CENTER", 0, 0) -- Center it within the main frame
        updateFrame:SetFrameStrata("HIGH")                                      -- Set the strata so it appears above other frames
        updateFrame:SetFrameLevel(20)                                           -- Increase the frame level to ensure it overlays
        -- Add a background and border
        updateFrame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        -- Add text to the Upd frame
        local updateText = updateFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge") -- Change to a larger font
        updateText:SetPoint("CENTER", updateFrame, "CENTER", 0, 0)
        updateText:SetText("Updating...")
    end

    --Re-register event if needed
    if not UnBotTargetInspectFrame:IsEventRegistered("UNIT_INVENTORY_CHANGED") then
        UnBotTargetInspectFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")
    end
    if not UnBotTargetInspectFrame:IsEventRegistered("PLAYER_TARGET_CHANGED") then
        UnBotTargetInspectFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    end

    --Show main frame
    UnBotTargetInspectFrame:Show()
    -- Show the update frame (loading of items is in progress)
    updateFrame:Show()

    -- Update title and target details
    UnBotTargetInspectFrame.titleText:SetText("Inspecting: " .. UnitName(playerT))
    local targetClass, _ = UnitClass(playerT)
    UnBotTargetInspectFrame.classText:SetText("Class: " .. targetClass)
    UnBotTargetInspectFrame.levelText:SetText("Level: " .. UnitLevel(playerT))

    -- Create content area for player equipment
    if not content then
        content = CreateFrame("Frame", nil, UnBotTargetInspectFrame)
        content:SetSize(460, 700)
        content:SetPoint("TOPLEFT", UnBotTargetInspectFrame, "TOPLEFT", 10, -80)

        -- Ensure full opacity for the content frame
        content:SetAlpha(1)                          -- Fully opaque
        content:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8", -- Solid background
            edgeFile = nil,                          -- No border unless required
            tile = false,
            edgeSize = 0,                            -- No edges
            insets = { left = 0, right = 0, top = 0, bottom = 0 }
        })
        content:SetBackdropColor(0, 0, 0, 1) -- Solid black background

        -- Initialize slots table to store pre-created slots
        content.slots = {}

        local validSlotIndex = 0 -- Tracks the visual index of valid slots (excluding skipped ones)
        for slotID = 1, 18 do
            local slotName = slotNames[slotID]

            -- Skip specific slots (e.g., "Shirt" at slotID = 4)
            if slotID ~= 4 and slotName then
                validSlotIndex = validSlotIndex + 1 -- Increment for valid slots only
                local slot = {}
                -- Slot name
                slot.slotNameText = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                slot.slotNameText:SetPoint("TOPLEFT", content, "TOPLEFT", 5, -85 - (validSlotIndex * 40) + 90 + 15)
                slot.slotNameText:SetText(slotName)
                slot.slotNameText:SetAlpha(1) -- Ensure text is fully opaque

                -- Slot icon
                slot.icon = content:CreateTexture(nil, "ARTWORK")
                slot.icon:SetSize(30, 30)
                slot.icon:SetPoint("TOPLEFT", content, "TOPLEFT", 75, -55 - (validSlotIndex * 40) + 90)
                slot.icon:SetTexture("Interface/Icons/INV_Misc_QuestionMark")
                slot.icon:SetAlpha(1) -- Ensure icon is fully opaque

                -- Item text button
                slot.itemText = CreateFrame("Button", nil, content)
                slot.itemText:SetSize(250, 40)
                slot.itemText:SetPoint("TOPLEFT", content, "TOPLEFT", 115, -55 - (validSlotIndex * 40) + 90)
                slot.itemText:SetText("Empty")
                slot.itemText:SetNormalFontObject(GameFontHighlight)
                slot.itemText:SetHighlightFontObject(GameFontNormal)
                slot.itemText:GetFontString():SetPoint("LEFT", slot.itemText, "LEFT", 5, 0)
                slot.itemText:SetAlpha(1) -- Ensure button text is fully opaque

                -- Tooltip functionality
                slot.itemText:SetScript("OnEnter", function(self)
                    if slot.itemLink then
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:SetHyperlink(slot.itemLink)
                        GameTooltip:Show()
                    end
                end)
                slot.itemText:SetScript("OnLeave", function() GameTooltip:Hide() end)

                -- Left-click unequip action
                slot.itemText:RegisterForClicks("LeftButtonUp")
                slot.itemText:SetScript("OnClick", function(self, button)
                    if button == "LeftButton" and slot.itemLink then
                        local itemID = slot.itemID
                        SendChatMessage("ue " .. slot.itemLink, "WHISPER", nil, UnitName(playerT))
                        slot.icon:SetTexture("Interface/Icons/INV_Misc_QuestionMark")
                        slot.itemText:GetFontString():SetText("Empty")
                    end
                end)

                -- Store the slot in the slots table
                content.slots[slotID] = slot
            else
                print("Skipping slotID:", slotID, "due to exclusion.")
            end
        end
    end

    -- Refresh content (left char side)
    RefreshMainFrameContent()

    -- Create the BagFrame (right side)
    if not bagFrame then
        -- Create the frame
        bagFrame = CreateFrame("Frame", "BagFrame", UnBotTargetInspectFrame)
        bagFrame:SetSize(390, 700)                                                   -- Set dimensions of the subframe
        bagFrame:SetPoint("TOPLEFT", UnBotTargetInspectFrame, "TOPRIGHT", -400, -80) -- Position relative to the main frame

        -- Ensure the frame is fully opaque
        bagFrame:SetAlpha(1)                         -- Fully opaque
        bagFrame:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8", -- Solid background texture
            edgeFile = nil,                          -- No border unless required
            tile = false,
            edgeSize = 0,                            -- No edges
            insets = { left = 0, right = 0, top = 0, bottom = 0 }
        })
        bagFrame:SetBackdropColor(0, 0, 0, 1) -- Solid black background
    end
    bagFrame:Show()

    -- Initialize the slots table if it doesn't exist
    if not bagFrame.slots then
        bagFrame.slots = {}
    end

    -- Loop through rows and columns to create the 17 x 5 grid
    for rowIndex = 1, 17 do
        for colIndex = 1, 5 do
            local slotIndex = (rowIndex - 1) * 5 + colIndex -- Unique index for each slot
            if not bagFrame.slots[slotIndex] then
                -- Create a slot in the BagFrame
                local slot = CreateFrame("Button", nil, bagFrame)
                slot:SetSize(30, 30) -- Adjust size of each slot
                slot:SetPoint("TOPLEFT", bagFrame, "TOPLEFT", 150 + (colIndex - 1) * 45, -10 - (rowIndex - 1) * 40)
                slot:EnableMouse(true)

                -- Add a default texture to the slot
                local slotTexture = slot:CreateTexture(nil, "BACKGROUND")
                slotTexture:SetAllPoints()
                slotTexture:SetTexture("Interface/Buttons/UI-EmptySlot") -- Generic empty slot texture

                -- Tooltip functionality for empty slots
                slot:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:AddLine("Empty Slot")
                    GameTooltip:Show()
                end)
                slot:SetScript("OnLeave", function(self)
                    GameTooltip:Hide()
                end)

                -- Add left-click functionality
                slot:SetScript("OnMouseDown", function(self, button)
                    if button == "LeftButton" then
                        -- Highlight effect for left-click
                        slotTexture:SetPoint("TOPLEFT", self, "TOPLEFT", 2, -2)
                        slotTexture:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 2)
                    end
                end)

                slot:SetScript("OnMouseUp", function(self, button)
                    if button == "LeftButton" then
                        -- Reset highlight effect
                        slotTexture:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
                        slotTexture:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
                    end
                end)

                slot.rowIndex = rowIndex
                slot.slotID = (rowIndex >= 4) and (rowIndex + 1) or rowIndex -- Map rowIndex to slotID

                -- Store the slot for future reuse
                bagFrame.slots[slotIndex] = slot
            end
        end
    end

    -- Initialize the whisper delay frame
    if not whisperDelayFrame then
        whisperDelayFrame = CreateFrame("Frame")
        whisperDelayFrame.timeElapsed = 0
        whisperDelayFrame:SetScript("OnUpdate", nil) -- Initially disabled
    end

    -- Accumulate playerbot inventory whispers in a table
    accumulatedMessages = accumulatedMessages or {}

    -- Create or manage the chat listener for BagFrame
    if not chatListenerMainBag then
        chatListenerMainBag = CreateFrame("Frame", nil, UnBotTargetInspectFrame)
    end
    if chatListenerMainBag:IsEventRegistered("CHAT_MSG_WHISPER") then
        chatListenerMainBag:UnregisterEvent("CHAT_MSG_WHISPER")
    end
    chatListenerMainBag:RegisterEvent("CHAT_MSG_WHISPER")

    chatListenerMainBag:SetScript("OnEvent", function(_, _, message, sender)
        -- Ensure the main frame is visible before handling messages
        if UnBotTargetInspectFrame and UnBotTargetInspectFrame:IsShown() then
            -- Whisper filtering (maybe there will be more  than 3)
            if sender == UnitName(playerT) and string.match(message, "%[.+%]") and not string.find(message, "Equipping") and not string.find(message, "unequipped") then
                -- Accumulate each whisper message
                table.insert(accumulatedMessages, message)
                -- Start or restart the whisper delay timer
                if whisperDelayFrame:GetScript("OnUpdate") == nil then
                    whisperDelayFrame.timeElapsed = 0 -- Reset timer
                    whisperDelayFrame:SetScript("OnUpdate", function(self, elapsed)
                        self.timeElapsed = self.timeElapsed + elapsed
                        if self.timeElapsed >= 1 then -- 1-second timeout
                            -- Combine accumulated messages into a single string
                            local combinedMessage = table.concat(accumulatedMessages, " ")
                            -- UpdateBagFrame function placeholder
                            UpdateBagFrame(combinedMessage, bagFrame)
                            -- Clear accumulated messages
                            accumulatedMessages = {}
                            -- Stop the timer
                            self.timeElapsed = 0
                            self:SetScript("OnUpdate", nil)
                        end
                    end)
                end
            end
        end
    end)

    -- Trigger bot command to fetch bag items from whisper reply
    SendChatMessage("c", "WHISPER", nil, UnitName(playerT))
end
