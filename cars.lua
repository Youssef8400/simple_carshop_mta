local showroomList = {}
local shopWin, listGrid, buyBtn, infoBtn, closeBtn
local infoWindow, grid, col, col2, closeInfoBtn
local infoWin, infoGrid, infoClose

local previewVeh = nil
local previewActive = false
local previewWin, applyBtn, purchaseBtn, cancelBtn
local paletteX, paletteY, paletteW, paletteH = 0.72, 0.18, 0.24, 0.36
local selectedX, selectedY = 0.5, 0.5
local isMouseDown = false

local PREVIEW_POS = { x = 510.07421875, y = -1304.3515625, z = 17.2421875 }
local CAM_POS = { x = 514.3701171875, y = -1296.1181640625, z = 19.406179428101 }

local function clamp(n, a, b) if n < a then return a end if n > b then return b end return n end

local function HSVtoRGB(h, s, v)
    if s == 0 then
        local val = math.floor(v * 255 + 0.5)
        return val, val, val
    end
    h = h % 360
    local hf = h / 60
    local i = math.floor(hf)
    local f = hf - i
    local p = v * (1 - s)
    local q = v * (1 - s * f)
    local t = v * (1 - s * (1 - f))
    local r, g, b = 0,0,0
    if i == 0 then r,g,b = v,t,p
    elseif i == 1 then r,g,b = q,v,p
    elseif i == 2 then r,g,b = p,v,t
    elseif i == 3 then r,g,b = p,q,v
    elseif i == 4 then r,g,b = t,p,v
    else r,g,b = v,p,q end
    return math.floor(clamp(r*255,0,255)+0.5), math.floor(clamp(g*255,0,255)+0.5), math.floor(clamp(b*255,0,255)+0.5)
end

local function relToPaletteLocal(mx, my)
    local sw, sh = guiGetScreenSize()
    local px = paletteX * sw
    local py = paletteY * sh
    local pw = paletteW * sw
    local ph = paletteH * sh
    return (mx - px) / pw, (my - py) / ph, px, py, pw, ph
end

local function applyColorToPreview(r,g,b)
    if not isElement(previewVeh) then return end
    setVehicleColor(previewVeh, r, g, b, r, g, b)
end

local function drawColorPalette()
    local sw, sh = guiGetScreenSize()
    local px = paletteX * sw
    local py = paletteY * sh
    local pw = paletteW * sw
    local ph = paletteH * sh

    local stepsX = 120
    local stepsY = 96
    local stepW = pw / stepsX
    local stepH = ph / stepsY

    for ix=0,stepsX-1 do
        local hue = (ix / (stepsX-1)) * 360
        for iy=0,stepsY-1 do
            local val = 1 - (iy / (stepsY-1))
            local r,g,b = HSVtoRGB(hue, 1, val)
            dxDrawRectangle(px + ix*stepW, py + iy*stepH, stepW+1, stepH+1, tocolor(r,g,b,255), false)
        end
    end

    dxDrawRectangle(px-2, py-20, pw+4, 18, tocolor(20,20,20,200), false)
    dxDrawText("Palette couleur - clique/clic+drag", px, py-20, px+pw, py-4, tocolor(255,255,255,230), 1.05, "default-bold", "center", "center")

    local selScreenX = px + clamp(selectedX,0,1) * pw
    local selScreenY = py + clamp(selectedY,0,1) * ph
    dxDrawRectangle(selScreenX-6, selScreenY-6, 12, 12, tocolor(255,255,255,200), false)
    dxDrawRectangle(selScreenX-4, selScreenY-4, 8, 8, tocolor(0,0,0,200), false)

    local hue = clamp(selectedX,0,1) * 360
    local val = 1 - clamp(selectedY,0,1)
    local r,g,b = HSVtoRGB(hue, 1, val)
    dxDrawRectangle(px - 92, py, 80, 80, tocolor(r,g,b,255), false)
    dxDrawText(("R:%d G:%d B:%d"):format(r,g,b), px - 92, py+84, px - 12, py+110, tocolor(255,255,255,230), 1, "default-bold", "center", "top")
