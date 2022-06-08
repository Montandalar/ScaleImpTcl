#!/usr/bin/tclsh
package require platform

## COMMAND-LINE ARGS
set showGUI 1
set buildkit ""
set TCLKIT ""
foreach arg $argv {
	# --no-gui: Run without the build GUI. MUST also use --build-kit arg to build in
	# a CLI-only environment, as the tk-enabled runtime tclkit will be used by
	# default
	if [string equal $arg "--no-gui"] { 
		set showGUI 0
		puts "Running the build in CLI mode."
	}

	# --build-kit: Specify a separate tclkit for building the runtime. The build
	# tclkit does not need to have Tk.
	if [expr [string first "--build-kit" $arg] == 0] {
		# Extract the part after the =
		set buildkit [string range $arg 12 end]
		if [expr ![file exists $buildkit]] {
			puts "No such --build-kit: $buildkit"
			return 1
		} else {
			puts "Build kit: $buildkit"
		}
	}

	# --runtime-kit: Specify a runtime kit instead of searching PATH for a file
	# called `tclkit(.exe)`.
	if [expr [string first "--runtime-kit" $arg] == 0] {
		set TCLKIT [string range $arg 14 end]
		if [expr ![file exists $TCLKIT]] {
			puts "No such --runtime-kit: $TCLKIT"
			return 2
		} else {
			puts "Runtime kit: $TCLKIT"
		}
	}
}

if $showGUI {
	puts "Running the build GUI."
	package require Tk
}

proc fixPath {path platform} {
    if [expr ![string first win32 $platform]] {
        return [string map {/ \\} $path]
    } else {
        return $path
    }
}

## LIBRARY FUNCTIONS

#For each of the wanted files, find it on the path, and complain if not found.
proc got_what_we_wanted {wanted PATH pathsep slash} {
        set PATH ${PATH}${pathsep}.${slash}
    set len [string length $PATH]
    # All paths in PATH
    foreach prog $wanted {
        dict set progs $prog 0
    }
    for {set idx 0} {$idx < $len} {} {
        set nextIdx [string first $pathsep "$PATH" $idx]
                if [expr $nextIdx == -1] {
                    set nextIdx $len
                }
        set dir [string range $PATH $idx $nextIdx-1]
        set lidx 0
        # All programs in wanted
        while 1 {
            set prg [lindex $wanted $lidx]
            set execName [file join $dir $prg]
            if [file exists $execName] {
                set wanted [concat [lrange $wanted 0 $lidx-1] \
                    [lrange $wanted $lidx+1 end]]
                dict set progs $prg $execName
                set lidx 0
                #break - don't, may be more than one in current dir
            } else {
                incr lidx
            }
            if [expr \
                [expr $lidx >= [expr [llength $wanted]]] \
                || [expr [llength $wanted] <= 0]] {
                break
            }
        }
        if [expr $nextIdx < 0] {
                    break
        }
        set idx [expr $nextIdx + 1]
    }
    return [list [expr [llength "$wanted"] == 0] $progs]
}

proc needPrereqs {assigned} {
    set errortext ""
    foreach prog [dict keys $assigned] {
        set v [dict get $assigned $prog]
        if [string equal $v 0] {
            set errortext [string cat $errortext "Missing prerequisite: $prog\n"]
        }
    }
    set errortext [string cat $errortext \
        "Please download all prerequisites and put them in this directory," \
        " or elsewhere on your PATH"]
    return $errortext
}

