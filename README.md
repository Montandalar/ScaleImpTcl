# ScaleImpTcl: Scale calculator tool re-implemented in Tcl/Tk
This README is a work in progress.

## Installation

### Prebuilt binaries
Will be made available through GitHub Releases.

Windows: Supported as a portable application, not installable.

Linux: .deb will be provided for Debian, and .rpm for Fedora. I will also try to
get ScaleImp into these distributions to be available through apt/dnf install.

MacOS: Builds will be provided via a CI environment, but I have no way of verifying
their correctness since this environment has no GUI.

### From Source

Prerequisites: tclkit, sdx; Optional: Make, GNU autotools, fossil

The cross-platform build process in general is to:
1. Build or download a pre-build from the kitcreator project.
2. Download sdx.
3. Run the build script, which will use sdx with tclkit to build ScaleImp into
a starkit which will be a statically linked executable for your platform.

This portable, statically linked executable won't appear in any start menus.
Installable ScaleImp is only supported on Linux for now.

#### Windows

Prerequisites are:
* tclkit - basis of a standalone Tcl/Tk program
* sdx - tool for packing ScaleImp into tclkit
* ResourceHacker - used to update the icons inside tclkit
* Optionaly: UPX - will reduce the final program's size

All prerequisites need to go in this directory or on your PATH environment
variable.

Download TclKit for 8.6.11 with Tk included from:
https://tclkits.rkeene.org/fossil/wiki/Downloads

tclkit has to be called tclkit.exe to be detected

Download sdx from:
https://chiselapp.com/user/aspect/repository/sdx/index

sdx has to be called sdx to be detected

Download ResourceHacker from:
http://angusj.com/resourcehacker/

ResourceHacker needs to be called ResourceHacker.exe to be detected

Optionally, you can also have UPX

https://upx.github.io/

on the path during the build process and it will be used to pack the final
executable. UPX has to be called upx.exe to be detected.

To perform the actual build: run build-w32.cmd to build scaleimp.exe. Once the
build is done, the final status will appear in a small window, which will either
tell you your build succeeded or if you were missing prerequisites.

#### Linux
Note that since Tk has no support for Wayland built in, you will need xwayland
to run ScaleImp under wayland.

##### Through make install / unsupported distros
Running `sudo make install` should install ScaleImp just fine as long as you 
have Tk installed. `checkinstall` and similar should work just fine if you
wanted to make a package that way.

##### Build as a package
Debhelper should be used to build for Debian and rpmbuild on Fedora. Similarly
for derivative distributions (Debian-\>Ubuntu/Mint; Fedora -\> RHEL/CentOS).
If I am missing the installation of any dependencies in these instructions 
please let me know.

For Debian:
```
apt install debhelper tk dpkg-dev # pre-requisite for building - run as root/sudo
dpkg-buildpackage -b --no-sign

# To install
dpkg -i ../scaleimp_1.0.0-1_all.deb #run as root/sudo
```

(leave off the --no-sign if planning on publishing the package or if you have
your own PGP key you would like to sign with)

For Fedora, starting in ScaleImp's directory:
```
dnf install rpmbuild tk #as root/via sudo
mkdir -p ~/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}

cp fedora/scaleimp.spec ~/rpmbuild/SPECS/
rpmbuild -bs ~/rpmbuild/SPECS/scaleimp.spec
rpmbuild -ba ~/rpmbuild/SPECS/scaleimp.spec

# To install - substitute your appropriate version string
rpm -i ~/rpmbuild/RPMS/noarch/scaleimp-${ver}.rpm #as root/via sudo
```

##### As a tclkit
If for some reason you prefer a portable ScaleImp for Linux, you can run the
build.tcl process that is usually meant for Windows. Note that this won't give
you start menu/desktop file entries unlike installing.

Note that UPX is not supported on Linux; UPX doesn't seem to like tclkit.

To install the prerequisites on Debian the following should suffice:
```
$ sudo apt install build-essential autoconf fossil
```

Clone the kitcreator repository and build kitcreator. The default build of
kitcreator includes Tk.
```
$ fossil clone https://kitcreator.rkeene.org
$ cd kitcreator
$ ./build/pre.sh
$ ./kitcreator
```

If the build succeeded, you should now have a tclkit-<version> binary e.g.
`tclkit-8.6.11` in your kitcreator directory.