end

local function startRenderHandlers()
    addEventHandler("onClientRender", root, drawColorPalette)
end

local function stopRenderHandlers()
    removeEventHandler("onClientRender", root, drawColorPalette)
end

local function cleanupPreview()
    if isElement(previewVeh) then destroyElement(previewVeh); previewVeh = nil end
    if previewActive then setCameraTarget(localPlayer) end
    previewActive = false
    isMouseDown = false
    if isElement(previewWin) then destroyElement(previewWin); previewWin = nil end
    stopRenderHandlers()
    showCursor(false)
end

local function createColorPreviewWindow(index, model, price)
    if previewActive then cleanupPreview() end
    if not showroomList[index] or not showroomList[index].available then
        outputChatBox("Vehicule indisponible.", 255,100,100)
        return
    end
    local x,y,z = PREVIEW_POS.x, PREVIEW_POS.y, PREVIEW_POS.z
    previewVeh = createVehicle(tonumber(model) or 445, x, y, z, 0,0,0)
    if isElement(previewVeh) then
        setElementFrozen(previewVeh, true)
        if type(setVehicleDamageProof) == "function" then setVehicleDamageProof(previewVeh, true) end
    end
    setCameraMatrix(CAM_POS.x, CAM_POS.y, CAM_POS.z, PREVIEW_POS.x, PREVIEW_POS.y, PREVIEW_POS.z)
    previewActive = true
    previewWin = guiCreateWindow(0.36, 0.62, 0.28, 0.26, "Choix couleur", true)
    guiWindowSetSizable(previewWin, false)
    applyBtn = guiCreateButton(0.06, 0.72, 0.28, 0.20, "Appliquer", true, previewWin)
    purchaseBtn = guiCreateButton(0.36, 0.72, 0.28, 0.20, "Purchase", true, previewWin)
    cancelBtn = guiCreateButton(0.66, 0.72, 0.28, 0.20, "Cancel", true, previewWin)

    addEventHandler("onClientGUIClick", applyBtn, function()
        if not previewActive then return end
        local hue = clamp(selectedX,0,1) * 360
        local val = 1 - clamp(selectedY,0,1)
        local r,g,b = HSVtoRGB(hue, 1, val)
        applyColorToPreview(r,g,b)
    end, false)

    addEventHandler("onClientGUIClick", purchaseBtn, function()
        if not previewActive then return end
        local hue = clamp(selectedX,0,1) * 360
        local val = 1 - clamp(selectedY,0,1)
        local r,g,b = HSVtoRGB(hue, 1, val)
        triggerServerEvent("carshop:requestBuyWithColor", resourceRoot, index, {r,g,b}, {r,g,b})
        cleanupPreview()
    end, false)

    addEventHandler("onClientGUIClick", cancelBtn, function()
        if not previewActive then return end
        cleanupPreview()
    end, false)

    selectedX, selectedY = 0.5, 0.5
    startRenderHandlers()

    addEventHandler("onClientClick", root, function(button, state)
        if not previewActive then return end
        if button ~= "left" then return end
        if state == "down" then
            isMouseDown = true
            local cx, cy = getCursorPosition()
            if not cx then return end
            local sw, sh = guiGetScreenSize()
            local mx, my = cx * sw, cy * sh
            local relX, relY, px, py, pw, ph = relToPaletteLocal(mx, my)
            if relX >= 0 and relX <= 1 and relY >= 0 and relY <= 1 then
                selectedX = clamp(relX, 0, 1)
                selectedY = clamp(relY, 0, 1)
            end
        elseif state == "up" then
            isMouseDown = false
        end
    end)

    addEventHandler("onClientRender", root, function()
        if not previewActive then return end
        if isCursorShowing() then
            local cx, cy = getCursorPosition()
            if cx then
                local sw, sh = guiGetScreenSize()
                local mx, my = cx * sw, cy * sh
                local relX, relY, px, py, pw, ph = relToPaletteLocal(mx, my)
                if isMouseDown and relX and relY and relX >= 0 and relX <= 1 and relY >= 0 and relY <= 1 then
                    selectedX = clamp(relX, 0, 1)
                    selectedY = clamp(relY, 0, 1)
                end
            end
        end
    end)
    showCursor(true)
