TARGET = soloway
PREFIX = /usr/share/glib-2.0/schemas
SRC = \
src/interfaces.vala \
src/sidepanel.vala \
src/filedialog.vala \
src/playlist.vala \
src/widgets.vala \
src/player.vala \
src/window.vala \
src/application.vala

PKG = \
--pkg gtk+-3.0 \
--pkg gstreamer-1.0

# .PHONY: schema

all: $(TARGET)

$(TARGET): $(SRC)
	valac $(PKG) -o $(TARGET) $(SRC)

install:
	sudo cp apps.$(TARGET).gschema.xml $(PREFIX)
	sudo glib-compile-schemas --strict $(PREFIX)
	sudo ln -s $(CURDIR)/$(TARGET) /bin
	sudo ln -s $(CURDIR)/apps.Soloway.desktop /usr/share/applications

uninstall:
	sudo rm $(PREFIX)/apps.$(TARGET).gschema.xml
	sudo glib-compile-schemas --strict $(PREFIX)
	sudo rm /bin/$(TARGET)
	sudo rm /usr/share/applications/apps.soloway.desktop
