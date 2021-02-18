local lastQuantity
local faction
local currentArenaSeason
local AddonPrefix = "AMP"
local COMMAND_TALKME = "0";
local COMMAND_MYPROGRESS = "1";
local AchievementIds = {
    ["Horde"] = 14612,
    ["Alliance"] = 14611,
}
local Saddles = {
    ["Horde"] = {
        14611, 13521, 13522, 13523, 13524, 13525, 13526, 13527, 13528, 13529, 13812, 13813, 13814, 13815,
        13816, 13817, 13818, 13819, 13820, 13821, 13945, 13946, 13947, 13948, 13949, 13950, 13951, 13952,
        13953, 13954, 14561, 14563, 14564, 14565, 14566
    },
    ["Alliance"] = {
        14612, 13530, 13531, 13532, 13533, 13534, 13535, 13536, 13537, 13538, 13822, 13823, 13824, 13825,
        13826, 13827, 13828, 13829, 13830, 13831, 13933, 13934, 13935, 13936, 13937, 13938, 13939, 13940,
        13941, 13942, 14555, 14557, 14558, 14559, 14560
    },
}
local playerName, playerRealm = UnitFullName("player")

local function FormatedMsg(player, quantity, reqQuantity)
    print(format("%s: %s%% | %s 2v2: %d %s 3v3: %d", player, math.ceil(quantity / reqQuantity * 10000) / 100, L["LEFT"],
        math.ceil((reqQuantity - quantity) / 10), L["OR"], math.ceil((reqQuantity - quantity) / 30)))
end

local function getMountProgress()
    if faction == nil or currentArenaSeason == nil then
        return nil, nil, nil
    end

    if AchievementIds[faction] and GetAchievementNumCriteria(AchievementIds[faction]) > 0 then
        local _, _, completed, quantity, reqQuantity = GetAchievementCriteriaInfo(AchievementIds[faction], 1)

        if completed ~= true then
            return quantity, reqQuantity, false
        end
    end

    for i, AchievementId in pairs(Saddles[faction]) do
        if GetAchievementNumCriteria(AchievementId) > 0 then
            local _, _, completed, quantity, reqQuantity = GetAchievementCriteriaInfo(AchievementId, 1)

            if completed ~= true then
                return quantity, reqQuantity, true
            end
        end
    end

    return nil, nil, nil
end

local frame = CreateFrame("FRAME")

frame:RegisterEvent("CHAT_MSG_ADDON")
frame:RegisterEvent("CRITERIA_UPDATE")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

local function eventHandler(self, event, prefix, message, type, sender)
    if event == "CRITERIA_UPDATE" then
        local quantity, reqQuantity = getMountProgress()

        if (quantity ~= nil and quantity ~= lastQuantity) then

            if lastQuantity ~= nil then
                FormatedMsg(playerName, quantity, reqQuantity)

                if IsInGroup() then
                    C_ChatInfo.SendAddonMessage(AddonPrefix, format("%d|%s|%d|%d", COMMAND_MYPROGRESS, playerName, quantity, reqQuantity), 'GROUP')
                end
            end

            lastQuantity = quantity
        end
    end

    if event == "CHAT_MSG_ADDON" then
        if prefix == AddonPrefix then
            if sender == playerName or sender == format('%s-%s', playerName, playerRealm) then return end

            local command, targetName, targetQuantity, targetReqQuantity = strsplit("|", message)

            if command == COMMAND_TALKME then
                local quantity, reqQuantity = getMountProgress()

                if reqQuantity then
                    C_ChatInfo.SendAddonMessage(AddonPrefix, format("%d|%s|%d|%d", COMMAND_MYPROGRESS, playerName, quantity, reqQuantity), 'WHISPER', sender)
                end
            elseif command == COMMAND_MYPROGRESS then
                FormatedMsg(targetName, targetQuantity, targetReqQuantity)
            end
        end
    end

    if event == "PLAYER_ENTERING_WORLD" then
        faction = UnitFactionGroup("player")
        currentArenaSeason = GetCurrentArenaSeason()
    end
end

C_ChatInfo.RegisterAddonMessagePrefix(AddonPrefix)
frame:SetScript("OnEvent", eventHandler)

SLASH_AMP1 = "/amp"
SlashCmdList["AMP"] = function(msg)
    local quantity, reqQuantity = getMountProgress()

    FormatedMsg(playerName, quantity, reqQuantity)

    if IsInGroup() then
        C_ChatInfo.SendAddonMessage(AddonPrefix, COMMAND_TALKME, "PARTY")
    end
end
