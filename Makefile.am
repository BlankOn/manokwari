NULL = 

#Build in these directories:

SUBDIRS = \
	data \
	src \
	system \
	po \
	files/bin \
	files/sessions \
	files/xsessions \
	files/menus \
	$(NULL)

manokwaridocdir = ${prefix}/doc/manokwari
manokwaridoc_DATA = \
	ChangeLog \
	README \
	COPYING \
	AUTHORS \
	INSTALL \
	NEWS\
	$(NULL)

EXTRA_DIST = \
	$(manokwaridoc_DATA) \
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

