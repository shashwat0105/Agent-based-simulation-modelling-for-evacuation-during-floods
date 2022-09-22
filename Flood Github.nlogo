globals [
  actual-flood-height
  start-flood?
  begin-evacuate?
  rise-count
  ]

turtles-own [
  target
  temp-target
  on-target?
  another-target
  another-target-distance
  anguish-index  
  ]

patches-own [
  altitude
  water?
  ]


to setup
  clear-all                             ;deletes all
  set-default-shape turtles "person"    ;the shape of the turtles - person
  ask patches [ set water? false ]      ;at the start, all patches are set to not be water
  create-
;it launches procedures ...
  create-water
  color-coast  
  color-water
  add-people
  set rise-count 1                      ;setup rise-count to 1                  
  reset-ticks                           ;resets time
end


to create-shoreline ; it leads to the formation of shoreline
ask number-of hill-count-at-beginning patches [ if pxcor > 30
[ set alt 1 ] ]
repeat 400 [ diffuse alt 0.2 ]
scale-shoreline
ask patches [ if pxcor <= 15 [ set altitude 0 ] ] ; if the patch
gets covered with water, its altitude will be 0
end

to create-water   ;it create the water
  ask patches [ if altitude < 100 and pxcor <= 50 [ set water? true ] ]  ;for the first 50 patches with height under 100 on the x sets the variable water to true
  ask patches [ if water? = true [ set altitude -1 ] ]  ; patches with variable water = true sets the height - 1, for another rescale
  scale-coast-final ;final coast scale
end


to scale-coast 
  let low [altitude] of min-one-of patches [altitude]   ;low - the lowest height of the patch  
  let high [altitude] of max-one-of patches [altitude]  ;high - the highest height of the patch   
  let range high - low                        ;range = disctinction between high and low                    

  ask patches [                    ;rescale by the range to 0-1000
    set altitude altitude - low                  
    set altitude altitude * 1000 / range         
    ]
end


to scale-shoreline
let down [altitude] of minimum-one-of patches [altitude]
;down - the minimum peak of the patch
let up [altitude] of maximum-one-of patches [altitude]
;up - the maximum peak of the patch
let range up - down
;extent = difference between up and down
ask patches [
set altitude altitude - down
set altitude altitude * 1000 / extent
]
end


to color-coast ; color patches by its height
  ask patches [ if altitude >= 0 and altitude < 050 [ set pcolor 51] ]
  ask patches [ if altitude >= 050 and altitude < 100 [ set pcolor 52] ]
  ask patches [ if altitude >= 100 and altitude < 150 [ set pcolor 53] ]
  ask patches [ if altitude >= 150 and altitude < 200 [ set pcolor 54] ]
  ask patches [ if altitude >= 200 and altitude < 250 [ set pcolor 55] ]
  ask patches [ if altitude >= 250 and altitude < 300 [ set pcolor 56] ]
  ask patches [ if altitude >= 300 and altitude < 350 [ set pcolor 57] ]
  ask patches [ if altitude >= 350 and altitude < 400 [ set pcolor 47] ]
  ask patches [ if altitude >= 400 and altitude < 450 [ set pcolor 46] ]
  ask patches [ if altitude >= 450 and altitude < 500 [ set pcolor 45] ]
  ask patches [ if altitude >= 500 and altitude < 550 [ set pcolor 44] ]
  ask patches [ if altitude >= 550 and altitude < 600 [ set pcolor 43] ]
  ask patches [ if altitude >= 600 and altitude < 650 [ set pcolor 42] ]
  ask patches [ if altitude >= 650 and altitude < 700 [ set pcolor 36] ]
  ask patches [ if altitude >= 700 and altitude < 750 [ set pcolor 35] ]
  ask patches [ if altitude >= 750 and altitude < 800 [ set pcolor 34] ]
  ask patches [ if altitude >= 800 and altitude < 850 [ set pcolor 33] ]
  ask patches [ if altitude >= 850 and altitude < 900 [ set pcolor 32] ]
  ask patches [ if altitude >= 900 and altitude < 950 [ set pcolor 31] ]
  ask patches [ if altitude >= 950 and altitude <= 1000 [ set pcolor 30] ] 
end

to color-water ;color everything what is water to 104 blue
  ask patches [ if water? = true [ set pcolor 104 ] ] 
end


to add-people
ask number-of people-count-at-beginning (patches with [fluid? != true])
; depending on input value, peoples are produced.
[ sprout 1 [ set on-target? false ; new turtles are
generated using sprout method
set color red
set anguish-value 0 ]

]
end


to move ;ensures the movement of people before the start of the floods, randomly turns left and right, if it is not pointed at the wall and into the water they move, otherwise they turns
  ask turtles [
    rt random 50
    lt random 50
    ifelse patch-ahead 1 != nobody 
      [ ifelse [water?] of patch-ahead 1 = true
        [ lt random-float 360 ]
        [ fd 1 ] 
      ]
      [ lt random-float 360 ]
    ] 
