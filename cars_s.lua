math.randomseed(getTickCount() or os.time())
local RESPAWN_MS = 15 * 60 * 1000
local showroomDefs = {
    { model=445, vx=562.7841796875, vy=-1287.4521484375, vz=17.248237609863, px=562.7978515625, py=-1283.486328125, pz=17.248237609863, info={name="Mercedes Benz cla", modelName="Admiral", year=2014, price=400000} },
    { model=400, vx=555.9833984375, vy=-1287.8818359375, vz=17.248237609863, px=555.9541015625, py=-1283.6298828125, pz=17.248237609863, info={name="Mercedes Benz glcass", modelName="Landstalker", year=2020, price=3000000} },
    { model=507, vx=549.5126953125, vy=-1287.9306640625, vz=17.248237609863, px=549.7421875, py=-1283.7060546875, pz=17.248237609863, info={name="Dacia Logan", modelName="Elegant", year=2008, price=300000} },
    { model=579, vx=542.1728515625, vy=-1288.439453125, vz=17.2421875, px=542.126953125, py=-1284.02734375, pz=17.2421875, info={name="Range Rover SVR", modelName="Huntley", year=2017, price=1500000} },
    { model=410, vx=535.8935546875, vy=-1288.005859375, vz=17.2421875, px=535.89453125, py=-1284.080078125, pz=17.2421875, info={name="Peugeot 205", modelName="Manana", year=1995, price=150000} },
    { model=527, vx=528.4375, vy=-1288.9560546875, vz=17.2421875, px=528.5693359375, py=-1284.3017578125, pz=17.2421875, info={name="Mini Cooper", modelName="Cadrona", year=2013, price=1200000} },
    { model=421, vx=559.3154296875, vy=-1277.3125, vz=17.2421875, px=539.2861328125, py=-1273.7451171875, pz=17.2421875, info={name="Porsche Panamera", modelName="Washington", year=2016, price=2000000} },
    { model=445, vx=553.1513671875, vy=-1277.6630859375, vz=17.248237609863, px=546.337890625, py=-1273.1435546875, pz=17.248237609863, info={name="Mercedes Benz cla", modelName="Admiral", year=2014, price=400000} },
    { model=527, vx=546.412109375, vy=-1277.46484375, vz=17.248237609863, px=552.9560546875, py=-1273.23046875, pz=17.2421875, info={name="Mini Cooper", modelName="Cadrona", year=2013, price=1200000} },
    { model=400, vx=539.3623046875, vy=-1277.9990234375, vz=17.2421875, px=559.34375, py=-1272.900390625, pz=17.2421875, info={name="Mercedes Benz glcass", modelName="Landstalker", year=2020, price=3000000} },
}
local BUY_SPAWN = { x = 521.388671875, y = -1288.3642578125, z = 17.2421875, rz = 308.40466308594 }
local vendor = { x=521.5908203125, y=-1292.2333984375, z=17.2421875, rot=5.814605712890 }
local showroom = {}
local vendorPed, vendorCol, vendorHealthTimer

local function randColor()
    return math.random(0,255), math.random(0,255), math.random(0,255)
end

local function clearShowroom()
    for i,entry in ipairs(showroom) do
        if isElement(entry.vehicle) then destroyElement(entry.vehicle) end
        if isElement(entry.pickup) then destroyElement(entry.pickup) end
        showroom[i] = nil
    end
end

local function buildPublicList()
    local out = {}
    for i,entry in ipairs(showroom) do
        table.insert(out, {
            index = i,
            available = entry.available,
            info = entry.info,
            px = entry.px, py = entry.py, pz = entry.pz,
            model = entry.model
        })
    end
    return out
end

