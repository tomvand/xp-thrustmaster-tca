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