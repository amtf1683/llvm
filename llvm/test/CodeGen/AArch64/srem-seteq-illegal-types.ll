; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=aarch64-unknown-linux-gnu < %s | FileCheck %s

define i1 @test_srem_odd(i29 %X) nounwind {
; CHECK-LABEL: test_srem_odd:
; CHECK:       // %bb.0:
; CHECK-NEXT:    mov w8, #33099 // =0x814b
; CHECK-NEXT:    mov w9, #24493 // =0x5fad
; CHECK-NEXT:    movk w8, #8026, lsl #16
; CHECK-NEXT:    movk w9, #41, lsl #16
; CHECK-NEXT:    madd w8, w0, w8, w9
; CHECK-NEXT:    mov w9, #48987 // =0xbf5b
; CHECK-NEXT:    movk w9, #82, lsl #16
; CHECK-NEXT:    and w8, w8, #0x1fffffff
; CHECK-NEXT:    cmp w8, w9
; CHECK-NEXT:    cset w0, lo
; CHECK-NEXT:    ret
  %srem = srem i29 %X, 99
  %cmp = icmp eq i29 %srem, 0
  ret i1 %cmp
}

define i1 @test_srem_even(i4 %X) nounwind {
; CHECK-LABEL: test_srem_even:
; CHECK:       // %bb.0:
; CHECK-NEXT:    sbfx w9, w0, #0, #4
; CHECK-NEXT:    mov w8, #6 // =0x6
; CHECK-NEXT:    add w9, w9, w9, lsl #1
; CHECK-NEXT:    ubfx w10, w9, #7, #1
; CHECK-NEXT:    add w9, w10, w9, lsr #4
; CHECK-NEXT:    msub w8, w9, w8, w0
; CHECK-NEXT:    and w8, w8, #0xf
; CHECK-NEXT:    cmp w8, #1
; CHECK-NEXT:    cset w0, eq
; CHECK-NEXT:    ret
  %srem = srem i4 %X, 6
  %cmp = icmp eq i4 %srem, 1
  ret i1 %cmp
}

define i1 @test_srem_pow2_setne(i6 %X) nounwind {
; CHECK-LABEL: test_srem_pow2_setne:
; CHECK:       // %bb.0:
; CHECK-NEXT:    sbfx w8, w0, #0, #6
; CHECK-NEXT:    ubfx w8, w8, #9, #2
; CHECK-NEXT:    add w8, w0, w8
; CHECK-NEXT:    and w8, w8, #0x3c
; CHECK-NEXT:    sub w8, w0, w8
; CHECK-NEXT:    tst w8, #0x3f
; CHECK-NEXT:    cset w0, ne
; CHECK-NEXT:    ret
  %srem = srem i6 %X, 4
  %cmp = icmp ne i6 %srem, 0
  ret i1 %cmp
}

define <3 x i1> @test_srem_vec(<3 x i33> %X) nounwind {
; CHECK-LABEL: test_srem_vec:
; CHECK:       // %bb.0:
; CHECK-NEXT:    mov x8, #7282 // =0x1c72
; CHECK-NEXT:    sbfx x9, x0, #0, #33
; CHECK-NEXT:    movk x8, #29127, lsl #16
; CHECK-NEXT:    mov x11, #7281 // =0x1c71
; CHECK-NEXT:    movk x8, #50972, lsl #32
; CHECK-NEXT:    movk x11, #29127, lsl #16
; CHECK-NEXT:    movk x8, #7281, lsl #48
; CHECK-NEXT:    movk x11, #50972, lsl #32
; CHECK-NEXT:    sbfx x12, x1, #0, #33
; CHECK-NEXT:    sbfx x10, x2, #0, #33
; CHECK-NEXT:    smulh x13, x9, x8
; CHECK-NEXT:    movk x11, #7281, lsl #48
; CHECK-NEXT:    smulh x8, x12, x8
; CHECK-NEXT:    smulh x11, x10, x11
; CHECK-NEXT:    add x13, x13, x13, lsr #63
; CHECK-NEXT:    sub x11, x11, x10
; CHECK-NEXT:    add x8, x8, x8, lsr #63
; CHECK-NEXT:    add x13, x13, x13, lsl #3
; CHECK-NEXT:    asr x14, x11, #3
; CHECK-NEXT:    sub x9, x9, x13
; CHECK-NEXT:    add x11, x14, x11, lsr #63
; CHECK-NEXT:    add x8, x8, x8, lsl #3
; CHECK-NEXT:    sub x8, x12, x8
; CHECK-NEXT:    add x11, x11, x11, lsl #3
; CHECK-NEXT:    fmov d0, x9
; CHECK-NEXT:    add x10, x10, x11
; CHECK-NEXT:    mov x9, #8589934591 // =0x1ffffffff
; CHECK-NEXT:    adrp x11, .LCPI3_0
; CHECK-NEXT:    adrp x12, .LCPI3_1
; CHECK-NEXT:    mov v0.d[1], x8
; CHECK-NEXT:    fmov d1, x10
; CHECK-NEXT:    dup v2.2d, x9
; CHECK-NEXT:    ldr q3, [x11, :lo12:.LCPI3_0]
; CHECK-NEXT:    ldr q4, [x12, :lo12:.LCPI3_1]
; CHECK-NEXT:    and v1.16b, v1.16b, v2.16b
; CHECK-NEXT:    and v0.16b, v0.16b, v2.16b
; CHECK-NEXT:    cmeq v0.2d, v0.2d, v3.2d
; CHECK-NEXT:    cmeq v1.2d, v1.2d, v4.2d
; CHECK-NEXT:    mvn v0.16b, v0.16b
; CHECK-NEXT:    xtn v0.2s, v0.2d
; CHECK-NEXT:    mvn v1.16b, v1.16b
; CHECK-NEXT:    xtn v1.2s, v1.2d
; CHECK-NEXT:    mov w1, v0.s[1]
; CHECK-NEXT:    fmov w0, s0
; CHECK-NEXT:    fmov w2, s1
; CHECK-NEXT:    ret
  %srem = srem <3 x i33> %X, <i33 9, i33 9, i33 -9>
  %cmp = icmp ne <3 x i33> %srem, <i33 3, i33 -3, i33 3>
  ret <3 x i1> %cmp
}
