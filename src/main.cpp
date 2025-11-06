#include <cstdio>
#include <zlib.h>
#include <png.h>
#include <ft2build.h>
#include FT_FREETYPE_H
#include <hb.h>
#include <lcms2.h>
#include <tiffio.h>
#include <openjpeg.h>
#include <jpeglib.h>
#include <openssl/opensslv.h>
#include <curl/curl.h>

// This is a placeholder TU to force-link libraries resolved by Conan.
// Not an Android entry point.
int main() {
    printf("zlib: %s\n", ZLIB_VERSION);
#ifdef OPENSSL_VERSION_TEXT
    printf("openssl: %s\n", OPENSSL_VERSION_TEXT);
#endif
    curl_version_info_data* v = curl_version_info(CURLVERSION_NOW);
    if (v) printf("libcurl: %s\n", v->version);
    return 0;
}
