if PLANE_ICAO == "B738" then
  dataref("dr_flap", "laminar/B738/flt_ctrls/flap_lever")
  dataref("dr_approach_flaps", "laminar/B738/FMS/approach_flaps")

  local tca_flap_pos = 0  -- [0..8]
  local flap_hysteresis = 0.10  -- % flap position

  local last_time = os.clock()

  function tca_flaps_737_on_frame()
    -- Wait for TCA axes to be read
    if tca == nil then
      return
    end
    -- Limit update rate
    if os.clock() < last_time + 0.1 then
      return
    end
    -- Apply hysteresis to find TCA half-detent
    local thres_incr = tca_flap_pos + 0.5 + flap_hysteresis
    local thres_decr = tca_flap_pos - 0.5 - flap_hysteresis
    if 8.0 * tca.axis.flaps > thres_incr then
      tca_flap_pos = tca_flap_pos + 1
    elseif 8.0 * tca.axis.flaps < thres_decr then
      tca_flap_pos = tca_flap_pos - 1
    end
    -- Find 737 flap lever target
    local target_flap = 0
    if tca_flap_pos >= 2 and tca_flap_pos < 8 then
      target_flap = tca_flap_pos - 1
    elseif tca_flap_pos == 8 then
      -- Landing flap from FMS
      if dr_approach_flaps > 35 then
        target_flap = 8
      else
        target_flap = 7
      end
    end
    -- Set 737 flap lever
    local current_flap = dr_flap * 8.0
    if target_flap > current_flap then
      command_once("sim/flight_controls/flaps_down")
    elseif target_flap < current_flap then
      command_once("sim/flight_controls/flaps_up")
    end
  end
  do_every_frame("tca_flaps_737_on_frame()")  
end