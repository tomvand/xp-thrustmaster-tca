if PLANE_ICAO == "DH8D" then
  local dr_mixture = dataref_table("sim/cockpit2/engine/actuators/mixture_ratio")
  local dr_prop = dataref_table("sim/cockpit2/engine/actuators/prop_rotation_speed_rad_sec")
  dr_igniter = dataref_table("sim/cockpit2/engine/actuators/igniter_on")

  local axis_synced = false
  local prop_pos = {
    CUTOFF = 0,
    START = 1,
    MIN = 2,
    P900 = 3,
    MAX = 4,
    state = 0,
  }

  -- FUEL/OFF: dr_mixture = 0.0
  -- START/FEATHER: dr_mixture = 0.5. 1.0 when started?
  -- press NTOP/MCL/MCR to move past START/FEATHER!
  -- PROP MAX 1020: dr_prop = 106.800003 (no detent, NTOP)
  -- PROP 900: dr_prop = 94.199997 (no detent, MCL)
  -- PROP MIN 850: dr_prop = 89.09998 (no detent, MCR)
  -- PROP START/FEATHER: dr_prop = 62.830002
  -- Manually moving prop levers does not seem to change power rating.
  --  --> not tested in flight!
  -- So, have to emulate button presses.

  local PROP_MAX = 106.800003
  local PROP_900 = 94.199997
  local PROP_MIN = 89.09998
  local PROP_START = 62.830002

  -- FJS/Switches/starterSwitch: 0: left, 1: center, 2: right
  -- FJS/Switches/starterButton: 0: released, 1: pressed

  -- Power RATING = full throttle
  -- Overpower by pressing MTOP button (below NTOP)
  -- Assign to intuitive button
  -- Commands:
  -- FJS/FADEC/NTOP, MTOP, MCL, MCR
  -- Throttle 'axes':
  -- sim/cockpit2/engine/actuators/throttle_beta_rev_ratio
  -- < -1.0: Reverse
  -- <  0.0: DISC
  -- >= 0.0: Flight idle
  --    1.0: Rating
  
  function tca_q400_prop()
    local tca_prop_pos = math.floor(4.0 * (1.0 - tca.axis.speedbrake) + 0.5)
    
    if not axis_synced and tca_prop_pos == 0 then
      axis_synced = true
    elseif not axis_synced then
      dr_mixture[0] = 0.0
      dr_mixture[1] = 0.0
      return
    end

    if tca_prop_pos ~= prop_pos.state then
      prop_pos.state = tca_prop_pos
      if tca_prop_pos == 0 then
        dr_mixture[0] = 0.0
        dr_mixture[1] = 0.0
      elseif tca_prop_pos == 1 then
        dr_mixture[0] = 0.5
        dr_mixture[1] = 0.5
        dr_prop[0] = PROP_START
        dr_prop[1] = PROP_START
      elseif tca_prop_pos == 2 then
        command_once("FJS/FADEC/MCR")
        -- dr_prop[0] = PROP_MIN
        -- dr_prop[1] = PROP_MIN
      elseif tca_prop_pos == 3 then
        command_once("FJS/FADEC/MCL")
        -- dr_prop[0] = PROP_900
        -- dr_prop[1] = PROP_900
      elseif tca_prop_pos == 4 then
        command_once("FJS/FADEC/NTOP")
        -- dr_prop[0] = PROP_MAX
        -- dr_prop[1] = PROP_MAX
      end
    end

    -- -- Prop lever
    -- local mixture = (1.0 - tca.axis.speedbrake) / 0.20 * 0.50
    -- if mixture > 0.5 then
    --   mixture = 0.5  -- snap exactly
    -- end
    -- if tca.axis.speedbrake <= 0.80 then
    --   -- Operating range
    --   local prop = (0.75 - tca.axis.speedbrake)  -- 0.00 to 0.75
    --   if prop < 0 then
    --     prop = 0.0
    --   end
    --   if prop < 0.25 then
    --     -- START/FEATHER to MIN
    --     dr_prop[0] = PROP_START + (PROP_MIN - PROP_START) * (prop) / 0.25
    --     dr_prop[1] = PROP_START + (PROP_MIN - PROP_START) * (prop) / 0.25
    --   elseif prop < 0.50 then
    --     -- MIN to 900
    --     dr_prop[0] = PROP_MIN + (PROP_900 - PROP_MIN) * (prop - 0.25) / 0.25
    --     dr_prop[1] = PROP_MIN + (PROP_900 - PROP_MIN) * (prop - 0.25) / 0.25
    --   else
    --     -- 900 to MAX
    --     dr_prop[0] = PROP_900 + (PROP_MAX - PROP_900) * (prop - 0.50) / 0.25
    --     dr_prop[1] = PROP_900 + (PROP_MAX - PROP_900) * (prop - 0.50) / 0.25
    --   end
    -- else
    --   -- Shutoff range
    --   dr_mixture[0] = mixture
    --   dr_mixture[1] = mixture
    -- end
  end
  do_every_frame("tca_q400_prop()")


  dataref("dr_flap", "sim/cockpit2/controls/flap_ratio")
  local tca_flap_pos = 0
  local flap_hysteresis = 0.10
  function tca_q400_flaps()
    if tca == nil then
      return
    end
    local thres_incr = tca_flap_pos + 0.5 + flap_hysteresis
    local thres_decr = tca_flap_pos - 0.5 - flap_hysteresis
    if 4.0 * tca.axis.flaps > thres_incr then
      tca_flap_pos = tca_flap_pos + 1
    elseif 4.0 * tca.axis.flaps < thres_decr then
      tca_flap_pos = tca_flap_pos - 1
    end
    local current_flap = 4.0 * dr_flap
    if tca_flap_pos > current_flap then
      command_once("sim/flight_controls/flaps_down")
    elseif tca_flap_pos < current_flap then
      command_once("sim/flight_controls/flaps_up")
    end
  end
  do_every_frame("tca_q400_flaps()")


  local baro_type_set = false
  function tca_q400_baro()
    if not baro_type_set then
      set("FJS/baro/type", 1)
      baro_type_set = true
    end
  end
  do_often("tca_q400_baro()")


  function tca_q400_select(engine)
    if engine == 1 then
      set("FJS/Switches/starterSwitch", 0)
    elseif engine == 2 then
      set("FJS/Switches/starterSwitch", 2)
    else
      set("FJS/Switches/starterSwitch", 1)
    end
  end
  create_command("tca/q400/select1", "Select engine 1", "tca_q400_select(1)", "", "")
  create_command("tca/q400/select2", "Select engine 2", "tca_q400_select(2)", "", "")
  create_command("tca/q400/select_none", "Select no engine", "tca_q400_select(0)", "", "")

  create_command("tca/q400/start_button", "Press start button", "set(\"FJS/Swtiches/starterButton\", 1)", "", "set(\"FJS/Swtiches/starterButton\", 0)")

  create_command("tca/q400/ignition1_on", "Ignition 1: on", "dr_igniter[0] = 1", "", "")
  create_command("tca/q400/ignition1_off", "Ignition 1: off", "dr_igniter[0] = 0", "", "")
  create_command("tca/q400/ignition2_on", "Ignition 2: on", "dr_igniter[1] = 1", "", "")
  create_command("tca/q400/ignition2_off", "Ignition 2: off", "dr_igniter[1] = 0", "", "")
end