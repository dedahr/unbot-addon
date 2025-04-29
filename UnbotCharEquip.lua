local chatBotInventoryListener = nil
--Current target local variable
local playerT = ""
-- Item type mapping for char slots
local slotMap = {
    ["INVTYPE_HEAD"] = 1,
    ["INVTYPE_NECK"] = 2,
    ["INVTYPE_SHOULDER"] = 3,
    ["INVTYPE_CHEST"] = 5,
    ["INVTYPE_ROBE"] = 5,
    ["INVTYPE_WAIST"] = 6,
    ["INVTYPE_LEGS"] = 7,
    ["INVTYPE_FEET"] = 8,
    ["INVTYPE_WRIST"] = 9,
    ["INVTYPE_HAND"] = 10,
    ["INVTYPE_FINGER"] = 11,
    ["INVTYPE_TRINKET"] = 13,
    ["INVTYPE_CLOAK"] = 15,
    ["INVTYPE_WEAPON"] = 16,
    ["INVTYPE_WEAPONMAINHAND"] = 16,
    ["INVTYPE_2HWEAPON"] = 16,
    ["INVTYPE_SHIELD"] = 17,
    ["INVTYPE_WEAPONOFFHAND"] = 17,
    ["INVTYPE_RANGED"] = 18,
    ["INVTYPE_RANGEDRIGHT"] = 18,
    ["INVTYPE_THROWN"] = 18,
    ["INVTYPE_RELIC"] = 18,
    ["INVTYPE_HOLDABLE"] = 18,
}
local itemData = {}

-- Define slot names (char slots)
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
local equipmentTable = {}
tempSlots = {} -- Table to store temporary affected slots on swap

-- Debug function for ptinting table contents (not used except for debugging)
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

--Delay frame for update wait
function WaitAndCheckFrameHidden(frame, timeout, callback)
    local startTime = GetTime() -- Record the start time

    -- Create a temporary frame for OnUpdate tracking
    local checkerFrame = CreateFrame("Frame")
    checkerFrame:SetScript("OnUpdate", function(self, elapsed)
        if not frame:IsShown() then
            -- Frame is hidden, call the callback with true
            callback(true)
            self:SetScript("OnUpdate", nil) -- Stop the OnUpdate script
            self:Hide()                     -- Hide the tracker frame
        elseif GetTime() - startTime >= timeout then
            -- Timeout reached, call the callback with false
            callback(false)
            self:SetScript("OnUpdate", nil) -- Stop the OnUpdate script
            self:Hide()                     -- Hide the tracker frame
        end
    end)

    checkerFrame:Show() -- Activate the frame to start OnUpdate tracking
end

--Inspect char item table
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

