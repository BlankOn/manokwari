AC_INIT([manokwari], [1.0.0], [], [manokwari])
AC_CONFIG_SRCDIR([Makefile.am])
AC_CONFIG_HEADERS(config.h)
AM_INIT_AUTOMAKE([dist-bzip2])
AM_MAINTAINER_MODE

AC_PROG_CC
AM_PROG_CC_C_O
AC_DISABLE_STATIC
AC_PROG_LIBTOOL

AM_PROG_VALAC([0.18.0])

AC_ARG_ENABLE([devel], AC_HELP_STRING([--enable-devel],[Enable development mode with system dir in current directory]), USE_DEVEL="$enableval", USE_DEVEL="no")
if test $USE_DEVEL = yes ; then
AC_DEFINE_UNQUOTED(SYSTEM_PATH, "$PWD/system", [Location of the JS scripts])
AC_SUBST(SYSTEM_PATH)
else
AC_DEFINE(SYSTEM_PATH, "/usr/lib/manokwari/system", [Location of the JS scripts])
AC_SUBST(SYSTEM_PATH)
fi

AC_ARG_ENABLE([devel], AC_HELP_STRING([--enable-devel],[Enable development mode with sessions dir in current directory]), USE_DEVEL="$enableval", USE_DEVEL="no")
if test $USE_DEVEL = yes ; then
AC_DEFINE_UNQUOTED(SESSIONS_PATH, "$PWD/files/sessions", [Location of the Sessions scripts])
AC_SUBST(SESSIONS_PATH)
else
AC_DEFINE(SESSIONS_PATH, "/usr/share/gnome-session/sessions", [Location of the Sessions scripts])
AC_SUBST(SESSIONS_PATH)
fi

AC_ARG_ENABLE([devel], AC_HELP_STRING([--enable-devel],[Enable development mode with xsessions dir in current directory]), USE_DEVEL="$enableval", USE_DEVEL="no")
if test $USE_DEVEL = yes ; then
AC_DEFINE_UNQUOTED(XSESSIONS_PATH, "$PWD/files/xsessions", [Location of the Xsessions scripts])
AC_SUBST(XSESSIONS_PATH)
else
AC_DEFINE(XSESSIONS_PATH, "/usr/share/xsessions", [Location of the Xsessions scripts])
AC_SUBST(XSESSIONS_PATH)
fi

AC_ARG_ENABLE([devel], AC_HELP_STRING([--enable-devel],[Enable development mode with bin dir in current directory]), USE_DEVEL="$enableval", USE_DEVEL="no")
if test $USE_DEVEL = yes ; then
AC_DEFINE_UNQUOTED(BIN_PATH, "$PWD/files/bin", [Location of the Session scripts])
AC_SUBST(BIN_PATH)
else
AC_DEFINE(BIN_PATH, "/usr/bin", [Location of the Session scripts])
AC_SUBST(BIN_PATH)
fi

AH_TEMPLATE([GETTEXT_PACKAGE], [Package name for gettext])
GETTEXT_PACKAGE=manokwari
AC_DEFINE_UNQUOTED(GETTEXT_PACKAGE, "$GETTEXT_PACKAGE")
AC_SUBST(GETTEXT_PACKAGE)
AM_GLIB_GNU_GETTEXT
IT_PROG_INTLTOOL([0.35.0])

AC_SUBST(CFLAGS)
AC_SUBST(CPPFLAGS)
AC_SUBST(LDFLAGS)

GLIB_REQUIRED=2.12.0
GTK_REQUIRED=3.0.8
ATK_REQUIRED=2.0.0
GEE_REQUIRED=0.6.1
CAIRO_REQUIRED=1.10.2
LIBGNOME_MENU_REQUIRED=2.30.5
LIBWNCK_REQUIRED=3.0.0
UNIQUE_REQUIRED=3.0.0
WEBKIT_REQUIRED=1.3.0
X11_REQUIRED=1.6.0
LIBNOTIFY_REQUIRED=0.7.6

PKG_CHECK_MODULES(MANOKWARI, glib-2.0 >= $GLIB_REQUIRED gobject-2.0 >= $GLIB_REQUIRED gtk+-3.0 >= $GTK_REQUIRED atk >= $ATK_REQUIRED gee-1.0 >= $GEE_REQUIRED cairo >= $CAIRO_REQUIRED libgnome-menu-3.0 >= $LIBGNOME_MENU_REQUIRED libwnck-3.0 >= $LIBWNCK_REQUIRED unique-3.0 >= $UNIQUE_REQUIRED webkitgtk-3.0 >= $WEBKIT_REQUIRED x11 >= $X11_REQUIRED libnotify >= $LIBNOTIFY_REQUIRED)

WNCK_GMENU_DISCLAIMER='-DGMENU_I_KNOW_THIS_IS_UNSTABLE -DWNCK_I_KNOW_THIS_IS_UNSTABLE'

AC_SUBST(WNCK_GMENU_DISCLAIMER)
AC_SUBST(MANOKWARI_CFLAGS)
AC_SUBST(MANOKWARI_LIBS)

VALA_PACKAGES="--pkg atk --pkg x11 --pkg gdk-x11-3.0 --pkg gee-1.0 --pkg cairo --pkg gtk+-3.0 --pkg gio-unix-2.0 --pkg libgnome-menu-3.0 --pkg gdk-3.0 --pkg libwnck-3.0 --pkg unique-3.0 --pkg webkit-1.0 --pkg javascriptcore --pkg libsoup-2.4 --pkg libnotify"

AC_SUBST(VALA_PACKAGES)

AC_PREFIX_DEFAULT("/usr")

AC_CONFIG_FILES([Makefile
	data/Makefile
	data/manokwari.desktop
	src/Makefile
	system/Makefile
	po/Makefile.in
	files/bin/Makefile
	files/sessions/Makefile
	files/xsessions/Makefile
	files/menus/Makefile])

AC_OUTPUT