proc doBuild {haveUpx platform exeSuffix progs slash BUILDKIT \
	haveRH showGUI TCLKIT} \
{

	puts "Cleaning up old artifacts"
    # Clean up any previous artificates
    file delete -force scaleimp;
    file delete -force scaleimp$exeSuffix
    file delete -force scaleimp.vfs
    file delete -force tclkit-for-scaleimp$exeSuffix
	file delete -force ScaleImp.app/Contents/MacOS
	file delete -force ScaleImp.app/Contents/Resources

	# Thanks tcl for using forward slash even on Windows :|
	if [string equal $TCLKIT ""] {
		set TCLKIT [fixPath [dict get $progs tclkit$exeSuffix] $platform]
	}

	if [string equal $BUILDKIT ""] {
		set BUILDKIT $TCLKIT 
	}

	puts "Making a copy of the runtime kit"
    # If I try to use a tcl file copy, it extracts the metakit filesystem out of
    # tclkit.exe and dumps it to a directory called scaleimp.exe. Not useful!
    if [expr ![string first win32 $platform]] {
        exec cmd /c copy /y "$TCLKIT" ".\\tclkit-for-scaleimp$exeSuffix"
    } else { #UNIXy
        exec cp $TCLKIT ./tclkit-for-scaleimp$exeSuffix
    }

	puts "Making the vfs"
    # In-kit branding 
    file mkdir scaleimp.vfs
    file copy -force scaleimp24.png scaleimp.vfs${slash}ScaleImp.png

    if [expr ![string first "win32" $platform] && $haveRH] {
		puts "Applying branding via ResourceHacker"
        exec ResourceHacker -open tclkit-for-scaleimp$exeSuffix \
            -action addoverwrite \
            -res ScaleImp.ico \
            -mask ICONGROUP,TK, \
            -save tclk4si.brand.exe
        file delete -force tclkit-for-scaleimp$exeSuffix
        file rename tclk4si.brand$exeSuffix \
                    tclkit-for-scaleimp$exeSuffix
    }

	puts "Packaging ScaleImp"
    # Packaging ScaleImp code
    file copy -force scaleimp.tcl scaleimp.vfs${slash}main.tcl
    set SDX [fixPath [dict get $progs sdx] $platform]

	if $showGUI {
		set pid [exec $BUILDKIT $SDX \
			wrap scaleimp -runtime tclkit-for-scaleimp$exeSuffix &]
		after 2000
		if [expr ![string first win32 $platform]] {
			exec taskkill /f /pid $pid
			} else { #UNIXy
				try {
				exec kill $pid
			} trap CHILDSTATUS {} {}
		}
	} else {
		exec $BUILDKIT $SDX wrap scaleimp -runtime tclkit-for-scaleimp$exeSuffix
	}

    if $haveUpx {
		puts "Compressing ScaleImp with UPX"
		# After wrapping with TCLKIT, $exeSuffix is never present
        exec upx scaleimp 
    }

	puts "Renaming with exeSuffix"
    file rename -force scaleimp scaleimp$exeSuffix

    # Build mac .app directory
    if [expr ![string first macosx $platform]] {
		puts "Building .app directory"

        file mkdir ScaleImp.app/Contents/Resources
        file copy -force scaleimp.icns ScaleImp.app/Contents/Resources/scaleimp.icns

        file mkdir ScaleImp.app/Contents/MacOS
        file copy -force scaleimp$exeSuffix ScaleImp.app/Contents/MacOS/scaleimp
    }

    return "Built ScaleImpTcl successfully!";
}

## MAIN PROCEDURE

set platform [platform::generic]
if [expr ![string first win32 $platform]] {
    set exeSuffix ".exe"
        set pathSep ";"
        set slash "\\"
} else {
    set exeSuffix ""
        set pathSep ":"
        set slash "/"
}

set errorText ""
set haveUpx 0
set haveRH 0

# UPX only supported on Windows; on linux it kills the VFS and not tested on
# macOS.
if [expr ![string first win32 $platform]] {
    lassign [got_what_we_wanted "upx$exeSuffix" $env(PATH) $pathSep $slash] \
		overall assigned
    if [expr $overall] {
        set haveUpx 1
    } else {
		set msg "UPX not found, final result will not be compressed.\n" 
		puts "$msg"
        set errorText "$msg"
	}
}

if [expr ![string first win32 $platform]] {
	lassign [got_what_we_wanted "ResourceHacker$exeSuffix" $env(PATH) \
		$pathSep $slash] overall assigned
	if [expr $overall] {
		set haveRH 1
	} else {
		set msg "ResourceHacker not found, branding will not be applied during this build\n" 
		puts "$msg"
        set errorText [string cat $errorText $msg]
	}
}

set hardDeps "tclkit$exeSuffix sdx"

lassign [ \
    got_what_we_wanted "$hardDeps" \
    $env(PATH) \
        $pathSep \
        $slash \
] overall assigned

if [expr !$overall] {
    set errorText [string cat $errorText [needPrereqs $assigned]]
} else {
    set buildResult [doBuild $haveUpx $platform $exeSuffix $assigned $slash \
		$buildkit $haveRH $showGUI $TCLKIT]
    set errorText [string cat $errorText $buildResult]
	puts $buildResult
}

if [expr "$showGUI"] {
	label .helptext -text $errorText
	pack configure .helptext -side bottom
	bind . <Escape> exit
	focus -force .
}
