
function initMemoTable()
    
    local hexMemoTable = getMemoTable() or {}

    -- The world coordinates of the hexnode
    if (hexMemoTable["coordinatesWorld"] == nil) then
        hexMemoTable["coordinatesWorld"] = { x = 0, z = 0 }
    end
    -- A truncated version of the world coordinates used for identification and display purposes.
    if (hexMemoTable["coordinates"] == nil) then
        hexMemoTable["coordinates"] = { x = 0, z = 0 }
    end

    if (hexMemoTable["platoonCount"] == nil) then
        hexMemoTable["platoonCount"] = 0
    end

    if (hexMemoTable["neighbours"] == nil) then
        hexMemoTable["neighbours"] = {}
    end

    if(hexMemoTable["hasFullNeighbours"] == nil) then
        hasFullNeighbours = false
    end
    
    setMemoTable(hexMemoTable)
    setHexCoordinates()
    setHexCoordinatesWorld()
end

-- Getters and Setters --

function getMemoTable()
    if (self.memo == nil or self.memo == "") then 
        return {
            empty = "No memo object found"
        } 
    end
    return JSON.decode(self.memo)
end

function setMemoTable(memoTable)
    self.memo = JSON.encode(memoTable)
end

function getHexCoordinatesWorld()
    local memoTable = getMemoTable()
    return memoTable.coordinatesWorld
end

function setHexCoordinatesWorld()
    local memoTable = getMemoTable()
    local position = self.getPosition()
    
    local coordinatesWorld = {
        x = position.x,
        z = position.z  -- TTS uses z as the vertical axis
    }

    memoTable.coordinatesWorld = coordinatesWorld
    setMemoTable(memoTable)
end

function getHexCoordinates()
    local memoTable = getMemoTable()
    return memoTable.coordinates
end

function setHexCoordinates()
    local memoTable = getMemoTable()
    local position = self.getPosition()
    
    local coordinates = {
        x = math.floor(position.x),
        z = math.floor(position.z)  -- TTS uses z as the vertical axis
    }

    memoTable.coordinates = coordinates
    setMemoTable(memoTable)
end

function getNeighbours()
    local memoTable = getMemoTable()
    local neighbours = memoTable.neighbours

    return neighbours
end

function getHasFullNeighbours()
    local memoTable = getMemoTable()
    return memoTable.hasFullNeighbours
end

function updateHasFullNeighbours()
    local memoTable = getMemoTable()
    local neighbours = memoTable.neighbours
    
    if (#neighbours < 6) then
        memoTable.hasFullNeighbours = false
    elseif (#neighbours == 6) then
        memoTable.hasFullNeighbours = true
    end
end

function addNeighbour(neighbourNode)
    local memoTable = getMemoTable()
    local neighbours = memoTable.
    updateHasFullNeighbours()
end

-- Complex functionality --

function HexCoordinateLabel() end
function spawn_HexCoordinateLabel()
    local labelText = self.getName()
    local coordinates = getHexCoordinates()
    local label = tostring(coordinates.x or "?") .. "," .. tostring(coordinates.z or "?")

    self.createButton({
        click_function = "HexCoordinateLabel",
        function_owner = self,
        label          = label,
        position       = {0, 0.3, -5},
        rotation       = {0, 0, 0},
        color          = {1, 1, 1, 1}, 
        width          = 0,
        height         = 0,
        font_size      = 500, 
    })
end

-- Utility --

function printMemoTable()

    local memo = getMemoTable()
    print("-=Memo table for: "..self.getGUID().. "=-")

    local function printTable(tbl, indent)
        indent = indent or ""
        for k, v in pairs(tbl) do
            local line = indent.."["..tostring(k).."] = "
            if type(v) == "table" then
                print(line.."{")
                printTable(v, indent.."  ")
                print(indent.."}")
            else
                print(line..tostring(v))
            end
        end
    end
    printTable(memo)
    print(" ")
end

function getDistanceTo(hexNode)
    local selfPosition = getHexCoordinatesWorld()
    local targetPosition = hexNode.call("getHexCoordinatesWorld")

    local difference_x = selfPosition.x - targetPosition.x
    local difference_z = selfPosition.z - targetPosition.z

    local distance = math.sqrt(difference_x*difference_x + difference_z * difference_z)
    return distance
end

function compareTo(hexNode)
    return self.getGUID() == hexNode.getGUID()
end