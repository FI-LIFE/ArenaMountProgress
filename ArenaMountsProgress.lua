local AchievementIds = {
    [26] = {13136},
    [27] = {13227, 13453, 13521, 13522, 13523, 13524, 13525, 13526, 13527, 13528, 13529}
};

local AchievementIds_Alliance = {
    [26] = {13137},
    [27] = {13228, 13452, 13530, 13531, 13532, 13533, 13534, 13535, 13536, 13537, 13538}
};

local currentArenaSeason = 0;

local lastQuantity = -1;

local function getMountProgress()
    if currentArenaSeason == 0 then
        return false;
    end

    for i, AchievementId in pairs(AchievementIds[currentArenaSeason]) do
        if GetAchievementNumCriteria(AchievementId) > 0 then
            local criteriaString, criteriaType, completed, quantity, reqQuantity = GetAchievementCriteriaInfo(AchievementId, 1);

            if completed ~= true then
                return quantity, reqQuantity;
            end
        end
    end

    return false;
end

local function FormatedMsg(player, quantity, reqQuantity)
    print(format("%s: %s%% | %s 2v2: %d %s 3v3: %d", player, math.ceil(quantity/reqQuantity*10000)/100, L["LEFT"],
        math.ceil((reqQuantity - quantity)/10), L["OR"], math.ceil((reqQuantity - quantity)/30)));
end


local frame = CreateFrame("FRAME");

frame:RegisterEvent("CHAT_MSG_ADDON");
frame:RegisterEvent("CRITERIA_UPDATE");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");

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
            end

            lastQuantity = quantity;
        end
    end

    if event == "CHAT_MSG_ADDON" then
        if prefix == "NEUGEN_AMP" then
            local playerName, playerQuantity, playerReqQuantity = strsplit("|", message, 4)

            FormatedMsg(playerName, tonumber(playerQuantity), tonumber(playerReqQuantity));
        end
    end

    if event == "PLAYER_ENTERING_WORLD" then
        local faction = UnitFactionGroup("player");
        currentArenaSeason = GetCurrentArenaSeason();

        if faction ~= "Horde" then
            AchievementIds = AchievementIds_Alliance;
        end
    end
end

C_ChatInfo.RegisterAddonMessagePrefix("NEUGEN_AMP");
frame:SetScript("OnEvent", eventHandler);

SLASH_AMP1 = "/amp"
SlashCmdList["AMP"] = function(msg)
    if msg == 'all' then
        for i, Season in pairs(AchievementIds) do
            local left2x2, left3x3 = 0, 0;

            print(format(L["SEASON"], i));

            for i2, AchievementId in pairs(Season) do
                if GetAchievementNumCriteria(AchievementId) > 0 then
                    local id, name = GetAchievementInfo(AchievementId);
                    local criteriaString, criteriaType, completed, quantity, reqQuantity = GetAchievementCriteriaInfo(AchievementId, 1);

                    print(format("  %s: %d/%d (%s%%) 2v2: %d %s 3v3: %d", name, quantity, reqQuantity, math.ceil(quantity/reqQuantity*10000)/100,
                        math.ceil((reqQuantity - quantity)/10), L["OR"], math.ceil((reqQuantity - quantity)/30)));

                    left2x2 = left2x2 + math.ceil((reqQuantity - quantity)/10);
                    left3x3 = left3x3 + math.ceil((reqQuantity - quantity)/30);
                end
            end

            if i == currentArenaSeason then
                print (format("%s: 2v2: %d %s 3v3: %d", L["LEFT"], left2x2, L["OR"], left3x3));
            end
        end
    else
        local quantity, reqQuantity = getMountProgress();

        if IsInGroup() then
            C_ChatInfo.SendAddonMessage("NEUGEN_AMP", format("%s|%d|%d", UnitName("player"), quantity, reqQuantity), "PARTY")
        else
            FormatedMsg(UnitName("player"), quantity, reqQuantity);
        end
    end
end
