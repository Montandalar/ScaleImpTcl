#!/bin/wish
package require Tk

namespace eval util {
    proc renderValue {v} {
        return [renderValueDP $v 3]
    }

    proc renderValueDP {v dp} {
        #Zero values should be omitted
        if {$v == 0} then {
            return ""
        }
        #Numbers that, when rounded have `dp` decimal places of zeroes
        #should be presented as integers
        set powten [expr pow(10,$dp)]
        set powten [format "%0.0f" $powten]
        set l [expr round($v*$powten)]
        if {$l % $powten == 0} {
            return [format "%0.0f" [expr $l/$powten]]
        }
        #All others should be represented to the specified precision
        set formatStr [format "%%.%df" $dp]
        return [format $formatStr $v]
    }

    proc emptyAsZero {v} {
        if {$v eq ""} then {
            return 0
        }; return $v
    }

    proc zeroAsEmpty {v} {
        if {$v == 0} then {
            return ""
        }; return $v
    }
}

oo::class create MeasurementModel {
    variable real_mm
    variable real_ft
    variable real_in
    variable real_in_numerator
    variable real_in_denominator
    variable scale
    variable scale_in
    variable scale_mm

    constructor {} {
        set real_mm ""
        set real_ft ""
        set real_in ""
        set real_in_numerator ""
        set real_in_denominator ""
        set scale 1
        set scale_in ""
        set scale_mm ""
    }

    method clearImperial {} {
        set fields [list real_ft real_in real_in_numerator real_in_denominator \
            real_mm scale_in scale_mm]
        foreach field $fields {
            set $field ""
        }
    }

    method clear {} {
        set fields [list real_mm scale_mm scale_in real_ft real_in \
            real_in_numerator real_in_denominator]
        foreach field $fields {
            set $field ""
        }
    }

    method setScaledUnits {new_mm} {
        set scale_mm [expr $new_mm / [::tcl::mathfunc::double $scale]]
        set scale_in [expr $scale_mm / 25.4]
    }

    method roundScaleUnits {} {
        set scale_mm [::util::renderValueDP $scale_mm 2]
        set scale_in [::util::renderValue $scale_in]
    }

    method mmToImperial {mm} {
        set working_mm $mm
        set ft [expr floor($working_mm / 304.8)]
        set working_mm [expr $working_mm - (304.8*$ft)]
        set in [expr floor($working_mm / 25.4)]
        set working_mm [expr $working_mm - (25.4*$in)]
        set numer [expr round($working_mm / 0.396875)]
        set denom 64
        while {($numer%2 == 0) && $numer > 1} {
            set numer [expr $numer/2]
            set denom [expr $denom/2]
        }
        #Rounding up to the next inch, inch to ft
        if {$numer == 1 && $denom == 1} {
            set in [expr $in+1]
            set numer 0
        }
        if {$in == 12} {
            set in 0
            set ft [expr $ft+1]
        }
        if {$numer == 0} then {set denom 0}
        set varlist [list ft in numer denom]
        foreach var $varlist {
            set var_deref [set $var]
            set $var [::util::renderValueDP $var_deref 0]
        }
        return [list $ft $in $numer $denom]
    }

    method setByRealmm {new_mm} {
        if {$new_mm == 0 || $new_mm eq ""} then {
            my clear
            set real_mm $new_mm
            return
        }
        set imperial_units [my mmToImperial $new_mm]
        set real_ft [lindex $imperial_units 0]
        set real_in [lindex $imperial_units 1]
        set real_in_numerator [lindex $imperial_units 2]
        set real_in_denominator [lindex $imperial_units 3]

        my setScaledUnits $new_mm
        my roundScaleUnits
    }

    method imperialTomm {ft in numer denom} {
        set mm ""
        if {$ft ne ""} {set mm [expr $ft*304.8]}
        if {$in ne ""} {set mm [expr $mm + ($in*25.4)]}
        if {$numer ne "" && $denom ne ""} {
            #float conversion on denom so division does not yield an integer
            set mm [expr $mm + \
                (($numer/[::tcl::mathfunc::double $denom])*25.4)]

        }
        return $mm
    }

    method setByRealImperial {new_ft new_in new_numer new_denom} {
        set fields [list new_ft new_in new_numer new_denom]
        set counter 0
        foreach field $fields {
            # Indirection on the arguments of this function
            set field_deref [set $field]
            if {$field_deref eq ""} {
                set counter [expr $counter+1]
            }
        }
        #We don't have any data
        if {$counter >= 4} then {
            my clear; return
        }
        set real_mm [my imperialTomm $new_ft $new_in $new_numer $new_denom]
        set real_mm [::util::emptyAsZero $real_mm]
        my setScaledUnits $real_mm
        set real_mm [::util::renderValueDP $real_mm 2]
        set real_ft $new_ft
        set real_in $new_in
        set real_in_numerator $new_numer
        set real_in_denominator $new_denom
        my roundScaleUnits
    }

    method scaledToRealCommon {new_scale_mm} {
        set real_mm [expr $new_scale_mm*$scale]
        set imperial_units [my mmToImperial $real_mm]
        set real_ft [lindex $imperial_units 0]
        set real_in [lindex $imperial_units 1]
        set real_in_numerator [lindex $imperial_units 2]
        set real_in_denominator [lindex $imperial_units 3]
        set real_mm [expr round($real_mm)]
    }

    method setByScaleImperial {new_scalein} {
        if {$new_scalein == 0 || $new_scalein eq ""} then {
            my clear
            set scale_in $new_scalein
            return
        }
        set scale_in $new_scalein
        set scale_mm [expr $new_scalein * 25.4]
        my scaledToRealCommon $scale_mm
        set scale_mm [::util::renderValueDP [expr 25.4*$new_scalein] 2]
    }

    method setByScalemm {new_scalemm} {
        if {$new_scalemm == 0 || $new_scalemm eq ""} then {
            my clear
            set scale_mm $new_scalemm
            return
        }
        set scale_mm $new_scalemm
        set scale_in [::util::renderValue [expr $new_scalemm / 25.4]]
        my scaledToRealCommon $new_scalemm
    }

    method scaleRecalc {new_scale src} {
        if {$new_scale eq "" || $new_scale == 0} then {
            return
        }
        set scale $new_scale
        switch $src {
            0 { my setByRealImperial $real_ft $real_in \
                    $real_in_numerator $real_in_denominator }
            1 { my setByScaleImperial $scale_in }
            2 { my setByRealmm $real_mm }
            3 { my setByScalemm $scale_mm }
        }
    }
}
oo::define MeasurementModel {export varname}
set mm [MeasurementModel new]

