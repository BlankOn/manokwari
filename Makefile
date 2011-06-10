SOURCES=panel-item.vala \
    main.vala \
    panel-abstract-window.vala \
    panel-window.vala \
    panel-menu-box.vala \
    panel-button.vala \
    panel-menu-content.vala \
    panel-tray.vala \

LIBS= --pkg atk --pkg gdk-x11-3.0 --pkg gee-1.0 --pkg cairo --pkg gtk+-3.0 --pkg gio-unix-2.0 --pkg libgnome-menu --pkg gdk-3.0 -X "-DGMENU_I_KNOW_THIS_IS_UNSTABLE" --pkg libwnck-3.0 -X "-DWNCK_I_KNOW_THIS_IS_UNSTABLE" 
BIN=blankon-panel

PREFIX=$(INSTALL_DIR)/usr
BINDIR=$(PREFIX)/bin

$(BIN):
	valac  -o $(BIN) $(SOURCES) $(LIBS) --vapidir vapi

all: $(BIN) 

clean:
	rm -f $(BIN)

dirinstall:
	install -d $(BINDIR)

install: dirinstall
	install $(BIN) $(BINDIR)
