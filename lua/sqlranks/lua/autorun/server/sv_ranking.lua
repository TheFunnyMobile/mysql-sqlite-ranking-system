--[[-------------------------------------------------------

		RankingSQL Module by Hipster Lettuce

---------------------------------------------------------]]

-- START OF CONFIGURABLE ITEMS --

RankingSQL.Logs = {}

local queue = {}
local db = nil
if RankingSQL.Config.HUD.Enabled then util.AddNetworkString( "RankingSQL_TopPlayers" ) end

function RankingSQL.AddLog( sqltype, log )
	RankingSQL.Logs[#RankingSQL.Logs+1] = {os.date(), "[Ranking " .. sqltype .. "]: "..log}
	ServerLog("[Ranking " .. sqltype .. "]: "..log.."\n")
end

concommand.Add( "rankingsql_logs", function( ply, cmd, args )
	if IsValid(ply) then return end
	print("RankingSQL Logs:")
	for i=1,#RankingSQL.Logs do
		print(unpack(RankingSQL.Logs[i]))
	end
end )

if RankingSQL.Config.MySQL.Enabled then

	require('mysqloo')
	
	if not mysqloo then
		RankingSQL.AddLog("MySQL", "MySQLoo is not installed.")
		return nil
	end

	db = mysqloo.connect(RankingSQL.Config.MySQL.Server == "localhost" and "127.0.0.1" or RankingSQL.Config.MySQL.Server, RankingSQL.Config.MySQL.Username, RankingSQL.Config.MySQL.Password, RankingSQL.Config.MySQL.Database, RankingSQL.Config.MySQL.Port)
	
	function db:onConnected()
		RankingSQL.AddLog( "MySQL", "Connected!")

		for k, v in pairs( queue ) do
			query( v[1], v[2] )
		end
		
		queue = {}
	end

	function db:onConnectionFailed(err)
		RankingSQL.AddLog( "MySQL", "Connection Failed, please check your settings: " .. err)
	end

	db:connect();
	db:wait();
end

function RankingSQL.Query( str, callback )
	if RankingSQL.Config.MySQL.Enabled and db then
		local q = db:query( str )
		if not q then
			table.insert( queue, { str, callback } )
			db:connect()
			return
		end
		function q:onSuccess( data )
			callback( data )
		end
		function q:onError( err )
			if db:status() == mysqloo.DATABASE_NOT_CONNECTED then
				table.insert( queue, { str, callback } )
				db:connect()
			return end
			RankingSQL.AddLog( "MySQL", "Error! The query \"" .. (str or "") .. "\" failed: " .. (err or "") )
		end
		q:start();
		q:wait();
	else
		local result = sql.Query(str)
		if (sql.LastError(result) ~= nil) then
			RankingSQL.AddLog( "SQLite", "Error! The query \"" .. (str ~= nil and str or "") .. "\" failed: " .. (sql.LastError(result) ~= nil and sql.LastError(result) or "") )
			return
		end
		callback( result )
	end
end

-- START OF SQL QUERIES --

function RankingSQL.Initialize()
	RankingSQL.Query("CREATE TABLE IF NOT EXISTS " .. RankingSQL.Config.TableName .. " ( steamid varchar(255) NOT NULL, name char(255) NOT NULL, kills int(32) NOT NULL, headshots int(32) NOT NULL, deaths int(32) NOT NULL, plytime int(32) NOT NULL, PRIMARY KEY (steamid) )", function(data)
		for k,v in pairs(player.GetAll()) do
			if IsValid(v) and v:IsPlayer() and not v:IsBot() then RankingSQL.Get(v) end
		end
		RankingSQL.AddLog( "MySQL", "Initialized.")
	end)
end

function RankingSQL.Save(ply)
	local steamid = ply:SteamID()
	local name = string.gsub(ply:GetName(), "'", "")
	if RankingSQL.Config.MySQL.Enabled and db then
		RankingSQL.Query("INSERT INTO `" .. RankingSQL.Config.TableName .. "` (steamid, name, kills, headshots, deaths, plytime) VALUES ('" .. steamid .. "', '" .. name .. "', '" .. ply:RSGetKills() .. "', '" .. ply:RSGetHeadshots() .. "', '" .. ply:RSGetDeaths()  .. "', '" .. ply:RSGetTotalTime() .. "') ON DUPLICATE KEY UPDATE name = VALUES(name), kills = VALUES(kills), headshots = VALUES(headshots), deaths = VALUES(deaths), plytime = VALUES(plytime)", function() end)
	else
		RankingSQL.Query("INSERT OR REPLACE INTO " .. RankingSQL.Config.TableName .. " (steamid, name, kills, headshots, deaths, plytime) VALUES ('" .. steamid .. "', '" .. name .. "', '" .. ply:RSGetKills() .. "', '" .. ply:RSGetHeadshots() .. "', '" .. ply:RSGetDeaths()  .. "', '" .. ply:RSGetTotalTime() .. "')", function() end)
	end
end

function RankingSQL.Get( ply )
	RankingSQL.Query("SELECT kills,headshots,deaths,plytime FROM " .. RankingSQL.Config.TableName .. " WHERE steamid = '" .. ply:SteamID() .. "'", function(data)
		if data and data[1] then
			local row = data[1]
			ply:RSSetKills(row.kills)
			ply:RSSetHeadshots(row.headshots)
			ply:RSSetDeaths(row.deaths)
			ply:RSSetTotalTime(row.plytime)
		end
	end)
end

if RankingSQL.Config.HUD.Enabled then
	function RankingSQL.GetTopPlayers( ply, command, args )
		RankingSQL.Query("SELECT steamid,name,kills,headshots,deaths,ROUND(kills/deaths,2) AS kdr FROM " .. RankingSQL.Config.TableName .. " GROUP BY steamid ORDER BY kills DESC LIMIT 3", function(data)
			if data and data[1] then
				local tableOfKills = {}
				for id, row in pairs( data ) do
					tableOfKills[id] = {steamid = row.steamid, name = row.name, kills = row.kills, headshots = row.headshots, deaths = row.deaths, kdr = row.kdr ~= "NULL" and row.kdr or 0}
				end
				net.Start( "RankingSQL_TopPlayers" )
					RankingSQL.TopPlayerTable = tableOfKills
					net.WriteTable(tableOfKills)
				net.Send(ply)
			end
		end)
	end
	concommand.Add( "rakingsql_refreshtopplayers", RankingSQL.GetTopPlayers )
end

function RankingSQL.GetRank( ply, command, args )
	if not (IsValid(ply) and ply:IsPlayer()) then return end

	RankingSQL.Query("SELECT 1 + (SELECT count( * ) FROM " .. RankingSQL.Config.TableName .. " a WHERE a.kills > b.kills ) AS rank, (SELECT count( * ) FROM " .. RankingSQL.Config.TableName .. ") AS plycount FROM " .. RankingSQL.Config.TableName .. " b WHERE steamid = '" .. ply:SteamID() .. "'", function(data)
		if data and data[1] then
			local result = data[1]
			local kills = ply:RSGetKills()
			local headshots = ply:RSGetHeadshots()
			local deaths = ply:RSGetDeaths()
			local rank = tonumber(result.rank)
			local kdr = ply:RSGetKDR()
			local plycount = tonumber(result.plycount or 0)
			if kdr == nil then kdr = 0 end
			local teamcol = team.GetColor(ply:Team())
			local normcol = Color(255,30,60,255)
			if RankingSQL.Config.BroadcastRank then
				for k, v in pairs(player.GetAll()) do
					SendText(v, teamcol, ply:Nick(), normcol, " is ranked " .. rank .. " out of " .. plycount .. " with " .. headshots .. (headshots > 1 and " headshots " or " headshot ") .. "and a KDR of " .. kdr .. " (".. kills .. "/" .. deaths ..")")
				end
			else
				SendText(ply, teamcol, ply:Nick(), normcol, " is ranked " .. rank .. " out of " .. plycount .. " with " .. headshots .. (headshots > 1 and " headshots " or " headshot ") .. "and a KDR of " .. kdr .. " (".. kills .. "/" .. deaths ..")")
			end
		else
			SendText(ply, normcol, "You are not tracked on the server yet.")
		end
	end);
end
concommand.Add( "ranksql_getrank", RankingSQL.GetRank )

function RankingSQL.GetTopPage( ply, command, args )
	if not IsValid(ply) and ply:IsPlayer() then return end
	local page = args[1] and tonumber(args[1]) or 1
	if page == nil or page < 1 then page = 1 end
	local pagelimit = (page - 1) * RankingSQL.Config.TopCommandPageLimit

	RankingSQL.Query("SELECT name,kills,1 + (SELECT count( * ) FROM " .. RankingSQL.Config.TableName .. " a WHERE a.kills > b.kills ) AS rank FROM " .. RankingSQL.Config.TableName .. " b GROUP BY steamid ORDER BY kills DESC LIMIT " .. pagelimit .. " , " .. RankingSQL.Config.TopCommandPageLimit, function(data)
		if data and data[1] then
			for id, row in pairs( data ) do
				SendText(ply, row.rank .. ". " .. row.name .. " with " .. row.kills .. " kills")
			end
		else
			SendText(ply, "No data found in this page.")
		end
	end);
end
concommand.Add( "ranksql_gettop", RankingSQL.GetTopPage )

-- END OF SQL QUERIES --


-- HOOKS START HERE --

-- Headshot recognition using ScalePlayerDamage
hook.Add("ScalePlayerDamage", "RankingSQL.DoScaleDamage", function(ply, HitGroup)
	if IsValid(ply) then ply.ranking_getlasthitgroup = HitGroup end
end)

function RankingSQL.DoDeath( victim, weapon, killer ) 
	if IsValid(killer) and killer:IsPlayer() and not killer:IsBot() and killer ~= victim then
		--TTT Handling
		if string.match(GetConVarString("gamemode"), "terrortown") and (RankingSQL.Config.TTT.SkipInactiveRound or RankingSQL.Config.TTT.SkipIllegalKills) and IsValid(victim) then
			local VictimIsTraitor = victim:IsActiveTraitor()
			local VictimIsDetective = victim:IsActiveDetective()
			local VictimIsInnocent = !victim:IsActiveDetective() and !victim:IsActiveTraitor()
			local KillerIsTraitor = killer:IsActiveTraitor()
			local KillerIsDetective = killer:IsActiveDetective()
			local KillerIsInnocent = (!killer:IsActiveDetective() and !killer:IsActiveTraitor())

			if GetRoundState() ~= ROUND_ACTIVE and RankingSQL.Config.TTT.SkipInactiveRound then return end
			if VictimIsTraitor and KillerIsTraitor and RankingSQL.Config.TTT.SkipIllegalKills then return end
			if VictimIsInnocent and KillerIsInnocent and RankingSQL.Config.TTT.SkipIllegalKills then return end
			if VictimIsDetective and KillerIsDetective and RankingSQL.Config.TTT.SkipIllegalKills then return end
			if VictimIsDetective and KillerIsInnocent and RankingSQL.Config.TTT.SkipIllegalKills then return end
			if VictimIsInnocent and KillerIsDetective and RankingSQL.Config.TTT.SkipIllegalKills then return end
		end

		killer:RSSetKills(killer:RSGetKills()+1)
		if IsValid(victim) and victim.ranking_getlasthitgroup and victim.ranking_getlasthitgroup == HITGROUP_HEAD then
			killer:RSSetHeadshots(killer:RSGetHeadshots()+1)
		end

		if RankingSQL.Config.PS.Enabled and (IsValid(victim) and victim.ranking_getlasthitgroup and victim.ranking_getlasthitgroup == HITGROUP_HEAD) then
			killer:PS_GivePoints(RankingSQL.Config.PS.PointsPerHeadshot)
		elseif RankingSQL.Config.PS.Enabled then
			killer:PS_GivePoints(RankingSQL.Config.PS.PointsPerKill)
		end

		if RankingSQL.Config.HUD.Enabled then
			local toptbl = RankingSQL.TopPlayerTable
			local killersteamid = killer:SteamID()
			if toptbl then
				if (toptbl[1] and toptbl[1].steamid == killersteamid) or (toptbl[2] and toptbl[2].steamid == killersteamid) or (toptbl[3] and toptbl[3].steamid == killersteamid) then
					RankingSQL.Save(killer)
					for k, v in pairs(player.GetAll()) do
						RankingSQL.GetTopPlayers( v )
					end
				end
			else
				RankingSQL.Save(killer)
				for k, v in pairs(player.GetAll()) do
					RankingSQL.GetTopPlayers( v )
				end
			end
		end
	end
	
	if IsValid(victim) and victim:IsPlayer() and not victim:IsBot() then
		victim:RSSetDeaths(victim:RSGetDeaths()+1)
	end
end
hook.Add( "PlayerDeath", "RankingSQL.DoDeath", RankingSQL.DoDeath )

function RankingSQL.DoDisconnect( ply )
	RankingSQL.Save(ply)
end
hook.Add( "PlayerDisconnected", "RankingSQL.DoDisconnect", RankingSQL.DoDisconnect )

function RankingSQL.DoShutdown()
	if SERVER then
		for k,v in pairs(player.GetAll()) do
			if IsValid(v) and v:IsPlayer() and not v:IsBot() then RankingSQL.Save(v) end
		end
	end
end
hook.Add( "ShutDown", "RankingSQL.DoShutdown", RankingSQL.DoShutdown )

function RankingSQL.DoSpawn( ply )
	ply:RSSetJoinTime(CurTime())
	RankingSQL.Get( ply )
end
hook.Add( "PlayerInitialSpawn", "RankingSQL.DoSpawn", RankingSQL.DoSpawn )

function RankingSQL.Commands( ply, text, public )
	if string.lower( string.sub( text, 1, 5) ) == "!rank" then
		ply:SendLua("RunConsoleCommand('ranksql_getrank')")
		return ""
	elseif string.lower( string.sub( text, 1, 5) ) == "/rank" then
		ply:SendLua("RunConsoleCommand('ranksql_getrank')")
		return ""
	elseif string.lower( string.sub( text, 1, 4) ) == "!top" then
		local args = string.Split(text, " ")
		local page = tonumber(args[2])
		if page == nil or page < 1 then page = 1 end
		ply:SendLua("RunConsoleCommand('ranksql_gettop', " .. page .. ")")
		return ""
	elseif string.lower( string.sub( text, 1, 4) ) == "/top" then
		local args = string.Split(text, " ")
		local page = tonumber(args[2])
		if page == nil or page < 1 then page = 1 end
		ply:SendLua("RunConsoleCommand('ranksql_gettop', " .. page .. ")")
		return ""
	end
end
hook.Add( "PlayerSay", "RankingSQL.Commands", RankingSQL.Commands)

-- END OF HOOKS --

-- SendText command (serverside AddChat) --

function SendText( pl, ... )
	local t, k, v, s
	t = { ... }
	for k,v in ipairs(t) do
		if type(v) == "table" then
			if v.r and v.g and v.b then
				t[k] = string.format( "Color(%d,%d,%d,255)", tonumber(v.r) or 255, tonumber(v.g) or 255, tonumber(v.b) or 255)
			end
		else
			t[k] = string.format( "%q", tostring(v))
		end
	end
	s = "chat.AddText( %s )"
	pl:SendLua(s:format(table.concat(t, ",")))
end

RankingSQL.Initialize()