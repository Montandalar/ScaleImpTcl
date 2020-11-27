#!/bin/tclsh
tk appname scaleimp
wm title . ScaleImp
wm geometry . =500x150

set selunit ri
set scale 1

set realft ""
set realin ""
set realin_num ""
set realin_denom ""
set realmm ""
set scalein ""
set scalemm ""

proc clearImperial {} {
    global realft; set realft ""
    global realin; set realin ""
    global realin_num; set realin_num ""
    global realin_denom; set realin_denom ""
}

frame .top
frame .top.realimp
radiobutton .top.realimp.sel -state normal -variable selunit -value ri \
                -text "Real ft" -underline 5
bind . <Alt-f> {.top.realimp.sel invoke}
entry .top.realimp.realft -width 7 -textvar realft
entry .top.realimp.realin -width 6 -textvar realin
label .top.realimp.inchlbl -text "in"
entry .top.realimp.inchnum -width 4 -textvar realin_num
label .top.realimp.slashlbl -text "/"
entry .top.realimp.inchdenom -width 4 -textvar realin_denom
label .top.realimp.fractlbl -text "fraction"
button .top.realimp.clear -text "C" -command clearImperial -underline 0
bind . <Alt-c> {.top.realimp.clear invoke}
frame .top.scaleinches
radiobutton .top.scaleinches.sel -state normal -variable selunit -value si \
                -text "Scale in" -underline 6
bind . <Alt-i> {.top.scaleinches.sel invoke}
entry .top.scaleinches.entry -width 9 -textvar scalein

pack configure .top -side top -fill x -pady 8 -padx 4
pack configure .top.realimp -side left
pack configure .top.realimp.sel -side left
pack configure .top.realimp.realft -side left
pack configure .top.realimp.realin -side left
pack configure .top.realimp.inchlbl -side left
pack configure .top.realimp.inchnum -side left
pack configure .top.realimp.slashlbl -side left
pack configure .top.realimp.inchdenom -side left
pack configure .top.realimp.fractlbl -side left
pack configure .top.realimp.clear -side left
pack configure .top.scaleinches -side right -padx 12
pack configure .top.scaleinches.sel -side left
pack configure .top.scaleinches.entry -side left

frame .mid
label .mid.prefix -text "1:"
entry .mid.scale -width 5 -textvariable scale
label .mid.suffix -text "scale"

pack configure .mid -anchor n
pack configure .mid.prefix -side left -fill y
pack configure .mid.scale -side left -fill y
pack configure .mid.suffix -side left -fill y

frame .bottom
frame .bottom.realmm
radiobutton .bottom.realmm.sel -state normal -variable selunit -value rm \
                -text "Real mm" -underline 5
bind . <Alt-m> {.bottom.realmm.sel invoke}
entry .bottom.realmm.entry -width 10 -textvar realmm
frame .bottom.scalemm
radiobutton .bottom.scalemm.sel -state normal -variable selunit -value sm \
                -text "Scale mm" -underline 0
bind . <Alt-s> {.bottom.scalemm.sel invoke}
entry .bottom.scalemm.entry -width 10 -textvar scalemm

pack configure .bottom -fill x -pady 8
pack configure .bottom.realmm -side left -padx 16
pack configure .bottom.realmm.sel -side left
pack configure .bottom.realmm.entry -side left
pack configure .bottom.scalemm -side right -padx 12
pack configure .bottom.scalemm.sel -side left
pack configure .bottom.scalemm.entry -side left

label .helptext -text "Select source unit with the radio buttons"
pack configure .helptext -side bottom

focus -force .
clearImperial
