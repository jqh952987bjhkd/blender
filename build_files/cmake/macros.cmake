
# only MSVC uses SOURCE_GROUP
MACRO(BLENDERLIB_NOLIST
	name
	sources
	includes)

	MESSAGE(STATUS "Configuring library ${name}")

	INCLUDE_DIRECTORIES(${includes})
	ADD_LIBRARY(${name} ${sources})

	# Group by location on disk
	SOURCE_GROUP("Source Files" FILES CMakeLists.txt)
	FOREACH(SRC ${sources})
		GET_FILENAME_COMPONENT(SRC_EXT ${SRC} EXT)
		IF(${SRC_EXT} MATCHES ".h" OR ${SRC_EXT} MATCHES ".hpp") 
			SOURCE_GROUP("Header Files" FILES ${SRC})
		ELSE()
			SOURCE_GROUP("Source Files" FILES ${SRC})
		ENDIF()
	ENDFOREACH(SRC)
ENDMACRO(BLENDERLIB_NOLIST)

#	# works fine but having the includes listed is helpful for IDE's (QtCreator/MSVC)
#	MACRO(BLENDERLIB_NOLIST
#		name
#		sources
#		includes)
#
#		MESSAGE(STATUS "Configuring library ${name}")
#		INCLUDE_DIRECTORIES(${includes})
#		ADD_LIBRARY(${name} ${sources})
#	ENDMACRO(BLENDERLIB_NOLIST)


MACRO(BLENDERLIB
	name
	sources
	includes)

	BLENDERLIB_NOLIST(${name} "${sources}" "${includes}")

	# Add to blender's list of libraries
	FILE(APPEND ${CMAKE_BINARY_DIR}/cmake_blender_libs.txt "${name};")
ENDMACRO(BLENDERLIB)

MACRO(SETUP_LIBDIRS)
	# see "cmake --help-policy CMP0003"
	if(COMMAND cmake_policy)
		CMAKE_POLICY(SET CMP0003 NEW)
	endif(COMMAND cmake_policy)
	
	LINK_DIRECTORIES(${JPEG_LIBPATH} ${PNG_LIBPATH} ${ZLIB_LIBPATH} ${FREETYPE_LIBPATH})

	IF(WITH_PYTHON)
		LINK_DIRECTORIES(${PYTHON_LIBPATH})
	ENDIF(WITH_PYTHON)
	IF(WITH_INTERNATIONAL)
		LINK_DIRECTORIES(${ICONV_LIBPATH})
		LINK_DIRECTORIES(${GETTEXT_LIBPATH})
	ENDIF(WITH_INTERNATIONAL)
	IF(WITH_SDL)
		LINK_DIRECTORIES(${SDL_LIBPATH})
	ENDIF(WITH_SDL)
	IF(WITH_CODEC_FFMPEG)
		LINK_DIRECTORIES(${FFMPEG_LIBPATH})
	ENDIF(WITH_CODEC_FFMPEG)
	IF(WITH_IMAGE_OPENEXR)
		LINK_DIRECTORIES(${OPENEXR_LIBPATH})
	ENDIF(WITH_IMAGE_OPENEXR)
	IF(WITH_IMAGE_TIFF)
		LINK_DIRECTORIES(${TIFF_LIBPATH})
	ENDIF(WITH_IMAGE_TIFF)
	IF(WITH_LCMS)
		LINK_DIRECTORIES(${LCMS_LIBPATH})
	ENDIF(WITH_LCMS)
	IF(WITH_CODEC_QUICKTIME)
		LINK_DIRECTORIES(${QUICKTIME_LIBPATH})
	ENDIF(WITH_CODEC_QUICKTIME)
	IF(WITH_OPENAL)
		LINK_DIRECTORIES(${OPENAL_LIBPATH})
	ENDIF(WITH_OPENAL)
	IF(WITH_JACK)
		LINK_DIRECTORIES(${JACK_LIBPATH})
	ENDIF(WITH_JACK)
	IF(WITH_CODEC_SNDFILE)
		LINK_DIRECTORIES(${SNDFILE_LIBPATH})
	ENDIF(WITH_CODEC_SNDFILE)
	IF(WITH_SAMPLERATE)
		LINK_DIRECTORIES(${LIBSAMPLERATE_LIBPATH})
	ENDIF(WITH_SAMPLERATE)
	IF(WITH_FFTW3)
		LINK_DIRECTORIES(${FFTW3_LIBPATH})
	ENDIF(WITH_FFTW3)
	IF(WITH_OPENCOLLADA)
		LINK_DIRECTORIES(${OPENCOLLADA_LIBPATH})
		LINK_DIRECTORIES(${PCRE_LIBPATH})
		LINK_DIRECTORIES(${EXPAT_LIBPATH})
	ENDIF(WITH_OPENCOLLADA)

	IF(WIN32 AND NOT UNIX)
		LINK_DIRECTORIES(${PTHREADS_LIBPATH})
	ENDIF(WIN32 AND NOT UNIX)
