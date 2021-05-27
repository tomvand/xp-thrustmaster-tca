if PLANE_ICAO == "A320" then
  local start_time = os.clock()

  local last_time = os.clock()
  local last_tca_autobrake_state = AB_DISARM
  local autobrake_adjusting = false

  local xplm_ab_lo_power = nil
  local xplm_ab_med_power = nil
  local xplm_ab_max_power = nil
  local xplm_ab_lo_btn = nil
  local xplm_ab_med_btn = nil
  local xplm_ab_max_btn = nil

  local datarefs_loaded = false

  function load_datarefs()
    if datarefs_loaded then
      return true
    end

    if xplm_ab_lo_power == nil then 
      xplm_ab_lo_power = XPLMFindDataRef("a320/Aircraft/Cockpit/Panel/BrakeAuto1_On/Power")
      return false
    elseif xplm_ab_med_power == nil then
      xplm_ab_med_power = XPLMFindDataRef("a320/Aircraft/Cockpit/Panel/BrakeAuto2_On/Power")
      return false
    elseif xplm_ab_max_power == nil then
      xplm_ab_max_power = XPLMFindDataRef("a320/Aircraft/Cockpit/Panel/BrakeAuto3_On/Power")
      return false
    elseif xplm_ab_lo_btn == nil then
      xplm_ab_lo_btn = XPLMFindDataRef("a320/Panel/BrakeAuto1")
      return false
    elseif xplm_ab_med_btn == nil then
      xplm_ab_med_btn = XPLMFindDataRef("a320/Panel/BrakeAuto2")
      return false
    elseif xplm_ab_max_btn == nil then
      xplm_ab_max_btn = XPLMFindDataRef("a320/Panel/BrakeAuto3")
      return false
    end
    datarefs_loaded = true
    return true
  end

  function tca_autobrake_a320_on_frame()
    -- Limit update rate (buttons need time to respond)
    if os.clock() < last_time + 0.05 then
      return
    end
    last_time = os.clock()
    -- Find FF A320 datarefs, which appear later...
    if not load_datarefs() then
      return
    end
    -- Wait for TCA autobrake to change position
    -- Do not just check for difference between TCA and FF, as buttons may be turned off automatically!
    if autobrake_state ~= last_tca_autobrake_state then
      last_tca_autobrake_state = autobrake_state
      autobrake_adjusting = true
    end
    if not autobrake_adjusting then
      return
    end
    -- Determine target autobrake position
    local A320_AB_OFF = 0
    local A320_AB_LO = 1
    local A320_AB_MED = 2
    local A320_AB_MAX = 3
    local a320_target_autobrake_state = A320_AB_OFF
    if autobrake_state == AB_BTV then
      a320_target_autobrake_state = A320_AB_MAX
    elseif autobrake_state == AB_LO then
      a320_target_autobrake_state = A320_AB_LO
    elseif autobrake_state > AB_LO then
      a320_target_autobrake_state = A320_AB_MED
    end
    -- Read current autobrake state
    local a320_current_autobrake_state = A320_AB_OFF
    if XPLMGetDataf(xplm_ab_lo_power) > 0.5 then
      a320_current_autobrake_state = A320_AB_LO
    elseif XPLMGetDataf(xplm_ab_med_power) > 0.5 then
      a320_current_autobrake_state = A320_AB_MED
    elseif XPLMGetDataf(xplm_ab_max_power) > 0.5 then
      a320_current_autobrake_state = A320_AB_MAX
    end
    -- Control autobrake buttons
    -- logMsg(tostring(a320_target_autobrake_state) .. ", " .. tostring(a320_current_autobrake_state))
    if XPLMGetDataf(xplm_ab_lo_btn) > 0.5 or XPLMGetDataf(xplm_ab_med_btn) > 0.5 or XPLMGetDataf(xplm_ab_max_btn) > 0.5 then
      -- Release current keypress
      XPLMSetDataf(xplm_ab_lo_btn, 0)
      XPLMSetDataf(xplm_ab_med_btn, 0)
      XPLMSetDataf(xplm_ab_max_btn, 0)
    else
      if a320_target_autobrake_state ~= a320_current_autobrake_state then
        if a320_target_autobrake_state == A320_AB_OFF then
          if a320_current_autobrake_state == A320_AB_LO then
            XPLMSetDataf(xplm_ab_lo_btn, 1)
          elseif a320_current_autobrake_state == A320_AB_MED then
            XPLMSetDataf(xplm_ab_med_btn, 1)
          elseif a320_current_autobrake_state == A320_AB_MAX then
            XPLMSetDataf(xplm_ab_max_btn, 1)
          end
        else
          if a320_target_autobrake_state == A320_AB_LO then
            XPLMSetDataf(xplm_ab_lo_btn, 1)
          elseif a320_target_autobrake_state == A320_AB_MED then
            XPLMSetDataf(xplm_ab_med_btn, 1)
          elseif a320_target_autobrake_state == A320_AB_MAX then
            XPLMSetDataf(xplm_ab_max_btn, 1)
          end
        end
      else
        autobrake_adjusting = false
      end
    end
  end
  do_every_frame("tca_autobrake_a320_on_frame()")
end