function initMemoTable()
    print("Initializing new memo table")
    local hexMemoTable = {
        coordinates = {},
        platoonCount = 0
    }

    if (self.memo == nil) then
        self.setMemoTable(hexMemoTable)
    end
end

--
-- Getters and Setters ->
--

function getHexCoordinates()
    local memoTable = self.getMemoTable()
    return memoTable.coordinates
end

function setHexCoordinates(coordinates)
    local memoTable = self.getMemoTable()
    memoTable.coordinates = coordinates
    self.setMemoTable(memoTable)
end

function getMemoTable()
    local memo = self.memo
    
    if (memo == nil or memo == "") then 
        return nil 
    end
    
    return JSON.decode(memo)
end

function setMemoTable(table)
    self.memo = JSON.encode(table)
end

--
-- Complex functionality ->
--

function ButtonAsLabel() end
function spawn_HexCoordinateLabel()

    local labelText = self.getName()
    local coordinates = self.getHexCoordinates()

    self.createButton({
    click_function = "ButtonAsLabel",
    function_owner = self,
    label          = coordinates,
    position       = {0, 0.3, -5},
    rotation       = {0, 0, 0},
    color          = {1, 1, 1, 1}, 
    width          = 0,
    height         = 0,
    font_size      = 500, 
    })
end