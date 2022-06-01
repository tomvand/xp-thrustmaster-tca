-- USER CONFIGURATION
local TCA_AXES_START = 125  -- sim/joystick/joystick_axis_values flap axis index
-- END OF USER CONFIGURATION

local axis_values = dataref_table("sim/joystick/joystick_axis_values")

function tca_axes_on_frame()
  -- Parse throttle values
  local throttle1_raw = axis_values[TCA_AXES_START + 2]
  if throttle1_raw < 0.0 then
    return  -- TCA throttle not connected
  end
  local throttle1 = 0.0
  if throttle1_raw < 0.70 then
    throttle1 = (0.70 - throttle1_raw) / 0.70
  elseif throttle1_raw > 0.80 then
    throttle1 = (0.80 - throttle1_raw) / 0.20
  end
  
  local throttle2_raw = axis_values[TCA_AXES_START + 1]
  local throttle2 = 0.0
  if throttle2_raw < 0.70 then
    throttle2 = (0.70 - throttle2_raw) / 0.70
  elseif throttle2_raw > 0.80 then
    throttle2 = (0.80 - throttle2_raw) / 0.20
  end

  -- Share axis values with other lua scripts
  tca = {
    axis = {
      flaps = axis_values[TCA_AXES_START],
      throttle2_raw = throttle2_raw,
      throttle1_raw = throttle1_raw,
      speedbrake = axis_values[TCA_AXES_START + 3],
      throttle1 = throttle1,
      throttle2 = throttle2
    }
  }
end
do_every_frame("tca_axes_on_frame()")