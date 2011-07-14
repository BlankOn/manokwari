NULL = 

#Build in these directories:

SUBDIRS = \
	data \
	src \
	po \
	$(NULL)

blankon_paneldocdir = ${prefix}/doc/blankon_panel
blankon_paneldoc_DATA = \
	ChangeLog \
	README \
	COPYING \
	AUTHORS \
	INSTALL \
	NEWS\
	$(NULL)

EXTRA_DIST = \
	$(blankon_paneldoc_DATA) \
	intltool-extract.in \
	intltool-merge.in \
	intltool-update.in\
	$(NULL)

DISTCLEANFILES = \
	intltool-extract \
	intltool-merge \
	intltool-update \
	po/.intltool-merge-cache \
	$(NULL)

