.equ NUM_SEG_LISTS,     8
.equ WORD_SIZE,         4
.equ PAGE_SIZE,         4096

.global mm_init
.global mm_deinit
.global mm_malloc
.global mm_free

.macro HEADER payload_addr
.endm

.macro FOOTER payload_addr
.endm

.macro NEXT_PAYLOAD payload_addr
.endm

.macro PREV_PAYLOAD payload_addr
.endm

.macro NEXT_FREE_PAYLOAD payload_addr
.endm

.macro PREV_FREE_PAYLOAD payload_addr
.endm

.text

get_seglist_index:
    bx lr

remove_from_list:
    bx lr

add_to_list:
    bx lr

extend_heap:
    bx lr

place:
    bx lr

find_fit:
    bx lr

coalesce:
    bx lr

mm_init:
    bx lr

mm_deinit:
    bx lr

mm_malloc:
    bx lr

mm_free:
    bx lr
