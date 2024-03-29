.equ NUM_SEG_LISTS,     8
.equ WORD_SIZE,         4
.equ PAGE_SIZE,         4096

.global mm_init
.global mm_deinit
.global mm_malloc
.global mm_free

/*
 *       Free block               Allocated block
 * +----------------+----+    +----------------+----+
 * |  Size (28 bits)| 000|    | Size (28 bits) | 001|
 * |                |    |    |                |    |
 * +----------------+----+    +----------------+----+
 * |        prev_p       |    |                     |
 * |                     |    |                     |
 * +---------------------+    |                     |
 * |        next_p       |    |                     |
 * |                     |    |                     |
 * +---------------------+    |                     |
 * |                     |    |       Payload       |
 * |                     |    |                     |
 * |                     |    |                     |
 * |        Padding      |    |                     |
 * |                     |    |                     |
 * |                     |    |                     |
 * |                     |    |                     |
 * +----------------+----+    +----------------+----+
 * |  Size (28 bits)| 000|    | Size (28 bits) | 001|
 * |                |    |    |                |    |
 * +----------------+----+    +----------------+----+
 */

.text

// Retrieves the block size
//
// Parameter:
//      addr - Address of the header or footer
// Return:
//      Places the result in r0
.macro SIZE addr
    push {r1}
    ldr r0, [\addr]  // Load the contents of the header
    mvn r1, #0x3  // Size mask: ~0x3
    and r0, r0, r1  // Size of the block
    pop {r1}
.endm

// Retrieves the bit representing whether the block is allocated
//
// Parameter:
//      addr - Address of the header or footer
// Return:
//      Places the result in r0
.macro ALLOCATED addr
    push {r1}
    ldr r0, [\addr]  // Load the contents of the header
    mov r1, #0x1  // Allocated mask: 0x1
    and r0, r0, r1  // Size of the block
    pop {r1}
.endm

// Calculates the address of the block's header
//
// Parameter:
//      payload_addr - Register containng the payload address
// Return:
//      Places the result in r0
.macro HEADER payload_addr
    sub r0, \payload_addr, #WORD_SIZE
.endm

// Calculates the address of the block's footer
//
// Parameter:
//      payload_addr - Register containng the payload address
// Return:
//      Places the result in r0
.macro FOOTER payload_addr
    push {r1}
    mov r1, \payload_addr  // Save a copy
    HEADER \payload_addr
    SIZE r0
    sub r0, r0, # 2 * WORD_SIZE  // r0 = size - 2 * WORD_SIZE
    add r0, r1, r0  // payload + size - 2 * WORD_SIZE
    pop {r1}
.endm

// Calculates the address of the next block's payload
//
// Parameter:
//      payload_addr - Register containng the payload address
// Return:
//      Places the result in r0
.macro NEXT_PAYLOAD payload_addr
    push {r1}
    mov r1, \payload_addr
    HEADER \payload_addr
    SIZE r0
    add r0, r0, r1
    pop {r1}
.endm

// Calculates the address of the previous block's payload
//
// Parameter:
//      payload_addr - Register containng the payload address
// Return:
//      Places the result in r0
.macro PREV_PAYLOAD payload_addr
    push {r1}
    mov r1, \payload_addr
    sub r0, r1, # 2 * WORD_SIZE  // r0 = previous block's footer
    SIZE r0  // Size of previous block
    sub r0, r1, r0  // payload - prev_size
    pop {r1}
.endm

// Calculates the address of the next free block's payload
//
// Parameter:
//      payload_addr - Register containng the payload address
// Return:
//      Places the result in r0
.macro NEXT_FREE_PAYLOAD payload_addr
    HEADER \payload_addr
    add r0, r0, # 2 * WORD_SIZE  // r0 = header + 2 * WORD_SIZE
    ldr r0, [r0]
.endm

// Calculates the address of the previous free block's payload
//
// Parameter:
//      payload_addr - Register containng the payload address
// Return:
//      Places the result in r0
.macro PREV_FREE_PAYLOAD payload_addr
    HEADER \payload_addr
    add r0, r0, #WORD_SIZE  // r0 = header + WORD_SIZE
    ldr r0, [r0]
.endm

// Calculates the index of the free list for blocks of the given size
//
// Parameter:
//      r0 - The size of the block
// Returns:
//      r0 - The index of the segregated free list
get_seglist_index:
    push {r4-r12, lr}
    mov r4, r0, LSR #5  // Divide by 32
    mov r0, #0
loop:
    cmp r0, #NUM_SEG_LISTS - 1
    beq return_index
    cmp r4, #0
    beq return_index
    mov r4, r4, LSR #1  // Divide by 2
    add r0, r0, #1
    b loop
return_index:
    pop {r4-r12, lr}
    bx lr

// Removes a free block from its list
//
// Parameter:
//      r0 - The address of the block's payload
// Returns:
//      Nothing
remove_from_list:
    push {r4-r12, lr}
    mov r4, r0  // Copy the payload's address
    PREV_FREE_PAYLOAD r0
    HEADER r0
    mov r5, r0  // r5 = header of previous free block
    mov r0, r4
    NEXT_FREE_PAYLOAD r0
    HEADER r0
    mov r6, r0  // r6 = header of the next free block
    // prev_free_block.next = next_free_block
    str r6, [r5, #2 * WORD_SIZE]
    // next_free_block.prev = prev_free_block
    str r5, [r6, #WORD_SIZE]
    pop {r4-r12, lr}
    bx lr

// Adds a free block to the appropriate list
//
// Parameter:
//      r0 - The address of the block's payload
// Returns:
//      Nothing
add_to_list:
    push {r4-r12, lr}
    mov r4, r0  // Store the payload pointer
    HEADER r4
    SIZE r0
    bl get_seglist_index
    ldr r5, =seg_listp
    ldr r5, [r5]  // The head of the segmented free list
    HEADER r4
    // TODO
    pop {r4-r12, lr}
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

.bss

.align 2
seg_listp: .space NUM_SEG_LISTS