ENDMACRO(SETUP_LIBDIRS)

MACRO(SETUP_LIBLINKS
	target)
	SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${PLATFORM_LINKFLAGS} ")

	TARGET_LINK_LIBRARIES(${target} ${OPENGL_gl_LIBRARY} ${OPENGL_glu_LIBRARY} ${JPEG_LIBRARY} ${PNG_LIBRARIES} ${ZLIB_LIBRARIES} ${LLIBS})

	# since we are using the local libs for python when compiling msvc projects, we need to add _d when compiling debug versions
	IF(WITH_PYTHON)
		TARGET_LINK_LIBRARIES(${target} ${PYTHON_LINKFLAGS})

		IF(WIN32 AND NOT UNIX)
			TARGET_LINK_LIBRARIES(${target} debug ${PYTHON_LIB}_d)
			TARGET_LINK_LIBRARIES(${target} optimized ${PYTHON_LIB})
		ELSE(WIN32 AND NOT UNIX)
			TARGET_LINK_LIBRARIES(${target} ${PYTHON_LIB})
		ENDIF(WIN32 AND NOT UNIX)
	ENDIF(WITH_PYTHON)

	TARGET_LINK_LIBRARIES(${target} ${OPENGL_glu_LIBRARY} ${JPEG_LIB} ${PNG_LIB} ${ZLIB_LIB})
	TARGET_LINK_LIBRARIES(${target} ${FREETYPE_LIBRARY})

	IF(WITH_INTERNATIONAL)
		TARGET_LINK_LIBRARIES(${target} ${GETTEXT_LIB})

		IF(WIN32 AND NOT UNIX)
			TARGET_LINK_LIBRARIES(${target} ${ICONV_LIB})
		ENDIF(WIN32 AND NOT UNIX)
	ENDIF(WITH_INTERNATIONAL)

	IF(WITH_OPENAL)
		TARGET_LINK_LIBRARIES(${target} ${OPENAL_LIBRARY})
	ENDIF(WITH_OPENAL)
	IF(WITH_FFTW3)	
		TARGET_LINK_LIBRARIES(${target} ${FFTW3_LIB})
	ENDIF(WITH_FFTW3)
	IF(WITH_JACK)
		TARGET_LINK_LIBRARIES(${target} ${JACK_LIB})
	ENDIF(WITH_JACK)
	IF(WITH_CODEC_SNDFILE)
		TARGET_LINK_LIBRARIES(${target} ${SNDFILE_LIB})
	ENDIF(WITH_CODEC_SNDFILE)
	IF(WITH_SAMPLERATE)
		TARGET_LINK_LIBRARIES(${target} ${LIBSAMPLERATE_LIB})
	ENDIF(WITH_SAMPLERATE)	
	IF(WITH_SDL)
		TARGET_LINK_LIBRARIES(${target} ${SDL_LIBRARY})
	ENDIF(WITH_SDL)
	IF(WITH_CODEC_QUICKTIME)
		TARGET_LINK_LIBRARIES(${target} ${QUICKTIME_LIB})
	ENDIF(WITH_CODEC_QUICKTIME)
	IF(WITH_IMAGE_TIFF)
		TARGET_LINK_LIBRARIES(${target} ${TIFF_LIBRARY})
	ENDIF(WITH_IMAGE_TIFF)
	IF(WITH_IMAGE_OPENEXR)
		IF(WIN32 AND NOT UNIX)
			FOREACH(loop_var ${OPENEXR_LIB})
				TARGET_LINK_LIBRARIES(${target} debug ${loop_var}_d)
				TARGET_LINK_LIBRARIES(${target} optimized ${loop_var})
			ENDFOREACH(loop_var)
		ELSE(WIN32 AND NOT UNIX)
			TARGET_LINK_LIBRARIES(${target} ${OPENEXR_LIB})
		ENDIF(WIN32 AND NOT UNIX)
	ENDIF(WITH_IMAGE_OPENEXR)
	IF(WITH_LCMS)
		TARGET_LINK_LIBRARIES(${target} ${LCMS_LIBRARY})
	ENDIF(WITH_LCMS)
	IF(WITH_CODEC_FFMPEG)
		TARGET_LINK_LIBRARIES(${target} ${FFMPEG_LIB})
	ENDIF(WITH_CODEC_FFMPEG)
	IF(WITH_OPENCOLLADA)
		IF(WIN32 AND NOT UNIX)
			FOREACH(loop_var ${OPENCOLLADA_LIB})
				TARGET_LINK_LIBRARIES(${target} debug ${loop_var}_d)
				TARGET_LINK_LIBRARIES(${target} optimized ${loop_var})
			ENDFOREACH(loop_var)
			TARGET_LINK_LIBRARIES(${target} debug ${PCRE_LIB}_d)
			TARGET_LINK_LIBRARIES(${target} optimized ${PCRE_LIB})
			IF(EXPAT_LIB)
				TARGET_LINK_LIBRARIES(${target} debug ${EXPAT_LIB}_d)
				TARGET_LINK_LIBRARIES(${target} optimized ${EXPAT_LIB})
			ENDIF(EXPAT_LIB)
		ELSE(WIN32 AND NOT UNIX)
			TARGET_LINK_LIBRARIES(${target} ${OPENCOLLADA_LIB})
			TARGET_LINK_LIBRARIES(${target} ${PCRE_LIB})
			TARGET_LINK_LIBRARIES(${target} ${EXPAT_LIB})
		ENDIF(WIN32 AND NOT UNIX)
	ENDIF(WITH_OPENCOLLADA)
	IF(WITH_LCMS)
		IF(WIN32 AND NOT UNIX)
			TARGET_LINK_LIBRARIES(${target} debug ${LCMS_LIB}_d)
			TARGET_LINK_LIBRARIES(${target} optimized ${LCMS_LIB})
		ENDIF(WIN32 AND NOT UNIX)
	ENDIF(WITH_LCMS)
	IF(WIN32 AND NOT UNIX)
		TARGET_LINK_LIBRARIES(${target} ${PTHREADS_LIB})
	ENDIF(WIN32 AND NOT UNIX)
