SOURCES=panel-item.vala \
    main.vala \
    panel-abstract-window.vala \
    panel-horizontal.vala \
    panel-menu.vala \
    panel-menu-box.vala \
    panel-button.vala \
    panel-clock.vala \
    panel-favorites.vala \

LIBS= --pkg cairo --pkg gtk+-3.0 --pkg gio-unix-2.0 --pkg libgnome-menu --pkg gdk-3.0 -X "-DGMENU_I_KNOW_THIS_IS_UNSTABLE" 
BIN=blankon-panel

blankon-panel:
	valac -o $(BIN) $(SOURCES) $(LIBS) --vapidir vapi

all: blankon-panel

clean:
	rm -f $(BIN)
