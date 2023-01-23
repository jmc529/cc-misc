local modules = peripheral.find("neuralInterface")

if not modules then error("Must have neural interface", 0) end
if not modules.hasModule("plethora:sensor") then error("The entity sensor is missing", 0) end
if not modules.hasModule("plethora:introspection") then error("The introspection module is missing", 0) end

local inv = modules.getInventory()
local cachedSlot = false

local acceptableFood = {["minecraft:cooked_porkchop"] = true, ["minecraft:cooked_beef"] = true, ["minecraft:cooked_mutton"] = true,
						["minecraft:cooked_salmon"] = true, ["minecraft:cooked_chicken"] = true, ["minecraft:baked_potato"] = true,
						["minecraft:bread"] = true, ["minecraft:cooked_cod"] = true, ["minecraft:cooked_rabbit"] = true}

while true do
	local data = modules.getMetaOwner()
	while data.food.hungry do
		local item
		if cachedSlot then
			local slotItem = inv.getItemDetail(cachedSlot)
			if slotItem.name  and inv.consume(cachedSlot) then
				item = slotItem
			else
				cachedSlot = nil
			end
		end

		if not item then
			for slot, meta in pairs(inv.list()) do
				local slotItem = inv.getItemDetail(slot)
				if acceptableFood[slotItem.name] and slotItem.consume(slot) then
					print("Using food from slot " .. slot)
					item = slotItem
					cachedSlot = slot
					break
				end
			end
		end

		if item then
			item.consume()
		else
			print("Cannot find food")
			break
		end

		data = modules.getMetaOwner()
	end

	sleep(5)
end