tk appname scaleimp
wm title . ScaleImp
wm geometry . =500x150
if [file exists "/usr/share/icons/hicolor/16x16/apps/scaleimp.png"] {
    set imgIcon [image create photo -file "/usr/share/icons/hicolor/16x16/apps/scaleimp.png"]
} elseif [file exists "ScaleImp.png"] {
    set imgIcon [image create photo -file "ScaleImp.png"]
}
wm iconphoto . -default $imgIcon

set selunit 0

proc inputvalidate {evtyp newval widg} {
    global mm
    if [expr $evtyp != 1] then {
        return 1
    }
    set result [expr [string is double $newval] || [string equal $newval "."]]
    return $result
}

proc validatedEntry {name args} {
    eval entry $name -validate key -validatecommand \{inputvalidate %d %P %W\} \
            {*}$args 
    bind $name <KeyRelease> "keyReleaseHandler $name %K"
    bind $name <FocusOut> "clearInvalidEntry $name"
}

label .helptext -text "Select source unit with the radio buttons"
pack configure .helptext -side bottom

# Toggle states: disabled/normal
proc toggleRealImperial {state} {
    set widgets [list realft realin inchnum inchdenom clear]
    foreach widg $widgets {
        .top.realimp.$widg configure -state $state
    }
}
proc setSrc {realimp scaleimp realmm scalemm} {
    toggleRealImperial $realimp
    .top.scaleinches.entry configure -state $scaleimp
    .bottom.realmm.entry configure -state $realmm
    .bottom.scalemm.entry configure -state $scalemm
}

proc recalcByImperial {} {
    set widget_suffixes [list realft realin inchnum inchdenom]
    set entries [list]
    foreach widg $widget_suffixes {
        lappend entries [.top.realimp.$widg get]
    }
    global mm
    $mm setByRealImperial [lindex $entries 0] [lindex $entries 1] \
        [lindex $entries 2] [lindex $entries 3]
}

proc keyReleaseHandler {widg key} {
    set processKeys [list 0 1 2 3 4 5 6 7 8 9 period BackSpace Delete]
    if {[lsearch $processKeys $key] == -1} then return
    set scale [.mid.scale get]
    if {$scale eq "" || $scale == 0} then {
        .helptext configure -text "! Scale is invalid !"
        .helptext configure -foreground red
    } else {
        .helptext configure -foreground black
        .helptext configure -text ""
    }
    if {$scale eq "" || $scale == 0} then return
    global mm


    switch -glob $widg {
        ".top.realimp.*" {
            recalcByImperial
        }
        ".top.scaleinches.entry" {
            $mm setByScaleImperial [.top.scaleinches.entry get]
        }
        ".mid.scale" {
            global selunit
            $mm scaleRecalc $scale $selunit
        }
        ".bottom.realmm.entry" {
            $mm setByRealmm [.bottom.realmm.entry get]
        }
        ".bottom.scalemm.entry" {
            $mm setByScalemm [.bottom.scalemm.entry get]
        }
    }

    set textcontents [$widg get]
    if {[string equal $textcontents "0"]} then {
        $widg icursor 1
    } elseif {[string equal $textcontents "0."]} then {
        $widg icursor 2
    }
}

