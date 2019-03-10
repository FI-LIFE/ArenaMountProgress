local AchievementIds = {13227, 13453};
local faction = UnitFactionGroup("player");

if faction ~= "Horde" then
    AchievementIds = {13228, 13452}
end

local lastQuantity = -1;

local function getMountProgress()
    for i, AchievementId in pairs(AchievementIds) do
        if GetAchievementNumCriteria(AchievementId) > 0 then
            local criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString,
                criteriaID, eligible = GetAchievementCriteriaInfo(AchievementId, 1);

            if completed ~= true then
                return quantity, reqQuantity;
            end
        end
    end

    return false;
end

local function FormatedMsg(player, quantity, reqQuantity)
    print(format("%s: %d/%d (%s%%) 2v2: %d or 3v3: %d", player, quantity, reqQuantity, math.ceil(quantity/reqQuantity*10000)/100,
        math.ceil((reqQuantity-quantity )/10), math.ceil((reqQuantity-quantity )/30)));
end


local frame = CreateFrame("FRAME");

frame:RegisterEvent("CHAT_MSG_ADDON");
frame:RegisterEvent("CRITERIA_UPDATE");

local function eventHandler(self, event, prefix, message)
    if event == "CRITERIA_UPDATE" then
        local quantity, reqQuantity = getMountProgress();

        if (quantity ~= false and quantity ~= lastQuantity) then
            if lastQuantity ~= -1 then
                if IsInGroup() then
                    C_ChatInfo.SendAddonMessage("NEUGEN_AMP", format("%s|%d|%d", UnitName("player"), quantity, reqQuantity), "PARTY")
                else
                    FormatedMsg(UnitName("player"), quantity, reqQuantity);
                end
            endgi

            lastQuantity = quantity;
        end
    end

    if event == "CHAT_MSG_ADDON" then
        if prefix == "NEUGEN_AMP" then
            local playerName, playerQuantity, playerReqQuantity = strsplit("|", message, 4)

            FormatedMsg(playerName, tonumber(playerQuantity), tonumber(playerReqQuantity));
        end
    end
end

C_ChatInfo.RegisterAddonMessagePrefix("NEUGEN_AMP");
frame:SetScript("OnEvent", eventHandler);

SLASH_AMP1 = "/amp"
SlashCmdList["AMP"] = function(msg)
    local quantity, reqQuantity = getMountProgress();

    if IsInGroup() then
        C_ChatInfo.SendAddonMessage("NEUGEN_AMP", format("%s|%d|%d", UnitName("player"), quantity, reqQuantity), "PARTY")
    else
        FormatedMsg(UnitName("player"), quantity, reqQuantity);
    end
end
