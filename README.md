# ScaleImpTcl: Scale calculator tool re-implemented in Tcl/Tk
ScaleImp is a tool to convert dimensions between imperial and metric units,
and at your chosen scale. It is a lightweight native application that you can
run today on Windows or Linux; or macOS in the near future.

A screenshot will probably help explain it best:

## What could I do with ScaleImp?  ScaleImp is great for anyone dealing with
physical measurements who needs to work in multiple unit systems and/or with a
scale factor.

* Use it just to convert units from one system to another.
* Convert imperial dimensions off old plans into scale metric dimensions.
* Convert scale dimensions off a model back into real dimensions.

## Instructions
ScaleImp always calculates based on a source unit, and gives the other three
dimensions. You can switch the source unit with the *radio buttons*, which are
display as round on most platforms - the selected source unit will have a filled
circle. The default unit is imperial, specifically the input for feet will be
selected.

Once you have selected your source unit and entered a scale factor, simply type
your quantity in and the other three units will be automatically filled out. The
real dimensions will be divided by the scale.  The program will do its best to
provide an approximation of the real imperial dimension up to 64ths of an inch,
simplifying the fraction down to 32nds, 16ths, 8ths, quarters, and halves where
possible but erring on the side of accuracy rather than simpler fractions.

To the right of the Real ft inputs you will see a little button with a 'C' on
it.  It is short for clear, like the button on calculator. Using it will clear
all input from the four imperial boxes and move your cursor back to the ft box.
This is to help your workflow as you enter dimensions one after another.

Activating the clear button only works while Real imperial units are active; the
quickest way to clear other units would by Modifier+A to select all followed by
backspace/delete. The secondary function of the clear button is to return the
cursor to the real ft input box, so activating it while another source unit is
active wouldn't make sense.

The program won't let you enter invalid numbers, and if scale is invalid when
you tab away from it, it will be reset to 1. You can use the numeric keypad or
the number row at your preference.

### Keyboard controls
The program fully supports using just the keyboard. In fact you can work quite
quickly with ScaleImp if you make full use of the shortcuts. The standard
keyboard controls for navigating a GUI will function fine: Tab to move between
UI elements, and Space or Enter to activate them.

Important to note is that there will be underlines present on the important
letters of each of the four units, as well as the scale factor and under the C
of the clear button. You can switch to any of the 4 input units or the scale
factor by using your operating-system- appropriate modifier key: This is Alt for
Windows and Linux, and Command for macOS. You can also activate the clear button
with modifier+C, but remember this only works when your source unit is real
imperial. The Mod+letter convention is not actually exclusive to ScaleImp; try
it in other programs when you see underlines (sometimes the underlines only
appear when you hold the modifier key first!)

In case there is any issue seeing the underlines or your graphical user
interface lacks them by some error, they are recorded here for posterity:

* Real ft: f
* Clear: c
* Real mm: m
* Scale: s
* Scale in: i
* Scale mm: a

Sorry that scale mm had to go on a 'weird' key but 'C'lear and 'S'cale were
already taken.

ScaleImp can be exited through your operating system's normal keyboard shortcuts
or by Control-W.

## Platform Support

Windows is delivered as a standalone executable in either 64-bit or 32-bit
formats. You will probably have to ask Windows nicely to run the program as it
is not signed.

Linux is delivered as a deb or rpm package for Debian or Fedora respectively,
and should be compatible with most derivatives of those systems such as Ubuntu,
Linux Mint, Pop!\_OS; or Rocky Linux, RHEL and so on. The package installs
freedesktop format icons and a desktop menu entry as well as the tcl script into
/usr/bin. I will also try to get ScaleImp into these distributions to be
available through apt/dnf install.

macOS cannot yet be delivered via GitLab CI as it is still in closed beta. I
will deliver macOS builds in proper .app format, though unsigned, as soon as
macOS reaches general availability. In the mean time you will have to build from
source yourself; I have left detailed instructions below. Builds will be
available for Intel Macs as well as Apple Silicon.  I have tested the builds in
a virtual machine previously but cannot verify their full compatibility with
Apple Silicon in future since I have no access to such hardware.

## Installation

### Prebuilt binaries

You can download the program from GitLab releases for Windows or Linux today,
though not for macOS yet. On Linux, check your package manager to see if
ScaleImp is available there.

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

##### The easy way
Run `build-easy.cmd`. This will use the prebuilt tclkit included in the source
repository to build ScaleImp. Branding is pre-applied to that kit, so you don't
have to download any dependencies.

##### The hard way: grabbing all dependencies yourself
If you don't trust my prebuilt tclkit, want to apply a different icon to
ScaleImp, or want produce an even smaller executable by using UPX, or just like
making life harder for yourself, you can follow these instructions.

Prerequisites are:
* tclkit - basis of a standalone Tcl/Tk program
* sdx - tool for packing ScaleImp into tclkit
* ResourceHacker - used to update the icons inside tclkit
* Optionally: UPX - will reduce the final program's size

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

To perform the actual build: run build-manualdeps.cmd to build scaleimp.exe. Once the
build is done, the final status will appear in a small window, which will either
tell you your build succeeded or if you were missing prerequisites.

#### Linux
Note that since Tk has no support for Wayland built in, you will need xwayland
to run ScaleImp under Wayland.

##### Through make install / unsupported distros
Running `sudo make install` should install ScaleImp just fine as long as you
have Tk installed. `checkinstall` and similar should work just fine if you
wanted to make a package that way.