Get sdx from https://chiselapp.com/user/aspect/repository/sdx/index and put it
wherever you want it. I recommend the same directory as tclkit, but this is not
necessary.

Finally, you need to make sure the build script can find tclkit and sdx by 
having them in your PATH. Then you can simply run:

```
$ ./build.tcl
```

to create the binary of ScaleImp, which you can run with:

```
$ ./scaleimp
```

#### Cross-compile for Windows from Linux
I haven't managed to get cross-compiling working yet. Below are my notes.

Install the MinGW cross-compiler, e.g. on Debian:

$ sudo apt install mingw-w64

Now build kitcreator with the cross compiler. The following instructions are
based on the README of kitcreator:

```
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
```

#### MacOS - run through homebrew
This option is in case you are comfortable running ScaleImp from the command
line only and can't or won't compile the program for whatever reason. It's not
the usual recommended way.

Install tcl-tk through homebrew. Clone the ScaleImp repository with git and 
launch ScaleImp via wish.

```
brew install tcl-tk
git clone https://github.com/Montandalar/ScaleImpTcl.git
cd ScaleImpTcl
wish ./scaleimp.tcl
```

#### MacOS - as a tclkit
The first step is to acquire a tclkit binary, which ScaleImp's build.tcl can 
then use to build itself into a standalone application. You may struggle a bit
if you are trying to run on Apple Silicon - the following instructions are only
guaranteed for Intel Macs for now.

##### Acquiring tclkit pre-build binaries
Unlike Windows, which has manually built tclkits, you will need to request
builds through the kitcreator web interface if you don't want to build tclkit
yourself. Visit https://kitcreator.rkeene.org/kitcreator and build a kit with a
Mac OS X platform (you probably want amd64).

The build service doesn't provide for Apple silicon.

##### Building tclkit from source

  If you want to build tclkit yourself, or can't/won't use the build service,
follow these instructions.  The kitcreator project will be used to make our
tclkit.  Since I couldn't find any up to date pre-build tclkits from kitcreator,
we will be building tclkit from source.

The first step is to install homebrew and build dependencies. You probably don't
need a later tcl version than the one included with MacOS, but I recommend
installing it through homebrew regardless.

$ brew install git fossil automake tcl-tk
$ eval $(/opt/homebrew/bin/brew shellenv)

Open a terminal and build tclkit. A few special arguments are needed to build a
working tclkit with kitcreator. Despite the confusing syntax of 'x86\_64', the
following command line will build for either Intel or Apple Silicon Macs:

```
fossil clone https://kitcreator.rkeene.org
cd kitcreator
build/pre.sh
./kitcreator --disable-threads --enable-aqua --host=x86_64-apple-darwin9
```

The tclkit will now be built as tclkit-8.6.12 or later in your current 
directory. To make sure it works, test it by running it from the terminal and
trying to use Tk:

```
$ ./tclkit-8.6.12
% package require Tk
```

If it throws an error, the tclkit is bad. Make sure you gave the right arguments
to kitcreator.

##### Building ScaleImp
Once you have a working tclkit, copy it into ScaleImp's source tree. You do not
need another tcl interpreter like the Mac tcl or tcl-tk from homebrew: the 
tclkit will be our interpreter for the build script.

Next, download sdx from:
https://chiselapp.com/user/aspect/repository/sdx/index

sdx has to be called `sdx` to be detected. Rename it from the downloaded file
and put it in ScaleImp's directory or on your `PATH`.

Also move your tclkit from your Download or kitcreator build directory to
ScaleImp's directory or on your PATH, and rename it from `tclkit-8.6.xx` 
to just `tclkit`.

Now to run the build, run the following in a terminal:

```
PATH=.:$PATH ./tclkit build.tcl
```

The `PATH` definition is important so that we don't run `sdx` that shipped with
macOS or from homebrew. That `sdx` would cause the build to fail.

After a few seconds, you should get a little pop-up window saying "Built
ScaleImpTcl successfully!" and an executable file called scaleimp should appear
in your build directory. You can run this executbale from a Terminal or from 
Finder. I don't know how to hide the terminal window when running from Finder 
sorry!

#### MacOS - as an application

Follow the above instructions in 'Building ScaleImp', and then package the
application as a .app along with scaleimp.icns and info.plist (TODO WIP)

I have yet to work out how to turn a tclkit into an application. When I do, I'll
give instructions on how to assemble the compiled tclkit into an application
which you can put on the dock and it will have icons.
