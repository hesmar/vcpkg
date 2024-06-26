# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/parameter
    REF boost-${VERSION}
    SHA512 e3cc033ec3faeed84bc6dc287ce1f5f1eceec78d7730ee6a222a6ef097f991b0a4ad13dcd404da638ce7a9be4cc60d379a5999e2d12a75b22cd57f2d988986d5
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
