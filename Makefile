SOURCES=panel-item.vala \
    main.vala \
    panel-abstract-window.vala \
    panel-window.vala \
    panel-menu-box.vala \
    panel-button.vala \
    panel-menu-content.vala \

LIBS= --pkg gdk-x11-3.0 --pkg gee-1.0 --pkg cairo --pkg gtk+-3.0 --pkg gio-unix-2.0 --pkg libgnome-menu --pkg gdk-3.0 -X "-DGMENU_I_KNOW_THIS_IS_UNSTABLE" --pkg libwnck-3.0 -X "-DWNCK_I_KNOW_THIS_IS_UNSTABLE" 
BIN=blankon-panel

blankon-panel:
	valac  -o $(BIN) $(SOURCES) $(LIBS) --vapidir vapi

all: blankon-panel

clean:
	rm -f $(BIN)
