-- Generic aircraft wrapper to simplify scripts
-- (So essentially what datarefs should have been doing(!))


-- Global aircraft table
-- See default value initialization in aircraft_keep_current() for overview
aircraft = nil

drt_gear_deploy_ratio = dataref_table("sim/flightmodel2/gear/deploy_ratio")

local start_time = os.clock()


function aircraft_keep_current()
  if os.clock() < start_time + 1 then return end
  if aircraft == nil or PLANE_ICAO ~= aircraft.icao_type then
    -- Set up global aircraft struct
    -- Set default values
    aircraft = {
      icao_type = PLANE_ICAO,
      on_frame = {},  -- do_every_frame callbacks
      -- LIGHTS ---------------------------------------------------------------
      lights = {
        nav = function(state)
          if state == "on" then
            command_once("sim/lights/nav_lights_on")
          elseif state == "off" then
            command_once("sim/lights/nav_lights_off")
          elseif state == "toggle" then
            command_once("sim/lights/nav_lights_toggle")
          end
          return get("sim/cockpit2/switches/navigation_lights_on") > 0
        end,
        beacon = function(state)
          if state == "on" then
            command_once("sim/lights/beacon_lights_on")
          elseif state == "off" then
            command_once("sim/lights/beacon_lights_off")
          elseif state == "toggle" then
            command_once("sim/lights/beacon_lights_toggle")
          end
          return get("sim/cockpit2/switches/beacon_on") > 0
        end,
        strobe = function(state)
          if state == "on" then
            command_once("sim/lights/strobe_lights_on")
          elseif state == "off" then
            command_once("sim/lights/strobe_lights_off")
          elseif state == "toggle" then
            command_once("sim/lights/strobe_lights_toggle")
          end
          return get("sim/cockpit2/switches/strobe_lights_on") > 0
        end,
        landing = {
          all = function(state)
            if state == "on" then
              command_once("sim/lights/landing_lights_on")
            elseif state == "off" then
              command_once("sim/lights/landing_lights_off")
            elseif state == "toggle" then
              command_once("sim/lights/landing_lights_toggle")
            end
            return get("sim/cockpit2/switches/landing_lights_on") > 0
          end,
        },
        taxi = {
          all = function(state)
            if state == "on" then
              command_once("sim/lights/taxi_lights_on")
            elseif state == "off" then
              command_once("sim/lights/taxi_lights_off")
            elseif state == "toggle" then
              command_once("sim/lights/taxi_lights_toggle")
            end
            return get("sim/cockpit2/switches/taxi_light_on") > 0
          end,
        },
      },
      -- Autopilot ------------------------------------------------------------
      autopilot = {}, -- TODO
      -- Flight controls ------------------------------------------------------
      controls = {},
      engine = {},
      apu = {},
      -- Misc -----------------------------------------------------------------
      xpdr = {},
      wxr = {},
    }


    -- Override functions for specific aircraft
    if PLANE_ICAO == "A320" then
      aircraft.lights.beacon = function(state)
        local xplm_beacon = XPLMFindDataRef("a320/Overhead/LightBeacon")
        if xplm_beacon ~= nil then
          aircraft.lights.beacon = function(state)
            if state == "on" then
              XPLMSetDataf(xplm_beacon, 1)
            elseif state == "toggle" then
              local current_state = aircraft.lights.beacon()
              if current_state then
                aircraft.lights.beacon("off")
              else
                aircraft.lights.beacon("on")
              end
            else
              XPLMSetDataf(xplm_beacon, 0)
            end
            return XPLMGetDataf(xplm_beacon)
          end
          return aircraft.lights.beacon(state) > 0.5
        end
      end
    end


    if PLANE_ICAO == "A321" then
      drt_a321_lights = dataref_table("AirbusFBW/OHPLightSwitches")
      aircraft.lights.beacon = function(state)
        if state == "on" then
          drt_a321_lights[0] = 1
        elseif state == "off" then
          drt_a321_lights[0] = 0
        elseif state == "toggle" then
          local current_state = aircraft.lights.beacon()
          if current_state then
            aircraft.lights.beacon("off")
          else
            aircraft.lights.beacon("on")
          end
        end
        return drt_a321_lights[0] > 0.5
      end
      aircraft.lights.strobe = function(state)
        if state == "on" then
          drt_a321_lights[7] = 2
        elseif state == "auto" then
          drt_a321_lights[7] = 1
        elseif state == "off" then
          drt_a321_lights[7] = 0
        elseif state == "toggle" then
          local current_state = aircraft.lights.strobe()
          if current_state then
            aircraft.lights.strobe("off")
          else
            aircraft.lights.strobe("on")
          end
        end
        return drt_a321_lights[7] > 1.5
      end
      aircraft.lights.landing.all = function(state)
        if state == "on" then
          drt_a321_lights[4] = 2
          drt_a321_lights[5] = 2
        elseif state == "off" then
          drt_a321_lights[4] = 0
          drt_a321_lights[5] = 0
        elseif state == "toggle" then
          local current_state = aircraft.lights.landing.all()
          if current_state then
            aircraft.lights.landing.all("off")
          else
            aircraft.lights.landing.all("on")
          end
        end
        return drt_a321_lights[4] > 1.5
      end
      aircraft.lights.taxi.all = function(state)
        if state == "on" then
          drt_a321_lights[3] = 1
          drt_a321_lights[6] = 1
        elseif state == "off" then
          drt_a321_lights[3] = 0
          drt_a321_lights[6] = 0
        elseif state == "toggle" then
          local current_state = aircraft.lights.taxi.all()
          if current_state then aircraft.lights.taxi.all("off") else aircraft.lights.taxi.all("on") end
        end
        return drt_a321_lights[3] > 0.5
      end
      aircraft.engine.antiice = function(state, engine)
        engine = engine or "all"
        if engine == "all" then
          aircraft.engine.antiice(state, 1)
          aircraft.engine.antiice(state, 2)
        else
          if state == "on" then
            command_once("toliss_airbus/antiicecommands/ENG" .. engine .. "On")
            logMsg("toliss_airbus/antiicecommands/ENG" .. engine .. "On")
          elseif state == "off" then
            command_once("toliss_airbus/antiicecommands/ENG" .. engine .. "Off")
            logMsg("toliss_airbus/antiicecommands/ENG" .. engine .. "Off")
          elseif state == "toggle" then
            if aircraft.engine.antiice() then aircraft.engine.antiice("off") else aircraft.engine.antiice("on") end
          end
        end
        return get("ckpt/lamp/119") > 0.5
      end
      aircraft.controls.speedbrake = function(state)
        if state == "down" then
          command_end("toliss_airbus/speedbrake/hold_armed")
          set("sim/cockpit2/controls/speedbrake_ratio", 0)
        elseif state == "arm" then
          command_begin("toliss_airbus/speedbrake/hold_armed")
        else
          command_end("toliss_airbus/speedbrake/hold_armed")
          set("sim/cockpit2/controls/speedbrake_ratio", state)
        end
        return get("sim/cockpit2/controls/speedbrake_ratio")
      end
      aircraft.apu = function(state)
        if state == "on" then
          command_once("toliss_airbus/apucommands/MasterOn")
        elseif state == "off" then
          command_once("toliss_airbus/apucommands/MasterOff")
        elseif state == "start" then
          command_once("toliss_airbus/apucommands/StarterOn")
        end
        return get("ckpt/lamp/127")
      end
      aircraft.controls.wiper = function(state)
        if state == "on" then
          set("AirbusFBW/LeftWiperSwitch", 2)
          set("AirbusFBW/RightWiperSwitch", 2)
        elseif state == "off" then
          set("AirbusFBW/LeftWiperSwitch", 0)
          set("AirbusFBW/RightWiperSwitch", 0)
        elseif state == "incr" then
          local next = get("AirbusFBW/LeftWiperSwitch") + 1
          if next > 2 then next = 2 end
          set("AirbusFBW/LeftWiperSwitch", next)
          set("AirbusFBW/RightWiperSwitch", next)
        elseif state == "decr" then
          local next = get("AirbusFBW/LeftWiperSwitch") - 1
          if next < 0 then next = 0 end
          set("AirbusFBW/LeftWiperSwitch", next)
          set("AirbusFBW/RightWiperSwitch", next)
        end
      end
      aircraft.xpdr = function(mode)
        if mode == "altoff" then
          set("AirbusFBW/XPDRTCASMode", 1)
          set("AirbusFBW/XPDRPower", 1)
        elseif mode == "alton" then
          set("AirbusFBW/XPDRTCASMode", 1)
          set("AirbusFBW/XPDRPower", 2)
        elseif mode == "ta" then
          set("AirbusFBW/XPDRTCASMode", 1)
          set("AirbusFBW/XPDRPower", 3)
        elseif mode == "tara" then
          set("AirbusFBW/XPDRTCASMode", 1)
          set("AirbusFBW/XPDRPower", 4)
        else
          set("AirbusFBW/XPDRTCASMode", 0)
          set("AirbusFBW/XPDRPower", 0)
        end
        local mode_name = {"stdby", "altoff", "alton", "ta", "tara"}
        return mode_name[get("AirbusFBW/XPDRPower") + 1]
      end
      aircraft.wxr = function(state)
        if state == "on" then
          if get("ckpt/radar/sys/anim") > 0 then
            command_once("toliss_airbus/WXRadarSwitchLeft")
          end
          set("ckpt/ped/radar/pwr/anim", 2)
        else
          if get("ckpt/radar/sys/anim") < 1 then
            command_once("toliss_airbus/WXRadarSwitchRight")
          end
          set("ckpt/ped/radar/pwr/anim", 0)
        end
        return get("ckpt/radar/sys/anim") ~= 1
      end
      aircraft.on_frame.debug = function()
        --logMsg(get("AirbusFBW/XPDRTCASMode"))
      end
    end


    if PLANE_ICAO == "B732" then
      aircraft.lights.beacon = function(state)
        if state == "on" then
          set("FJS/732/lights/AntiColLightSwitch", 1)
        elseif state == "off" then
          set("FJS/732/lights/AntiColLightSwitch", 0)
        elseif state == "toggle" then
          local current_state = aircraft.lights.beacon()
          if current_state then
            aircraft.lights.beacon("off")
          else
            aircraft.lights.beacon("on")
          end
        end
        return get("FJS/732/lights/AntiColLightSwitch") > 0.5
      end
      aircraft.lights.strobe = function(state)
        if state == "on" then
          set("FJS/732/lights/StrobeLightSwitch", 1)
        elseif state == "off" then
          set("FJS/732/lights/StrobeLightSwitch", 0)
        elseif state == "toggle" then
          local current_state = aircraft.lights.strobe()
          if current_state then
            aircraft.lights.strobe("off")
          else
            aircraft.lights.strobe("on")
          end
        end
        return get("FJS/732/lights/StrobeLightSwitch") > 0.5
      end
      aircraft.lights.landing.all = function(state)
        if state == "on" then
          set("FJS/732/lights/InBoundLLightSwitch1", 1)
          set("FJS/732/lights/InBoundLLightSwitch2", 1)
          set("FJS/732/lights/OutBoundLLightSwitch1", 2)
          set("FJS/732/lights/OutBoundLLightSwitch2", 2)
        elseif state == "off" then
          set("FJS/732/lights/InBoundLLightSwitch1", 0)
          set("FJS/732/lights/InBoundLLightSwitch2", 0)
          set("FJS/732/lights/OutBoundLLightSwitch1", 0)
          set("FJS/732/lights/OutBoundLLightSwitch2", 0)
        elseif state == "toggle" then
          local current_state = aircraft.lights.landing.all()
          if current_state then
            aircraft.lights.landing.all("off")
          else
            aircraft.lights.landing.all("on")
          end
        end
        return get("FJS/732/lights/OutBoundLLightSwitch1") > 1.5
      end
      aircraft.lights.taxi.all = function(state)
        if state == "on" then
          set("FJS/732/lights/TaxiLightSwitch", 1)
          set("FJS/732/lights/RunwayTurnoffSwitch1", 1)
          set("FJS/732/lights/RunwayTurnoffSwitch2", 1)
        elseif state == "off" then
          set("FJS/732/lights/TaxiLightSwitch", 0)
          set("FJS/732/lights/RunwayTurnoffSwitch1", 0)
          set("FJS/732/lights/RunwayTurnoffSwitch2", 0)
        elseif state == "toggle" then
          local current_state = aircraft.lights.taxi.all()
          if current_state then aircraft.lights.taxi.all("off") else aircraft.lights.taxi.all("on") end
        end
        return get("FJS/732/lights/TaxiLightSwitch") > 0.5
      end
      aircraft.autopilot.engage = function()
        if get("FJS/732/Autopilot/APRollEngageSwitch") < 0.5 then
          command_once("FJS/732/Autopilot/AP_RollSelect")
        end
        if get("FJS/732/Autopilot/APPitchEngageSwitch") < 0.5 then
          command_once("FJS/732/Autopilot/AP_PitchSelect")
        end
      end
      aircraft.autopilot.toga = function()
        aircraft.autopilot.do_select_toga = true
      end
      aircraft.on_frame.autopilot_toga = function()
        if aircraft.autopilot.do_select_toga then
          if get("FJS/732/Autopilot/FDModeSelector") > -1 then
            command_once("FJS/732/Autopilot/FD_SelectLeft")
          else
            aircraft.autopilot.do_select_toga = nil
          end
        end
      end
      aircraft.controls.speedbrake = function(state)
        if state == "down" then
          set("FJS/732/FltControls/SpeedBrakeArmed", 0)
          set("sim/cockpit2/controls/speedbrake_ratio", 0)
        elseif state == "arm" then
          set("sim/cockpit2/controls/speedbrake_ratio", 0)
          set("FJS/732/FltControls/SpeedBrakeArmed", 1)
        else
          set("FJS/732/FltControls/SpeedBrakeArmed", 0)
          set("sim/cockpit2/controls/speedbrake_ratio", state)
        end
        return get("sim/cockpit2/controls/speedbrake_ratio")
      end
      aircraft.controls.flaps = function(state)
        set("sim/cockpit2/controls/flap_ratio", state)
        return get("sim/cockpit2/controls/flap_ratio")
      end
      aircraft.controls.autobrake = function(state)
        set("FJS/732/FltControls/AutoBrakeKnob", state)
      end
      aircraft.controls.gear = function(state)
        if state == "up" then
          command_once("sim/flight_controls/landing_gear_up")
        elseif state == "down" then
          command_once("sim/flight_controls/landing_gear_down")
        elseif state == "off" then
          set("FJS/732/FltControls/GearHandlePosition", 1)
        end
      end
      aircraft.on_frame.gear_off = function()
        if get("FJS/732/FltControls/GearHandlePosition") == 2 and drt_gear_deploy_ratio[0] == 0 then
          aircraft.controls.gear("off")
        end
      end
      aircraft.controls.parkbrake = function(state)
        local is_on = get("FJS/732/FltControls/ParkBrakeHandle") > 0.5
        if is_on and state == "off" then
          command_once("sim/flight_controls/brakes_toggle_max")
        elseif not is_on and state == "on" then
          command_once("sim/flight_controls/brakes_toggle_max")
        end
      end
      aircraft.controls.wiper = function(state)
        if state == "on" then
          set("FJS/732/AntiIce/WiperKnob", 4)
        elseif state == "off" then
          set("FJS/732/AntiIce/WiperKnob", -1)
        elseif state == "incr" then
          local next = get("FJS/732/AntiIce/WiperKnob") + 1
          if next > 4 then next = 4 end
          set("FJS/732/AntiIce/WiperKnob", next)
        elseif state == "decr" then
          local next = get("FJS/732/AntiIce/WiperKnob") - 1
          if next < -1 then next = -1 end
          set("FJS/732/AntiIce/WiperKnob", next)
        end
      end
      aircraft.on_frame.wiper = function()
        if get("FJS/732/AntiIce/WiperKnob") < 0 and get("FJS/732/AntiIce/WiperRatio") < 0.001 then
          set("FJS/732/AntiIce/WiperKnob", 0)
        end
      end
      aircraft.engine.fuel = {}
      aircraft.engine.fuel[1] = function(state)
        if state == "on" then
          set("FJS/732/fuel/FuelMixtureLever1", 1)
        elseif state == "off" then
          set("FJS/732/fuel/FuelMixtureLever1", 0)
        end
        return get("FJS/732/fuel/FuelMixtureLever1")
      end
      aircraft.engine.fuel[2] = function(state)
        if state == "on" then
          set("FJS/732/fuel/FuelMixtureLever2", 1)
        elseif state == "off" then
          set("FJS/732/fuel/FuelMixtureLever2", 0)
        end
        return get("FJS/732/fuel/FuelMixtureLever2")
      end
      aircraft.engine.starter = function(state, engine)
        -- Auto-select engine
        if engine == nil then
          if aircraft.engine.fuel[2]() == 0 then
            engine = 2
          elseif aircraft.engine.fuel[1]() == 0 then
            engine = 1
          else
            engine = "all"
          end
        end
        -- Control starter
        if engine == "all" then
          aircraft.engine.starter(state, 1)
          aircraft.engine.starter(state, 2)
        else
          if state == "on" then
            set("FJS/732/Eng/Engine" .. engine .. "StartKnob", -1)
          elseif state == "off" then
            set("FJS/732/Eng/Engine" .. engine .. "StartKnob", 0)
          elseif state == "cont" then
            set("FJS/732/Eng/Engine" .. engine .. "StartKnob", 1)
          elseif state == "flt" then
            set("FJS/732/Eng/Engine" .. engine .. "StartKnob", 2)
          end
        end
      end
      aircraft.engine.antiice = function(state, engine)
        engine = engine or "all"
        if engine == "all" then
          aircraft.engine.antiice(state, 1)
          aircraft.engine.antiice(state, 2)
        else
          if state == "on" then
            set("FJS/732/AntiIce/EngAntiIce" .. engine .. "Switch", 1)
          elseif state == "off" then
            set("FJS/732/AntiIce/EngAntiIce" .. engine .. "Switch", 0)
          elseif state == "toggle" then
            local next = "off"
            if aircraft.engine.antiice(nil, engine) == false then
              next = "on"
            end
            aircraft.engine.antiice(next, engine)
          end
          return get("FJS/732/AntiIce/EngAntiIce" .. engine .. "Switch") > 0.5
        end
      end
      aircraft.apu = function(state)
        if state == "on" then
          set("FJS/732/Elec/APUStartSwitch", 1)
        elseif state == "off" then
          set("FJS/732/Elec/APUStartSwitch", 0)
        elseif state == "start" then
          set("FJS/732/Elec/APUStartSwitch", 2)
        end
        return get("FJS/732/Elec/APUStartSwitch")
      end
    end
  end
