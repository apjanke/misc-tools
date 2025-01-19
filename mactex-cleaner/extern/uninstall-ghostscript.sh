#!/usr/bin/env bash

# Copyright (c) 2015, 2020, and 2021 by Greg Werbin.
#
# Permission to use, copy, modify, and/or distribute this software for any purpose with
# or without fee is hereby granted, provided that the above copyright notice and this
# permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED “AS IS” AND ISC DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS
# SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT
# SHALL ISC BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY
# DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION
# OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH
# THE USE OR PERFORMANCE OF THIS SOFTWARE.

# The MacTex website (https://www.tug.org/mactex/uninstalling.html) says it's
# "difficult" to uninstall Ghostscript, as installed by MacTex.
# 
# Their suggestion is to "Open the MacTeX-2015 install package and select 'Show Files'
# from the resulting 'File' menu of Apple's installer", and then "find files related to
# Ghostscript and remove them."
#
# This script is an attempt to automate that process. It prints the names of the deleted
# files, and moves the files to the user's Trash. This can help you roll back the
# effects of the script in case something goes wrong.
#
# Note that this requires write access to the `/tmp` directory on your computer.
#
# Note also that different versions of MacTex might require changes to this script.
#
# Example usage:
#  1) You saved `mactex-20150613.pkg` in `~/Downloads`, and used that to install MacTex.
#  2) Run `bash uninstall-ghostscript.sh ~/Downloads/mactex-20150613.pkg`
#
# These files were removed from my system when I used this tool:
#  /usr/local/bin/dvipdf
#  /usr/local/bin/eps2eps
#  /usr/local/bin/font2c
#  /usr/local/bin/gs-X11
#  /usr/local/bin/gs-X11-64Bit
#  /usr/local/bin/gs-X11-Yosemite
#  /usr/local/bin/gs-noX11
#  /usr/local/bin/gs-noX11-64Bit
#  /usr/local/bin/gs-noX11-Yosemite
#  /usr/local/bin/gsbj
#  /usr/local/bin/gsdj
#  /usr/local/bin/gsdj500
#  /usr/local/bin/gslj
#  /usr/local/bin/gslp
#  /usr/local/bin/gsnd
#  /usr/local/bin/lprsetup.sh
#  /usr/local/bin/pdf2dsc
#  /usr/local/bin/pdf2ps
#  /usr/local/bin/pf2afm
#  /usr/local/bin/pfbtopfa
#  /usr/local/bin/pphs
#  /usr/local/bin/printafm
#  /usr/local/bin/ps2ascii
#  /usr/local/bin/ps2epsi
#  /usr/local/bin/ps2pdf
#  /usr/local/bin/ps2pdf12
#  /usr/local/bin/ps2pdf13
#  /usr/local/bin/ps2pdf14
#  /usr/local/bin/ps2pdfwr
#  /usr/local/bin/ps2ps
#  /usr/local/bin/ps2ps2
#  /usr/local/bin/unix-lpr.sh
#  /usr/local/bin/wftopfa
#  /usr/local/share/man/de/man1/dvipdf.1
#  /usr/local/share/man/de/man1/font2c.1
#  /usr/local/share/man/de/man1/gsnd.1
#  /usr/local/share/man/de/man1/pdf2dsc.1
#  /usr/local/share/man/de/man1/pdf2ps.1
#  /usr/local/share/man/de/man1/printafm.1
#  /usr/local/share/man/de/man1/ps2ascii.1
#  /usr/local/share/man/de/man1/ps2pdf.1
#  /usr/local/share/man/de/man1/ps2ps.1
#  /usr/local/share/man/de/man1/wftopfa.1
#  /usr/local/share/man/man1/dvipdf.1
#  /usr/local/share/man/man1/font2c.1
#  /usr/local/share/man/man1/gs.1
#  /usr/local/share/man/man1/gslp.1
#  /usr/local/share/man/man1/gsnd.1
#  /usr/local/share/man/man1/pdf2dsc.1
#  /usr/local/share/man/man1/pdf2ps.1
#  /usr/local/share/man/man1/pf2afm.1
#  /usr/local/share/man/man1/pfbtopfa.1
#  /usr/local/share/man/man1/printafm.1
#  /usr/local/share/man/man1/ps2ascii.1
#  /usr/local/share/man/man1/ps2epsi.1
#  /usr/local/share/man/man1/ps2pdf.1
#  /usr/local/share/man/man1/ps2pdfwr.1
#  /usr/local/share/man/man1/ps2ps.1
#  /usr/local/share/man/man1/wftopfa.1
#
# And finally the directory:
#  /usr/local/share/ghostscript

move_to_trash() {
  # Move a file to the MacOS "Trash".
  # If the operation fails (e.g. the file is missing), an error message is emitted.
  command mv -v "$1" ~/.Trash \
    || >&2 echo "Failed to remove file or directory: $1"
}

uninstall_ghostscript () {
  # `pkgutil --bom` extracts any BOM ("bill of materials") files from the package
  # and emits its location. We only need `local.pkg`.
  # NOTE: This filename might change in newer versions of MacTex.
  bom_usr_local="$( pkgutil --bom $1 | fgrep local.pkg )"

  # 1) `lsbom -s f` lists the paths of the files in the BOM.
  # 2) Filter out the `ghostscript` directory (we will remove it only once everything else is gone).
  # 3) Replace the `.` prefix with the proper installation prefix: `/usr/local`.
  # 4) For each filename, move the file to Trash.
  lsbom -s -f "$bom_usr_local" \
  | fgrep -v ghostscript \
  | sed 's_^\._/usr/local_' \
  | while read filename; do 
      move_to_trash "$filename"
    done

  # Finally, remove the `ghostscript` directory itself.
  move_to_trash /usr/local/share/ghostscript
}

uninstall_ghostscript "$@"
