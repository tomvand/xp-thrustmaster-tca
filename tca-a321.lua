local speedbrake_prev = 0

function tca_a321_speedbrake_on_frame()
  if tca == nil or aircraft == nil or aircraft.icao_type ~= "A321" then return end -- Requires aircraft.lua to be initialized
  -- Control speedbrake lever
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
do_every_frame("tca_a321_speedbrake_on_frame()")