cssthemedir = $(datadir)/blankon-panel
csstheme_DATA = blankon-panel.css

desktopdir = $(datadir)/applications
desktop_in_files = blankon-panel.desktop.in
desktop_DATA = $(desktop_in_files:.desktop.in=.desktop)
@INTLTOOL_DESKTOP_RULE@

EXTRA_DIST = \
    $(csstheme_DATA) \
	$(desktop_in_files)

CLEANFILES = \
	$(desktop_DATA)
