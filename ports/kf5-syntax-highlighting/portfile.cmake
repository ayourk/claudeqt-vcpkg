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

# ClaudeQt uses the C++ library and syntax-definition XMLs but not the
# KDE .po/.qm translations. ecm_install_po_files_as_qm() pulls in
# Qt6LinguistTools (from qttools) — a heavy dependency we don't need.
# Patch it out rather than adding qttools to the dep tree.
vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt"
    "ecm_install_po_files_as_qm(poqm)"
    "# ecm_install_po_files_as_qm(poqm)  # patched out by vcpkg port"
)

# KSH unconditionally requires Qt6::Test in its find_package even
# though it's only used by the test suite. With BUILD_TESTING=OFF
# the component is unused — remove it to avoid pulling in testlib.
vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt"
    "REQUIRED COMPONENTS Core Network Test"
    "REQUIRED COMPONENTS Core Network"
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    "gui" KSYNTAXHIGHLIGHTING_USE_GUI
    "qrc" QRC_SYNTAX
    INVERTED_FEATURES
    "gui" _KSH_NO_GUI
    "qrc" _KSH_NO_QRC
)

if(_KSH_NO_GUI)
    set(KSH_GUI_OPT -DKSYNTAXHIGHLIGHTING_USE_GUI=OFF)
else()
    set(KSH_GUI_OPT -DKSYNTAXHIGHLIGHTING_USE_GUI=ON)
endif()

if(_KSH_NO_QRC)
    set(KSH_QRC_OPT -DQRC_SYNTAX=OFF)
else()
    set(KSH_QRC_OPT -DQRC_SYNTAX=ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_QCH=OFF
        -DBUILD_WITH_QT6=ON
        ${KSH_GUI_OPT}
        ${KSH_QRC_OPT}
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
