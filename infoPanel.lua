--Default Panel object and properties.
local Panel = {
      message="Info Panel", -- Default copy for info panel
}


--Constructor
--Args will default to property values above, or can pass parameters directly
function Panel:new( ... )

      --Create a local table for new panel instance and set Meta and Index
      local newPanel = ... or {}
      setmetatable( newPanel, self )
      self.__index = self

      --Set up new display group with rectangle and label for this panel instance
      newPanel.group = display.newGroup()
      newPanel.group.anchorChildren = true
      newPanel.label = newPanel:setLabel(--[[newPanel.depth]])
      newPanel.group:insert(newPanel.label)
      newPanel.group:addEventListener( "updateInfo", newPanel )

      return newPanel -- return new panel instance

end


--Add a label to the group. This houses the copy.
function Panel:setLabel(label)
      local options =
      {
            text = self.message or "",
            font = native.systemFont,
            fontSize = 20,
      }
      return display.newText( options )
end


--Update the group's label. Helpful for debug purposes
--Optional event.target with selected Tile object
--Optional event.reset boolean to return to default label text
function Panel:updateInfo(e)

      if e.target then
            self.label.text = "Type: " .. e.target.type .. "\nRow: " .. e.target.row .. "\nColumn: " .. e.target.col
      elseif e.reset == true then
            self.label.text = self.message or ""
      end
end


return Panel -- return the Panel instance
