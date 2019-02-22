local AchievementId = 13227;
local lastQuantity = -1;
local faction = UnitFactionGroup("player");

if faction ~= "Horde" then
	AchievementId = 13228
end

local function FormatedMsg(player, quantity, reqQuantity)
  print (player,':',quantity ,'/',reqQuantity,'| 2v2:',math.ceil((reqQuantity-quantity )/10),'or 3v3:',math.ceil((reqQuantity-quantity )/30));
end

local frame = CreateFrame("FRAME");

frame:RegisterEvent("CHAT_MSG_ADDON");
frame:RegisterEvent("CRITERIA_UPDATE");

local function eventHandler(self, event, prefix, message)
  if event == "CRITERIA_UPDATE" and GetAchievementNumCriteria(AchievementId) > 0 then
	local q, w, completed, quantity, reqQuantity = GetAchievementCriteriaInfo(AchievementId, 1);
	
	if lastQuantity ~= quantity then
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
end

C_ChatInfo.RegisterAddonMessagePrefix("NEUGEN_AMP");
frame:SetScript("OnEvent", eventHandler);

SLASH_AMP1 = "/amp"
SlashCmdList["AMP"] = function(msg)
  local q, w, completed, quantity, reqQuantity = GetAchievementCriteriaInfo(AchievementId, 1);

  if IsInGroup() then
    C_ChatInfo.SendAddonMessage("NEUGEN_AMP", format("%s|%d|%d", UnitName("player"), quantity, reqQuantity), "PARTY")
  else
    FormatedMsg(UnitName("player"), quantity, reqQuantity);
  end
end