--Inspect char bag items
local function UpdateBagFrame(message, bagFrame)
    -- Validate the input message
    if not message or message == "" then
        print("Error: Message is nil or empty")
        return
    end
    --print("Received message: ", message)
    -- Parse the incoming message and populate wearableItems
    for i = 1, 18 do
        wearableItems[i] = {} -- Each row has up to 5 slots
    end

    for itemID in string.gmatch(message, "|Hitem:(%d+):") do
        local numericItemID = tonumber(itemID)

        -- Fetch item data
        local itemName, itemLink, _, itemLevel, _, _, _, _, itemEquipLoc = GetItemInfo(numericItemID)

        --print(itemName, itemLink, itemEquipLoc, slotMap[itemEquipLoc], itemLevel) -- Debug output

        if itemLink and slotMap[itemEquipLoc] then
            local rowIndex = slotMap[itemEquipLoc]
            local row = wearableItems[rowIndex]

            -- Add items to the corresponding row, up to 5 slots per row
            if #row < 5 then
                table.insert(row, {
                    itemLink = itemLink,
                    itemName = itemName,
                    itemEquipLoc = itemEquipLoc,
                    itemLevel = itemLevel -- Include the item level for sorting
                })

                -- Sort the row by item level in descending order
                table.sort(row, function(a, b)
                    return (a.itemLevel or 0) > (b.itemLevel or 0) -- Handle cases where itemLevel might be nil
                end)
            end
        else
            -- Attempt to cache uncached items (optional)
            --GameTooltip:SetHyperlink("item:" .. numericItemID)
        end
    end

    -- Update the existing slots
    for rowIndex = 1, 18 do
        if (rowIndex ~= 4) then
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
                        local _, _, _, itemLevel, _, _, _, _, _, itemTexture = GetItemInfo(itemData.itemLink)
                        if itemTexture then
                            slotTexture:SetTexture(itemTexture) -- Use item texture
                            slot.slotIlvl:SetText(itemLevel)
                        else
                            slotTexture:SetTexture("Interface/Icons/INV_Misc_QuestionMark") -- Default for uncached items
                        end

                        -- Update tooltip
                        --local itemID = string.match(itemData.itemLink, "Hitem:(%d+):")
                        local capturedItemLink = itemData and
                            itemData.itemLink -- Capture the link for this specific slot
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
                        --Left Button
                        slot:SetScript("OnMouseUp", function(self, button)
                            if button == "LeftButton" then
                                slotTexture:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
                                slotTexture:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)

                                local slotID = self.slotID
                                if not slotID then
                                    print("Error: slotID is not defined for this slot.")
                                    return
                                end
                                SendChatMessage("e " .. capturedItemLink, "WHISPER", nil, UnitName(playerT))
                                updateFrame:Show()
                                WaitAndCheckFrameHidden(updateFrame, 5, function(result)
                                    if not result then
                                        updateFrame:Hide()
                                        print("Equip failed!")
                                        BotEquippmentManagerMainFrame()
                                        return
                                    end
                                end)
                                if capturedItemLink then
                                    local itemID = string.match(capturedItemLink, "Hitem:(%d+):")

                                    if itemID then
                                        if tempSlots[slotID] then
                                            equipmentTable[slotID] = tempSlots[slotID]
                                            tempSlots[slotID] = nil
                                        else
                                            equipmentTable[slotID] = {
                                                itemID = tonumber(itemID),
                                                itemLink = select(2, GetItemInfo(itemID)),
                                                itemTexture = GetItemIcon(itemID),
                                            }
                                        end
                                    else
                                        print("Error: Unable to parse itemID from itemLink.")
                                    end
                                else
                                    print("No item data available for slotID:", slotID)
                                end
                                -- send to 2nd slot for rings trinkets and weapons (we can't do that yet as PB doesnt have that command and all is RND thing)
                                -- workaround is to unequip both slots and equip with left click 1st slot and right click 2nd
                            elseif button == "RightButton" and (rowIndex == 11 or rowIndex == 13 or rowIndex == 16) then
                                slotTexture:SetPoint("TOPLEFT", self, "TOPLEFT", 2, -2)
                                slotTexture:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 2)

                                local slotID = self.slotID
                                if not slotID then
                                    print("Error: slotID is not defined for this slot.")
                                    return
                                end

                                if capturedItemLink then
                                    local itemID = string.match(capturedItemLink, "Hitem:(%d+):")
                                    SendChatMessage("e " .. capturedItemLink, "WHISPER", nil, UnitName(playerT))
                                    updateFrame:Show()
                                    WaitAndCheckFrameHidden(updateFrame, 5, function(result)
                                        if not result then
                                            updateFrame:Hide()
                                            print("Equip failed!")
                                            BotEquippmentManagerMainFrame()
                                            return
                                        end
                                    end)
                                    if itemID then
                                        -- Use slotID + 1 for equipmentTable assignment
                                        local newSlotID = slotID + 1
                                        if tempSlots[slotID] then
                                            equipmentTable[newSlotID] = tempSlots[slotID]
                                            tempSlots[slotID] = nil
                                        else
                                            equipmentTable[newSlotID] = {
                                                itemID = tonumber(itemID),
                                                itemLink = select(2, GetItemInfo(itemID)),
                                                itemTexture = GetItemIcon(itemID),
                                            }
                                        end
                                    else
                                        print("Error: Unable to parse itemID from itemLink.")
                                    end
                                else
                                    print("No item data available for slotID:", slotID)
                                end
                            end
                        end)
                    else
                        -- Reset to default texture for empty slots
                        slotTexture:SetTexture("Interface/Buttons/UI-EmptySlot")
                        slot.slotIlvl:SetText("")

                        -- Reset tooltip
                        slot:SetScript("OnEnter", function(self)
                            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                            GameTooltip:AddLine("Empty Slot")
                            GameTooltip:Show()
                        end)
                        slot:SetScript("OnLeave", function(self)
                            GameTooltip:Hide()
                        end)

                        -- Add left-click functionality for empty slots
                        slot:SetScript("OnMouseUp", function(self, button)
                            if button == "LeftButton" then
                                -- Handle any additional actions for empty slots here
                            end
                        end)
                    end
                end
            end
        end
    end

    updateFrame:Hide()
