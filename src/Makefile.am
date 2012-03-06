NULL = 

AM_CPPFLAGS = \
	$(WNCK_GMENU_DISCLAIMER) \
	$(BLANKON_PANEL_CFLAGS) \
	-include config.h \
	-DLOCALEDIR=\""$(localedir)"\" \
	-DPKGDATADIR=\""$(pkgdatadir)"\" \
	$(NULL)

bin_PROGRAMS = blankon-panel

blankon_panel_SOURCES = panel-item.vala \
    main.vala \
    panel-abstract-window.vala \
    panel-window.vala \
    panel-menu-box.vala \
    panel-button.vala \
    panel-menu-content.vala \
    panel-tray.vala \
    panel-scrollable-content.vala \
    panel-animated-adjustment.vala \
    panel-clock.vala \
    panel-places.vala \
    panel-screen.vala \
    panel-menu-favorites.vala \
    panel-utils.vala \
    panel-hotkey.vala \
    panel-session-manager.vala \
    panel-menu-html.vala \
    panel-xdg-data.vala \
    panel-user.vala \
	$(NULL)

blankon_panel_VALAFLAGS = \
    --vapidir ../vapi \
	--pkg config \
    $(VALA_PACKAGES) \
    $(NULL)

blankon_panel_LDADD = \
	$(BLANKON_PANEL_LIBS) \
	$(NULL)

EXTRA_DIST = \
	$(NULL)

DISTCLEANFILES = \
	$(NULL)


