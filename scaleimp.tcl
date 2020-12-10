#!/bin/wish

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
        set real_ft ""
        set real_in ""
        set real_in_numerator ""
        set real_in_denominator ""
        focus .top.realimp.realft
    }

    method setScaledUnits {new_mm} {
        set scale_mm [expr $new_mm / $scale]
        set scale_in [expr $scale_mm / 25.4]
    }

    method roundScaleUnits {} {
        set scale_mm [::util::renderValueDP $scale_mm 2]
        set scale_in [::util::renderValue $scale_in]
    }

    method setByRealmm {new_mm} {
        my variable real_ft
        set real_ft [expr floor($new_mm / 304.8)]
        set working_mm [expr $new_mm - (304.8*$real_ft)]
        set real_ft [::util::renderValueDP $real_ft 0]
        my variable real_in
        set real_in [expr floor($working_mm / 25.4)]
        set working_mm [expr $working_mm - ($real_in*25.4)]
        set real_in [::util::renderValueDP $real_in 0]
        set numer [expr round($working_mm / 0.396875)]
        set denom 64
        while {($numer%2 == 0) && $numer > 1} {
            set numer [expr $numer/2]
            set denom [expr $denom/2]
        }
        my variable real_in_numerator
        set real_in_numerator [::util::renderValueDP $numer 0]
        my variable real_in_denominator
        set real_in_denominator [::util::renderValueDP $denom 0]

        my variable real_mm
        set real_mm $new_mm

        my setScaledUnits $new_mm
        my roundScaleUnits
    }

    method setByRealImperial {new_ft new_in new_numer new_denom} {
        #float coercion on denom so that division does not yield an integer
        set real_mm [expr ($new_ft*304.8) + ($new_in*25.4) + \
            ($new_numer/[format "%f" $new_denom])*(25.4)]
        my setScaledUnits $real_mm
        set real_ft $new_ft
        set real_in $new_in
        set real_in_numerator $new_numer
        set real_in_denominator $new_denom
        my roundScaleUnits
    }

    method setByScaleImperial {new_scalein} {
        set scale_in $new_scalein
        set scale_mm [expr 25.4*$new_scalein]
        my setByRealmm [expr $scale*$scale_mm]
        #Limit precision going towards real units
        set real_mm [expr round($real_mm)]
    }

    method setByScalemm {new_scalemm} {
        set scale_mm $new_scalemm
        set scale_in [expr $new_scalemm / 25.4]
        my setByRealmm [expr $scale*$scale_mm]
        #Limit precision going towards real units
        set real_mm [expr round($real_mm)]
    }
}
oo::define MeasurementModel {export varname}
set mm [MeasurementModel new]

tk appname scaleimp
wm title . ScaleImp
wm geometry . =500x150

set selunit 0

proc recalcByRealImperial {} {}
proc recalcByScaleImperial {} {}
proc recalcByRealMetric {} {}
proc recalcByScaleMetric {} {}

proc inputvalidate {evtyp keystr widg} {
    .helptext configure -text "$keystr $widg"
    if [expr $evtyp != 1] then {
        return 1
    }
    set result [expr [string is double $keystr] \
        || [string equal "$keystr" "."]]
    .helptext configure -text "$keystr $widg $result"
    switch -glob $widg {
        ".top.realimp.*" {
            recalcByRealImperial
        }
        ".top.scaleinches.entry" {
            recalcByScaleImperial
        }
        ".bottom.realmm.entry" {
            recalcByRealMetric
        }
        ".bottom.scalemm.entry" {
            recalcByScaleMetric
        }
    }
    return $result
}

proc validatedEntry {name args} {
    eval entry $name -validate key -validatecommand \{inputvalidate %d %S %W\} \
            {*}$args 
}

label .helptext -text "Select source unit with the radio buttons"
pack configure .helptext -side bottom

frame .top
frame .top.realimp
radiobutton .top.realimp.sel -state normal -variable selunit -value 0 \
                -text "Real ft" -underline 5
bind . <Alt-f> {.top.realimp.sel invoke}
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
#FIXME: how do I invoke an instance method as the command?
button .top.realimp.clear -text "C" -command "$mm clearImperial" -underline 0
bind . <Alt-c> {.top.realimp.clear invoke}
frame .top.scaleinches
radiobutton .top.scaleinches.sel -state normal -variable selunit -value 1 \
                -text "Scale in" -underline 6
bind . <Alt-i> {.top.scaleinches.sel invoke}
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
label .mid.suffix -text "scale"

pack configure .mid -anchor n
pack configure .mid.prefix -side left -fill y
pack configure .mid.scale -side left -fill y
pack configure .mid.suffix -side left -fill y

frame .bottom
frame .bottom.realmm
radiobutton .bottom.realmm.sel -state normal -variable selunit -value 2 \
                -text "Real mm" -underline 5
bind . <Alt-m> {.bottom.realmm.sel invoke}
validatedEntry .bottom.realmm.entry -width 10 -textvar [$mm varname real_mm]
frame .bottom.scalemm
radiobutton .bottom.scalemm.sel -state normal -variable selunit -value 3 \
                -text "Scale mm" -underline 0
bind . <Alt-s> {.bottom.scalemm.sel invoke}
validatedEntry .bottom.scalemm.entry -width 10 -textvar [$mm varname scale_mm]

pack configure .bottom -fill x -pady 8
pack configure .bottom.realmm -side left -padx 16
pack configure .bottom.realmm.sel -side left
pack configure .bottom.realmm.entry -side left
pack configure .bottom.scalemm -side right -padx 12
pack configure .bottom.scalemm.sel -side left
pack configure .bottom.scalemm.entry -side left

proc recalcByUnit unit {
    if {$unit == 1} then {
        #Real imperial
    } elseif {$unit == 2} then {
        #Scale imperail
    } elseif {$unit == 3} then {
        #Real metric
    } elseif {$unit == 4} then {
        #Scale metric
    } else {
        #An error
    }
}

proc selectNewUnit unit {
    global selunit
    set selunit $unit
}

proc arrowKeyHandle dir {
    global selunit
    selectNewUnit [expr ($selunit + $dir) % 4]
}

bind . <Key-Up> {arrowKeyHandle -1}
bind . <Key-Down> {arrowKeyHandle +1}
focus -force .

bind . <Control-w> exit

#Show the wish console for debugging
#console show