end
do_every_frame("aircraft_keep_current()")  -- Should not cost fps, as it returns immediately unless switching aircraft


function aircraft_on_frame()
  if aircraft == nil then return end
  for _, cb in pairs(aircraft.on_frame) do
    cb()
  end
end
do_every_frame("aircraft_on_frame()")


create_command("aircraft/lights/beacon/toggle", "Toggle beacon light", "aircraft.lights.beacon('toggle')", "", "")
create_command("aircraft/lights/strobe/toggle", "Toggle strobe light", "aircraft.lights.strobe('toggle')", "", "")
create_command("aircraft/lights/landing/all/toggle", "Toggle landing lights (all)", "aircraft.lights.landing.all('toggle')", "", "")
create_command("aircraft/lights/taxi/all/toggle", "Toggle taxi lights (all)", "aircraft.lights.taxi.all('toggle')", "", "")

create_command("aircraft/autopilot/engage", "Engage autopilot", "aircraft.autopilot.engage()", "", "")
create_command("aircraft/autopilot/toga", "Autopilot: TOGA", "aircraft.autopilot.toga()", "", "")

create_command("aircraft/controls/parkbrake/on", "Parking brake: SET", "aircraft.controls.parkbrake('on')", "", "")
create_command("aircraft/controls/parkbrake/off", "Parking brake: Release", "aircraft.controls.parkbrake('off')", "", "")

