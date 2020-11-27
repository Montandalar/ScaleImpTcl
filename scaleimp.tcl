#!/bin/tclsh
wm title . ScaleImp
wm geometry . =500x150

set selunit ri
set scale 1

set realft "a"
set realin "b"
set realin_num "c"
set realin_denom "d"
set realmm "e"
set scalein "f"
set scalemm "g"

frame .top
frame .top.realimp
radiobutton .top.realimp.sel -state normal -variable selunit -value ri \
                -text "Real ft"
#label .top.realimp.realftlbl -text "Real ft"
entry .top.realimp.realft -width 7 -textvar realft
entry .top.realimp.realin -width 6 -textvar realin
label .top.realimp.inchlbl -text "in"
entry .top.realimp.inchnum -width 4 -textvar realin_num
label .top.realimp.slashlbl -text "/"
entry .top.realimp.inchdenom -width 4 -textvar realin_denom
label .top.realimp.fractlbl -text "fraction"
frame .top.scaleinches
radiobutton .top.scaleinches.sel -state normal -variable selunit -value si \
                -text "Scale in"
#label .top.scaleinches.lbl -text "Scale in"
entry .top.scaleinches.entry -width 9 -textvar scalein

pack configure .top -side top -fill x -pady 8 -padx 4
pack configure .top.realimp -side left
pack configure .top.realimp.sel -side left
#pack configure .top.realimp.realftlbl -side left
pack configure .top.realimp.realft -side left
pack configure .top.realimp.realin -side left
pack configure .top.realimp.inchlbl -side left
pack configure .top.realimp.inchnum -side left
pack configure .top.realimp.slashlbl -side left
pack configure .top.realimp.inchdenom -side left
pack configure .top.realimp.fractlbl -side left
pack configure .top.scaleinches -side right -padx 12
pack configure .top.scaleinches.sel -side left
#pack configure .top.scaleinches.lbl -side left
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
#label .bottom.realmm.lbl -text "Real mm"
radiobutton .bottom.realmm.sel -state normal -variable selunit -value rm \
                -text "Real mm"
entry .bottom.realmm.entry -width 10 -textvar realmm
frame .bottom.scalemm
radiobutton .bottom.scalemm.sel -state normal -variable selunit -value sm \
                -text "Scale mm"
#label .bottom.scalemm.lbl -text "Scale mm"
entry .bottom.scalemm.entry -width 10 -textvar scalemm

pack configure .bottom -fill x -pady 8
pack configure .bottom.realmm -side left -padx 16
pack configure .bottom.realmm.sel -side left
#pack configure .bottom.realmm.lbl -side left
pack configure .bottom.realmm.entry -side left
pack configure .bottom.scalemm -side right -padx 12
pack configure .bottom.scalemm.sel -side left
#pack configure .bottom.scalemm.lbl -side left
pack configure .bottom.scalemm.entry -side left

label .helptext -text "Select source unit with the radio buttons"
pack configure .helptext -side bottom
