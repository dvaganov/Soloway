SRC = \
src/settings.vala \
src/filedialog.vala \
src/playlist.vala \
src/widgets.vala \
src/player.vala \
src/window.vala \
src/application.vala

PKG = \
--pkg gtk+-3.0 \
--pkg gstreamer-1.0

all: soloway

soloway: $(SRC)
	valac $(PKG) -o SoloWay $(SRC)
