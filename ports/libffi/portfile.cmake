vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/libffi/libffi/releases/download/v${VERSION}/libffi-${VERSION}.tar.gz"
    FILENAME "libffi-${VERSION}.tar.gz"
    SHA512 76974a84e3aee6bbd646a6da2e641825ae0b791ca6efdc479b2d4cbcd3ad607df59cffcf5031ad5bd30822961a8c6de164ac8ae379d1804acd388b1975cdbf4d
)
vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        dll-bindir.diff
)

vcpkg_list(SET options)
if(VCPKG_TARGET_IS_WINDOWS)
    set(linkage_flag "-DFFI_STATIC_BUILD")
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        set(linkage_flag "-DFFI_BUILDING_DLL")
    endif()
    vcpkg_list(APPEND options "CFLAGS=\${CFLAGS} ${linkage_flag}")
endif()

vcpkg_cmake_get_vars(cmake_vars_file ADDITIONAL_LANGUAGES ASM)
include("${cmake_vars_file}")
if(VCPKG_DETECTED_CMAKE_C_COMPILER_ID STREQUAL "MSVC")
    vcpkg_add_to_path("${SOURCE_PATH}")
    vcpkg_list(APPEND options "CCAS=msvcc.sh")
    set(ccas_options "")
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        string(APPEND ccas_options " -m32")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        string(APPEND ccas_options " -m64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
        string(APPEND ccas_options " -marm")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        string(APPEND ccas_options " -marm64")
    endif()
    if(ccas_options)
        vcpkg_list(APPEND options "CCASFLAGS=\${CCASFLAGS}${ccas_options}")
    endif()
endif()

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    LANGUAGES C CXX ASM
    OPTIONS
        --enable-portable-binary
        --disable-docs
        --disable-multi-os-directory
        ${options}
)

vcpkg_make_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

# On Linux, ffi.h may be installed into an arch-specific or version-specific subdirectory
# (e.g. include/aarch64-linux-gnu/ffi.h or lib/libffi-VERSION/include/ffi.h).
# Search recursively and move headers to the top-level include dir.
if(NOT EXISTS "${CURRENT_PACKAGES_DIR}/include/ffi.h")
    file(GLOB_RECURSE FFI_H "${CURRENT_PACKAGES_DIR}/ffi.h")
    if(FFI_H)
        list(GET FFI_H 0 FFI_H_FOUND)
        get_filename_component(FFI_H_DIR "${FFI_H_FOUND}" DIRECTORY)
        file(COPY "${FFI_H_FOUND}" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
        file(REMOVE "${FFI_H_FOUND}")
        file(GLOB FFI_TARGET_H "${FFI_H_DIR}/ffitarget.h")
        if(FFI_TARGET_H)
            file(COPY "${FFI_TARGET_H}" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
            file(REMOVE "${FFI_TARGET_H}")
        endif()
    endif()
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/ffi.h" "defined(FFI_STATIC_BUILD)" "1")
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/unofficial-libffi-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-libffi")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/libffiConfig.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/man3"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
