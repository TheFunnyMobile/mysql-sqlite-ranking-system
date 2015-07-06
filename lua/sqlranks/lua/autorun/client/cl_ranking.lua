
--[[-------------------------------------------------------

		RankingSQL Module by Hipster Lettuce

---------------------------------------------------------]]

if CLIENT and RankingSQL.Config.HUD.Enabled then

	RankingSQL = RankingSQL or {}
	RankingSQL.TopPlayerTable = nil

	net.Receive( "RankingSQL_TopPlayers", function( intMsgLen )
		tableRecieved = net.ReadTable()
		RankingSQL.TopPlayerTable = tableRecieved
	end )

	RankingSQL.FontData = {
		["bigbold"] = {
			font 	= "DermaDefault",
			size 	= 14,
			weight 	= 700
		},
		["defaultbold"] = {
			font 	= "DermaDefault",
			size 	= 12,
			weight 	= 700
		},
		["default"] = {
			font 	= "DermaDefault",
			size 	= 12,
			weight 	= 500
		},
	}

	surface.CreateFont( "rankingsql_bigbold", 	RankingSQL.FontData.bigbold )
	surface.CreateFont( "rankingsql_defaultbold", RankingSQL.FontData.defaultbold )
	surface.CreateFont( "rankingsql_default", 	RankingSQL.FontData.default )

	function RankingSQL.DrawTopPlayerHUD()
		local w, h 	= 200, 80
		local x, y = ScrW()-(ScrW()/2)-(w/2), 0

		if     RankingSQL.Config.HUD.Position == "top-left" then
			x, y = 0, 1
		elseif RankingSQL.Config.HUD.Position == "top-middle" then
			x, y = ScrW()-(ScrW()/2)-(w/2), 1
		elseif RankingSQL.Config.HUD.Position == "top-right" then
			x, y = ScrW()-w, 1
		elseif RankingSQL.Config.HUD.Position == "bottom-left" then
			x, y = 0, ScrH()-h-1
		elseif RankingSQL.Config.HUD.Position == "bottom-middle" then
			x, y = ScrW()-(ScrW()/2)-(w/2), ScrH()-h-1
		elseif RankingSQL.Config.HUD.Position == "bottom-right" then
			x, y = ScrW()-w, ScrH()-h-1
		end

		local TEX_GRADIENT = surface.GetTextureID( "gui/gradient_down" )

		surface.SetDrawColor( RankingSQL.Config.HUD.MainColor )
		surface.DrawRect( x, y, w, h )
		
		surface.SetDrawColor( RankingSQL.Config.HUD.OutlineColor )
		surface.DrawRect( x, y, 1, h-1 )
		surface.DrawRect( x, y+h-1, w, 1 )
		surface.DrawRect( x, y-1, w, 1 )
		surface.DrawRect( x+w-1, y, 1, h-1 )
		
		surface.SetDrawColor( RankingSQL.Config.HUD.InlineColor )
		surface.DrawRect( x+1, y, 1, h-2 )
		surface.DrawRect( x+1, y+h-2, w-2, 1 )
		surface.DrawRect( x+1, y, w-2, 1 )
		surface.DrawRect( x+1, y+h-63, w-2, 1 )
		surface.DrawRect( x+w-2, y, 1, h-2 )
		surface.DrawRect( x+w-60, y+18, 1, h-20 )
		
		surface.SetDrawColor( RankingSQL.Config.HUD.GradientColor )
		surface.SetTexture( TEX_GRADIENT )
		surface.DrawTexturedRect( x+1, y, w-2, h*0.50 )
		
		surface.SetFont( "rankingsql_bigbold" )
		surface.SetTextColor( RankingSQL.Config.HUD.TextColor )
		
		local tw, th = surface.GetTextSize( "DHur" )
		surface.SetTextPos( x+w*0.50-tw*1.25, y+1 )
		surface.DrawText( "Top 3 Players" )

		local isTableValid = RankingSQL.TopPlayerTable ~= nil
		
		if not isTableValid then
			LocalPlayer():ConCommand("rakingsql_refreshtopplayers")
		end
		
		surface.SetFont( "rankingsql_defaultbold" )
		
		surface.SetTextPos( x+40, y+18 )
		surface.DrawText( "Name" )
		surface.SetTextPos( x+160, y+18 )
		surface.DrawText( "Kills" )

		surface.SetFont( "rankingsql_default" )
		surface.SetTextPos( x+8, y+32 )
		surface.DrawText( string.sub( ((isTableValid and RankingSQL.TopPlayerTable[1] ~= nil and RankingSQL.TopPlayerTable[1].name ~= nil and RankingSQL.TopPlayerTable[1].name .. " ") or (isTableValid and "-") or "COULD NOT LOAD LIST"), 1, 28) )
		
		surface.SetTextPos( x+8, y+47 )
		surface.DrawText( string.sub( ((isTableValid and RankingSQL.TopPlayerTable[2] ~= nil and RankingSQL.TopPlayerTable[2].name ~= nil and RankingSQL.TopPlayerTable[2].name .. " ") or (isTableValid and "-") or "COULD NOT LOAD LIST"), 1, 28) )
		
		surface.SetTextPos( x+8, y+62 )
		surface.DrawText( string.sub( ((isTableValid and RankingSQL.TopPlayerTable[3] ~= nil and RankingSQL.TopPlayerTable[3].name ~= nil and RankingSQL.TopPlayerTable[3].name .. " ") or (isTableValid and "-") or "COULD NOT LOAD LIST"), 1, 28) )
		
		local xNumPos1 = x+167
		local xNumPos2 = x+167
		local xNumPos3 = x+167

		if (isTableValid) then
			if RankingSQL.TopPlayerTable[1] ~= nil then
				if tonumber(RankingSQL.TopPlayerTable[1].kills) > 9999 then
					xNumPos1 = x + 158
				elseif tonumber(RankingSQL.TopPlayerTable[1].kills) > 999 then
					xNumPos1 = x + 160
				elseif tonumber(RankingSQL.TopPlayerTable[1].kills) > 99 then
					xNumPos1 = x + 162
				elseif tonumber(RankingSQL.TopPlayerTable[1].kills) > 9 then
					xNumPos1 = x + 164
				end
			end
			if RankingSQL.TopPlayerTable[2] ~= nil then
				if tonumber(RankingSQL.TopPlayerTable[2].kills) > 9999 then
					xNumPos2 = x + 158
				elseif tonumber(RankingSQL.TopPlayerTable[2].kills) > 999 then
					xNumPos2 = x + 160
				elseif tonumber(RankingSQL.TopPlayerTable[2].kills) > 99 then
					xNumPos2 = x + 162
				elseif tonumber(RankingSQL.TopPlayerTable[2].kills) > 9 then
					xNumPos2 = x + 164
				end
			end
			if RankingSQL.TopPlayerTable[3] ~= nil then
				if tonumber(RankingSQL.TopPlayerTable[3].kills) > 9999 then
					xNumPos3 = x + 158
				elseif tonumber(RankingSQL.TopPlayerTable[3].kills) > 999 then
					xNumPos3 = x + 160
				elseif tonumber(RankingSQL.TopPlayerTable[3].kills) > 99 then
					xNumPos3 = x + 162
				elseif tonumber(RankingSQL.TopPlayerTable[3].kills) > 9 then
					xNumPos3 = x + 164
				end
			end
		end

		surface.SetTextPos( xNumPos1, y+32 )
		surface.DrawText( (isTableValid and RankingSQL.TopPlayerTable[1] ~= nil and RankingSQL.TopPlayerTable[1].kills) or "0" )
		surface.SetTextPos( xNumPos2, y+47 )
		surface.DrawText( (isTableValid and RankingSQL.TopPlayerTable[2] ~= nil and RankingSQL.TopPlayerTable[2].kills) or "0" )
		surface.SetTextPos( xNumPos3, y+62 )
		surface.DrawText( (isTableValid and RankingSQL.TopPlayerTable[3] ~= nil and RankingSQL.TopPlayerTable[3].kills) or "0" )
	end
	hook.Add( "HUDPaint", "RankingSQL_Top3PlayerHUD", RankingSQL.DrawTopPlayerHUD )

end