proc clearInvalidEntry {widg} {
    set entry_text [$widg get]
    if {![string is double $entry_text]} {
        $widg delete 0 end
    }
    #Not having a scale will bork all other calculations, disallow it
    if {[string equal $widg .mid.scale ] \
        && [string equal [$widg get] ""]} {
        $widg insert 0 1
        .helptext configure -foreground black
        .helptext configure -text ""
    }
}

frame .top
frame .top.realimp
radiobutton .top.realimp.sel -state normal -variable selunit -value 0 \
                -text "Real ft" -underline 5 \
                -command {setSrc normal disabled disabled disabled}
bind . <Alt-f> {.top.realimp.sel invoke; focus .top.realimp.realft}
validatedEntry .top.realimp.realft -width 7 -textvar [$mm varname real_ft]
#.top.realimp.realft configure -validatecommand exit
validatedEntry .top.realimp.realin -width 6 -textvar [$mm varname real_in]
label .top.realimp.inchlbl -text "in"
validatedEntry .top.realimp.inchnum -width 4 \
                   -textvar [$mm varname real_in_numerator]
label .top.realimp.slashlbl -text "/"
validatedEntry .top.realimp.inchdenom -width 4 \
                   -textvar [$mm varname real_in_denominator]
label .top.realimp.fractlbl -text "fraction"
button .top.realimp.clear -text "C" -command "$mm clearImperial" -underline 0
bind . <Alt-c> {.top.realimp.clear invoke; focus .top.realimp.realft}
frame .top.scaleinches
radiobutton .top.scaleinches.sel -state normal -variable selunit -value 1 \
                -text "Scale in" -underline 6 \
                -command {setSrc disabled normal disabled disabled}
bind . <Alt-i> {.top.scaleinches.sel invoke; focus .top.scaleinches.entry}
validatedEntry .top.scaleinches.entry -width 9 -textvar [$mm varname scale_in]

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
validatedEntry .mid.scale -width 5 -textvariable [$mm varname scale]
bind . <Alt-s> {focus .mid.scale}
label .mid.suffix -text "scale" -underline 0

pack configure .mid -anchor n
pack configure .mid.prefix -side left -fill y
pack configure .mid.scale -side left -fill y
pack configure .mid.suffix -side left -fill y

frame .bottom
frame .bottom.realmm

radiobutton .bottom.realmm.sel -state normal -variable selunit -value 2 \
                -text "Real mm" -underline 5 \
                -command {setSrc disabled disabled normal disabled}
bind . <Alt-m> {.bottom.realmm.sel invoke; focus .bottom.realmm.entry}
validatedEntry .bottom.realmm.entry -width 10 -textvar [$mm varname real_mm]
frame .bottom.scalemm
radiobutton .bottom.scalemm.sel -state normal -variable selunit -value 3 \
                -text "Scale mm" -underline 2 \
                -command {setSrc disabled disabled disabled normal}
bind . <Alt-a> {.bottom.scalemm.sel invoke; focus .bottom.scalemm.entry}
validatedEntry .bottom.scalemm.entry -width 10 -textvar [$mm varname scale_mm]

pack configure .bottom -fill x -pady 8
pack configure .bottom.realmm -side left -padx 16
pack configure .bottom.realmm.sel -side left
pack configure .bottom.realmm.entry -side left
pack configure .bottom.scalemm -side right -padx 12
pack configure .bottom.scalemm.sel -side left
pack configure .bottom.scalemm.entry -side left

proc arrowKeyHandle dir {
    global selunit
    set selunit [expr ($selunit + $dir) % 4]
    switch -exact selunit {
        0 { .top.realimp.sel invoke }
        1 { .top.scaleinches.sel invoke }
        2 { .bottom.realmm.sel invoke }
        3 { .bottom.scalemm.sel invoke }
    }
}

bind . <Key-Up> {arrowKeyHandle -1}
bind . <Key-Down> {arrowKeyHandle +1}
focus -force .

bind . <Control-w> exit

setSrc normal disabled disabled disabled

#Show the wish console for debugging
#console show
