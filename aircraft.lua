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
      autopilot = {
        fd = {}
      }, -- TODO
      -- Flight controls ------------------------------------------------------
      controls = {},
      engine = {},
      apu = {},
      -- Misc -----------------------------------------------------------------
      xpdr = function() end,
      wxr = function() end,
    }


    -- Override functions for specific aircraft
    if PLANE_ICAO == "A306" then
      aircraft.A306 = {}
      aircraft.lights.beacon = function(state)
        if state == "on" then
          command_once("A300/LIGHTS/beacon_light_on")
        elseif state == "off" then
          command_once("A300/LIGHTS/beacon_light_off")
        elseif state == "toggle" then
          local current_state = aircraft.lights.beacon()
          if current_state then
            aircraft.lights.beacon("off")
          else
            aircraft.lights.beacon("on")
          end
        end
        return get("A300/lights/beacon_light_on") > 0.5
      end
      aircraft.lights.strobe = function(state)
        if state == "on" then
          command_once("A300/LIGHTS/strobe_lights_on")
        elseif state == "off" then
          command_once("A300/LIGHTS/strobe_lights_off")
        elseif state == "toggle" then
          local current_state = aircraft.lights.strobe()
          if current_state then
            aircraft.lights.strobe("off")
          else
            aircraft.lights.strobe("on")
          end
        end
        return get("A300/lights/strobe_light_on") > 1.5
      end
      aircraft.lights.taxi.all = function(state)
        if state == "on" then
          command_once("A300/LIGHTS/nose_light_taxi")
          command_once("A300/LIGHTS/rwy_turnoff_left_on")
          command_once("A300/LIGHTS/rwy_turnoff_right_on")
        elseif state == "off" then
          command_once("A300/LIGHTS/nose_light_off")
          command_once("A300/LIGHTS/rwy_turnoff_left_off")
          command_once("A300/LIGHTS/rwy_turnoff_right_off")
        elseif state == "toggle" then
          local current_state = aircraft.lights.taxi.all()
          if current_state then aircraft.lights.taxi.all("off") else aircraft.lights.taxi.all("on") end
        end
        return get("A300/lights/rwy_turnoff_left_switch") > 0.5
      end
      aircraft.lights.landing.all = function(state)
        if state == "on" then
          command_once("A300/LIGHTS/landing_lights_on")
        elseif state == "off" then
          command_once("A300/LIGHTS/landing_lights_off")
        elseif state == "toggle" then
          local current_state = aircraft.lights.landing.all()
          if current_state then
            aircraft.lights.landing.all("off")
          else
            aircraft.lights.landing.all("on")
          end
        end
        return get("A300/lights/landing_light_left_switch") > 1.5
      end
      aircraft.xpdr = function(mode)
        if mode == "stdby" then
          command_once("A300/TCAS/pedestal_mode_down")
          command_once("A300/TCAS/pedestal_mode_down")
          command_once("A300/TCAS/pedestal_mode_down")
        elseif mode == "altoff" then
          command_once("A300/TCAS/pedestal_mode_down")
          command_once("A300/TCAS/pedestal_mode_down")
          command_once("A300/TCAS/pedestal_mode_down")
          command_once("A300/TCAS/pedestal_mode_up")
        elseif mode == "alton" then
          command_once("A300/TCAS/pedestal_mode_down")
          command_once("A300/TCAS/pedestal_mode_down")
          command_once("A300/TCAS/pedestal_mode_down")
          command_once("A300/TCAS/pedestal_mode_up")
        elseif mode == "ta" then
          command_once("A300/TCAS/pedestal_mode_up")
          command_once("A300/TCAS/pedestal_mode_up")
          command_once("A300/TCAS/pedestal_mode_up")
        elseif mode == "tara" then
          command_once("A300/TCAS/pedestal_mode_up")
          command_once("A300/TCAS/pedestal_mode_up")
          command_once("A300/TCAS/pedestal_mode_up")
          command_once("A300/TCAS/pedestal_mode_down")
        end
        local mode_name = {"stdby", "alton", "tara", "ta"}
        local mode_number = get("A300/TCAS/tcas_mode_pedestal")
        return mode_name[mode_number]
      end
      aircraft.wxr = function(state)
        if state == "off" then
          command_once("A300/WXR/system_down")
          command_once("A300/WXR/system_down")
          command_once("A300/WXR/system_up")
        elseif state == "on" then
          command_once("A300/WXR/system_down")
          command_once("A300/WXR/system_down")
        end
        return get("A300/WXR/system") ~= 1
      end
      aircraft.autopilot.fd.all = function(state)
        if state == "off" then
          command_once("A300/MCDU/fdir1_down")
        elseif state == "on" then
          command_once("A300/MCDU/fdir1_up")
        elseif state == "toggle" then
          if aircraft.autopilot.fd.all() then
            aircraft.autopilot.fd.all("off")
          else
            aircraft.autopilot.fd.all("on")
          end
        end
        return get("A300/MCDU/fdir1_on") > 0.25
      end
      aircraft.autopilot.toga = function()
        command_once("A300/MCDU/takeoff_goaround_trigger")
      end
      aircraft.autopilot.at_disco = function()
        command_once("A300/MCDU/disconnect_at")
      end
      aircraft.engine.antiice = function(state, engine)
        engine = engine or "all"
        if engine == "all" then
          aircraft.engine.antiice(state, 1)
          aircraft.engine.antiice(state, 2)
        else
          if state == "on" then
            if aircraft.engine.antiice(nil, engine) == false then
              aircraft.engine.antiice("toggle", engine)
            end
          elseif state == "off" then
            if aircraft.engine.antiice(nil, engine) == true then
              aircraft.engine.antiice("toggle", engine)
            end
          elseif state == "toggle" then
            command_once("A300/ICE/eng" .. engine .. "_toggle")
          end
        end
        if engine == "all" then engine = 1 end
        return get("A300/ICE/eng"..engine.."_aice_running_timer") > 0
      end
      aircraft.apu = function(state)
        if state == "on" and aircraft.apu() < 0.5 then
          command_once("A300/apu_msw_switch")
        elseif state == "off" and aircraft.apu() > 0.5 then
          command_once("A300/apu_msw_switch")
        elseif state == "start" then
          command_once("A300/apu_start_button")
        end
        return get("A300/APU/master_switch_button")
      end
      aircraft.controls.parkbrake = function(state)
        local is_on = get("A300/brakes/parking_brake_status") > 0.5
        if is_on and state == "off" then
          command_once("sim/flight_controls/brakes_toggle_max")
        elseif not is_on and state == "on" then
          command_once("sim/flight_controls/brakes_toggle_max")
        end
      end
      aircraft.controls.autobrake = function(state)
        local low_lt = get("A300/brakes/autobrake_low_light") > 0.5
        local med_lt = get("A300/brakes/autobrake_mid_light") > 0.5
        local max_lt = get("A300/brakes/autobrake_max_light") > 0.5
        if state == "off" then
          if low_lt then command_once("A300/brakes/autobrake_low_toggle") end
          if med_lt then command_once("A300/brakes/autobrake_medium_toggle") end
          if max_lt then command_once("A300/brakes/autobrake_max_toggle") end
        elseif state == "low" and not low_lt then
          command_once("A300/brakes/autobrake_low_toggle")
        elseif state == "med" and not med_lt then
          command_once("A300/brakes/autobrake_medium_toggle")
        elseif state == "max" and not max_lt then
          command_once("A300/brakes/autobrake_max_toggle")
        end
      end
      aircraft.on_frame.autobrake = function()
        if autobrake_state ~= nil then  -- Provided by tca-autobrake.lua
          if autobrake_state == AB_DISARM then
            aircraft.controls.autobrake("off")
          elseif autobrake_state == AB_BTV then
            aircraft.controls.autobrake("max")
          elseif autobrake_state == AB_LO then
            aircraft.controls.autobrake("low")
          else
            aircraft.controls.autobrake("med")
          end
        end
      end
      aircraft.controls.wiper = function(state)
        if state == "on" then
          aircraft.controls.wiper("incr")
          aircraft.controls.wiper("incr")
        elseif state == "off" then
          aircraft.controls.wiper("decr")
          aircraft.controls.wiper("decr")
        elseif state == "incr" then
          command_once("A300/wiper_left_up")
          command_once("A300/wiper_right_up")
        elseif state == "decr" then
          command_once("A300/wiper_left_down")
          command_once("A300/wiper_right_down")
        end
      end
      aircraft.controls.speedbrake = function(state)
        if state == "down" then
          set("sim/cockpit2/controls/speedbrake_ratio", 0)
        elseif state == "arm" and get("sim/cockpit2/controls/speedbrake_ratio") >= 0 then
          command_once("sim/flight_controls/speed_brakes_up_one")
        else
          set("sim/cockpit2/controls/speedbrake_ratio", state)
        end
        return get("sim/cockpit2/controls/speedbrake_ratio")
      end
      aircraft.on_frame.speedbrake = function()
        if tca then
          if tca.axis.speedbrake < 0.125 and speedbrake_prev ~= 0 then
            speedbrake_prev = 0
            aircraft.controls.speedbrake("down")
          elseif tca.axis.speedbrake >= 0.125 and tca.axis.speedbrake < 0.375 and speedbrake_prev ~= 1 then
            speedbrake_prev = 1
            aircraft.controls.speedbrake("arm")
          elseif tca.axis.speedbrake >= 0.375 and tca.axis.speedbrake < 0.50 then
            speedbrake_prev = 2
            aircraft.controls.speedbrake(0.0 + (0.50 - 0.0) * (tca.axis.speedbrake - 0.375) / (0.50 - 0.375))
          elseif tca.axis.speedbrake >= 0.50  then
            speedbrake_prev = 2
            aircraft.controls.speedbrake(tca.axis.speedbrake)
          end
        end
      end
      aircraft.on_frame.armrest = function()
        if get("A300/armrest_captain_status") == 0.0 then
          command_once("A300/armrest_captain_toggle")
        end
      end
      aircraft.engine.starter = function(state, engine)
        if state == "on" and (engine == 1 or engine == 2) then
          command_once("A300/starter"..engine.."_toggle")
        end
      end
    end


    if PLANE_ICAO == "A320" then
      aircraft.a320 = {}
      aircraft.on_frame.dataref = function()
        if aircraft.a320.initialized then
          return
        elseif aircraft.a320.beacon == nil then
          aircraft.a320.beacon = XPLMFindDataRef("a320/Overhead/LightBeacon")
        elseif aircraft.a320.strobe == nil then
          aircraft.a320.strobe = XPLMFindDataRef("a320/Overhead/LightStrobe")
        elseif aircraft.a320.xpdr_mode == nil then
          aircraft.a320.xpdr_mode = XPLMFindDataRef("a320/Pedestal/ATC_Mode")
        elseif aircraft.a320.tcas_mode == nil then
          aircraft.a320.tcas_mode = XPLMFindDataRef("a320/Pedestal/TCAS_Traffic")
        elseif aircraft.a320.wxr == nil then
          aircraft.a320.wxr = XPLMFindDataRef("a320/Pedestal/WR_POWER")
        else
          aircraft.a320.initialized = true
        end
      end
      aircraft.lights.beacon = function(state)
        if aircraft.a320.beacon == nil then
          return nil
        else
          if state == "on" then
            XPLMSetDataf(aircraft.a320.beacon, 1)
          elseif state == "off" then
            XPLMSetDataf(aircraft.a320.beacon, 0)
          elseif state == "toggle" then
            local current_state = aircraft.lights.beacon()
            if current_state then
              aircraft.lights.beacon("off")
            else
              aircraft.lights.beacon("on")
            end
          end
          return XPLMGetDataf(aircraft.a320.beacon) > 0.5
        end
      end
      aircraft.lights.strobe = function(state)
        if aircraft.a320.strobe == nil then
          return nil
        else
          if state == "on" then
            XPLMSetDataf(aircraft.a320.strobe, 2)
          elseif state == "off" then
            XPLMSetDataf(aircraft.a320.strobe, 1)
          elseif state == "toggle" then
            local current_state = aircraft.lights.strobe()
            if current_state then
              aircraft.lights.strobe("off")
            else
              aircraft.lights.strobe("on")
            end
          end
          return XPLMGetDataf(aircraft.a320.strobe) > 1.5
        end
      end
      aircraft.xpdr = function(mode)
        if aircraft.a320.xpdr_mode == nil or aircraft.a320.tcas_mode == nil then return nil end
        if mode == "stdby" then
          XPLMSetDataf(aircraft.a320.xpdr_mode, 0)
          XPLMSetDataf(aircraft.a320.tcas_mode, 0)
        elseif mode == "altoff" then
          XPLMSetDataf(aircraft.a320.xpdr_mode, 2)
          XPLMSetDataf(aircraft.a320.tcas_mode, 0)
        elseif mode == "alton" then
          XPLMSetDataf(aircraft.a320.xpdr_mode, 2)
          XPLMSetDataf(aircraft.a320.tcas_mode, 0)
        elseif mode == "ta" then
          XPLMSetDataf(aircraft.a320.xpdr_mode, 2)
          XPLMSetDataf(aircraft.a320.tcas_mode, 1)
        elseif mode == "tara" then
          XPLMSetDataf(aircraft.a320.xpdr_mode, 2)
          XPLMSetDataf(aircraft.a320.tcas_mode, 2)
        end
        local mode_name = {"stdby", "altoff", "alton", "ta", "tara"}
        local mode_number = XPLMGetDataf(aircraft.a320.xpdr_mode) + 1
        if mode_number > 0 then
          mode_number = mode_number + XPLMGetDataf(aircraft.a320.tcas_mode)
        end
        return mode_name[mode_number]
      end
      aircraft.wxr = function(state)
        if aircraft.a320.wxr == nil then return nil end
        if state == "off" then
          XPLMSetDataf(aircraft.a320.wxr, 1)  -- 1/0 swapped intentionally!
        elseif state == "on" then
          XPLMSetDataf(aircraft.a320.wxr, 0)
        end
        return XPLMGetDataf(aircraft.a320.wxr) > 0.5
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
        elseif mode == "stdby" then
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
        elseif state == "off" then
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


    if PLANE_ICAO == "B744" then
      aircraft.b744 = {
        toggle_switch = dataref_table("laminar/B747/toggle_switch/position"),
        transponder_mode = dataref_table("sim/cockpit/radios/transponder_mode"),
        fuel_switch_pos = dataref_table("laminar/B747/fuel/fuel_control/toggle_sw_pos"),
        throttle = dataref_table("sim/cockpit2/engine/actuators/throttle_ratio"),
        speedbrake = dataref_table("sim/cockpit2/controls/speedbrake_ratio"),
        autobrake = dataref_table("laminar/B747/gear/autobrakes/sel_dial_pos"),
        flaps = dataref_table("sim/cockpit2/controls/flap_ratio"),
      }
      aircraft.lights.beacon = function(state)
        if state == "on" and not aircraft.lights.beacon() then
          command_once("laminar/B747/toggle_switch/beacon_light_down")
        elseif state == "off" and aircraft.lights.beacon() then
          command_once("laminar/B747/toggle_switch/beacon_light_up")
        elseif state == "toggle" then
          if aircraft.lights.beacon() then
            aircraft.lights.beacon("off")
          else
            aircraft.lights.beacon("on")
          end
        end
        return aircraft.b744.toggle_switch[8] ~= 0
      end
      aircraft.lights.landing.left_outboard = function(state)
        local sw = aircraft.b744.toggle_switch[1] ~= 0
        if (state == "on" and not sw) or (state == "off" and sw) or (state == "toggle") then
          command_once("laminar/B747/toggle_switch/landing_light_OBL")
        end
        return sw
      end
      aircraft.lights.landing.right_outboard = function(state)
        local sw = aircraft.b744.toggle_switch[2] ~= 0
        if (state == "on" and not sw) or (state == "off" and sw) or (state == "toggle") then
          command_once("laminar/B747/toggle_switch/landing_light_OBR")
        end
        return sw
      end
      aircraft.lights.landing.left_inboard = function(state)
        local sw = aircraft.b744.toggle_switch[3] ~= 0
        if (state == "on" and not sw) or (state == "off" and sw) or (state == "toggle") then
          command_once("laminar/B747/toggle_switch/landing_light_IBL")
        end
        return sw
      end
      aircraft.lights.landing.right_inboard = function(state)
        local sw = aircraft.b744.toggle_switch[4] ~= 0
        if (state == "on" and not sw) or (state == "off" and sw) or (state == "toggle") then
          command_once("laminar/B747/toggle_switch/landing_light_IBR")
        end
        return sw
      end
      aircraft.lights.landing.all = function(state)
        if state == "on" then
          aircraft.lights.landing.left_outboard("on")
          aircraft.lights.landing.left_inboard("on")
          aircraft.lights.landing.right_inboard("on")
          aircraft.lights.landing.right_outboard("on")
        elseif state == "off" then
          aircraft.lights.landing.left_outboard("off")
          aircraft.lights.landing.left_inboard("off")
          aircraft.lights.landing.right_inboard("off")
          aircraft.lights.landing.right_outboard("off")
        elseif state == "toggle" then
          if aircraft.lights.landing.all() then
            aircraft.lights.landing.all("off")
          else
            aircraft.lights.landing.all("on")
          end
        end
        return aircraft.lights.landing.left_outboard()
      end
      aircraft.lights.taxi.l = function(state)
        local sw = aircraft.b744.toggle_switch[5] ~= 0
        if (state == "on" and not sw) or (state == "off" and sw) or (state == "toggle") then
          command_once("laminar/B747/toggle_switch/rwy_tunoff_L")  -- sic
        end
        return sw
      end
      aircraft.lights.taxi.r = function(state)
        local sw = aircraft.b744.toggle_switch[6] ~= 0
        if (state == "on" and not sw) or (state == "off" and sw) or (state == "toggle") then
          command_once("laminar/B747/toggle_switch/rwy_tunoff_R")  -- sic
        end
        return sw
      end
      aircraft.lights.taxi.taxi = function(state)
        local sw = aircraft.b744.toggle_switch[7] ~= 0
        if (state == "on" and not sw) or (state == "off" and sw) or (state == "toggle") then
          command_once("laminar/B747/toggle_switch/taxi_light")
        end
        return sw
      end
      aircraft.lights.taxi.all = function(state)
        if state == "on" then
          aircraft.lights.taxi.l("on")
          aircraft.lights.taxi.r("on")
          aircraft.lights.taxi.taxi("on")
        elseif state == "off" then
          aircraft.lights.taxi.l("off")
          aircraft.lights.taxi.r("off")
          aircraft.lights.taxi.taxi("off")
        elseif state == "toggle" then
          if aircraft.lights.taxi.all() then
            aircraft.lights.taxi.all("off")
          else
            aircraft.lights.taxi.all("on")
          end
        end
        return aircraft.lights.taxi.taxi()
      end
      aircraft.lights.strobe = function(state)
        local sw = aircraft.b744.toggle_switch[10] ~= 0
        if (state == "on" and not sw) or (state == "off" and sw) or (state == "toggle") then
          command_once("laminar/B747/toggle_switch/strobe_light")
        end
        return sw
      end
      aircraft.xpdr = function(mode)
        if mode == "alton" then
          aircraft.b744.xpdr_tgt = 2
        elseif mode == "altoff" then
          aircraft.b744.xpdr_tgt = 2
        elseif mode == "tara" then
          aircraft.b744.xpdr_tgt = 3
        elseif mode == "stdby" then
          aircraft.b744.xpdr_tgt = 1
        end
        local mode_name = {"stdby", "alton", "tara"}
        mode = aircraft.b744.transponder_mode[0]
        return mode_name[mode + 1]
      end
      aircraft.on_frame.xpdr = function()
        if aircraft.b744.xpdr_tgt ~= nil then
          local mode = aircraft.b744.transponder_mode[0]
          if mode > aircraft.b744.xpdr_tgt then
            command_once("laminar/B747/flt_mgmt/transponder/mode_sel_dial_dn")
          elseif mode < aircraft.b744.xpdr_tgt then
            command_once("laminar/B747/flt_mgmt/transponder/mode_sel_dial_up")
          else
            aircraft.b744.xpdr_tgt = nil
          end
        end
      end
      aircraft.wxr = function(state)
        if (state == "on" and not aircraft.wxr()) or (state == "off" and aircraft.wxr()) then
          command_once("laminar/B747/nd/wxr/capt/switch")
        end
        return get("sim/cockpit/switches/EFIS_shows_weather") ~= 0
      end
      aircraft.engine.fuel = {}
      for i = 1, 4 do
        aircraft.engine.fuel[i] = function(state)
          if (state == "on" and not aircraft.engine.fuel[i]) or (state == "off" and aircraft.engine.fuel[i]) then
            command_once("laminar/B747/fuel/fuel_control_" .. i .. "/toggle_switch")
          end
          return aircraft.b744.fuel_switch_pos[i - 1] > 0.5
        end
      end
      aircraft.controls.autobrake = function(state)
        if state == "rto" then
          aircraft.b744.autobrake[0] = 0
        elseif state == "disarm" then
          aircraft.b744.autobrake[0] = 2
        elseif state == "off" or state == 0 then
          aircraft.b744.autobrake[0] = 1
        elseif state == "max" then
          aircraft.b744.autobrake[0] = 7
        elseif type(state) == 'number' then
        end
        local autobrake_name = {"rto", 0, "disarm", 1, 2, 3, 4, 5}
        return autobrake_name[aircraft.b744.autobrake[0] + 1]
      end
      aircraft.autopilot.toga = function()
        if aircraft.b744.flaps[0] > 1.0 / 6 * 4 then
          aircraft.b744.flaps[0] = 1.0 / 6 * 4
        end
        command_once("sim/engines/TOGA_power")
      end
      aircraft.autopilot.at_disco = function()
        command_once("laminar/B747/autopilot/button_switch/autothrottle_disco_L")
      end
      aircraft.on_frame.tca_throttle = function()
        if tca ~= nil then  -- tca-axes.lua present and initialized
          local ratio = {0.0, 0.0, 0.0, 0.0}
          for i = 1, 2 do
            if aircraft.engine.fuel[i]() then
              ratio[i] = tca.axis.throttle1
            end
          end
          for i = 3, 4 do
            if aircraft.engine.fuel[i]() then
              ratio[i] = tca.axis.throttle2
            end
          end
          for i = 1, 4 do
            aircraft.b744.throttle[i - 1] = ratio[i]
          end
        end
      end
      aircraft.on_frame.tca_speedbrake = function()
        if tca ~= nil then
          local flt_detent = 0.447059
          local sbrk = tca.axis.speedbrake
          if sbrk < 0.125 then
            aircraft.b744.speedbrake[0] = 0.0
          elseif sbrk < 0.25 + 0.05 then
            if aircraft.b744.speedbrake[0] >= 0 and aircraft.b744.speedbrake[0] < 0.10 then
              aircraft.b744.speedbrake[0] = -0.5
            end
          elseif sbrk < 0.75 - 0.05 then
            aircraft.b744.speedbrake[0] = (sbrk - (0.25+0.05)) / ((0.75-0.05) - (0.25+0.05)) * flt_detent
          elseif sbrk < 0.75 + 0.125 then
            aircraft.b744.speedbrake[0] = flt_detent
          else
            aircraft.b744.speedbrake[0] = 1.0
          end
        end
      end
      aircraft.on_frame.tca_flaps = function()
        if tca ~= nil then
          if tca.axis.flaps < 0.125 then
            aircraft.b744.flaps[0] = 0
          elseif tca.axis.flaps < 0.25 + 0.125 then
            aircraft.b744.flaps[0] = 1.0 / 6
          elseif tca.axis.flaps < 0.50 + 0.125 then
            aircraft.b744.flaps[0] = 1.0 / 6 * 2
          elseif tca.axis.flaps < 0.75 + 0.125 then
            aircraft.b744.flaps[0] = 1.0 / 6 * 3
          elseif aircraft.b744.flaps[0] < 1.0 / 6 * 4 then
            aircraft.b744.flaps[0] = 1.0 / 6 * 4
          end
        end
      end
      aircraft.b744.extend_flaps_further = function()
        if tca ~= nil and tca.axis.flaps > 0.75 + 0.125 then
          command_once("sim/flight_controls/flaps_down")
        else
          command_once("BetterPushback/start")
        end
      end
      create_command("aircraft/b744/extend_flaps_further", "Further extend flaps",
          "aircraft.b744.extend_flaps_further()", "", "")
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
  if aircraft.xpdr and aircraft.wxr and xpdr_press_time and os.clock() > (xpdr_press_time + XPDR_HOLD_TIME) then
    aircraft.xpdr("stdby")
    aircraft.wxr("off")
    xpdr_press_time = nil
  end
