if PLANE_ICAO == "E170" or PLANE_ICAO == "E195" then
  local HYSTERESIS = 0.1

  -- Speedbrake
  local sbrk = {
    dataref = nil,
    pos = 0,
    hysteresis = 0.1,
  }
  function ejet_speedbrake()
    -- Wait for tca to start
    if tca == nil then
      return
    end
    -- Initialize dataref
    if sbrk.dataref == nil then
      sbrk.dataref = XPLMFindDataRef("sim/cockpit2/controls/speedbrake_ratio")
      return
    end
    -- Control speedbrake lever
    -- local cur_pos = 4.0 * XPLMGetDataf(sbrk.dataref) -- Speedbrake dr reverts to 0.0 sometimes?
    local cur_pos = sbrk.pos
    local tgt_pos = 4.0 * tca.axis.speedbrake
    local thres_inc = cur_pos + 0.5 + sbrk.hysteresis
    local thres_dec = cur_pos - 0.5 - sbrk.hysteresis
    if tgt_pos > thres_inc then
      command_once("SSG/EJET/CONTROLS/SPEED_BRAKE_HANDLE_EXT")
      sbrk.pos = sbrk.pos + 1
      if sbrk.pos > 4 then
        sbrk.pos = 4
      end
    elseif tgt_pos < thres_dec then
      command_once("SSG/EJET/CONTROLS/SPEED_BRAKE_HANDLE_RET")
      sbrk.pos = sbrk.pos - 1
      if sbrk.pos < 0 then
        sbrk.pos = 0
      end
    end
  end
  do_every_frame("ejet_speedbrake()")
  

  -- Flaps
  local flaps = {
    dataref = nil,
    hysteresis = 0.1,
  }
  function ejet_flaps()
    -- Wait for tca to start
    if tca == nil then
      return
    end
    -- Initialize dataref
    if flaps.dataref == nil then
      flaps.dataref = XPLMFindDataRef("sim/cockpit2/controls/flap_ratio")
      return
    end
    -- Control flaps lever
    local cur_pos = 6.0 * XPLMGetDataf(flaps.dataref)
    local thres_inc = cur_pos + 0.5 + flaps.hysteresis
    local thres_dec = cur_pos - 0.5 - flaps.hysteresis
    local tgt_pos
    -- if tca.axis.flaps > 0.5 then
    --   tgt_pos = 4.0 + 2.0 * (tca.axis.flaps - 0.5) / 0.5
    -- else
    --   tgt_pos = 4.0 * (tca.axis.flaps) / 0.5
    -- end
    if tca.axis.flaps < 0.25 then
      tgt_pos = 0.0 + 2.0 * (tca.axis.flaps) / 0.25
    elseif tca.axis.flaps < 0.50 then
      tgt_pos = 2.0 + 1.0 * (tca.axis.flaps - 0.25) / 0.25
    elseif tca.axis.flaps < 0.75 then
      tgt_pos = 3.0 + 2.0 * (tca.axis.flaps - 0.50) / 0.25
    else
      tgt_pos = 5.0 + 1.0 * (tca.axis.flaps - 0.75) / 0.25
    end
    if tgt_pos > thres_inc then
      command_once("sim/flight_controls/flaps_down")
    elseif tgt_pos < thres_dec then
      command_once("sim/flight_controls/flaps_up")
    end
  end
  do_every_frame("ejet_flaps()")
  

  -- Autobrake (bug: off position not reliable)
  local abrk = {
    dataref = nil,
    prev_state = AB_DISARM,
    adjusting = false,
  }
  function ejet_autobrake()
    -- Wait for tca to start
    if tca == nil then
      return
    end
    -- Initialize dataref
    if abrk.dataref == nil then
      abrk.dataref = XPLMFindDataRef("SSG/GEAR/autobrake_on")
      return
    end
    -- Check for changes in tca knob position
    if autobrake_state ~= abrk.prev_state or abrk.adjusting then
      -- Control autobrake knob
      local tgt_pos = autobrake_state
      if autobrake_state == AB_BTV then
        tgt_pos = 0
      elseif autobrake_state == AB_DISARM then
        tgt_pos = 1
      elseif autobrake_state > 4 then
        tgt_pos = 4
      end
      XPLMSetDatai(abrk.dataref, tgt_pos)
    end
  end
  do_every_frame("ejet_autobrake()")
  

  -- Starters
  function ejet_start(engine, to_on)
    set("SSG/EJET/ENG/eng_start" .. engine .. "_cover", 1)
    if to_on then
      set("SSG/EJET/ENG/eng_start" .. engine .. "_sw", 2)
    else
      set("SSG/EJET/ENG/eng_start" .. engine .. "_sw", 0)
    end
  end
  create_command("tca/ejet/starter/start1",
      "Starter 1: START",
      "ejet_start(1, true)", "", "")
  create_command("tca/ejet/starter/start2",
      "Starter 2: START",
      "ejet_start(2, true)", "", "")
  create_command("tca/ejet/starter/off1",
      "Starter 1: OFF",
      "ejet_start(1, false)", "", "")
  create_command("tca/ejet/starter/off2",
      "Starter 2: OFF",
      "ejet_start(2, false)", "", "")


  -- APU (on mode knob)
  function ejet_apu(pos)
    set("SSG/EJET/APU/apu_ctrl_sw", pos)
  end
  create_command("tca/ejet/apu/off", "APU: OFF",
      "ejet_apu(0)", "", "")
  create_command("tca/ejet/apu/on", "APU: ON",
      "ejet_apu(1)", "", "")
  create_command("tca/ejet/apu/start", "APU: START",
      "ejet_apu(2)", "", "")
  

  -- Wipers
  local wiper = {
    pos = 0,
  }
  function ejet_wiper(delta)
    wiper.pos = wiper.pos + delta
    if wiper.pos > 2 then
      wiper.pos = 2
    elseif wiper.pos < 0 then
      wiper.pos = 0
    end
    set("SSG/EJET/WIPER/wiperL_sw", wiper.pos)
    set("SSG/EJET/WIPER/wiperR_sw", wiper.pos)
  end
  create_command("tca/ejet/wiper/inc", "Wiper: increase",
      "ejet_wiper(1)", "", "")
  create_command("tca/ejet/wiper/dec", "Wiper: decrease",
      "ejet_wiper(-1)", "", "")

  -- Park brake
  function ejet_parkbrake(pos)
    set("sim/cockpit2/controls/parking_brake_ratio", pos)
  end
  create_command("tca/ejet/parkbrake/set", "Parking brake: set",
      "ejet_parkbrake(1)", "", "")
  create_command("tca/ejet/parkbrake/release", "Parking brake: release",
      "ejet_parkbrake(0)", "", "")


  -- TO/GA / Disco
  local toga = {
    press_time = 0,
    HOLD_TIME = 0.5,
  }
  function ejet_toga_disco_press()
    toga.press_time = os.clock()
  end
  function ejet_toga_disco_hold()
    if toga.press_time ~= 0 and os.clock() > toga.press_time + toga.HOLD_TIME then
      toga.press_time = 0
      set("ssg/B748/MCP/mcp_at_arm_act", 0)
    end
  end
  function ejet_toga_disco_release()
    if os.clock() <= toga.press_time + toga.HOLD_TIME then
      command_once("SSG/EJET/MCP/Toga")
    end
    toga.press_time = 0
  end
  create_command("tca/ejet/toga/toga_disco", "Combined TO/GA - Disconnect button",
      "ejet_toga_disco_press()", "ejet_toga_disco_hold()", "ejet_toga_disco_release()")
end