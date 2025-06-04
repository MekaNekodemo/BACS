local HEXNODE_DISTANCE_THRESHOLD = 3.04 -- the distance of the TTS ruler tool is usable here, use only euclidian mesurements


function onLoad()
    -- syncs ->
    syncHexNodeScripts()
end

--
-- runners ->
--

function RunProcess01()
    local hexNodes = getAllObjects_Named("HexNode")

    for _, node in ipairs(hexNodes) do
        spawn_CoordinateLabel(node)
    end
end

function RunProcess02()
    local hexNodes = getAllObjects_Named("HexNode")

    for _, node in ipairs(hexNodes) do
        node.call("initMemoTable")
    end
end

function RunProcess03()
    local hexNodes = getAllObjects_Named("HexNode")

    checkHexCoordinateDuplicates(hexNodes)
end

function RunProcess04()
    local hexNodes = getAllObjects_Named("HexNode")

    updateHexCoordinateLabels(hexNodes)
end

function RunProcess05()
    local hexNodes = getAllObjects_Named("HexNode")
    
    for _, node in ipairs(hexNodes) do
        node.call("printMemoTable")
    end
end

function RunProcess06()
    setNodeNeighbourNetwork()
end
--
-- Calculations ->
--

function checkHexCoordinateDuplicates(hexNodes)
    local seen = {}
    local hasDuplicates = false

    for _, hex in ipairs(hexNodes) do
        local pos = hex.getPosition()
        local key = math.floor(pos.x) .. "," .. math.floor(pos.z)

        if seen[key] then
            print("Duplicate found at coordinates: " .. key)
            hasDuplicates = true
        else
            seen[key] = true
        end
    end

    if hasDuplicates then
        print("One or more duplicates found.")
    else
        print("All hex coordinates are unique.")
    end
end

--
-- HexNode transforming ->
--

-- Wrapper to call initMemoTable() cleanly on a HexNode object
function initMemoTable(HexNode)
    hexNode.call("initMemoTable")
end

function spawn_Hitbox(HexNode)
    local HexNodePosition = HexNode.getPosition()
    local HexNodeName = HexNode.getName()

    spawnObject({
        type ="ScriptingTrigger",
        position = HexNodePosition, 
        scale = {2.0, 1.0, 2.0},
        rotation = {0, 0, 0},
        callback_function = function(zone)
            zone.setName("Zone_" .. HexNodeName)
            zone.interactable = true
            zone.setVar("hexID", HexNodeName)
            
        end
    })
end

function spawn_GUIDLabel(hexNode)
    hexNode.call("spawn_GUIDLabel")
end

function spawn_CoordinateLabel(hexNode)
    hexNode.call("spawn_HexCoordinateLabel")
end

function updateHexCoordinateLabels(hexNodes)
    for _, node in ipairs(hexNodes) do
        clearButton(node, "HexCoordinateLabel")
        node.call("setHexCoordinates")
        node.call("spawn_HexCoordinateLabel")
    end
end



function setNodeNeighbourNetwork()

    local hexNodes = getAllObjects_Named("HexNode")
    local pointerHexNode = {}
    local pointerMemoTable = {}
    local pointer = 1
    

    if (#hexNodes == 0) then
        print("No HexNodes found!")
        return
    else
        
        while (pointer <= #hexNodes) do

            pointerHexNode = hexNodes[pointer]
            
            if (pointerHexNode.call("getHasFullNeighbours")) then
                pointer = pointer + 1
            else

                fillNodeWithNeighbours(pointer, pointerHexNode, hexNodes) 
                pointer = pointer + 1
            end
        end
    end
end

function fillNodeWithNeighbours(mainPointer, pointerHexNode, hexNodes)

    local searchPointer = 0
    local searchHexNode = {}

    searchPointer = mainPointer + 1

    while (searchPointer <= #hexNodes) do

        if not (pointerHexNode.call("getHasFullNeighbours")) then

            searchHexNode = hexNodes[searchPointer]
            distanceNodeToNode = pointerHexNode.call("getDistanceTo", searchHexNode)

            if (distanceNodeToNode <= HEXNODE_DISTANCE_THRESHOLD) then

                if not (searchHexNode.call("getHasFullNeighbours")) then
                    searchHexNode.call("addNeighbour", pointerHexNode)
                end

                pointerHexNode.call("addNeighbour", searchHexNode)
            end

            if pointerHexNode.call("getHasFullNeighbours") then
                break
            end

            searchPointer = searchPointer + 1
        end
    end
end


--
-- Get collections ->
--

function getAllObjects_Named(givenName)

    -- print("Running getAllObjects_Named " .. givenName .. "")
    local allObjects = getAllObjects()
    local listOfObjects = {}

    for index, object in ipairs(allObjects) do
        if object.getName() == givenName then
            table.insert(listOfObjects, object)
        end
    end
   
    if (#listOfObjects ~= 0) then
        -- print(" "..#listOfObjects.. " Objects named " ..givenName.. " found!")
        return listOfObjects
    end
end

--
-- Deletions ->
--

function deleteObjectsOnTag(tagName)
    -- print("Running deleteNamedScriptingZones()")
    for _, obj in ipairs(getAllObjects()) do
        if obj.tag == tagName then
                print("Deleting object tagged -> "  ..obj.tag.. " ")
                obj.destruct()
        end
    end
end

function deleteNamedObjects(objectName)
    -- print("Running deleteNamedObjects()")
    local scriptZones = Functions.call("getAllObjects_UserNamed", "Zone_HexNode_Master")

    for _, scriptZone in ipairs(scriptZones) do
        -- print("Deleting object named -> " ..scriptZone.getName().. "")
        scriptZone.destruct()
    end
end

function clearButton(object, buttonName)
    local buttons = object.getButtons()

    if (buttons) then
        for i = #buttons, 1, -1 do  -- Fjern baglæns for sikkerhed
            local button = buttons[i]
            if ((button) and (button.click_function == buttonName)) then
                object.removeButton(i-1)
                break  
            end 
        end
    end
end

--
-- Script syncs
--

function syncHexNodeScripts()
    -- print("Running: syncHexNodeScripts")
    local masterObject = getObjectFromGUID("d0feff")
    UpdateObjectScript_FromMaster(masterObject)
end

function UpdateObjectScript_FromMaster(masterObject)
    local masterObjName = masterObject.getName()
    local masterObjGUID = masterObject.getGUID()
    local subjects = getAllObjects_Named(masterObjName)
    
    for _, subject in ipairs(subjects) do
        local masterObject = getObjectFromGUID(masterObjGUID)
        local updatedCode = masterObject.getLuaScript()

        -- print("Updating subject -> " ..subject.getName().. " " .. subject.getGUID())
        
        subject.setLuaScript(updatedCode)
        
    end
end