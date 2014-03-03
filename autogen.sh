#!/bin/sh
# Run this to generate all the initial makefiles, etc.

srcdir=`dirname $0`
test -z "$srcdir" && srcdir=.

PKG_NAME="manokwari"

GNOME_AUTOGEN=`which gnome-autogen.sh`
if [ -z $GNOME_AUTOGEN ]
then
  echo "You need to run dev_require.sh located in this directory"
  exit
else
  . gnome-autogen.sh
fi

