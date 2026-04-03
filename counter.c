#include <emscripten.h>

int count = 1;

EMSCRIPTEN_KEEPALIVE
int increment() {
    count++;
    return count;
}

EMSCRIPTEN_KEEPALIVE
int get_count() {
    return count;
}

