NULL = 

AM_CPPFLAGS = \
	$(BLANKON_PANEL_CFLAGS) \
	-include $(CONFIG_HEADER) \
	$(NULL)

bin_PROGRAMS = blankon_panel

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
	$(NULL)

blankon_panel_VALAFLAGS = \
    --vapidir ../vapi \
    $(VALA_PACKAGES) \
    $(NULL)

blankon_panel_LDADD = \
	$(BLANKON_PANEL_LIBS) \
	$(NULL)

EXTRA_DIST = \
	$(NULL)

DISTCLEANFILES = \
	$(NULL)

