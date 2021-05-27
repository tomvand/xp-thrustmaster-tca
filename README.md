TCA scripts
===========
Joystick .joy configuration file and FlyWithLua scripts for the Thrustmaster TCA Quadrant and add-on. Includes scripts for the FF A320 and Zibo 737.

Notes
-----
**Caution: the buttons in X-Plane do not match those in Window's USB controls panel!!**
For instance, detent buttons are missing; autobrake disarm is missing, parking brake off is missing....
  - Caused by removed options in .joy file. Probably easiest to restore this, then use FlyWithLua for logic.

### TCA Q-Eng 1&2
| Axis      | Description                   |
| --------- | ----------------------------- |
| X         | Throttle 1 (left->increase)
| Y         | Throttle 2 (up->increase)
| Z         | Flaps (increase->extend)
| X-Twist   | (rudder?)
| Y-Twist   | (rudder?)
| Z-Twist   | Speedbrake (increase->extend)
| Slider    | (rudder?)

| Button    | Description                   |
| --------- | ----------------------------- |
| 1         | Throttle 1 Intuitive button
| 2         | Throttle 2 Intuitive button
| 3         | Engine 1 master (on->on)
| 4         | Engine 2 master (on->on)
| 5         | Engine 1 button
| 6         | Engine 2 button
| 7         | Mode (on->crank) [1]
| 8         | Mode (on->ign/start) [1]
| 9         | Throttle 1 detent (on->TOGA)
| 10        | Throttle 1 detent (on->Flex/MCT)
| 11        | Throttle 1 detent (on->Climb)
| 12        | Throttle 1 range (on->reverse)
| 13        | Throttle 2 detent (on->TOGA)
| 14        | Throttle 2 detent (on->Flex/MCT)
| 15        | Throttle 2 detent (on->Climb)
| 16        | Throttle 2 range (on->reverse)
| 17        | Rud Trim (on->reset)
| 18        | Rud Trim (on->left)
| 19        | Rud Trim (on->right)
| 20        | Parking Brake (on->engaged)
| 21        | Gear (on->up) [2]
| 22        | Autobrake: BTV  [3]
| 23        | Autobrake: LO
| 24        | Autobrake: 2
| 25        | Autobrake: 3
| 26        | Autobrake: HI
| 27        | Speedbrake detent (on->RET)
| 28        | Speedbrake detent (on->1/4)
| 29        | Speedbrake detent (on->1/2)
| 30        | Speedbrake detent (on->3/4)
| 31        | Speedbrake detent (on->FULL)

[1]: Neither 7 nor 8: norm
[2]: Not 21: down
[3]: Neither 22-26: disarm

X-Plane axis numbers `sim/joystick/joystick_axis_values` (probably hardware dependent!)
| Axis      | Description                   |
| --------- | ----------------------------- |
| 125       | Flaps (0->retract, 1->extend)
| 126       | Throttle 2 (0->full, ~0.735->idle, 1->reverse)
| 127       | Throttle 1 (0->full, ~0.735->idle, 1->reverse)
| 128       | Speedbrake (0->retract, 1->extend)


Todo
----
- [x] Autobrake
  - [x] FwL estimate position
  - [x] Control A320 and 737 autobrake
- [x] Speedbrake
  - [x] 737
    - [x] Handle automatic extension (i.e. do not retract if axis is noisy)
    - [x] Change curve for speedbrake arm position
  - [x] A320
    - [x] Use 1/4 position for speedbrake arm
- [x] Flaps
  - [x] 737
    - [x] Axis hysteresis
    - [x] Full: flap 30. Button to extend further to flap 40.
      - [x] Or better: read landing flap from FMC! (see xchecklist)
- [x] Gear
  - [x] 737
    - [x] Move to off after retraction.
- [x] Parking brake
  - [x] 737
    - [x] On and off commands
- [ ] Wiper increase/decrease (for rudder trim)
  - [ ] A320
  - [ ] 737
- [ ] Betterpushback call/start / seatbelts (for rudder trim reset button)
- [ ] Move relevant git-xp-zibohelper scripts here