end

--Inspec char wear items
local function UpdateBotEquipmentFrame()
    -- Prepare equipment data
    equipmentData = PrepareEquipmentTable()

    -- Populate equipment slots dynamically
    for slotID, slotData in pairs(equipmentData) do
        -- Retrieve the pre-created slot
        local slot = botEquipmentFrame.slots[slotID]

        if slot then
            -- Update the slot's icon
            slot.icon:SetTexture(slotData.itemTexture or "Interface/Icons/INV_Misc_QuestionMark")

            -- Update the slot's item text
            if slotData.itemID then
                local itemName, itemLink, _, itemLevel, _, _, _, _, itemEquipLoc = GetItemInfo(slotData.itemID)
                slot.itemText:GetFontString():SetText(itemLevel .. " " .. slotData.itemLink)
            else
                slot.itemText:GetFontString():SetText("Empty")
            end

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
            slot.itemText:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            -- Update leftclick unequip action
            slot.itemText:SetScript("OnClick", function(self, button)
                if botMainInspectFrame and botMainInspectFrame:IsShown() then
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
    for slotID, slot in pairs(botEquipmentFrame.slots) do
        if not equipmentData[slotID] then
            -- Reset icon to default texture
            slot.icon:SetTexture("Interface/Icons/INV_Misc_QuestionMark")

            -- Reset item text to "Empty"
            slot.itemText:GetFontString():SetText("Empty")

            -- Clear slot-specific data
            slot.itemLink = nil
            slot.itemID = nil
        end
    end
end

--Target error handlers
local function HandleInvalidTarget(message)
    print(message)
    if botMainInspectFrame then
        equipmentLoaded = false
        equipmentTable = {}
        tempSlots = {}
        botMainInspectFrame:UnregisterEvent("PLAYER_TARGET_CHANGED")
        botMainInspectFrame:UnregisterEvent("UNIT_INVENTORY_CHANGED")
        botMainInspectFrame:Hide()
    end
end

--Main function
function BotEquippmentManagerMainFrame()
    -- Perform target checks
    if not UnitIsPlayer("target") then
        HandleInvalidTarget("The selected target is not a player!")
        return
    end

    if UnitIsUnit("target", "player") then
        HandleInvalidTarget("Can't target yourself!")
        return
    end

    if UnitIsDead("target") then
        HandleInvalidTarget("The target is dead!")
        return
    end

    if not UnitIsConnected("target") then
        HandleInvalidTarget("The target is offline!")
        return
    end

    if not CheckInteractDistance("target", 1) then
        HandleInvalidTarget("The target is out of inspect range!")
        return
    end

    if UnitAffectingCombat("target") then
        HandleInvalidTarget("Target is in combat!")
        return
    end

    if not UnitInParty("target") and not UnitInRaid("target") then
        HandleInvalidTarget("Target is not in your party/raid!")
        return
    end

    SendChatMessage("nc -passive", "PARTY") --Ensure to bot reacts on inspection
    playerT = UnitName("target")

    NotifyInspect(playerT) -- Forces data retrieval for the target

    -- Ensure frame exists
    if not botMainInspectFrame then
        -- Create the main frame (only once)
        botMainInspectFrame = CreateFrame("Frame", "UnBotTargetInspectFrame", UIParent)
        botMainInspectFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")
        botMainInspectFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
        botMainInspectFrame:SetScript("OnEvent", function(self, event, unit)
            if event == "UNIT_INVENTORY_CHANGED" then
                if unit == "target" then
                    --print("Inventory has changed for", playerT)
                    BotEquippmentManagerMainFrame() -- Refresh the frame when inventory changes
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
                    botMainInspectFrame:UnregisterEvent("PLAYER_TARGET_CHANGED")
                    botMainInspectFrame:UnregisterEvent("UNIT_INVENTORY_CHANGED")
                    botMainInspectFrame:Hide()
                    return
                end
                botBagItemsFrame:Hide()
                botBagItemsFrame = nil
                equipmentLoaded = false
                equipmentTable = {}
                tempSlots = {}
                -- Ensure we are listening for the new target's inventory changes
                botMainInspectFrame:UnregisterEvent("UNIT_INVENTORY_CHANGED")
                BotEquippmentManagerMainFrame() -- Refresh UI as needed
            end
        end)
        -- Enable frame movement
        botMainInspectFrame:EnableMouse(true)             -- Allow mouse interaction
        botMainInspectFrame:SetMovable(true)              -- Make it movable
        -- Add drag functionality
        botMainInspectFrame:RegisterForDrag("LeftButton") -- Drag with left mouse button
        botMainInspectFrame:SetScript("OnDragStart", function(self)
            self:StartMoving()                            -- Start moving the frame
        end)
        botMainInspectFrame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing() -- Stop moving the frame
        end)
        botMainInspectFrame:SetSize(650, 785)
        botMainInspectFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
        botMainInspectFrame:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        botMainInspectFrame:SetBackdropColor(0, 0, 0, 1)
        botMainInspectFrame:SetFrameStrata("HIGH") -- Set the strata so it appears above other frames
        botMainInspectFrame:SetFrameLevel(10)

        -- Add close button
        local closeButton = CreateFrame("Button", nil, botMainInspectFrame, "UIPanelCloseButton")
        closeButton:SetPoint("TOPRIGHT", botMainInspectFrame, "TOPRIGHT")
        closeButton:SetScript("OnClick", function()
            equipmentLoaded = false -- Reload equipment data on next opening
            equipmentTable = {}
            tempSlots = {}
            botMainInspectFrame:UnregisterEvent("PLAYER_TARGET_CHANGED")
            botMainInspectFrame:UnregisterEvent("UNIT_INVENTORY_CHANGED")
            botBagItemsFrame:Hide()
            botBagItemsFrame = nil
            botMainInspectFrame:Hide()
        end)

        -- Title label
        local titleText = botMainInspectFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        titleText:SetPoint("TOP", botMainInspectFrame, "TOP", 0, -10)
        botMainInspectFrame.titleText = titleText
        -- Class label
        local classText = botMainInspectFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        classText:SetPoint("TOP", titleText, "BOTTOM", 0, -10)
        botMainInspectFrame.classText = classText
        --Level label
        local levelText = botMainInspectFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        levelText:SetPoint("TOP", classText, "BOTTOM", 0, -5)
        botMainInspectFrame.levelText = levelText
        --Player equipment label
        local leftLabel = botMainInspectFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        leftLabel:SetPoint("TOP", botMainInspectFrame, "TOP", -140, -28)
        leftLabel:SetText("Player equipment")
        leftLabel:SetTextColor(1, 0, 0) --Red
        leftLabel:SetJustifyH("LEFT")
        leftLabel:SetWidth(200)
        --Player equipment label help
        local leftLabelHelp = botMainInspectFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        leftLabelHelp:SetPoint("TOP", botMainInspectFrame, "TOP", -140, -40)
        leftLabelHelp:SetText("Left click on item link\nto store item in bag")
        --leftLabelHelp:SetTextColor(0, 1, 0) --Green
        leftLabelHelp:SetJustifyH("LEFT")
        leftLabelHelp:SetWidth(200)
        --Items in bags label
        local rightLabel = botMainInspectFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        rightLabel:SetPoint("TOP", botMainInspectFrame, "TOP", 198, -28)
        rightLabel:SetText("Items in bags")
        rightLabel:SetTextColor(1, 0, 0) --Red
        rightLabel:SetJustifyH("LEFT")
        rightLabel:SetWidth(200)
        --Items in bags label help
        local rightLabelHelp = botMainInspectFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        rightLabelHelp:SetPoint("TOP", botMainInspectFrame, "TOP", 198, -40)
        rightLabelHelp:SetText(
            "Left click on icon to equip item\nRight click to equip slot 2 for\nFinger 2, Trinket 2 and OH Wpn")
        --rightLabelHelp:SetTextColor(0, 1, 0) --Green
        rightLabelHelp:SetJustifyH("LEFT")
        rightLabelHelp:SetWidth(200)

        -- Create the "Updating..." frame
        updateFrame = CreateFrame("Frame", "UpdateFrame", botMainInspectFrame)
        updateFrame:SetSize(250, 150)
        updateFrame:SetPoint("CENTER", botMainInspectFrame, "CENTER", 0, 0) -- Center it within the main frame
        updateFrame:SetFrameStrata("HIGH")                                  -- Set the strata so it appears above other frames
        updateFrame:SetFrameLevel(20)                                       -- Increase the frame level to ensure it overlays
        --updateFrame:Show()                                                -- Initially hidden
        -- Ensure full opacity for the content frame
        updateFrame:SetAlpha(1)                                   -- Fully opaque
        updateFrame:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",              -- Solid background
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,                                          -- Tile the backgroundTexture
            edgeSize = 16,                                        -- Thickness of the border
            insets = { left = 4, right = 4, top = 4, bottom = 4 } -- Inset for the border
        })
        updateFrame:SetBackdropColor(0.1, 0.1, 0.1, 1)
        -- Add text to the frame
        local updateText = updateFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        updateText:SetPoint("CENTER", updateFrame, "CENTER", 0, 0)
        updateText:SetText("Updating...")
    end

    --Re-register event if needed
    if not botMainInspectFrame:IsEventRegistered("UNIT_INVENTORY_CHANGED") then
        --print("Re-registering UNIT_INVENTORY_CHANGED event")
        botMainInspectFrame:RegisterEvent("UNIT_INVENTORY_CHANGED") -- Register the event
    end
    if not botMainInspectFrame:IsEventRegistered("PLAYER_TARGET_CHANGED") then
        --print("Re-registering PLAYER_TARGET_CHANGED event")
        botMainInspectFrame:RegisterEvent("PLAYER_TARGET_CHANGED") -- Register the event
    end

    --Show main frame
    botMainInspectFrame:Show()
    updateFrame:Show()

    -- Update title and target details
    botMainInspectFrame.titleText:SetText(UnitName(playerT))
    local targetClass, _ = UnitClass(playerT)
    botMainInspectFrame.classText:SetText(targetClass)
    botMainInspectFrame.levelText:SetText("Level: " .. UnitLevel(playerT))

    -- Create content area for player equipment
    if not botEquipmentFrame then
        --print("Creating new content area")
        botEquipmentFrame = CreateFrame("Frame", nil, botMainInspectFrame)
        botEquipmentFrame:SetSize(460, 700)
        botEquipmentFrame:SetPoint("TOPLEFT", botMainInspectFrame, "TOPLEFT", 10, -80)

        -- Ensure full opacity for the content frame
        botEquipmentFrame:SetAlpha(1)                -- Fully opaque
        botEquipmentFrame:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8", -- Solid background
            edgeFile = nil,                          -- No border unless required
            tile = false,
            edgeSize = 0,                            -- No edges
            insets = { left = 0, right = 0, top = 0, bottom = 0 }
        })
        botEquipmentFrame:SetBackdropColor(0, 0, 0, 1) -- Solid black background

        -- Initialize slots table to store pre-created slots
        botEquipmentFrame.slots = {}

        local validSlotIndex = 0 -- Tracks the visual index of valid slots (excluding skipped ones)
        for slotID = 1, 18 do
            local slotName = slotNames[slotID]

            -- Skip specific slots (e.g., "Shirt" at slotID = 4)
            if slotID ~= 4 and slotName then
                validSlotIndex = validSlotIndex + 1 -- Increment for valid slots only

                local slot = {}

                -- Slot name
                slot.slotNameText = botEquipmentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                slot.slotNameText:SetPoint("TOPLEFT", botEquipmentFrame, "TOPLEFT", 3,
                    -85 - (validSlotIndex * 40) + 90 + 15)
                slot.slotNameText:SetText(slotName)
                slot.slotNameText:SetAlpha(1) -- Ensure text is fully opaque

                -- Item text button
                slot.itemText = CreateFrame("Button", nil, botEquipmentFrame)
                slot.itemText:SetSize(250, 40)
                slot.itemText:SetPoint("TOPLEFT", botEquipmentFrame, "TOPLEFT", 120, -55 - (validSlotIndex * 40) + 90)
                slot.itemText:SetText("Empty")
                slot.itemText:SetNormalFontObject(GameFontHighlight)
                slot.itemText:SetHighlightFontObject(GameFontNormal)
                slot.itemText:GetFontString():SetPoint("LEFT", slot.itemText, "LEFT", 5, 0)
                slot.itemText:SetAlpha(1) -- Ensure button text is fully opaque
                local fontString = slot.itemText:GetFontString()
                if fontString then
                    fontString:SetTextColor(0, 1, 0) -- Set the text color to green
                end
                -- Tooltip functionality
                slot.itemText:SetScript("OnEnter", function(self)
                    if slot.itemLink then
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:SetHyperlink(slot.itemLink)
                        GameTooltip:Show()
                    end
                end)
                slot.itemText:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
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
                slot.itemTextBorder = CreateFrame("Frame", nil, botEquipmentFrame,
                    BackdropTemplateMixin and "BackdropTemplate")
                slot.itemTextBorder:SetSize(310, 42) -- Slightly larger than the button
                slot.itemTextBorder:SetPoint("TOPLEFT", botEquipmentFrame, "TOPLEFT", 75,
                    -56 - (validSlotIndex * 40) + 90)
                slot.itemTextBorder:SetBackdrop({
                    bgFile = "Interface/ChatFrame/ChatFrameBackground", -- Background texture for dark gray
                    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",  -- Border texture
                    edgeSize = 12,                                      -- Thickness of the border
                })
                slot.itemTextBorder:SetBackdropBorderColor(1, 1, 1, 1)  -- White border color (full opacity)
                slot.itemTextBorder:SetBackdropColor(0.1, 0.1, 0.1, 1)  -- Dark gray background (RGB values + opacity)

                -- Slot icon
                slot.icon = slot.itemTextBorder:CreateTexture(nil, "OVERLAY") -- Parent icon to itemTextBorder
                slot.icon:SetSize(30, 30)
                slot.icon:SetPoint("TOPLEFT", botEquipmentFrame, "TOPLEFT", 80, -55 - (validSlotIndex * 40) + 82)
                slot.icon:SetTexture("Interface/Icons/INV_Misc_QuestionMark")
                slot.icon:SetAlpha(1) -- Ensure icon is fully opaque

                -- Create the Refresh button
                local refreshButton = CreateFrame("Button", nil, botEquipmentFrame, "UIPanelButtonTemplate")
                refreshButton:SetSize(130, 30)                                          -- Width: 100, Height: 30
                refreshButton:SetPoint("BOTTOM", botEquipmentFrame, "BOTTOM", 100, -30) -- Position it at the bottom of the frame
                refreshButton:SetText("Refresh")                                        -- Set button text

                -- Left-click action (you can add your functionality here)
                refreshButton:SetScript("OnClick", function(self, button)
                    if button == "LeftButton" then
                        BotEquippmentManagerMainFrame()
                    end
                end)

                -- Store the slot in the slots table
                botEquipmentFrame.slots[slotID] = slot
            else
                --print("Skipping slotID:", slotID, "due to exclusion.")
            end
        end
    end

    -- Refresh content
    UpdateBotEquipmentFrame()

    -- Create the BagFrame
    if not botBagItemsFrame then
        -- Create the frame
        botBagItemsFrame = CreateFrame("Frame", "BagFrame", botMainInspectFrame)
        botBagItemsFrame:SetSize(390, 700)                                               -- Set dimensions of the subframe
        botBagItemsFrame:SetPoint("TOPLEFT", botMainInspectFrame, "TOPRIGHT", -400, -80) -- Position relative to the main frame

        -- Ensure the frame is fully opaque
        botBagItemsFrame:SetAlpha(1)                 -- Fully opaque
        botBagItemsFrame:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8", -- Solid background texture
            edgeFile = nil,                          -- No border unless required
            tile = false,
            edgeSize = 0,                            -- No edges
            insets = { left = 0, right = 0, top = 0, bottom = 0 }
        })
        botBagItemsFrame:SetBackdropColor(0, 0, 0, 1) -- Solid black background
    end

    botBagItemsFrame:Show()

    -- Initialize the bag slots table if it doesn't exist
    if not botBagItemsFrame.slots then
        botBagItemsFrame.slots = {}
    end

    -- Bag items template fill
    local validBagSlotIndex = 0
    for rowIndex = 1, 18 do
        if (rowIndex ~= 4) then
            validBagSlotIndex = validBagSlotIndex + 1
            for colIndex = 1, 5 do
                local slotIndex = (rowIndex - 1) * 5 + colIndex -- Unique index for each slot
                if not botBagItemsFrame.slots[slotIndex] then
                    -- Create a slot in the BagFrame
                    local slot = CreateFrame("Button", nil, botBagItemsFrame)
                    slot:SetSize(30, 30) -- Adjust size of each slot
                    slot:SetPoint("TOPLEFT", botBagItemsFrame, "TOPLEFT", 170 + (colIndex - 1) * 45,
                        -10 - (validBagSlotIndex - 1) * 40)
                    slot:EnableMouse(true)

                    -- Add a default texture to the slot
                    local slotTexture = slot:CreateTexture(nil, "BACKGROUND")
                    slotTexture:SetAllPoints()
                    slotTexture:SetTexture("Interface/Buttons/UI-EmptySlot") -- Generic empty slot texture

                    --Add default Item lvl txt label
                    slot.slotIlvl = slot:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                    slot.slotIlvl:SetPoint("BOTTOM", slot, "BOTTOM", 0, -10) -- Position below the slot
                    slot.slotIlvl:SetText("")                                -- Default text
                    slot.slotIlvl:SetAlpha(1)                                -- Ensure visibility
                    slot.slotIlvl:SetTextColor(0, 1, 0)                      -- Set text color to white

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
                    slot.slotID = rowIndex -- Map rowIndex to slotID

                    -- Store the slot for future reuse
                    botBagItemsFrame.slots[slotIndex] = slot
                end
            end
        else
            --print("SKip: ", rowIndex)
        end
    end

    -- Initialize the whisper delay frame for bag items retreival
    if not whisperDelayFrame then
        whisperDelayFrame = CreateFrame("Frame")
        whisperDelayFrame.timeElapsed = 0
        whisperDelayFrame:SetScript("OnUpdate", nil) -- Initially disabled
    end

    -- Accumulate bot bag content whispers in a table
    botInventoryMessages = botInventoryMessages or {}

    -- Create or manage the chat listener for BagFrame
    if not chatBotInventoryListener then
        chatBotInventoryListener = CreateFrame("Frame", nil, botMainInspectFrame)
    end
    if not chatBotInventoryListener:IsEventRegistered("CHAT_MSG_WHISPER") then
        chatBotInventoryListener:RegisterEvent("CHAT_MSG_WHISPER")
    end

    chatBotInventoryListener:SetScript("OnEvent", function(_, _, message, sender)
        -- Ensure the main frame is visible before handling messages
        if botMainInspectFrame and botMainInspectFrame:IsShown() then
            if sender == UnitName(playerT) and string.match(message, "%[.+%]") and not string.find(message, "Equipping") and not string.find(message, "unequipped") then
                -- Accumulate each whisper message
                table.insert(botInventoryMessages, message)
                -- Start or restart the whisper delay timer
                if whisperDelayFrame:GetScript("OnUpdate") == nil then
                    whisperDelayFrame.timeElapsed = 0 -- Reset timer
                    whisperDelayFrame:SetScript("OnUpdate", function(self, elapsed)
                        self.timeElapsed = self.timeElapsed + elapsed
                        if self.timeElapsed >= 0.5 then -- 1-second timeout
                            -- Combine accumulated messages into a single string
                            local combinedMessage = table.concat(botInventoryMessages, " ")
                            -- UpdateBagFrame function placeholder
                            UpdateBagFrame(combinedMessage, botBagItemsFrame)
                            -- Clear accumulated messages
                            botInventoryMessages = {}
                            -- Stop the timer
                            self.timeElapsed = 0
                            self:SetScript("OnUpdate", nil)
                        end
                    end)
                end
            end
        end
    end)

    -- Trigger bot command to fetch bag items
    SendChatMessage("c", "WHISPER", nil, UnitName(playerT))
end