local function spawnShowroom()
    clearShowroom()
    for i,def in ipairs(showroomDefs) do
        local x,y,z = def.vx, def.vy, def.vz
        local px,py,pz = def.px or x, def.py or y, def.pz or z
        showroom[i] = { vehicle = nil, pickup = nil, available = true, info = def.info or {}, px = px, py = py, pz = pz, model = def.model }
        local veh = createVehicle(def.model, x, y, z, 0,0,def.rz or 0)
        if veh then
            local r1,g1,b1 = randColor()
            local r2,g2,b2 = randColor()
            setVehicleColor(veh, r1,g1,b1, r2,g2,b2)
            setElementFrozen(veh, true)
            setVehicleLocked(veh, true)
            if type(setVehicleDamageProof) == "function" then setVehicleDamageProof(veh, true) end
            setElementData(veh, "carshop:showroomIndex", i, false)
            showroom[i].vehicle = veh
        end
        local pickup = createPickup(px, py, pz, 3, 1239, 30000)
        if pickup then
            setElementData(pickup, "carshop:showroomIndex", i, false)
            addEventHandler("onPickupHit", pickup, function(hitElement)
                if getElementType(hitElement) ~= "player" then return end
                if getPedOccupiedVehicle(hitElement) then return end
                local idx = tonumber(getElementData(source, "carshop:showroomIndex")) or nil
                if not idx or not showroom[idx] or not showroom[idx].available then return end
                triggerClientEvent(hitElement, "carshop:showInfo", resourceRoot, showroom[idx].info)
            end)
            showroom[i].pickup = pickup
        end
    end
    triggerClientEvent(root, "carshop:syncShowroom", resourceRoot, buildPublicList())
end

local function clearVendor()
    if isTimer(vendorHealthTimer) then killTimer(vendorHealthTimer); vendorHealthTimer = nil end
    if isElement(vendorPed) then destroyElement(vendorPed); vendorPed = nil end
    if isElement(vendorCol) then destroyElement(vendorCol); vendorCol = nil end
end

local function spawnVendor()
    clearVendor()
    vendorPed = createPed(306, vendor.x, vendor.y, vendor.z, vendor.rot)
    if vendorPed then
        setElementFrozen(vendorPed, true)
        setElementData(vendorPed, "carshop:isVendor", true, false)
        if type(setPedCanBeTargetted) == "function" then setPedCanBeTargetted(vendorPed, false) end
        setElementHealth(vendorPed, 1000)
        vendorHealthTimer = setTimer(function()
            if isElement(vendorPed) and getElementHealth(vendorPed) < 900 then
                setElementHealth(vendorPed, 1000)
            end
        end, 1000, 0)
    end
    vendorCol = createColSphere(vendor.x, vendor.y, vendor.z, 2.2)
    addEventHandler("onColShapeHit", vendorCol, function(hitElement)
        if getElementType(hitElement) == "player" then
            triggerClientEvent(hitElement, "carshop:syncShowroom", resourceRoot, buildPublicList())
            triggerClientEvent(hitElement, "carshop:openShop", resourceRoot)
        end
    end)
end

addEventHandler("onResourceStart", resourceRoot, function()
    spawnShowroom()
    spawnVendor()
    setTimer(spawnShowroom, RESPAWN_MS, 0)
end)

addEvent("carshop:requestOpenPreview", true)
addEventHandler("carshop:requestOpenPreview", root, function(index)
    local player = client or source
    if not isElement(player) or getElementType(player) ~= "player" then return end
    index = tonumber(index)
    if not index or not showroom[index] or not showroom[index].available then
        triggerClientEvent(player, "carshop:buyResult", resourceRoot, false, "Indisponible.")
        return
    end
    triggerClientEvent(player, "carshop:openPreview", resourceRoot, index)
end)

