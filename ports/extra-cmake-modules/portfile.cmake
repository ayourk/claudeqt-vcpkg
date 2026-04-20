# extra-cmake-modules (ECM) 5.115.0 for ClaudeQt.
#
# ECM is a collection of CMake modules and scripts used by KDE
# Frameworks builds (KSyntaxHighlighting in our case). Pure CMake —
# no compiled binaries — so it's arch-independent and installs once
# regardless of target triplet.

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://invent.kde.org/frameworks/extra-cmake-modules.git
    REF bf19535ed090d8381a353ff39dc756fa927855c5
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_HTML_DOCS=OFF
        -DBUILD_MAN_DOCS=OFF
        -DBUILD_QTHELP_DOCS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME ECM CONFIG_PATH "share/ECM/cmake")

# ECM ships no debug artifacts — drop the empty debug tree.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Relocate bundled license to vcpkg's per-package location.
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING-CMAKE-SCRIPTS")
