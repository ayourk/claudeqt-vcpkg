set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

# Only apply the litehtml devendoring patch when building Assistant.
if("assistant" IN_LIST FEATURES)
    set(${PORT}_PATCHES devendor-litehtml.patch)
else()
    set(${PORT}_PATCHES "")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    "assistant" FEATURE_assistant
    "designer" FEATURE_designer
    "linguist" FEATURE_linguist
    "qdbus" FEATURE_qdbus
    "qdoc"   CMAKE_REQUIRE_FIND_PACKAGE_Clang
    "qml"    CMAKE_REQUIRE_FIND_PACKAGE_Qt6Qml
    "qml"    CMAKE_REQUIRE_FIND_PACKAGE_Qt6Quick
    "qml"    CMAKE_REQUIRE_FIND_PACKAGE_Qt6QuickWidgets
    "qml"    FEATURE_distancefieldgenerator
    INVERTED_FEATURES
    "qdoc"   CMAKE_DISABLE_FIND_PACKAGE_Clang
    "qdoc"   CMAKE_DISABLE_FIND_PACKAGE_WrapLibClang
    "qml"    CMAKE_DISABLE_FIND_PACKAGE_Qt6Qml
    "qml"    CMAKE_DISABLE_FIND_PACKAGE_Qt6Quick
    "qml"    CMAKE_DISABLE_FIND_PACKAGE_Qt6QuickWidgets
    )

set(TOOL_NAMES
    lconvert
    lprodump
    lrelease-pro
    lrelease
    lupdate-pro
    lupdate
    qtattributionsscanner
    qtdiag
    qtdiag6
    qtpaths
    qtplugininfo
)

if("assistant" IN_LIST FEATURES)
    list(APPEND TOOL_NAMES assistant qcollectiongenerator qhelpgenerator)
endif()
if("designer" IN_LIST FEATURES)
    list(APPEND TOOL_NAMES designer pixeltool qdistancefieldgenerator)
endif()
if("linguist" IN_LIST FEATURES)
    list(APPEND TOOL_NAMES linguist)
endif()
if("qdbus" IN_LIST FEATURES)
    list(APPEND TOOL_NAMES qdbus qdbusviewer)
endif()
if("qdoc" IN_LIST FEATURES)
    list(APPEND TOOL_NAMES qdoc)
endif()
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND TOOL_NAMES windeployqt)
elseif(VCPKG_TARGET_IS_OSX)
    list(APPEND TOOL_NAMES macdeployqt)
endif()

# When assistant is disabled, prevent CMake from finding litehtml
# so the qlitehtml subdirectory is skipped entirely.
set(EXTRA_CONFIGURE_OPTIONS "")
if(NOT "assistant" IN_LIST FEATURES)
    list(APPEND EXTRA_CONFIGURE_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_litehtml=ON)
endif()

qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     TOOL_NAMES ${TOOL_NAMES}
                     CONFIGURE_OPTIONS
                           ${FEATURE_OPTIONS}
                           ${EXTRA_CONFIGURE_OPTIONS}
                           -DCMAKE_DISABLE_FIND_PACKAGE_Qt6AxContainer=ON
                     CONFIGURE_OPTIONS_RELEASE
                     CONFIGURE_OPTIONS_DEBUG
                    )

if(VCPKG_TARGET_IS_OSX)
    set(OSX_APP_FOLDERS)
    if("designer" IN_LIST FEATURES)
        list(APPEND OSX_APP_FOLDERS Designer.app pixeltool.app)
    endif()
    if("linguist" IN_LIST FEATURES)
        list(APPEND OSX_APP_FOLDERS Linguist.app)
    endif()
    if("qdbus" IN_LIST FEATURES)
        list(APPEND OSX_APP_FOLDERS qdbusviewer.app)
    endif()
    foreach(_appfolder IN LISTS OSX_APP_FOLDERS)
        message(STATUS "Moving: ${_appfolder}")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/${_appfolder}")
        file(RENAME "${CURRENT_PACKAGES_DIR}/bin/${_appfolder}/" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/${_appfolder}/")
    endforeach()
    if(OSX_APP_FOLDERS)
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()
endif()

file(GLOB_RECURSE debug_dir "${CURRENT_PACKAGES_DIR}/debug/*")
list(LENGTH debug_dir debug_dir_elements)
if(debug_dir_elements EQUAL 0)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
endif()
