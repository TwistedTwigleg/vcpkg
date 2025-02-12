vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO strukturag/libde265
    REF "v${VERSION}"
    SHA512 aa744c521fb15e68940956f70997ab969094aee1c129d404ee9a52f318248353bb8d53250b575b4040402645e44701086b78143f1e1122b61a925e9b6cd07566
    HEAD_REF master
    PATCHES
        fix-interface-include.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        sse DISABLE_SSE
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_SDL=ON
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libde265)
vcpkg_copy_tools(TOOL_NAMES dec265 AUTO_CLEAN)

set(prefix "")
set(exec_prefix [[${prefix}]])
set(libdir [[${prefix}/lib]])
set(includedir [[${prefix}/include]])
set(LIBS "")
configure_file("${SOURCE_PATH}/libde265.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libde265.pc" @ONLY)
# The produced library name is `liblibde265.a` or `libde265.lib`
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libde265.pc" "-lde265" "-llibde265")
# libde265's pc file assumes libstdc++, which isn't always true.
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libde265.pc" " -lstdc++" "")
if(NOT VCPKG_BUILD_TYPE)
    configure_file("${SOURCE_PATH}/libde265.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libde265.pc" @ONLY)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libde265.pc" "-lde265" "-llibde265")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libde265.pc" " -lstdc++" "")
endif()
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libde265/de265.h" "!defined(LIBDE265_STATIC_BUILD)" "0")
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libde265/de265.h" "!defined(LIBDE265_STATIC_BUILD)" "1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
