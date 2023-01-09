local modules = peripheral.find("neuralInterface")

if not modules then error("Must have a neural interface", 0) end
if not modules.hasModule("plethora:sensor") then error("Must have a sensor", 0) end
if not modules.hasModule("plethora:introspection") then error("Must have an introspection module", 0) end
if not modules.hasModule("plethora:kinetic", 0) then error("Must have a kinetic agument", 0) end

local meta = {}
local hover = false
local power = 1

parallel.waitForAny(
	function()
		while true do
			meta = modules.getMetaOwner()
		end
	end,
	function()
		while true do
			local event, key = os.pullEvent("key")
			if key == keys.w then
				modules.launch(180, 0, power)
			elseif key == keys.a then
				modules.launch(90, 0, power)
			elseif key == keys.d then
				modules.launch(-90, 0, power)
			elseif key == keys.s then
				modules.launch(0, 0, power)
				if not hover then
					hover = true
					os.queueEvent("hover")
				end
			elseif event == "key_up" and key == keys.k then
				hover = false
			end
		end
	end,
	function()
		local last = os.clock()
		while true do
			if hover then
				local now = os.clock()
				local diff = now - last
				last = now
				local selectedSlot = meta.heldItemSlot
				power = selectedSlot * diff;

				local mY = meta.motionY
				mY = (mY - 0.138) / 0.8

				local pitch = meta.pitch
				local yaw = meta.yaw

				-- If it is sufficiently large then we fire ourselves in that direction.
				if mY > 0.5 or mY < 0 then
					local sign = 1
					if mY < 0 then sign = -1 end
					modules.launch(0, 90 * sign, math.min(4, math.abs(mY)))
				else
					sleep(0)
				end
			else
				os.pullEvent("hover")
			end
		end
	end
)
