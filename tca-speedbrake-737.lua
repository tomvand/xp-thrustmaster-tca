-- 737 speedbrake positions
-- laminar/B738/flt_ctrls/speedbrake_lever
-- DN:    0.0
-- Arm:   0.0889
-- FLT:   0.667
-- UP:    1.0

if PLANE_ICAO == "B738" then
  dataref("dr_speedbrake", "laminar/B738/flt_ctrls/speedbrake_lever")

  local speedbrake_detach = 0  -- detach speedbrake during automatic extension until axis is moved to fully extended

  function tca_speedbrake_737_on_frame()
    -- Detach speedbrake on automatic extension until axis is moved to UP
    if speedbrake_detach == false and dr_speedbrake > 0.975 and tca.axis.speedbrake < 0.975 then
      speedbrake_detach = true
    elseif speedbrake_detach == true and tca.axis.speedbrake > 0.975 then
      speedbrake_detach = false
    end
    -- Control speedbrake lever
    if speedbrake_detach == 0 then
      if tca.axis.speedbrake < 0.25 then
        set("laminar/B738/flt_ctrls/speedbrake_lever", 0.0889 * tca.axis.speedbrake / 0.25)
      elseif tca.axis.speedbrake < 0.75 then
        set("laminar/B738/flt_ctrls/speedbrake_lever", 0.0889 + (0.667 - 0.0889) * (tca.axis.speedbrake - 0.25) / 0.50)
      else
        set("laminar/B738/flt_ctrls/speedbrake_lever", 0.667 + (1.0 - 0.667) * (tca.axis.speedbrake - 0.75) / 0.25)
      end
    end
  end
  do_every_frame("tca_speedbrake_737_on_frame()")
end