addEvent("carshop:requestBuy", true)
addEventHandler("carshop:requestBuy", root, function(index)
    local player = client or source
    if not isElement(player) or getElementType(player) ~= "player" then return end
    index = tonumber(index)
    if not index or not showroom[index] or not showroom[index].available then
        triggerClientEvent(player, "carshop:buyResult", resourceRoot, false, "Indisponible.")
        return
    end
    local price = tonumber(showroom[index].info.price) or 0
    local money = getPlayerMoney(player) or 0
    if money < price then
        triggerClientEvent(player, "carshop:buyResult", resourceRoot, false, "Pas assez d'argent.")
        return
    end
    takePlayerMoney(player, price)
    local def = showroomDefs[index]
    local sx,sy,sz, srz = BUY_SPAWN.x, BUY_SPAWN.y, BUY_SPAWN.z, BUY_SPAWN.rz
    local newVeh = createVehicle(def.model, sx, sy, sz, 0,0, srz)
    if newVeh then
        local r1,g1,b1 = randColor()
        local r2,g2,b2 = randColor()
        setVehicleColor(newVeh, r1,g1,b1, r2,g2,b2)
        setElementData(newVeh, "carshop:ownedBy", player, false)
        warpPedIntoVehicle(player, newVeh)
    end
    if isElement(showroom[index].vehicle) then destroyElement(showroom[index].vehicle) end
    if isElement(showroom[index].pickup) then destroyElement(showroom[index].pickup) end
    showroom[index].available = false
    triggerClientEvent(player, "carshop:buyResult", resourceRoot, true, "Achat réussi.")
    triggerClientEvent(root, "carshop:syncShowroom", resourceRoot, buildPublicList())
end)

addEvent("carshop:requestBuyWithColor", true)
addEventHandler("carshop:requestBuyWithColor", root, function(index, color1, color2)
    local player = client or source
    if not isElement(player) or getElementType(player) ~= "player" then return end
    index = tonumber(index)
    if not index or not showroom[index] or not showroom[index].available then
        triggerClientEvent(player, "carshop:buyResult", resourceRoot, false, "Indisponible.")
        return
    end
    local price = tonumber(showroom[index].info.price) or 0
    local money = getPlayerMoney(player) or 0
    if money < price then
        triggerClientEvent(player, "carshop:buyResult", resourceRoot, false, "Pas assez d'argent.")
        return
    end
    takePlayerMoney(player, price)
    local def = showroomDefs[index]
    local sx,sy,sz, srz = BUY_SPAWN.x, BUY_SPAWN.y, BUY_SPAWN.z, BUY_SPAWN.rz
    local newVeh = createVehicle(def.model, sx, sy, sz, 0,0, srz)
    if newVeh then
        local r1,g1,b1 = 255,255,255
        local r2,g2,b2 = 255,255,255
        if type(color1) == "table" and tonumber(color1[1]) then r1,g1,b1 = tonumber(color1[1]), tonumber(color1[2]), tonumber(color1[3]) end
        if type(color2) == "table" and tonumber(color2[1]) then r2,g2,b2 = tonumber(color2[1]), tonumber(color2[2]), tonumber(color2[3]) end
        setVehicleColor(newVeh, r1,g1,b1, r2,g2,b2)
        setElementData(newVeh, "carshop:ownedBy", player, false)
        warpPedIntoVehicle(player, newVeh)
    end
    if isElement(showroom[index].vehicle) then destroyElement(showroom[index].vehicle) end
    if isElement(showroom[index].pickup) then destroyElement(showroom[index].pickup) end
    showroom[index].available = false
    triggerClientEvent(player, "carshop:buyResult", resourceRoot, true, "Achat réussi.")
    triggerClientEvent(root, "carshop:syncShowroom", resourceRoot, buildPublicList())
end)

addEventHandler("onVehicleStartEnter", root, function(player, seat, door)
    local idx = getElementData(source, "carshop:showroomIndex")
    if idx and showroom[idx] and showroom[idx].available then
        cancelEvent()
        if isElement(player) then
            outputChatBox("hdr m3a molchi wla utilise /buycar.", player, 255,100,100)
        end
    end
end)

addEventHandler("onPedWasted", root, function()
    if source == vendorPed then spawnVendor() end
end)
