if PLANE_ICAO == "B738" then
  local start_time = os.clock()

  local last_time = os.clock()

  local last_tca_autobrake_state = AB_DISARM
  local autobrake_adjusting = true

  dataref("dr_B738_autobrake", "laminar/B738/autobrake/autobrake_pos")

  function tca_autobrake_737_on_frame()
    -- Wait for tca-autobrake.lua to start
    if os.clock() < start_time + 1.0 then
      return
    end
    -- Wait for user to change autobrake position
    if autobrake_state ~= last_tca_autobrake_state then
      autobrake_adjusting = true
      last_tca_autobrake_state = autobrake_state
    end
    if not autobrake_adjusting then
      return
    end
    -- Limit update rate
    if os.clock() < last_time + 0.1 then
      return
    end
    last_time = os.clock()
    -- Control autobrake
    local autobrake_target_state = autobrake_state
    if autobrake_state == AB_DISARM then
      autobrake_target_state = 1
    elseif autobrake_state == AB_BTV then
      autobrake_target_state = 0
    end
    -- logMsg(tostring(autobrake_target_state) .. ", " .. tostring(dr_B738_autobrake))
    if autobrake_target_state > dr_B738_autobrake then
      command_once("laminar/B738/knob/autobrake_up")
    elseif autobrake_target_state < dr_B738_autobrake then
      command_once("laminar/B738/knob/autobrake_dn")
    end
    if dr_B738_autobrake == autobrake_target_state then
      autobrake_adjusting = false
    end
  end
  do_every_frame("tca_autobrake_737_on_frame()")
end