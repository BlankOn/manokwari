NULL = 

AM_CPPFLAGS = \
	$(WNCK_GMENU_DISCLAIMER) \
	$(MANOKWARI_CFLAGS) \
	-include config.h \
	-DLOCALEDIR=\""$(localedir)"\" \
	-DPKGDATADIR=\""$(pkgdatadir)"\" \
	$(NULL)

bin_PROGRAMS = manokwari

manokwari_SOURCES = panel-item.vala \
    main.vala \
    panel-abstract-window.vala \
    panel-window.vala \
    panel-menu-box.vala \
    panel-menu-content.vala \
    panel-tray.vala \
    panel-scrollable-content.vala \
    panel-animated-adjustment.vala \
    panel-clock.vala \
    panel-places.vala \
    panel-screen.vala \
    utils.vala \
    panel-hotkey.vala \
    panel-session-manager.vala \
    panel-menu-html.vala \
    xdg-data.vala \
    panel-user.vala \
    panel-desktop.vala \
    panel-desktop-html.vala \
    panel-desktop-data.vala \
    panel-calendar.vala \
    animated-property.vala \
		panel-shell.vala \
		panel-socket.vala \
		panel-xdg-properties.vala \
	$(NULL)

manokwari_VALAFLAGS = \
    --vapidir ../vapi \
	--pkg config \
    $(VALA_PACKAGES) \
    $(NULL)

manokwari_LDADD = \
	$(MANOKWARI_LIBS) \
	$(NULL)

EXTRA_DIST = \
	$(NULL)

DISTCLEANFILES = \
	$(NULL)


