#ifndef TEST_UTILS_H
#define TEST_UTILS_H

#include <stdio.h>
#include <stdlib.h>

typedef struct {
    const char *name;
    int (*func)(void);
    const char *type;
} TestCase;

#define TEST_START(name) printf("🔍 %s\n", name)
#define TEST_END() printf("✅ Test complete\n")
#define ASSERT(cond, msg) \
    do { \
        if (!(cond)) { \
            fprintf(stderr, "❌ %s (%s:%d)\n", msg, __FILE__, __LINE__); \
        } else { \
            printf("  ✔ %s\n", msg); \
        } \
    } while (0)

#define ASSERT_S(cond, msg, success_count, test_count) \
    do { \
        if (!(cond)) { \
            fprintf(stderr, "❌ %s (%d / %d) (%s:%d)\n", msg, success_count, test_count, __FILE__, __LINE__); \
        } else { \
            printf("  ✔ %s\n", msg); \
        } \
    } while (0)

#define ASSERT_EQ(a, b, msg) \
    do { \
        if ((a) != (b)) { \
            fprintf(stderr, "❌ %s (Expected %d, Got %d) (%s:%d)\n", \
                   msg, (int)(b), (int)(a), __FILE__, __LINE__); \
        } else { \
            printf("  ✔ %s\n", msg); \
        } \
    } while (0)

#endif
