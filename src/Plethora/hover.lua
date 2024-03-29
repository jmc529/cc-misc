local modules = peripheral.wrap("back")


local last = os.clock()
while true do
	local success, err = pcall(function()
		local meta = modules.getMetaOwner()

		local pitch = meta.pitch
		local yaw = meta.yaw
		
		local selectedSlot = meta.heldItemSlot
		
		local now = os.clock()
		local diff = now - last
		last = now

		local speed = selectedSlot * diff;
		
		if speed > 0 then
			speed = speed + 0.4	-- minimum to atleast hover

			pitch = pitch - 19.8 / speed
			if pitch < -90 then pitch = -90 end
		end

		if meta.isSprinting then
			if speed == 0 then
				local counterYVel = -meta.motionY * 1.2 + 3.8 * diff;
	
				if counterYVel > 4 then
					counterYVel = 4
				elseif counterYVel < -4 then
					counterYVel = -4
				end
	
				if counterYVel > 0 then
					modules.launch(0, -90, counterYVel)
				else
					modules.launch(0, 90, -counterYVel)
				end
			else
				modules.launch(yaw, pitch, speed)
			end
		end
	end)

	if not success then
		if err == "Terminated" then
			return
		end
		print("got err: " .. err)
	end
end