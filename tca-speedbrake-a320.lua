-- sim/cockpit2/controls/speedbrake_ratio

if PLANE_ICAO == "A320" then
  local xplm_a320sbrk = XPLMFindDataRef("sim/cockpit2/controls/speedbrake_ratio")

  function tca_speedbrake_a320_on_frame()
    if xplm_a320sbrk == nil then
      xplm_a320sbrk = XPLMFindDataRef("sim/cockpit2/controls/speedbrake_ratio")
      return
    end
    if tca.axis.speedbrake < 0.125 then
      XPLMSetDataf(xplm_a320sbrk, 0.0)
    elseif tca.axis.speedbrake < 0.375 then
      XPLMSetDataf(xplm_a320sbrk, -0.5)
    elseif tca.axis.speedbrake < 0.5 then
      XPLMSetDataf(xplm_a320sbrk, 0.50 * (tca.axis.speedbrake - 0.375) / 0.125)
    else
      XPLMSetDataf(xplm_a320sbrk, tca.axis.speedbrake)
    end
  end
  do_every_frame("tca_speedbrake_a320_on_frame()")
end