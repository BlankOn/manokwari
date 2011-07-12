NULL = 

AM_CPPFLAGS = \
	$(BLANKON_PANEL_CFLAGS) \
	-include $(CONFIG_HEADER) \
	$(NULL)

bin_PROGRAMS = blankon_panel

blankon_panel_SOURCES = \
	main.vala \
	$(NULL)

blankon_panel_VALAFLAGS = --pkg gtk+-2.0

blankon_panel_LDADD = \
	$(BLANKON_PANEL_LIBS) \
	$(NULL)

EXTRA_DIST = \
	$(NULL)

DISTCLEANFILES = \
	$(NULL)

