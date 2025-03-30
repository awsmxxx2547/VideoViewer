#include "../include/version.h"

const char* VERSION = "0.0.0";
const char* BUILD_DATE = "2023-11-15T00:00:00Z";
const char* GIT_HASH = "unknown";

void print_version_info() {
    printf("Video Viewer\n");
    printf("Version: %s\n", VERSION);
    printf("Build date: %s\n", BUILD_DATE);
    printf("Git commit: %s\n", GIT_HASH);
}
