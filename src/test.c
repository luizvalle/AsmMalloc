#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

uint32_t get_seglist_index(uint32_t size);

void remove_from_list(void *payload);

struct header {
    uint32_t size: 28;
    uint32_t unused: 2;
    uint32_t allocated: 1;

    union {
        struct {
            struct header *prev, *next;
        } links;
        char payload[0];
    };
} header_t;

struct footer {
    uint32_t size: 28;
    uint32_t unused: 2;
    uint32_t allocated: 1;
} footer_t;

int main(int argc, char **argv)
{
    char *heap = malloc(16 * 3);

    char *first_head = heap, *second_head = heap + 32, *third_head = heap + 64;

    (header_t *)first_head;

    free(heap);
    return 0;
}
