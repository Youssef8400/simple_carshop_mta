function range()
    local txd = engineLoadTXD('skins/range.txd')
    engineImportTXD(txd, 579)
    local dff = engineLoadDFF('skins/range.dff')
    engineReplaceModel(dff, 579)
end
addEventHandler('onClientResourceStart', resourceRoot, range)


function gclass()
    local txd = engineLoadTXD('skins/gclass.txd')
    engineImportTXD(txd, 400)
    local dff = engineLoadDFF('skins/gclass.dff')
    engineReplaceModel(dff, 400)
end
addEventHandler('onClientResourceStart', resourceRoot, gclass)


function mercedes_cl()
    local txd = engineLoadTXD('skins/adm.txd')
    engineImportTXD(txd, 445)
    local dff = engineLoadDFF('skins/adm.dff')
    engineReplaceModel(dff, 445)
end
addEventHandler('onClientResourceStart', resourceRoot, mercedes_cl)


function dacia()
    local txd = engineLoadTXD('skins/dacia.txd')
    engineImportTXD(txd, 507)
    local dff = engineLoadDFF('skins/dacia.dff')
    engineReplaceModel(dff, 507)
end
addEventHandler('onClientResourceStart', resourceRoot, dacia)


function panamera()
    local txd = engineLoadTXD('skins/panamera.txd')
    engineImportTXD(txd, 421)
    local dff = engineLoadDFF('skins/panamera.dff')
    engineReplaceModel(dff, 421)
end
addEventHandler('onClientResourceStart', resourceRoot, panamera)


function p205()
    local txd = engineLoadTXD('skins/peug.txd')
    engineImportTXD(txd, 410)
    local dff = engineLoadDFF('skins/peug.dff')
    engineReplaceModel(dff, 410)
end
addEventHandler('onClientResourceStart', resourceRoot, p205)


function mini()
    local txd = engineLoadTXD('skins/mini.txd')
    engineImportTXD(txd, 527)
    local dff = engineLoadDFF('skins/mini.dff')
    engineReplaceModel(dff, 527)
end
addEventHandler('onClientResourceStart', resourceRoot, mini)


function mdr()
    local txd = engineLoadTXD('skins/mdr.txd')
    engineImportTXD(txd, 306)
    local dff = engineLoadDFF('skins/mdr.dff')
    engineReplaceModel(dff, 306)
end
addEventHandler('onClientResourceStart', resourceRoot, mdr)