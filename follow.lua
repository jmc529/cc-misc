--turtle--
local modem = peripheral.find("modem")
modem.open(5769)
local target

parallel.waitForAny(
    --Waits for a message, containing cooridnates, on a designated channel then sends the--
    --signal to move to those cooridnates--
    function()
        while true do
            local e, s, sc, rc, m, d = os.pullEvent("modem_message")
            if sc == 5769 and d < 50 and d > 2 then
                target = textutils.unserialise(m)
                target = vector.new(target.x, target.y, target.z)
                os.queueEvent("goTo")
                sleep(2)
            end
        end
    end,
    --Moves the turtle when signaled--
    function()
        while true do
            os.pullEvent("goTo")
            bta.goTo(target)
        end
    end
)

--server
local modem = peripheral.find("modem")
local loc_old, target = vector.new(gps.locate(5))
loc_old:round()

parallel.waitForAny(
    --looks for changes in location then queue's a broadcast when change occurs--
    function()
        while true do
            sleep()
            loc_new = vector.new(gps.locate(5))
            loc_new:round()
            if loc_new:cross(loc_old):dot(loc_new) == 0 then
                loc_old = loc_new
                target = textutils.serialise(loc_old)
                os.queueEvent("broadcast")
            end
        end
    end,
    --broadcasts vector--
    function()
        while true do
            local event = os.pullEvent("broadcast")
            modem.transmit(5769, 5769, target)
        end
    end
)