end


to start-flood-and-evacuate ;starts the flood and the evacuation
  set start-flood? true ;launch the flood
  set begin-evacuate? true ;launch the evacuation 
end


to water-surge ; increment the height of the water level.
ask patches [
if fluid? = true and alt < flood-peak-max[ ;
if pycor < 150 [
ask patch-at-heading-and-length 0 1 [ if altitude <
current-flood-peak + flood-peak-increment
[ set fluid? true ] ]
]
if pxcor < 150 [
ask patch-at-heading-and-length 95 1 [ if altitude <
current-flood-peak + flood-peak-increment
[ set fluid? true ] ]
]
if pycor > 0 [
ask patch-at-heading-and-length 190 1 [ if altitude <
current-flood-peak + flood-peak-increment
[ set fluid? true ] ]
]
if pxcor > 0 [
ask patch-at-heading-and-length 285 1 [ if altitude <
current-flood-peak + flood-peak-increment
[ set fluid? true ] ]
]
]
]
if ticks / delay-in-flood-growth = surge-count [
ifelse current-flood-height + flood-height-increment <
max-flood-peak ;current peak can not be greater than
the max-peak
[ set current-flood-peak current-flood-peak +
flood-peak-increment
set surge-count surge-count + 1
]
[ set current-flood-peak max-flood-peak
set surge-count growth-count + 1

]
]
color-water ;
end

to evacuate
ask turtles [
ask self [ if fluid? = true [ death ] ]
if anguish-value >= max-anguish-value
[ set on-aim? true
set color brown ]
ifelse aim = 0 and on-aim? = false
[ if any? patches in-span sight with-max [altitude]
[ set aim max-one-of patches in-radius sight [altitude] ]]
[ set other-aim max-one-of patches in-span sight
[altitude]
set another-aim-length length another-aim
if another-aim-length < 20 [ set aim another-aim ] ]
ifelse length aim <= 1 and on-aim? = false
[ if count turtles-on aim < 1 ; there are no other turtles
[ move-to aim ] ; move there
set on-aim? true ]
[
face aim ;
if on-aim? = false
[ ifelse is-patch? patch-ahead 1 and count
turtles-on patch-front 1 < 1 and [fluid?] of patch-front
1 != true
[ move-to patch-here ; move to the middle of the patch
and make a stride
fd 1 ]
[ set temporary-aim one-of (neighbors with [water? != true])
set anguish-value anguish-value + 1
if is-patch? temporary-aim and
count turtles-on temporary-aim < 1
[ face temporary-aim
forward 1 ]
]
]
]
]
end

to go
        
  ifelse start-flood? = true and begin-evacuate? = true 
    [ water_rise 
      evacuate
      tick ]
    [ move ]
  
end
@#$#@#$#@
GRAPHICS-WINDOW
744
31
1398
706
-1
-1
4.0
1
5
1
1
1
0
0
0
1
0
160
0
160
0
0
1
ticks
30.0

BUTTON
526
69
648
138
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
527
152
651
221
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
123
67
307
100
flood-height-max
flood-height-max
0
1000
850
1
1
NIL
HORIZONTAL

SLIDER
38
110
222
143
flood-height-increment
flood-height-increment
1
100
46
1
1
NIL
HORIZONTAL

MONITOR
290
379
454
424
current flood height
actual-flood-height
2
1
11

SLIDER
230
110
440
143
delay-in-flood-rise
delay-in-flood-rise
1
10
1
1
1
(max delay=1)
HORIZONTAL

SLIDER
232
268
442
301
number-of-people
number-of-people
1
3000
800
1
1
NIL
HORIZONTAL

TEXTBOX
116
239
375
312
Terrain formation parameters:
18
0.0
1

SLIDER
37
268
225
301
number-of-hills-before-diffuse
number-of-hills-before-diffuse
100
500
300
10
1
NIL
HORIZONTAL

TEXTBOX
116
37
368
81
Flood formation parameters:
18
0.0
1

BUTTON
507
237
666
306
begin flood & evacuate
start-flood-and-evacuate
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
36
191
224
224
sight
sight
1
160
46
1
1
NIL
HORIZONTAL

MONITOR
207
431
370
476
alive and safe people
count turtles
17
1
11

SLIDER
232
192
443
225
max-anguish-value
max-anguish-value
0
50
20
1
1
NIL
HORIZONTAL

MONITOR
387
432
551
477
number of dead people
number-of-people - count turtles
17
1
11

TEXTBOX
158
162
397
206
Human parameters:
18
0.0
1

PLOT
205
492
554
705
% dead people
NIL
NIL
0.0
100.0
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 0 -2674135 true "" "plot (number-of-people - count turtles) / number-of-people * 100"

TEXTBOX
486
41
722
91
Simulation Control Buttons
18
0.0
1

TEXTBOX
308
345
457
370
Output variables
18
0.0
1

default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
