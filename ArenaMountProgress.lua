local lastQuantity;
local Faction;
local currentArenaSeason;
local AddonPrefix = "NEUGEN_AMP";
local AchievementIds = {
    ["Horde"] = 14612,
    ["Alliance"] = 14611,
};
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

local function FormatedMsg(player, quantity, reqQuantity)
    print(format("%s: %s%% | %s 2v2: %d %s 3v3: %d", player, math.ceil(quantity / reqQuantity * 10000) / 100, L["LEFT"],
        math.ceil((reqQuantity - quantity) / 10), L["OR"], math.ceil((reqQuantity - quantity) / 30)));
end

local function getMountProgress()
    if Faction == null or currentArenaSeason == null then
        return null, null, null;
    end

    if AchievementIds[Faction] and AchievementIds[Faction] and GetAchievementNumCriteria(AchievementIds[Faction]) > 0 then
        local _, _, completed, quantity, reqQuantity = GetAchievementCriteriaInfo(AchievementIds[Faction], 1);

        if completed ~= true then
            return quantity, reqQuantity, false;
        end
    end

    for i, AchievementId in pairs(Saddles[Faction]) do
        if GetAchievementNumCriteria(AchievementId) > 0 then
            local _, _, completed, quantity, reqQuantity = GetAchievementCriteriaInfo(AchievementId, 1);

            if completed ~= true then
                return quantity, reqQuantity, true;
            end
        end
    end

    return null, null, null;
end

local frame = CreateFrame("FRAME");

frame:RegisterEvent("CHAT_MSG_ADDON");
frame:RegisterEvent("CRITERIA_UPDATE");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");

local function eventHandler(self, event, prefix, message)
    if event == "CRITERIA_UPDATE" then
        local quantity, reqQuantity = getMountProgress();

        if (quantity ~= false and quantity ~= lastQuantity) then
            if lastQuantity ~= null then
                if IsInGroup() then
                    C_ChatInfo.SendAddonMessage("NEUGEN_AMP", format("%s|%d|%d", UnitName("player"), quantity, reqQuantity), "PARTY")
                else
                    FormatedMsg(UnitName("player"), quantity, reqQuantity);
                end
            end

            lastQuantity = quantity;
        end
    end

    if event == "CHAT_MSG_ADDON" then
        if prefix == AddonPrefix then
            local playerName, playerQuantity, playerReqQuantity = strsplit("|", message, 4)

            FormatedMsg(playerName, tonumber(playerQuantity), tonumber(playerReqQuantity));
        end
    end

    if event == "PLAYER_ENTERING_WORLD" then
        Faction = UnitFactionGroup("player");
        currentArenaSeason = GetCurrentArenaSeason();
    end
end

C_ChatInfo.RegisterAddonMessagePrefix(AddonPrefix);
frame:SetScript("OnEvent", eventHandler);

SLASH_AMP1 = "/amp"
SlashCmdList["AMP"] = function(msg)
    local quantity, reqQuantity = getMountProgress();

    if IsInGroup() then
        C_ChatInfo.SendAddonMessage(AddonPrefix, format("%s|%d|%d", UnitName("player"), quantity, reqQuantity), "PARTY")
    else
        FormatedMsg(UnitName("player"), quantity, reqQuantity);
    end
end
