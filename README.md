# ScaleImpTcl: Scale calculator tool re-implemented in Tcl/Tk
This README is a work in progress.

## Installation

### Prebuilt binaries
Will be made available through GitHub Releases.

### From Source

Prerequisites: tclkit, sdx; Optional: Make, GNU autotools, fossil

The process in general is to:
1. Build or download a pre-build from the kitcreator project.
2. Download sdx.
2. Run the build script, which will use sdx with tclkit to build ScaleImp into
a starkit which will be a statically linked executable for your platform.

#### Windows

Prerequisites are:
* Tclkit - basis of a standalone tcl/tk program
* sdx - tool for packing ScaleImp into tclkit
* ResourceHacker - used to update the icons inside tclkit
* Optionaly: UPX - will reduce the final program's size

All prerequisites need to go in this directory or on your PATH environment
variable.

Download TclKit for 8.6.11 with tk included from:
https://tclkits.rkeene.org/fossil/wiki/Downloads

tclkit has to be called tclkit.exe to be detected

Download sdx from:
https://chiselapp.com/user/aspect/repository/sdx/index

sdx has to be called sdx to be detected

Download ResourceHacker from:
http://angusj.com/resourcehacker/

ResourceHacker needs to be called ResourceHacker.exe to be detected

Optionally, you can also have upx

https://upx.github.io/

on the path during the build process and it will be used to pack the final
executable. UPX has to be called upx.exe to be detected.

To perform the actual build: run build-w32.cmd to build scaleimp.exe. Once the
build is done, the final status will appear in a small window, which will either
tell you your build succeeded or if you were missing prerequisites.

#### Linux

Note that UPX is not supported on Linux; UPX doesn't seem to like tclkit.

To install the prerequisites on Debian the following should suffice:
$ sudo apt install build-essential autoconf fossil

Clone the kitcreator repository and build kitcreator. The default build of
kitcreator includes Tk
$ fossil clone https://kitcreator.rkeene.org
$ cd kitcreator
$ ./build/pre.sh
$ ./kitcreator

If the build succeeded, you should now have a tclkit-<version> binary e.g.
tclkit-8.6.11 in your kitcreator directory.

Get sdx from https://chiselapp.com/user/aspect/repository/sdx/index and put it
wherever you want it. I recommend the same directory as tclkit, but this is not
necessary.

Finally, you need to make sure the build script can find tclkit and sdx by 
having them in your PATH. Then you can simply run:

$ ./build.tcl

to create the binary of ScaleImp, which you can run with:

$ ./scaleimp

TODO: A .desktop file will be provided as well

#### Cross-compile for Windows from Linux
I haven't managed to get cross-compiling working yet. Below are my notes.

Install the MinGW cross-compiler, e.g. on Debian:

$ sudo apt install mingw-w64

Now build kitcreator with the cross compiler. The following instructions are
based on the README of kitcreator:

export TCLVERS=8.6.11
./kitcreator #Make sure we already have a native kitcreator
mv tclkit-8.6.11 tclkit-local
TCLKIT="$(pwd)/tclkit-local"
STATICTK=1
STATICMK4=1
CC=x86\_64-w64-mingw32-gcc-win32
CXX=x86\_64-w64-mingw32-g++-win32
AR=x86\_64-w64-mingw32-gcc-ar-win32
RANLIB=x86\_64-w64-mingw32-gcc-ranlib-win32
export CC CXX AR RANLIB TCLKIT STATICTK STATICMK4
./kitcreator --host=x86\_64-w64-mingw32

FIXME: mk4tcl build is failing for cross-compile
