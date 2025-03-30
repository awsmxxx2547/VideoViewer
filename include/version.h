#ifndef VERSION_H
#define VERSION_H

#include <stdio.h>

extern const char* VERSION;
extern const char* BUILD_DATE;
extern const char* GIT_HASH;

void print_version_info();

#endif