end
function xpdr_wxr_stdby_release()
  if aircraft.xpdr and aircraft.wxr and xpdr_press_time then
    aircraft.xpdr("altoff")
    aircraft.wxr("off")
  end
end
local tara_press_time = nil  -- Not sure why, but required for B744.......
local TARA_HOLD_TIME = 0.01
function xpdr_wxr_tara_press()
  tara_press_time = os.clock()
end
function xpdr_wxr_tara_hold()
  if aircraft.xpdr and aircraft.wxr and tara_press_time and os.clock() > (tara_press_time + TARA_HOLD_TIME) then
    aircraft.xpdr("tara")
    aircraft.wxr("on")
    tara_press_time = nil
  end
end
function xpdr_wxr_tara_release()
end
create_command("aircraft/xpdr_wxr/stdby_altoff",
    "Transponder ALT OFF/STDBY, WXR off",
    "xpdr_wxr_stdby_press()",
    "xpdr_wxr_stdby_hold()",
    "xpdr_wxr_stdby_release()")
create_command("aircraft/xpdr_wxr/tara",
    "Transponder TA/RA, WXR on",
    "xpdr_wxr_tara_press()",
    "xpdr_wxr_tara_hold()",
    "xpdr_wxr_tara_release()")


local toga_press_time = nil
local TOGA_HOLD_TIME = 0.5  -- seconds for long press
function aircraft_toga_press()
  toga_press_time = os.clock()
