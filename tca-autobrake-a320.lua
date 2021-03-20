if PLANE_ICAO == "A320" then
  local start_time = os.clock()

  local last_time = os.clock()

  function tca_autobrake_a320_on_frame()
    -- Wait for tca-autobrake.lua to start and FF A320 datarefs to appear
    if os.clock() < start_time + 10.0 then
      return
    end
    -- Limit update rate (buttons need time to respond)
    if os.clock() < last_time + 0.05 then
      return
    end
    last_time = os.clock()
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
    if get("a320/Aircraft/Cockpit/Panel/BrakeAuto1_On/Power") > 0.5 then
      a320_current_autobrake_state = A320_AB_LO
    elseif get("a320/Aircraft/Cockpit/Panel/BrakeAuto2_On/Power") > 0.5 then
      a320_current_autobrake_state = A320_AB_MED
    elseif get("a320/Aircraft/Cockpit/Panel/BrakeAuto3_On/Power") > 0.5 then
      a320_current_autobrake_state = A320_AB_MAX
    end
    -- Control autobrake buttons
    -- logMsg(tostring(a320_target_autobrake_state) .. ", " .. tostring(a320_current_autobrake_state))
    if get("a320/Panel/BrakeAuto1") > 0.5 or get("a320/Panel/BrakeAuto2") > 0.5 or get("a320/Panel/BrakeAuto3") > 0.5 then
      -- Release current keypress
      set("a320/Panel/BrakeAuto1", 0)
      set("a320/Panel/BrakeAuto2", 0)
      set("a320/Panel/BrakeAuto3", 0)
    else
      if a320_target_autobrake_state ~= a320_current_autobrake_state then
        if a320_target_autobrake_state == A320_AB_OFF then
          if a320_current_autobrake_state == A320_AB_LO then
            set("a320/Panel/BrakeAuto1", 1)
          elseif a320_current_autobrake_state == A320_AB_MED then
            set("a320/Panel/BrakeAuto2", 1)
          elseif a320_current_autobrake_state == A320_AB_MAX then
            set("a320/Panel/BrakeAuto3", 1)
          end
        else
          if a320_target_autobrake_state == A320_AB_LO then
            set("a320/Panel/BrakeAuto1", 1)
          elseif a320_target_autobrake_state == A320_AB_MED then
            set("a320/Panel/BrakeAuto2", 1)
          elseif a320_target_autobrake_state == A320_AB_MAX then
            set("a320/Panel/BrakeAuto3", 1)
          end
        end
      end
    end
  end
  do_every_frame("tca_autobrake_a320_on_frame()")
end