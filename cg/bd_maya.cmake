set(MAYA_VERSION "2016" CACHE STRING "Maya version")
set(MAYA_VERSIONS "2009;2010;2011;2012;2013;2013.5;2014;2015;2016")
set_property(CACHE MAYA_VERSION PROPERTY STRINGS ${MAYA_VERSIONS})

set(MAYA_ROOT "C:/Program Files/Autodesk/Maya${MAYA_VERSION}" CACHE STRING "Maya install root")
set(MAYA_MODULE_PATH "${MAYA_ROOT}/modules" CACHE STRING "Maya modules path")
set(MAYA_PLUGIN_PATH "${MAYA_ROOT}/plug-ins" CACHE STRING "Maya plugins path")

set(MAYA_LOCAL_INSTALL_PATH "${LOCAL_INSTALL}/maya/${OS}/${MAYA_VERSION}/${ARCH}" CACHE PATH "")

if(WITH_CUSTOM_MAYA)
	set(MAYA_INCPATH ${WITH_MAYA_INCPATH})
	set(MAYA_LIBPATH ${WITH_MAYA_LIBPATH})
else()
	set(MAYA_INCPATH
		${SDK_ROOT}/maya/${MAYA_VERSION}/include
	)
	set(MAYA_LIBPATH
		${SDK_ROOT}/maya/${MAYA_VERSION}/lib/${OS}/${ARCH}
		# To fix my old OSX SDK directory structure
		${SDK_ROOT}/maya/${MAYA_VERSION}/lib/${OS}
	)
endif()

file(TO_CMAKE_PATH "${MAYA_INCPATH}" MAYA_INCPATH)
file(TO_CMAKE_PATH "${MAYA_LIBPATH}" MAYA_LIBPATH)

set(MAYA_DEFINITIONS
	-D_BOOL
	-DREQUIRE_IOSTREAM
	-DNOMINMAX
)

if(ARCH EQUAL "x64")
	list(APPEND MAYA_DEFINITIONS -DBits64_)
endif()

set(MAYA_LIBS
	OpenMaya
	OpenMayaUI
	OpenMayaFX
	OpenMayaAnim
	OpenMayaRender
)

if(WIN32)
	list(APPEND MAYA_LIBS
		Foundation
		OpenGL32
	)
endif()

if(APPLE)
	list(APPEND MAYA_LIBS
		Foundation
	)
endif()

macro(bd_init_maya)
	message_sdk("Maya SDK" "${MAYA_INCPATH}" "${MAYA_LIBPATH}")
endmacro()

function(bd_maya_setup _target)
	set_target_properties(${_target}
		PROPERTIES
			PREFIX ""
	)

	target_compile_definitions(${_target} PRIVATE ${MAYA_DEFINITIONS})
	target_include_directories(${_target} PRIVATE ${MAYA_INCPATH})
	target_link_directories(${_target}    PRIVATE ${MAYA_LIBPATH})
	target_link_libraries(${_target}      PRIVATE ${MAYA_LIBS})
endfunction()

function(bd_maya_ext _target)
	if(${OS} MATCHES "osx")
		set(MAYA_DSO_EXT ".bundle")
	elseif(${OS} MATCHES "windows")
		set(MAYA_DSO_EXT ".mll")
	else()
		set(MAYA_DSO_EXT ".so")
	endif()

	set_target_properties(${_target}
		PROPERTIES
			SUFFIX ${MAYA_DSO_EXT}
	)
endfunction()