create_command("aircraft/controls/wiper/incr", "Wiper: increase", "aircraft.controls.wiper('incr')", "", "")
create_command("aircraft/controls/wiper/decr", "Wiper: decrease", "aircraft.controls.wiper('decr')", "", "")

create_command("aircraft/engine/1/fuel_on", "Engine 1: fuel ON", "aircraft.engine.fuel[1]('on')", "", "")
create_command("aircraft/engine/2/fuel_on", "Engine 2: fuel ON", "aircraft.engine.fuel[2]('on')", "", "")
create_command("aircraft/engine/1/fuel_off", "Engine 1: fuel OFF", "aircraft.engine.fuel[1]('off')", "", "")
create_command("aircraft/engine/2/fuel_off", "Engine 2: fuel OFF", "aircraft.engine.fuel[2]('off')", "", "")

create_command("aircraft/engine/starter/on", "Engine starter: ON", "aircraft.engine.starter('on')", "", "")
create_command("aircraft/engine/starter/off", "Engine starter: OFF", "aircraft.engine.starter('off')", "", "")
create_command("aircraft/engine/starter/cont", "Engine starter: CONT", "aircraft.engine.starter('cont')", "", "")

create_command("aircraft/engine/antiice/toggle", "Engine anti-ice: toggle", "aircraft.engine.antiice('toggle')", "", "")