end
function aircraft_toga_hold()
  if aircraft.autopilot.at_disco and toga_press_time and os.clock() > (toga_press_time + TOGA_HOLD_TIME) then
    aircraft.autopilot.at_disco()
    toga_press_time = nil
  end
end
function aircraft_toga_release()
  if aircraft.autopilot.toga and toga_press_time then
    aircraft.autopilot.toga()
  end
end
create_command("aircraft/autopilot/toga_disco",
    "TO/GA or AT Disconnect",
    "aircraft_toga_press()",
    "aircraft_toga_hold()",
    "aircraft_toga_release()")


function aircraft_fd_toggle()
  if aircraft.autopilot.fd.all then
    aircraft.autopilot.fd.all("toggle")
  end
end
create_command("aircraft/autopilot/fd/toggle_all",
    "Toggle all FDs",
    "aircraft_fd_toggle()", "", "")


function aircraft_s1_or_apu_press()
  local ign = (get("A300/engine_ignition_switch") or 99) < 2
  if ign then
    aircraft.engine.starter("on", 1)
  else
    aircraft_apu_toggle_press()
  end
end
function aircraft_s1_or_apu_hold()
  local ign = (get("A300/engine_ignition_switch") or 99) < 2
  if ign then
  else
    aircraft_apu_toggle_hold()
  end
end
function aircraft_s1_or_apu_release()
  local ign = (get("A300/engine_ignition_switch") or 99) < 2
  if ign then
  else
    aircraft_apu_toggle_release()
  end
end
create_command("aircraft/s1_or_apu",
    "Start 1 or APU Off/On/Start",
    "aircraft_s1_or_apu_press()",
    "aircraft_s1_or_apu_hold()",
    "aircraft_s1_or_apu_release()")


function aircraft_s2_or_aice()
  local ign = (get("A300/engine_ignition_switch") or 99) < 2
  if ign then
    aircraft.engine.starter("on", 2)
  else
    aircraft.engine.antiice('toggle')
  end
end
create_command("aircraft/s2_or_aice",
    "Start 2 or Anti-Ice Toggle",
    "aircraft_s2_or_aice()", "", "")
