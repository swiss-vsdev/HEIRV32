.text
.globl _start

_start:
    li   t0, 1           # "dark" LED bitmask
    li   t1, 0xFF        # all LEDs ON
    li   t2, 0x100       # overflow sentinel

blink_loop:
    xor  x30, t1, t0     # all LEDs on except dark bit

    # Delay ON  (500000 = 0x7A120 = 122<<12 + 288)
    lui  t3, 122
    addi t3, t3, 288
delay_on:
    addi t3, t3, -1
    bnez t3, delay_on

    li   x30, 0          # all LEDs off

    # Delay OFF
    lui  t3, 122
    addi t3, t3, 288
delay_off:
    addi t3, t3, -1
    bnez t3, delay_off

    slli t0, t0, 1       # shift dark LED left

    blt  t0, t2, blink_loop
    li   t0, 1           # wrap back to bit 0
    j    blink_loop