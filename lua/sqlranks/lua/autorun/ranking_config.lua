--[[-------------------------------------------------------

		RankingSQL Module by Hipster Lettuce

---------------------------------------------------------]]

-- START OF CONFIGURABLE ITEMS --

RankingSQL				= RankingSQL or {}
RankingSQL.Config		= {}
RankingSQL.Config.HUD	= {}
RankingSQL.Config.TTT	= {}
RankingSQL.Config.MySQL	= {}
RankingSQL.Config.PS	= {}

RankingSQL.Config.TableName				= 'ranking_stats'	-- Your SQL table name (this will be created automatically if it doesn't exist)
RankingSQL.Config.TopCommandPageLimit	= 4	-- How many players per page should be shown in the !top command.
RankingSQL.Config.BroadcastRank			= true	-- When a player uses the !rank command, everyone in the server will see their rank if this is set to true.

-- PointShop Config
RankingSQL.Config.PS.Enabled			= false -- Set this to true if you want players to gain points in PointShop by _Undefined when getting kills.
RankingSQL.Config.PS.PointsPerKill		= 0 -- The number of points players earn with every kill.
RankingSQL.Config.PS.PointsPerHeadshot	= 0 -- The number of points players earn with every headshot.

-- Top 3 HUD config
RankingSQL.Config.HUD.Enabled			= false	-- Keep this as true if you want the Top 3 HUD to show.
RankingSQL.Config.HUD.Position			= "top-middle"	-- Position, can be "top-left", "top-middle", "top-right", "bottom-left", "bottom-middle", and "bottom-right" 
RankingSQL.Config.HUD.MainColor			= Color(20, 20, 20, 120)
RankingSQL.Config.HUD.GradientColor		= Color(0, 0, 0, 120)
RankingSQL.Config.HUD.OutlineColor		= Color(0, 0, 0, 120)
RankingSQL.Config.HUD.InlineColor		= Color(200, 200, 200, 120)
RankingSQL.Config.HUD.TextColor			= Color(255, 255, 255, 220)

	
-- Edit this if you are using MySQL --
RankingSQL.Config.MySQL.Enabled			= false	-- If you want to use a MySQL database, set this as true. Otherwise, it will use SQLite (doesn't require anything to run)
RankingSQL.Config.MySQL.Server			= 'localhost'	-- Your MySQL server address.
RankingSQL.Config.MySQL.Username		= 'root'	-- Your MySQL username.
RankingSQL.Config.MySQL.Password		= ''	-- Your MySQL password.
RankingSQL.Config.MySQL.Database		= 'rank_stats'	-- Your MySQL database. (If you're using MySQL then you will need to make this database)
RankingSQL.Config.MySQL.Port			= 3306	-- Your MySQL port. Most likely is 3306 (default).

-- TTT configs, skip if you are not running TTT --
RankingSQL.Config.TTT.SkipIllegalKills	= true	-- Ignore traitor VS traitor or innocent VS innocent kills or detective VS innocent
RankingSQL.Config.TTT.SkipInactiveRound	= true	-- Ignore kills before the round starts or after the round ends.