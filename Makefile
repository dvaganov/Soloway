SRC = \
src/window.vala \
src/application.vala \
src/player.vala \
src/widgets.vala

PKG = \
--pkg gtk+-3.0 \
--pkg gstreamer-1.0

all: soloway

soloway: $(SRC)
	valac $(PKG) -o SoloWay $(SRC)
