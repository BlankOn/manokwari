AC_INIT([blankon-panel], [0.1.0], [], [blankon-panel])
AC_CONFIG_SRCDIR([Makefile.am])
AC_CONFIG_HEADERS(config.h)
AM_INIT_AUTOMAKE([dist-bzip2])
AM_MAINTAINER_MODE

AC_PROG_CC
AM_PROG_CC_C_O
AC_DISABLE_STATIC
AC_PROG_LIBTOOL

AC_PATH_PROG(VALAC, valac, valac)
AC_SUBST(VALAC)

AH_TEMPLATE([GETTEXT_PACKAGE], [Package name for gettext])
GETTEXT_PACKAGE=blankon-panel
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

PKG_CHECK_MODULES(BLANKON_PANEL, glib-2.0 >= $GLIB_REQUIRED gobject-2.0 >= $GLIB_REQUIRED gtk+-3.0 >= $GTK_REQUIRED atk >= $ATK_REQUIRED gee-1.0 >= $GEE_REQUIRED cairo >= $CAIRO_REQUIRED libgnome-menu >= $LIBGNOME_MENU_REQUIRED libwnck-3.0 >= $LIBWNCK_REQUIRED)

BLANKON_PANEL_CFLAGS='-pthread -DGSEAL_ENABLE -I/usr/include/glib-2.0 -I/usr/lib/i386-linux-gnu/glib-2.0/include -I/usr/include/atk-1.0 -I/usr/include/pango-1.0 -I/usr/include/gio-unix-2.0/ -I/usr/include/freetype2 -I/usr/include/libpng12 -I/usr/include/gtk-3.0 -I/usr/include/cairo -I/usr/include/gdk-pixbuf-2.0 -I/usr/include/pixman-1 -I/usr/include/gee-1.0 -I/usr/include/gnome-menus "-DGMENU_I_KNOW_THIS_IS_UNSTABLE" -I/usr/include/libwnck-3.0 "-DWNCK_I_KNOW_THIS_IS_UNSTABLE" -I/usr/include/startup-notification-1.0'

AC_SUBST(BLANKON_PANEL_CFLAGS)
AC_SUBST(BLANKON_PANEL_LIBS)

VALA_PACKAGES="--pkg atk --pkg gdk-x11-3.0 --pkg gee-1.0 --pkg cairo --pkg gtk+-3.0 --pkg gio-unix-2.0 --pkg libgnome-menu --pkg gdk-3.0 -X '-DGMENU_I_KNOW_THIS_IS_UNSTABLE' --pkg libwnck-3.0 -X '-DWNCK_I_KNOW_THIS_IS_UNSTABLE'"

AC_SUBST(VALA_PACKAGES)

AC_CONFIG_FILES([Makefile
	data/Makefile.in
	src/Makefile
	po/Makefile.in])

AC_OUTPUT
