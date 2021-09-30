package require platform

#For each of the wanted files, find it on the path, and complain if not found.
proc got_what_we_wanted {wanted PATH} {
	set len [string length $PATH]
	puts [string cat "PATH=" $PATH]
	puts [string cat "wanted=" $wanted]
	puts [string cat "len=" $len]
	# All paths in PATH
	foreach prog $wanted {
		dict set progs $prog 0
	}
	for {set idx 0} {$idx < $len} {} {
		set nextIdx [string first ";" "$PATH" $idx]
		set dir [string range $PATH $idx $nextIdx-1]
		set lidx 0
		# All programs in wanted
		while 1 {
			puts [string cat "  wanted=" $wanted]
			set prg [lindex $wanted $lidx]
			set execName [file join $dir $prg]
			puts [string cat "  " $execName]
			if [file exists $execName] {
				puts "    exists"
				set wanted [concat [lrange $wanted 0 $lidx-1] \
					[lrange $wanted $lidx+1 end]]
				dict set progs $prg 1
				set lidx 0
				#dict set progs $prg execName
				#break - don't, may be more than one in current dir
			} else {
				incr lidx
			}
			if [expr $lidx >= [expr [llength $wanted]]] {
				puts "    wanted=$wanted"
				puts "    lidx=$lidx"
				puts "    donehere."
				break
			}
		}
		puts [string cat "break?=" [expr $nextIdx < 0]]
		if [expr $nextIdx < 0] {
			break
		}
		set idx [expr $nextIdx + 1]
	}
	puts "FINAL wanted=$wanted"
	puts [string cat "llength wanted=" [llength $wanted]]
	puts "FINAL Progs=$progs"
	foreach x [dict keys $progs] {
		puts [string cat $x "=" [dict get $progs $x]]
	}
	set succ [expr [llength "$wanted"] == 0]
	puts "succ=$succ"
	return [list [expr [llength "$wanted"] == 0] $progs]
}

proc needPrereqs {assigned} {
	set errortext ""
	foreach prog [dict keys $assigned] {
		set v [dict get $assigned $prog]
		if [expr !$v] {
			set errortext [string cat $errortext "Missing prerequisite: $prog\n"]
		}
	}
	set errortext [string cat $errortext \
		"Please download all prerequisites and put them in this directory," \
		" or elsewhere on your PATH"]
	return $errortext
}

proc doBuild {haveUpx platform exeSuffix} {
	# Clean up any previous artificates
	file delete -force scaleimp;
	file delete -force scaleimp$exeSuffix
	file delete -force scaleimp.vfs
	file delete -force tclkit-for-scaleimp$exeSuffix

	# If I try to use a tcl file copy, it extracts the metakit filesystem out of 
	# tclkit.exe and dumps it to a directory called scaleimp.exe
	exec cmd /c copy tclkit$exeSuffix tclkit-for-scaleimp$exeSuffix

	# Branding (currently windows-only)
	if [expr ![string first win32 $platform]] {
		exec ResourceHacker -open tclkit-for-scaleimp$exeSuffix \
			-action addoverwrite \
			-res ScaleImp.ico \
			-mask ICONGROUP,TK, \
			-save tclk4si.brand.exe
		file delete -force tclkit-for-scaleimp$exeSuffix
		file rename tclk4si.brand$exeSuffix tclkit-for-scaleimp$exeSuffix
	}

	# Packaging ScaleImp code
	file mkdir scaleimp.vfs
	file copy -force scaleimp.tcl scaleimp.vfs\\main.tcl
	set pid [exec tclkit sdx \
		wrap scaleimp -runtime tclkit-for-scaleimp.exe &]
	after 2000
	if [expr ![string first win32 $platform]] {
		exec taskkill /f /pid $pid
	} else { #UNIXy
		exec kill $pid
	}

	if $haveUpx {
		exec upx scaleimp
	}

	file rename -force scaleimp scaleimp$exeSuffix
	return "Built ScaleImpTcl successfully!";
}

set platform [platform::generic]
if [expr ![string first win32 $platform]] {
	set exeSuffix ".exe"
} else {
	set exeSuffix ""
}

set errorText ""
lassign [got_what_we_wanted "upx$exeSuffix" $env(PATH)] overall assigned
set haveUpx 1
if [expr !$overall] {
	set errorText "UPX not found, final result will not be compressed.\n"
	set haveUpx 0
}

lassign [ \
	got_what_we_wanted "tclkit$exeSuffix ResourceHacker$exeSuffix sdx" \
	$env(PATH) \
] overall assigned

if [expr !$overall] {
	set errorText [string cat $errorText [needPrereqs $assigned]]
} else {
	set errorText [string cat $errorText \
		[doBuild $haveUpx $platform $exeSuffix]]
}

label .helptext -text $errorText
pack configure .helptext -side bottom
bind . <Escape> exit
focus -force .
