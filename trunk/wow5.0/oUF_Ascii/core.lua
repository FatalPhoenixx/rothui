--------------------------------------
--VARIABLES
--------------------------------------

local addonName, ns = ...

local PowerBarColor = PowerBarColor
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local FACTION_BAR_COLORS = FACTION_BAR_COLORS
local abs, floor, format = abs, floor, format

local folder = "Interface\\AddOns\\"..addonName.."\\"
local fontFamily = folder.."font.ttf"

--------------------------------------
--COLOR LIB
--------------------------------------

--gradient color lib
local CS = CreateFrame("ColorSelect")

--get HSV from RGB color
function CS:GetHSVColor(color)
  self:SetColorRGB(color.r, color.g, color.b)
  local h,s,v = self:GetColorHSV()
  return {h=h,s=s,v=v}
end

--get RGB from HSV color
function CS:GetRGBColor(color)
  self:SetColorHSV(color.h, color.s, color.v)
  local r,g,b = self:GetColorRGB()
  return {r=r,g=g,b=b}
end

--input two HSV colors and a percentage
--returns new HSV color
function CS:GetSmudgeColorHSV(colorA,colorB,percentage)
  local colorC = {}
  --check if the angle between the two H values is > 180
  if abs(colorA.h-colorB.h) > 180 then
    local angle = (360-abs(colorA.h-colorB.h))*percentage
    if colorA.h < colorB.h then
      colorC.h = floor(colorA.h-angle)
      if colorC.h < 0 then
        colorC.h = 360+colorC.h
      end
    else
      colorC.h = floor(colorA.h+angle)
      if colorC.h > 360 then
        colorC.h = colorC.h-360
      end
    end
  else
    colorC.h = floor(colorA.h-(colorA.h-colorB.h)*percentage)
  end
  colorC.s = colorA.s-(colorA.s-colorB.s)*percentage
  colorC.v = colorA.v-(colorA.v-colorB.v)*percentage
  return colorC
end

local redColor = CS:GetHSVColor({r=1,g=0,b=0})
local greenColor = CS:GetHSVColor({r=0,g=1,b=0})

--------------------------------------
--GET RGB as HEX-Color
--------------------------------------

local function GetHexColor(color)
  return format("%02x%02x%02x", color.r*255, color.g*255, color.b*255)
end

--------------------------------------
--COLOR FUNCTIONS
--------------------------------------

--GetPowerColor func
local function GetPowerColor(unit)
  if not unit then return end
  local id, power, r, g, b = UnitPowerType(unit)
  local color = PowerBarColor[power]
  if color then
    r, g, b = color.r, color.g, color.b
  end
  return {r=r,g=g,b=b}
end

--GetLevelColor func
local function GetLevelColor(unit)
  if not unit then return end
  local level = UnitLevel(unit)
  return GetQuestDifficultyColor((level > 0) and level or 99)
end

--GetUnitColor func
local function GetUnitColor(unit)
  if not unit then return end
  local color
  if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
    color = {r = 0.5, g = 0.5, b = 0.5}
  elseif UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) then
    color = {r = 0.5, g = 0.5, b = 0.5}
  elseif UnitIsPlayer(unit) then
    color = RAID_CLASS_COLORS[select(2, UnitClass(unit))]
  else
    color = FACTION_BAR_COLORS[UnitReaction(unit, "player")]
  end
  return color
end

--GetHealthColor func
local function GetHealthColor(unit)
  if not unit then return end
  local hcur, hmax = UnitHealth(unit), UnitHealthMax(unit)
  local hper = 0
  if hmax > 0 then hper = hcur/hmax end
  --you may need to swap red and green color
  return CS:GetRGBColor(CS:GetSmudgeColorHSV(redColor,greenColor,hper))
end

--------------------------------------
--TAGS
--------------------------------------

--unit name tag
oUF.Tags.Methods["unit:name"] = function(unit)
  local name = oUF.Tags.Methods["name"](unit)
  local color = GetUnitColor(unit)
  if color then
    return "|cff"..GetHexColor(color)..name.."|r"
  else
    return "|cffff00ff"..name.."|r"
  end
end
oUF.Tags.Events["unit:name"] = "UNIT_NAME_UPDATE UNIT_CONNECTION"

--unit level tag
oUF.Tags.Methods["unit:level"] = function(unit)
  local level = oUF.Tags.Methods["level"](unit)
  local color = GetLevelColor(unit)
  if color then
    return "|cff"..GetHexColor(color)..level.."|r"
  else
    return "|cffff00ff"..level.."|r"
  end
end
oUF.Tags.Events["unit:level"] = "UNIT_NAME_UPDATE UNIT_CONNECTION"

--unit health tag
oUF.Tags.Methods["unit:health"] = function(unit)
  local perhp = oUF.Tags.Methods["perhp"](unit)
  local color = GetHealthColor(unit)
  if color then
    return "|cff"..GetHexColor(color)..perhp.."|r"
  else
    return "|cffff00ff"..perhp.."|r"
  end
end
oUF.Tags.Events["unit:health"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH"

--unit power tag
oUF.Tags.Methods["unit:power"] = function(unit)
  local perpp = oUF.Tags.Methods["perpp"](unit)
  local color = GetPowerColor(unit)
  if color then
    return "|cff"..GetHexColor(color)..perpp.."|r"
  else
    return "|cffff00ff"..perpp.."|r"
  end
end
oUF.Tags.Events["unit:power"] = "UNIT_DISPLAYPOWER UNIT_POWER_FREQUENT UNIT_MAXPOWER"


--------------------------------------
--FONT STRINGS
--------------------------------------

--fontstring func
local function NewFontString(parent,family,size,outline,layer)
  local fs = parent:CreateFontString(nil, layer or "OVERLAY")
  fs:SetFont(family,size,outline)
  fs:SetShadowOffset(4, -4)
  fs:SetShadowColor(0,0,0,1)
  return fs
end

local function CreateUnitStrings(self)

  local hpval = NewFontString(self, fontFamily, 32, "THINOUTLINE")
  hpval:SetPoint("TOPLEFT", self, 0,0)
  self:Tag(hpval, "[unit:health]")

  local ppval = NewFontString(self, fontFamily, 24, "THINOUTLINE")
  ppval:SetPoint("LEFT", hpval, "RIGHT", 5, 0)
  self:Tag(ppval, "[unit:power]")

  local level = NewFontString(self, fontFamily, 18, "THINOUTLINE")
  level:SetPoint("TOPLEFT", hpval, "BOTTOMLEFT", 0, -5)
  self:Tag(level, "[unit:level]")

  local name = NewFontString(self, fontFamily, 18, "THINOUTLINE")
  name:SetPoint("LEFT", level, "RIGHT", 5, 0)
  self:Tag(name, "[unit:name]")





end


--------------------------------------
--STYLE TEMPLATE FUNC
--------------------------------------

--style func
local function CreateUnitTemplate(self)
  self:SetSize(32,32)
  --create the unit strings
  CreateUnitStrings(self)
end

--------------------------------------
--UNIT SPAWN
--------------------------------------

--register the style function
oUF:RegisterStyle("DefaultTemplate", CreateUnitTemplate)
oUF:SetActiveStyle("DefaultTemplate")

--spawn player
oUF:Spawn("player","DefaultTemplate"):SetPoint("CENTER", UIParent, -100, 0)

--spawn target
oUF:Spawn("target","DefaultTemplate"):SetPoint("CENTER", UIParent, 100, 0)