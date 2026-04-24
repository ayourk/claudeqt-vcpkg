# qttools 6.4.2 for ClaudeQt — direct build without qt_install_submodule.
#
# The builtin vcpkg qtbase port ships qt_install_submodule.cmake, but
# hobbycad-vcpkg's custom qtbase port does not. This portfile uses
# vcpkg_from_git + vcpkg_cmake_configure directly.

set(QT_VERSION 6.4.2)

# Only apply the litehtml devendoring patch when building Assistant.
if("assistant" IN_LIST FEATURES)
    set(PATCHES devendor-litehtml.patch)
else()
    set(PATCHES "")
endif()

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://code.qt.io/qt/qttools.git
    REF 2ddbe1df490a4f9a7963a3dc78a8d865165cbf5b
    PATCHES ${PATCHES}
)

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

set(EXTRA_CONFIGURE_OPTIONS "")
if(NOT "assistant" IN_LIST FEATURES)
    list(APPEND EXTRA_CONFIGURE_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_litehtml=ON)
endif()

vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_PATH ${PERL} DIRECTORY)
vcpkg_add_to_path(${PERL_PATH})

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DQT_BUILD_EXAMPLES=OFF
        -DQT_BUILD_TESTS=OFF
        -DHOST_PERL=${PERL}
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6AxContainer=ON
        ${FEATURE_OPTIONS}
        ${EXTRA_CONFIGURE_OPTIONS}
)

vcpkg_cmake_install()

# Move libexec tools into bin/ so vcpkg_copy_tools can find them.
if(EXISTS "${CURRENT_PACKAGES_DIR}/libexec")
    file(GLOB _libexec_tools "${CURRENT_PACKAGES_DIR}/libexec/*")
    foreach(_tool IN LISTS _libexec_tools)
        get_filename_component(_name "${_tool}" NAME)
        file(RENAME "${_tool}" "${CURRENT_PACKAGES_DIR}/bin/${_name}")
    endforeach()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/libexec")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/libexec")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/libexec")
endif()

# Relocate tools to the standard vcpkg tools directory.
set(TOOL_NAMES
    lconvert lprodump lrelease lrelease-pro lupdate lupdate-pro
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
vcpkg_copy_tools(TOOL_NAMES ${TOOL_NAMES} AUTO_CLEAN)

# vcpkg_copy_tools moved executables from bin/ to tools/qttools/.
# Patch the installed CMake targets files so downstream find_package()
# resolves the relocated paths instead of the now-empty bin/.
file(GLOB_RECURSE _targets_files
    "${CURRENT_PACKAGES_DIR}/lib/cmake/Qt6*/Qt6*Targets*.cmake"
    "${CURRENT_PACKAGES_DIR}/share/Qt6*/Qt6*Targets*.cmake"
)
foreach(_f IN LISTS _targets_files)
    vcpkg_replace_string("${_f}" "{_IMPORT_PREFIX}/bin/" "{_IMPORT_PREFIX}/tools/${PORT}/" IGNORE_UNCHANGED)
    vcpkg_replace_string("${_f}" "{_IMPORT_PREFIX}/./bin/" "{_IMPORT_PREFIX}/tools/${PORT}/" IGNORE_UNCHANGED)
    vcpkg_replace_string("${_f}" "{_IMPORT_PREFIX}/./libexec/" "{_IMPORT_PREFIX}/tools/${PORT}/" IGNORE_UNCHANGED)
endforeach()

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
        if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/${_appfolder}")
            file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/${_appfolder}")
            file(RENAME "${CURRENT_PACKAGES_DIR}/bin/${_appfolder}/" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/${_appfolder}/")
        endif()
    endforeach()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/cmake")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/cmake")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSES/GPL-3.0-only.txt")
