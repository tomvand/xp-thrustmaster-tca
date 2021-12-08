local SYNC_ALTIMETERS = true
local fo_baro_command = "none"

function tca_732_sync_altimeters()
  if PLANE_ICAO ~= "B732" then return end -- TODO also move to aircraft framework?
  if SYNC_ALTIMETERS then
    local cpt_baro = get("FJS/732/Inst/BaroInchRoll_1D")
    local fo_baro = get("FJS/732/Inst/BaroInchRoll_2D")
    local stdby_baro = get("FJS/732/Inst/BaroInchRoll_3D")
    if stdby_baro ~= cpt_baro then
      set("FJS/732/Inst/StbyBaroKnob", cpt_baro)
    end
    if fo_baro_command == "none" then
      if fo_baro > cpt_baro + 0.5 then
        fo_baro_command = "sim/instruments/barometer_copilot_down"
        command_begin("sim/instruments/barometer_copilot_down")
      elseif fo_baro < cpt_baro - 0.5 then
        fo_baro_command = "sim/instruments/barometer_copilot_up"
        command_begin("sim/instruments/barometer_copilot_up")
      end
    else
      if fo_baro > cpt_baro - 0.5 and fo_baro < cpt_baro + 0.5 then
        command_end(fo_baro_command)
        fo_baro_command = "none"
      end
    end
  end
end
do_every_frame("tca_732_sync_altimeters()")


local speedbrake_prev = 0

function tca_732_speedbrake_on_frame()
  if tca == nil or aircraft == nil or aircraft.icao_type ~= "B732" then return end -- Requires aircraft.lua to be initialized
  -- Control speedbrake lever
  if tca.axis.speedbrake < 0.125 and speedbrake_prev ~= 0 then
    speedbrake_prev = 0
    aircraft.controls.speedbrake("down")
  elseif tca.axis.speedbrake >= 0.125 and tca.axis.speedbrake < 0.375 and speedbrake_prev ~= 1 then
    speedbrake_prev = 1
    aircraft.controls.speedbrake("arm")
  elseif tca.axis.speedbrake >= 0.375 and tca.axis.speedbrake < 0.50 then
    speedbrake_prev = 2
    aircraft.controls.speedbrake(0.08 + (0.50 - 0.08) * (tca.axis.speedbrake - 0.375) / (0.50 - 0.375))
  elseif tca.axis.speedbrake >= 0.50 and tca.axis.speedbrake < 0.75 then
    speedbrake_prev = 2
    aircraft.controls.speedbrake(0.50 + (0.815 - 0.50) * (tca.axis.speedbrake - 0.50) / (0.75 - 0.50))
  elseif tca.axis.speedbrake >= 0.75 then
    speedbrake_prev = 2
    aircraft.controls.speedbrake(0.815 + (1.0 - 0.815) * (tca.axis.speedbrake - 0.75) / (1.0 - 0.75))
  end
end
do_every_frame("tca_732_speedbrake_on_frame()")


local tca_flap_pos = 0  -- [0..8]
local flap_hysteresis = 0.10  -- % flap position
local last_target_flap = 0
tca_732_flaps_40 = false

function tca_732_flaps_on_frame()
  if tca == nil or aircraft == nil or aircraft.icao_type ~= "B732" then return end -- Requires aircraft.lua to be initialized
  -- Control flap lever
  -- Apply hysteresis to find TCA half-detent
  local thres_incr = tca_flap_pos + 0.5 + flap_hysteresis
  local thres_decr = tca_flap_pos - 0.5 - flap_hysteresis
  if 8.0 * tca.axis.flaps > thres_incr then
    tca_flap_pos = tca_flap_pos + 1
  elseif 8.0 * tca.axis.flaps < thres_decr then
    tca_flap_pos = tca_flap_pos - 1
  end
  -- Find 737 flap lever target
  if tca_flap_pos < 8 then
    tca_732_flaps_40 = false -- Only allow in final axis position
  end
  local target_flap = 0
  if tca_flap_pos >= 2 and tca_flap_pos < 8 then
    target_flap = tca_flap_pos - 1
  elseif tca_flap_pos == 8 then
    if tca_732_flaps_40 then
      target_flap = 8
    else
      target_flap = 7
    end
  end
  -- Set 737 flap lever on change
  if target_flap ~= last_target_flap then
    aircraft.controls.flaps(target_flap / 8.0)
    last_target_flap = target_flap
  end
end
do_every_frame("tca_732_flaps_on_frame()")
create_command("tca/B732/flap_40", "Flaps 40", "tca_732_flaps_40 = not tca_732_flaps_40", "", "")


local last_autobrake_state = AB_DISARM

function tca_732_autobrake_on_frame()
  if tca == nil or aircraft == nil or aircraft.icao_type ~= "B732" then return end -- Requires aircraft.lua to be initialized
  if autobrake_state ~= last_autobrake_state then
    if autobrake_state < AB_LO then
      aircraft.controls.autobrake(0)
    elseif autobrake_state <= AB_LO then
      aircraft.controls.autobrake(1)
    elseif autobrake_state <= AB_2 then
      aircraft.controls.autobrake(2)
    else
      aircraft.controls.autobrake(3)
    end
    last_autobrake_state = autobrake_state
  end
end
do_every_frame("tca_732_autobrake_on_frame()")



local apu_press_time = 0.0
local APU_HOLD_TIME = 0.5  -- seconds for long press

function tca_732_apu_toggle_press()
  apu_press_time = os.clock()
end

function tca_732_apu_toggle_hold()
  if apu_press_time and os.clock() > (apu_press_time + APU_HOLD_TIME) and aircraft.apu() == 1 then
    aircraft.apu("start")
  end
end

function tca_732_apu_toggle_release()
  if aircraft.apu() == 1 then
    aircraft.apu("off")
  else
    aircraft.apu("on")
  end
end

create_command("tca/B732/apu_toggle",
    "Toggle APU On/Off/Start",
    "tca_732_apu_toggle_press()",
    "tca_732_apu_toggle_hold()",
    "tca_732_apu_toggle_release()")
