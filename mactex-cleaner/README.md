# README - mactex-cleaner

A little tool for uninstalling the Ghostscript installed by [MacTeX](https://www.tug.org/mactex/), and doing other MacTeX-related cleanup.

You might want to do this if you have MacTeX and want to use a ghostscript from a different installation method like Homebrew, e.g. to get a newer ghostscript or just use a nicer package manager. `brew doctor` will also complain about non-brew-managed files in `/usr/local`, which you'll have from the MacTeX-installed ghostscript.

## Contents

The `extern/uninstall-ghostscript.sh` file was found in [this "gwerbin/uninstall-ghostscript.sh" gist on GitHub](https://gist.github.com/gwerbin/dcba755b0484423e9e45) and downloaded 2025-01-19. I don't know if it's quite working as of 2025-01 and MacTeX 2024. I'm using it as a reference to build my own removal tool.

## License

The `extern/uninstall-ghostscript.sh` file by Greg Wrbin is licensed under the [ISC license](https://opensource.org/license/isc-license-txt). (At least it looks that way based on its copyright header.)

No license is yet granted for the other files in this directory.

## References

* MacTeX documentation
  * [Uninstalling](https://www.tug.org/mactex/uninstalling.html)
  * [Uninstalling MacTeX](https://tug.org/~koch/Uninstalling.html) by user kock

## Notes

Using `pkgutil`:

`pkgutil --packages` lists installed, or at least "remembered" packages.

MacTeX packages seem to have an `org.tug.mactex.*` prefix. There's `texlive<year>`, `gui<year>`, and `ghostscript<ver>` packages. E.g.:

```
$ pkgutil --packages | grep -i mactex
org.tug.mactex.ghostscript10.03.0
org.tug.mactex.gui2024
org.tug.mactex.texlive2020
org.tug.mactex.texlive2023
org.tug.mactex.ghostscript9.50
org.tug.mactex.gui2023
org.tug.mactex.texlive2024
org.tug.mactex.gui2020
$ mt_pkg=org.tug.mactex.texlive2024
$ pkgutil --pkg-groups $mt_pkg
Package ID 'org.tug.mactex.texlive2024' on '/' is not part of any groups.

```

Can also do `pkgutil --pkgs='org\\.tug\\.mactex\\..*'`. That's probably more robust.

```
$ gs_pkg=org.tug.mactex.ghostscript10.03.0
$ pkgutil --pkg-info $gs_pkg
package-id: org.tug.mactex.ghostscript10.03.0
version: 10.03.0
volume: /
location: /
install-time: 1712848056
$
$ pkgutil --only-files --files $gs_pkg
[...]
```

One thing here is that I can't readily tell which ghostscript was installed by which MacTeX. And I think the Ghostscripts all go to the same place, so only one of them will be "live", and the older ones clobbered.

You can go the other way and find out which package a file is (ostensibly) part of. But I think that only means that a file was placed at that path by the given package(s), and doesn't indicate that the file (i.e. contents and attrs) currently there is the same one that was put there by one of those packages.

```
$ pkgutil --file-info /usr/local/share/man/man1/pf2afm.1
volume: /
path: /usr/local/share/man/man1/pf2afm.1

pkgid: org.tug.mactex.ghostscript10.03.0
pkg-version: 10.03.0
install-time: 1712848056
uid: 0
gid: 0
mode: 100644

pkgid: org.tug.mactex.ghostscript9.50
pkg-version: 1.0
install-time: 1588747045
uid: 0
gid: 0
mode: 100644
[texlive] $
```

The original gwerbin `uninstall-ghostscript.sh` script used `pkgutil --bom <file>.pkg` and `lsbom` to get a listing of files from the MacTeX installer file, instead of the installed-package database. Then did file munging to get their installed locations. Could be useful if your installation is messed up, but I think `pkgutil --files` cna get it done more directly for a package that has been installed.

Gonna have to be conservative about deleting directories. Don't want to just blow away `/usr` here.

```
[texlive] $ pkgutil --files $gs_pkg --verbose | head
Files from 'org.tug.mactex.ghostscript10.03.0' on '/':
	usr
	usr/local
	usr/local/bin
	usr/local/bin/dvipdf
	usr/local/bin/eps2eps
	usr/local/bin/gs-X11
	usr/local/bin/gs-noX11
	usr/local/bin/gsbj
```

I think the uninstallation will still need to remove the `/usr/local/share/ghostscript` directory, so its management can be taken over by the `brew link` mechanism. And also because some of its dirs will be root-owned.

```
[share] $ pwd
/usr/local/share
[share] $ ls -ld ghostscript/
drwxrwxr-x@ 5 janke  admin  160 Apr 11  2024 ghostscript/
[share] $ ls -l ghostscript/
total 0
drwxr-xr-x  5 root   wheel  160 Mar  7  2024 10.03.0
drwxrwxr-x  6 janke  admin  192 Jan 20  2019 9.23
drwxr-xr-x  5 root   wheel  160 Mar 10  2020 9.50
[share] $
```

On my machines, many of the files listed by mactex packages are absent from the disk, even for packages I don't remember trying to uninstall. Maybe there are some optional files, or maybe files get moved around by the TexLive self-updater (like the TeX Live Utility)? I'm guessing this is a normal case, so we shouldn't consider absent files an error.

```
./mactex-cleaner probe
Found 8 MacTeX-installed packages
org.tug.mactex.ghostscript10.03.0: files: 993 listed, 510 present, 483 missing
org.tug.mactex.gui2024: files: 35596 listed, 3081 present, 32515 missing
org.tug.mactex.texlive2020: files: 198224 listed, 0 present, 198224 missing
org.tug.mactex.texlive2023: files: 215496 listed, 0 present, 215496 missing
org.tug.mactex.ghostscript9.50: files: 1100 listed, 564 present, 536 missing
org.tug.mactex.gui2023: files: 35749 listed, 2886 present, 32863 missing
org.tug.mactex.texlive2024: files: 234139 listed, 229467 present, 4672 missing
org.tug.mactex.gui2020: files: 2728 listed, 1435 present, 1293 missing
```