##### Build as a package
Debhelper should be used to build for Debian and rpmbuild on Fedora. Similarly
for derivative distributions (Debian-\>Ubuntu/Mint; Fedora -\> RHEL/CentOS).
If I am missing the installation of any dependencies in these instructions
please let me know.

##### For Debian:
```
apt install debhelper tk dpkg-dev # pre-requisite for building - run as root/sudo
dpkg-buildpackage -b --no-sign

# To install
dpkg -i ../scaleimp_1.0.0-1_all.deb #run as root/sudo
```

(leave off the --no-sign if planning on publishing the package or if you have
your own PGP key you would like to sign with)

##### For Fedora

Starting in ScaleImp's directory:
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
you start menu/desktop file entries unlike installing and will probably look
different from the tcl/tk that shipped with your distro.

Note that UPX is not supported on Linux; UPX doesn't seem to like tclkit and
will just wipe it out in my experience.

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
I haven't managed to get cross-compiling working yet. Sorry, but native builds
are just plain easier! Below are my notes.

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

```

FIXME: mk4tcl build is failing for cross-compile

#### macOS - run through homebrew
This option is in case you are comfortable running ScaleImp from the command
line only and can't or won't compile the program for whatever reason. It's
not the usual recommended way.

Install tcl-tk through homebrew. Clone the ScaleImp repository with git and
launch ScaleImp via wish.

```
brew install tcl-tk
git clone https://github.com/Montandalar/ScaleImpTcl.git
cd ScaleImpTcl
wish ./scaleimp.tcl
```

#### macOS - as an application
The first step is to acquire a tclkit binary, which ScaleImp's build.tcl can
then use to build itself into a standalone application.

##### Acquiring/Choosing tclkit pre-built binaries
You can use the tclkit binaries that come with ScaleImp's source repository.
They live in tclkits-prebuilt/. There is a kit for x86\_64 (Intel Macs) and a
kit for Arm (Apple Silicon).

Unlike Windows, which has manually built tclkits, you will need to request
builds through the kitcreator web interface if you don't want to build tclkit
yourself. Visit https://kitcreator.rkeene.org/kitcreator and build a kit with a
Mac OS X platform (you probably want amd64).

The build service doesn't provide for Apple silicon; an apple silicon build of
tclkit has been provided in this repository that I built myself on macOS
Monterey 12.4. This is the tclkit used for the binary Apple Silicon release of
ScaleImp.

##### Optional: Building tclkit from source
If you want to build tclkit yourself, or can't/won't use the build service, or
trust my pre-built binaries, follow these instructions.  The kitcreator project
will be used to make our tclkit.  Since I couldn't find any up to date pre-build
tclkits from kitcreator, we will be building tclkit from source.

The first step is to install homebrew and build dependencies. You probably don't
need a later tcl version than the one included with macOS, but I recommend
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
<<<<<<< HEAD
Once you have a working tclkit, copy it into the root of ScaleImp's source tree.
In case you are using the prebuilt tclkits, this means you need to copy the
tclkit file from tclkits-prebuilt/ up one directory into this directory. e.g.

```
cp tclkits-prebuilt/tclkit-macosx-arm ./tclkit
```
or 
```
cp ~/Downloads/tclkit-something-or-other ./tclkit
```

You do not need another tcl interpreter like the Mac tcl or tcl-tk from
homebrew: the tclkit will be our interpreter for the build script. However the 
file must definitely called `tclkit`.
=======
Once you have a working tclkit, copy it into ScaleImp's source tree. You do not
need another tcl interpreter like the Mac tcl or tcl-tk from homebrew: the
tclkit will be our interpreter for the build script.
>>>>>>> 382a2b7 (Write user manual; streamline build process for end-users)

Next, download sdx from:
https://chiselapp.com/user/aspect/repository/sdx/index

sdx has to be called `sdx` to be detected. Rename it from the downloaded file
and put it in ScaleImp's directory or on your `PATH`.

<<<<<<< HEAD
=======
Also move your tclkit from your Download or kitcreator build directory to
ScaleImp's directory or on your PATH, and rename it from `tclkit-8.6.xx`
to just `tclkit`.

>>>>>>> 382a2b7 (Write user manual; streamline build process for end-users)
Now to run the build, run the following in a terminal:

```
PATH=.:$PATH ./tclkit build.tcl
```

The `PATH` definition is important so that we don't run `sdx` that shipped with
macOS or from homebrew. That `sdx` would cause the build to fail. If you left
your sdx somewhere else than `.`, just make sure it appears in the path BEFORE
the system and homebrew directories.

After a few seconds, you should get a little pop-up window saying "Built
<<<<<<< HEAD
ScaleImpTcl successfully!" and an executable file called `scaleimp` should
appear in your build directory. You can run this executable from a Terminal or
from Finder, or you can use the built `ScaleImp.app` (finder will only display
the name `ScaleImp` of course) in your own Applications directory. I don't know
how to hide the terminal window when running `scaleimp` from Finder sorry - it's
better to just run the .app :)
=======
ScaleImpTcl successfully!" and an executable file called scaleimp should appear
in your build directory. You can run this executable from a Terminal or from
Finder, or you can use the built ScaleImp.app in your own Applications
directory. I don't know how to hide the terminal window when running from Finder
sorry!
>>>>>>> 382a2b7 (Write user manual; streamline build process for end-users)