end

local function createInfoWindow()
    if isElement(infoWindow) then return end
    infoWindow = guiCreateWindow(0.05, 0.35, 0.2, 0.25, "Info dial Veh", true)
    guiWindowSetSizable(infoWindow, false)
    guiSetVisible(infoWindow, false)
    grid = guiCreateGridList(0.05, 0.08, 0.9, 0.7, true, infoWindow)
    col = guiGridListAddColumn(grid, "Propriété", 0.5)
    col2 = guiGridListAddColumn(grid, "Valeur", 0.45)
    closeInfoBtn = guiCreateButton(0.3, 0.82, 0.4, 0.12, "Fermer", true, infoWindow)
    addEventHandler("onClientGUIClick", closeInfoBtn, function()
        guiSetVisible(infoWindow, false)
        if (isElement(shopWin) and guiGetVisible(shopWin)) or previewActive then
            showCursor(true)
        else
            showCursor(false)
        end
    end, false)
end

local function showCarInfo(info)
    createInfoWindow()
    guiGridListClear(grid)
    local function addRow(k, v)
        local row = guiGridListAddRow(grid)
        guiGridListSetItemText(grid, row, col, tostring(k), false, false)
        guiGridListSetItemText(grid, row, col2, tostring(v), false, false)
    end
    addRow("Nom", info.name or "N/A")
    addRow("Model", info.modelName or "N/A")
    addRow("Année", info.year or "N/A")
    addRow("Prix", info.price or "N/A")
    if info.description then addRow("Description", info.description) end
    guiSetVisible(infoWindow, true)
    showCursor(true)
end

local function createShopGUI()
    if isElement(shopWin) then return end
    shopWin = guiCreateWindow(0.35,0.25,0.3,0.45,"Mol chi - Carshop", true)
    guiWindowSetSizable(shopWin, false)
    listGrid = guiCreateGridList(0.05,0.08,0.9,0.7, true, shopWin)
    guiGridListAddColumn(listGrid, "Index", 0.15)
    guiGridListAddColumn(listGrid, "Nom", 0.5)
    guiGridListAddColumn(listGrid, "Prix", 0.3)
    buyBtn = guiCreateButton(0.06,0.82,0.27,0.12,"Acheter",true,shopWin)
    infoBtn = guiCreateButton(0.36,0.82,0.27,0.12,"Infos",true,shopWin)
    closeBtn = guiCreateButton(0.67,0.82,0.27,0.12,"Fermer",true,shopWin)

    addEventHandler("onClientGUIClick", buyBtn, function()
        local row = guiGridListGetSelectedItem(listGrid)
        if row == -1 then outputChatBox("Selectionner veh.", 255,200,0); return end
        local idx = tonumber(guiGridListGetItemText(listGrid, row, 1))
        if not idx then outputChatBox("Index invalide.",255,0,0); return end
        local entry = showroomList[idx]
        if not entry then outputChatBox("Entrée introuvable.",255,0,0); return end
        if not entry.available then outputChatBox("Vehicule indisponible.",255,100,100); return end
        guiSetVisible(shopWin, false)
        createColorPreviewWindow(idx, entry.model, entry.info.price)
    end, false)

    addEventHandler("onClientGUIClick", infoBtn, function()
        local row = guiGridListGetSelectedItem(listGrid)
        if row == -1 then outputChatBox("Selectionne veh.", 255,200,0); return end
        local idx = tonumber(guiGridListGetItemText(listGrid, row, 1))
        local entry = showroomList[idx]
        if entry then showCarInfo(entry.info) end
    end, false)

    addEventHandler("onClientGUIClick", closeBtn, function() guiSetVisible(shopWin, false); showCursor(false) end, false)

    infoWin = guiCreateWindow(0.05,0.3,0.25,0.28,"Infos veh", true)
    guiWindowSetSizable(infoWin, false)
    guiSetVisible(infoWin, false)
    infoGrid = guiCreateGridList(0.05,0.08,0.9,0.7,true,infoWin)
    guiGridListAddColumn(infoGrid, "Champ", 0.4)
    guiGridListAddColumn(infoGrid, "Valeur", 0.55)
    infoClose = guiCreateButton(0.2,0.8,0.6,0.15,"Fermer",true,infoWin)
    addEventHandler("onClientGUIClick", infoClose, function()
        guiSetVisible(infoWin, false)
        if (isElement(shopWin) and guiGetVisible(shopWin)) or previewActive then
            showCursor(true)
        else
            showCursor(false)
        end
    end, false)
