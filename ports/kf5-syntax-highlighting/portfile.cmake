# kf5-syntax-highlighting 5.115.0 for ClaudeQt.
#
# Linux ClaudeQt uses the 5.115.0 KF5-qt6 backport from
# ppa:ayourk/claudeqt. We pin the same version on Windows/macOS so the
# highlighter behaves identically across platforms. BUILD_WITH_QT6=ON
# activates KSH's Qt 6 compile path (the KF5 branch retained it
# through 5.115.0 as the final KF5 release before KF6 took over).

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://invent.kde.org/frameworks/syntax-highlighting.git
    REF 3947c63636b0220bddf6cbcf008d7eb662fc9d4a
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_QCH=OFF
        -DBUILD_WITH_QT6=ON
        -DKSYNTAXHIGHLIGHTING_USE_GUI=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME KF5SyntaxHighlighting CONFIG_PATH "lib/cmake/KF5SyntaxHighlighting")

# Remove headers that ship under a KF6 namespace (KSH 5.115 installs
# both trees when BUILD_WITH_QT6=ON — ClaudeQt only consumes one).
# Leaving this commented until we confirm which one the app links.
# file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/KF6")

# Standard vcpkg layout expects no tools in /bin at static triplet.
# kate-syntax-highlighter ends up there — remove if it exists to
# pass vcpkg_fixup_pkgconfig's sanity checks.
if(EXISTS "${CURRENT_PACKAGES_DIR}/bin")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# KSH is a REUSE-compliant multi-licensed package: MIT for library
# source, plus GPL-2+, GPL-3+, LGPL-2.1+, Apache-2.0, BSD-3-Clause,
# CC0, WTFPL, and a KDEeV variant scattered across the syntax
# definition XMLs. Install the entire LICENSES/ directory rather than
# pretending a single file covers the package. vcpkg.json's
# license field is null for the same reason.
file(INSTALL "${SOURCE_PATH}/LICENSES" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSES/MIT.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
