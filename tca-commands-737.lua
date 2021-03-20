-- Missing commands for Zibo 737

if PLANE_ICAO == "B738" then
  -- Gear up, then off
  local dt_gear_deploy = dataref_table("sim/aircraft/parts/acf_gear_deploy")

  local gear_should_be_reset = false

  function tca_737_gear_up_then_off_often()
    local gear_is_up = (dt_gear_deploy[0] == 0) and (dt_gear_deploy[1] == 0) and (dt_gear_deploy[2] == 0)
    if gear_should_be_reset and gear_is_up then
      command_once("laminar/B738/push_button/gear_down_one")
    end
  end
  do_often("tca_737_gear_up_then_off_often()")

  function tca_737_gear_up_then_off_begin()
    gear_should_be_reset = true
    command_once("laminar/B738/push_button/gear_up")
  end
  create_command("tca/737/gear_up_then_off", "Gear up, then off",
      "tca_737_gear_up_then_off_begin()", "", "")
  

  -- Parking brake
  function tca_737_parking_brake(target_state)
    local current_state = get("laminar/B738/parking_brake_pos")
    if (target_state > 0.5 and current_state < 0.5) or (target_state < 0.5 and current_state > 0.5) then
      command_once("laminar/B738/push_button/park_brake_on_off")
    end
  end
  create_command("tca/737/parking_brake_set", "Set parking brake",
      "tca_737_parking_brake(1.0)", "", "")
  create_command("tca/737/parking_brake_release", "Release parking brake",
      "tca_737_parking_brake(0.0)", "", "")
end