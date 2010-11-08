
  -- // rWeaponEnchant
  -- // zork - 2010

  --get the addon namespace
  local addon, ns = ...
  
  --object container
  local cfg = CreateFrame("Frame") 
  
  cfg.tempEnchantList = {}
  
  local player_name, _ = UnitName("player")
  local _, player_class = UnitClass("player")
  
  local spec = GetActiveTalentGroup()
  
  -----------------------------
  -- CONFIG
  -----------------------------  
  
  cfg.framesUserplaced = true
  cfg.framesLocked = false  
  
  if player_class == "SHAMAN" or player_class == "ROGUE" then
  
    cfg.tempEnchantList = {
      mainhand = {
        show = true,
        size = 28,
        pos = { a1 = "CENTER", a2 = "CENTER", af = "UIParent", x = 0, y = 0 },
        desaturate = true,
        alpha = {
          found = {
            frame = 1,
            icon = 1,
          },
          not_found = {
            frame = 0.4,
            icon = 0.6,          
          },
        },
      },
      offhand = {
        show = true,
        size = 28,
        pos = { a1 = "CENTER", a2 = "CENTER", af = "UIParent", x = 40, y = 0 },
        desaturate = true,
        alpha = {
          found = {
            frame = 1,
            icon = 1,
          },
          not_found = {
            frame = 0.4,
            icon = 0.6,          
          },
        },
      },
      throw = {
        show = true,
        size = 28,
        pos = { a1 = "CENTER", a2 = "CENTER", af = "UIParent", x = 80, y = 0 },
        desaturate = true,
        alpha = {
          found = {
            frame = 1,
            icon = 1,
          },
          not_found = {
            frame = 0.4,
            icon = 0.6,          
          },
        },
      },
    }
  
  end
  
  -----------------------------
  -- HANDOVER
  -----------------------------
  
  --object container to addon namespace
  ns.cfg = cfg