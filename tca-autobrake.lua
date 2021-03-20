-- Public interface for other scripts
AB_DISARM = 0
AB_BTV = 1
AB_LO = 2
AB_2 = 3
AB_3 = 4
AB_HI = 5
autobrake_state = AB_DISARM


-- Internal logic
local AUTOBRAKE_DISARM_TIME = 0.2  -- How long no autobrake should be selected to disarm
local autobrake_off_time = nil  -- When all autobrake commands disappeared

function tca_autobrake_on_frame()
  -- Autobrake disarming
  if autobrake_off_time and os.clock() > autobrake_off_time + AUTOBRAKE_DISARM_TIME then
    autobrake_off_time = nil
    autobrake_state = AB_DISARM
  end
end
do_every_frame("tca_autobrake_on_frame()")


-- X-Plane commands
function tca_autobrake_btv_begin()
  autobrake_state = AB_BTV
  autobrake_off_time = nil
end
function tca_autobrake_btv_end()
  autobrake_off_time = os.clock()
end
create_command("tca/autobrake/btv", "TCA Autobrake BTV (Hold)",
    "tca_autobrake_btv_begin()", "", "tca_autobrake_btv_end()")

function tca_autobrake_lo_begin()
  autobrake_state = AB_LO
  autobrake_off_time = nil
end
function tca_autobrake_lo_end()
  autobrake_off_time = os.clock()
end
create_command("tca/autobrake/lo", "TCA Autobrake LO (Hold)",
    "tca_autobrake_lo_begin()", "", "tca_autobrake_lo_end()")

function tca_autobrake_2_begin()
  autobrake_state = AB_2
  autobrake_off_time = nil
end
function tca_autobrake_2_end()
  autobrake_off_time = os.clock()
end
create_command("tca/autobrake/ab2", "TCA Autobrake 2 (Hold)",
    "tca_autobrake_2_begin()", "", "tca_autobrake_2_end()")

function tca_autobrake_3_begin()
  autobrake_state = AB_3
  autobrake_off_time = nil
end
function tca_autobrake_3_end()
  autobrake_off_time = os.clock()
end
create_command("tca/autobrake/ab3", "TCA Autobrake 3 (Hold)",
    "tca_autobrake_3_begin()", "", "tca_autobrake_3_end()")

function tca_autobrake_hi_begin()
  autobrake_state = AB_HI
  autobrake_off_time = nil
end
function tca_autobrake_hi_end()
  autobrake_off_time = os.clock()
end
create_command("tca/autobrake/hi", "TCA Autobrake HI (Hold)",
    "tca_autobrake_hi_begin()", "", "tca_autobrake_hi_end()")