end

addEvent("carshop:openShop", true)
addEventHandler("carshop:openShop", root, function() createShopGUI(); guiSetVisible(shopWin, true); showCursor(true) end)

addEvent("carshop:openPreview", true)
addEventHandler("carshop:openPreview", root, function(index)
    if not showroomList[index] then outputChatBox("Entrée introuvable.",255,100,100); return end
    if not showroomList[index].available then outputChatBox("Vehicule indisponible.",255,100,100); return end
    if isElement(shopWin) and guiGetVisible(shopWin) then guiSetVisible(shopWin, false) end
    createColorPreviewWindow(index, showroomList[index].model, showroomList[index].info.price)
end)

addEvent("carshop:syncShowroom", true)
addEventHandler("carshop:syncShowroom", root, function(list, selectedIndex)
    showroomList = {}
    for i,entry in ipairs(list) do showroomList[i] = entry end
    createShopGUI()
    guiGridListClear(listGrid)
    for i,entry in ipairs(showroomList) do
        local row = guiGridListAddRow(listGrid)
        guiGridListSetItemText(listGrid, row, 1, tostring(entry.index), false, false)
        guiGridListSetItemText(listGrid, row, 2, tostring(entry.info.name .. (entry.available and "" or " (vendu)")), false, false)
        guiGridListSetItemText(listGrid, row, 3, tostring(entry.info.price), false, false)
    end
    if selectedIndex then
        for r=0, guiGridListGetRowCount(listGrid)-1 do
            if guiGridListGetItemText(listGrid, r, 1) == tostring(selectedIndex) then
                guiGridListSetSelectedItem(listGrid, r, 1)
                break
            end
        end
        if not guiGetVisible(shopWin) then guiSetVisible(shopWin, true); showCursor(true) end
    end
end)

addEvent("carshop:showInfo", true)
addEventHandler("carshop:showInfo", root, function(info) if type(info) == "table" then showCarInfo(info) end end)

addEvent("carshop:buyResult", true)
addEventHandler("carshop:buyResult", root, function(success, msg)
    if success then
        outputChatBox("Achat OK: "..(msg or ""), 0,200,0)
        if isElement(shopWin) and guiGetVisible(shopWin) then guiSetVisible(shopWin, false); showCursor(false) end
    else
        outputChatBox("Achat echoue: "..(msg or ""), 255,100,100)
    end
end)

addCommandHandler("buycar", function() createShopGUI(); guiSetVisible(shopWin, true); showCursor(true) end)

addEventHandler("onClientRender", root, function()
    if not previewActive then return end
    if not isCursorShowing() then showCursor(true) end
    local cx, cy = getCursorPosition()
    if not cx then return end
    local sw, sh = guiGetScreenSize()
    local mx, my = cx * sw, cy * sh
    local relX, relY, px, py, pw, ph = relToPaletteLocal(mx, my)
    local inside = relX >= 0 and relX <= 1 and relY >= 0 and relY <= 1
    if isMouseDown and inside then
        selectedX = clamp(relX,0,1)
        selectedY = clamp(relY,0,1)
    end
end)

addEventHandler("onClientPlayerWasted", root, function()
    if isElement(shopWin) and guiGetVisible(shopWin) then guiSetVisible(shopWin, false); showCursor(false) end
    if previewActive then cleanupPreview() end
end)

addEventHandler("onClientElementDestroy", root, function() if source == previewVeh then cleanupPreview() end end)