ENDMACRO(SETUP_LIBLINKS)

MACRO(TEST_SSE_SUPPORT)
	INCLUDE(CheckCSourceRuns)

	MESSAGE(STATUS "Detecting SSE support")
	IF(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
		SET(CMAKE_REQUIRED_FLAGS "-msse -msse2")
	ELSEIF(MSVC)
		SET(CMAKE_REQUIRED_FLAGS "/arch:SSE2") # TODO, SSE 1 ?
	ENDIF()

	CHECK_C_SOURCE_RUNS("
		#include <xmmintrin.h>
		int main() { __m128 v = _mm_setzero_ps(); return 0; }"
	SUPPORT_SSE_BUILD)

	CHECK_C_SOURCE_RUNS("
		#include <emmintrin.h>
		int main() { __m128d v = _mm_setzero_pd(); return 0; }"
	SUPPORT_SSE2_BUILD)
	MESSAGE(STATUS "Detecting SSE support")

	IF(SUPPORT_SSE_BUILD)
		MESSAGE(STATUS "   ...SSE support found.")
	ELSE(SUPPORT_SSE_BUILD)
		MESSAGE(STATUS "   ...SSE support missing.")
	ENDIF(SUPPORT_SSE_BUILD)

	IF(SUPPORT_SSE2_BUILD)
		MESSAGE(STATUS "   ...SSE2 support found.")
	ELSE(SUPPORT_SSE2_BUILD)
		MESSAGE(STATUS "   ...SSE2 support missing.")
	ENDIF(SUPPORT_SSE2_BUILD)

ENDMACRO(TEST_SSE_SUPPORT)

# when we have warnings as errors applied globally this
# needs to be removed for some external libs which we dont maintain.

# utility macro
MACRO(_REMOVE_STRICT_FLAGS
	flag)
	
	STRING(REGEX REPLACE ${flag} "" CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")
	STRING(REGEX REPLACE ${flag} "" CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG}")
	STRING(REGEX REPLACE ${flag} "" CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE}")
	STRING(REGEX REPLACE ${flag} "" CMAKE_C_FLAGS_MINSIZEREL "${CMAKE_C_FLAGS_MINSIZEREL}")
	STRING(REGEX REPLACE ${flag} "" CMAKE_C_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELWITHDEBINFO}")

	STRING(REGEX REPLACE ${flag} "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
	STRING(REGEX REPLACE ${flag} "" CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG}")
	STRING(REGEX REPLACE ${flag} "" CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}")
	STRING(REGEX REPLACE ${flag} "" CMAKE_CXX_FLAGS_MINSIZEREL "${CMAKE_CXX_FLAGS_MINSIZEREL}")
	STRING(REGEX REPLACE ${flag} "" CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO}")

ENDMACRO(_REMOVE_STRICT_FLAGS)

MACRO(REMOVE_STRICT_FLAGS)

	IF(CMAKE_COMPILER_IS_GNUCC)
		_REMOVE_STRICT_FLAGS("-Wstrict-prototypes")
		_REMOVE_STRICT_FLAGS("-Wunused-parameter")
		_REMOVE_STRICT_FLAGS("-Wshadow")
		_REMOVE_STRICT_FLAGS("-Werror=[^ ]+")
		_REMOVE_STRICT_FLAGS("-Werror")
	ENDIF(CMAKE_COMPILER_IS_GNUCC)

	IF(MSVC)
		# TODO
	ENDIF(MSVC)

ENDMACRO(REMOVE_STRICT_FLAGS)


MACRO(GET_BLENDER_VERSION)
	FILE(READ ${CMAKE_SOURCE_DIR}/source/blender/blenkernel/BKE_blender.h CONTENT)
	STRING(REGEX REPLACE "\n" ";" CONTENT "${CONTENT}")
	STRING(REGEX REPLACE "\t" ";" CONTENT "${CONTENT}")
	STRING(REGEX REPLACE " " ";" CONTENT "${CONTENT}")

	FOREACH(ITEM ${CONTENT})
		IF(LASTITEM MATCHES "BLENDER_VERSION")
			MATH(EXPR BLENDER_VERSION_MAJOR "${ITEM} / 100")
			MATH(EXPR BLENDER_VERSION_MINOR "${ITEM} % 100")
			SET(BLENDER_VERSION "${BLENDER_VERSION_MAJOR}.${BLENDER_VERSION_MINOR}")
		ENDIF(LASTITEM MATCHES "BLENDER_VERSION")
		
		IF(LASTITEM MATCHES "BLENDER_SUBVERSION")
			SET(BLENDER_SUBVERSION ${ITEM})
		ENDIF(LASTITEM MATCHES "BLENDER_SUBVERSION")
		
		IF(LASTITEM MATCHES "BLENDER_MINVERSION")
			MATH(EXPR BLENDER_MINVERSION_MAJOR "${ITEM} / 100")
			MATH(EXPR BLENDER_MINVERSION_MINOR "${ITEM} % 100")
			SET(BLENDER_MINVERSION "${BLENDER_MINVERSION_MAJOR}.${BLENDER_MINVERSION_MINOR}")
		ENDIF(LASTITEM MATCHES "BLENDER_MINVERSION")
		
		IF(LASTITEM MATCHES "BLENDER_MINSUBVERSION")
			SET(BLENDER_MINSUBVERSION ${ITEM})
		ENDIF(LASTITEM MATCHES "BLENDER_MINSUBVERSION")

		SET(LASTITEM ${ITEM})
	ENDFOREACH(ITEM ${CONTENT})
	
	MESSAGE(STATUS "Version major: ${BLENDER_VERSION_MAJOR}, Version minor: ${BLENDER_VERSION_MINOR}, Subversion: ${BLENDER_SUBVERSION}, Version: ${BLENDER_VERSION}")
	MESSAGE(STATUS "Minversion major: ${BLENDER_MINVERSION_MAJOR}, Minversion minor: ${BLENDER_MINVERSION_MINOR}, MinSubversion: ${BLENDER_MINSUBVERSION}, Minversion: ${BLENDER_MINVERSION}")
ENDMACRO(GET_BLENDER_VERSION)
