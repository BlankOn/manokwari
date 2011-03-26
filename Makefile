SOURCES=panel-item.vala \
    main.vala \
    panel-abstract-window.vala \
    panel-horizontal.vala \
    panel-menu.vala \
    panel-menu-box.vala \
    panel-button.vala \
    panel-clock.vala \
    panel-favorites.vala \
    panel-applications.vala \

LIBS= --pkg gee-1.0 --pkg cairo --pkg gtk+-3.0 --pkg gio-unix-2.0 --pkg libgnome-menu --pkg gdk-3.0 --pkg indicator3 -X "-DGMENU_I_KNOW_THIS_IS_UNSTABLE" --includedir=/usr/include/libindicator3-0.3/ 
BIN=blankon-panel

blankon-panel:
	valac  -o $(BIN) $(SOURCES) $(LIBS) --vapidir vapi

all: blankon-panel

clean:
	rm -f $(BIN)
