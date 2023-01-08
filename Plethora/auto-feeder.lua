local modules = peripheral.find("neuralInterface")
if not modules then
	error("Must have neural interface", 0)
end
if not modules.hasModule("plethora:sensor") then
	error("The entity sensor is missing", 0)
end
if not modules.hasModule("plethora:introspection") then
	error("The introspection module is missing", 0)
end

local inv = modules.getInventory()
local cachedSlot = false

while true do
	local data = modules.getMetaOwner()
	while data.food.hungry do
		local item
		if cachedSlot then
			local slotItem = inv.getItem(cachedSlot)
			if slotItem and slotItem.consume and slotItem then
				item = slotItem
			else
				cachedSlot = nil
			end
		end

		--- If the cached slot didn't yield any food then scan the reset of the inventory. We use `.list()` instead of
		--- iterating over each slot as this guarentees there will be an item there, making the scanning slightly
		--- quicker. If we find a food item then we cache the slot for next time and exit from the loop.
		if not item then
			for slot, meta in pairs(inv.list()) do
				local slotItem = inv.getItem(slot)
				if slotItem and slotItem.consume then
					print("Using food from slot " .. slot)
					item = slotItem
					cachedSlot = slot
					break
				end
			end
		end

		--- If we found food then we eat it and re-run the loop, otherwise we stop scanning this time and allow ourselves
		--- to sleep.
		if item then
			item.consume()
		else
			print("Cannot find food")
			break
		end

		--- As the hungry flag may have changed we refetch the data and rerun the feeding loop.
		data = modules.getMetaOwner()
	end

	--- The player is now no longer hungry or we have no food so we sleep for a bit.
	sleep(5)
end
