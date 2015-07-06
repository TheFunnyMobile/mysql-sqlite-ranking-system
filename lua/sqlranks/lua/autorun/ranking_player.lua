
--[[-------------------------------------------------------

		RankingSQL Module by Hipster Lettuce

---------------------------------------------------------]]

local PlayerMeta	= FindMetaTable("Player")

function PlayerMeta:RSGetKills()
	return self:GetNWInt("RankingSQL.Kills", 0)
end

function PlayerMeta:RSGetHeadshots()
	return self:GetNWInt("RankingSQL.Headshots", 0)
end

function PlayerMeta:RSGetDeaths()
	return self:GetNWInt("RankingSQL.Deaths", 0)
end

function PlayerMeta:RSGetKDR()
	if self:RSGetKills() == 0 then return 0 end
	if self:RSGetDeaths() == 0 then return self:RSGetKills() end
	return math.Round(self:RSGetKills()/self:RSGetDeaths(), 2)
end

function PlayerMeta:RSGetJoinTime()
	return math.Round(self:GetNWInt("RankingSQL.JoinTime", 0))
end

function PlayerMeta:RSGetSessionTime()
	return math.Round(CurTime()-self:RSGetJoinTime())
end

function PlayerMeta:RSGetTotalTime()
	return math.Round(self:RSGetSessionTime() + self:GetNWInt("RankingSQL.TotalTime", 0))
end

if SERVER then
	function PlayerMeta:RSSetKills(kills)
		self:SetNWInt("RankingSQL.Kills", kills)
	end

	function PlayerMeta:RSSetHeadshots(headshots)
		self:SetNWInt("RankingSQL.Headshots", headshots)
	end

	function PlayerMeta:RSSetDeaths(deaths)
		self:SetNWInt("RankingSQL.Deaths", deaths)
	end

	function PlayerMeta:RSSetJoinTime(jointime)
		self:SetNWInt("RankingSQL.JoinTime", jointime)
	end

	function PlayerMeta:RSSetTotalTime(totaltime)
		self:SetNWInt("RankingSQL.TotalTime", totaltime)
	end
end