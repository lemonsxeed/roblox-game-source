repeat game["Run Service"].RenderStepped:Wait() until stage.Config.TimePast.Value > -4 / song.speed

local currentarrows = {}

local time = 1.75

spawn(function()
	local notes = basesong.notes or song.notes

	local printDebounce = false
	while wait() do
		wait(_G.artificialLag)
		workspace.FNFStage.Events.UpdatePoints:FireServer()

		--\\ Debugging

		if stage.Config.CleaningUp.Value then return end

		--\\ Notes
		for sectionnum, section in pairs(notes) do
			for notenum, note in pairs(section.sectionNotes) do
				local timeposition 	= note[1]
				local notetype 		= note[2]
				local notelength	= note[3]
				local timeframe = tomilseconds(time / song.speed)
				local timepast = tomilseconds(stage.Config.TimePast.Value)

				if timepast > timeposition - timeframe and timeposition and notetype and notelength then
					local side = section.mustHitSection
					local actualnotetype, oppositeSide = notetypeconvert(notetype)

					if oppositeSide then side = not side end
					side = side and "R" or "L"

					if not oppositeSide then ui.Side.Value = side end

					--\\ Delete note from table
					table.remove(section.sectionNotes, notenum)

					--\\ Add note to game
					local slot = templates[actualnotetype]:Clone()
					--slot.Frame.Bar.Size = UDim2.new(0.325,0,notelength/1000/song.speed,0)
					slot.Position = UDim2.new(1,0,6.666,0)
					slot.Parent = ui.Game[side].Arrows.IncomingArrows

					local tweeninfo = {time * (2 / song.speed),Enum.EasingStyle.Linear,Enum.EasingDirection.In,0,false,0}
					local properties = {Position=UDim2.new(1,0,-6.666,0)}

					tweeninfo = TweenInfo.new(tweeninfo[1],tweeninfo[2],tweeninfo[3],tweeninfo[4],tweeninfo[5],tweeninfo[6])
					game.TweenService:Create(slot,tweeninfo,properties):Play()
					wait(time / (song.bpm * song.speed))
					currentarrows[slot] = tick()

					spawn(function()
						wait(time * (2 / song.speed))
						slot:Destroy()
					end)
				else
					if not printDebounce then
						printDebounce = true
						spawn(function()
							wait(1)
							printDebounce = false
						end)
					end	
				end
			end
		end
	end
end)