local apu_press_time = nil
local APU_HOLD_TIME = 0.5  -- seconds for long press
function aircraft_apu_toggle_press()
  apu_press_time = os.clock()
end
function aircraft_apu_toggle_hold()
  if apu_press_time and os.clock() > (apu_press_time + APU_HOLD_TIME) and aircraft.apu() > 0.5 then
    aircraft.apu("start")
    apu_press_time = nil
  end
end
function aircraft_apu_toggle_release()
  if apu_press_time then
    if aircraft.apu() > 0.5 then
      aircraft.apu("off")
    else
      aircraft.apu("on")
    end
  end
end
create_command("aircraft/apu/toggle",
    "Toggle APU On/Off/Start",
    "aircraft_apu_toggle_press()",
    "aircraft_apu_toggle_hold()",
    "aircraft_apu_toggle_release()")


local xpdr_press_time = nil
local XPDR_HOLD_TIME = 0.5
function xpdr_wxr_stdby_press()
  xpdr_press_time = os.clock()
end
function xpdr_wxr_stdby_hold()
  if xpdr_press_time and os.clock() > (xpdr_press_time + XPDR_HOLD_TIME) then
    aircraft.xpdr("stdby")
    aircraft.wxr("off")
    xpdr_press_time = nil
  end
end
function xpdr_wxr_stdby_release()
  if xpdr_press_time then
    aircraft.xpdr("altoff")
    aircraft.wxr("off")
  end
end
function xpdr_wxr_tara()
  aircraft.xpdr("tara")
  aircraft.wxr("on")
end
create_command("aircraft/xpdr_wxr/stdby_altoff",
    "Transponder ALT OFF/STDBY, WXR off",
    "xpdr_wxr_stdby_press()",
    "xpdr_wxr_stdby_hold()",
    "xpdr_wxr_stdby_release()")
create_command("aircraft/xpdr_wxr/tara",
    "Transponder TA/RA, WXR on",
    "xpdr_wxr_tara()", "", "")
