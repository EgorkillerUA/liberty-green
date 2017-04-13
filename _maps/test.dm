#if !defined(MAP_FILE)

		#define TITLESCREEN "title" //Add an image in misc/fullscreen.dmi, and set this define to the icon_state, to set a custom titlescreen for your map

		#define MINETYPE "lavaland"

        #include "test.dmm"

		#define MAP_PATH ""
        #define MAP_FILE "test.dmm"
        #define MAP_NAME "Box Station"

        #define MAP_TRANSITION_CONFIG	list(MAIN_STATION = CROSSLINKED)

#elif !defined(MAP_OVERRIDE)

	#warn a map has already been included, ignoring /tg/station 2.

#endif