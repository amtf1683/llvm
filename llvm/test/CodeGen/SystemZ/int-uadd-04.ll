; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py UTC_ARGS: --version 3
; Test 32-bit addition in which the second operand is constant.
;
; RUN: llc < %s -mtriple=s390x-linux-gnu | FileCheck %s

declare i32 @foo()

; Check addition of 1.
define zeroext i1 @f1(i32 %dummy, i32 %a, ptr %res) {
; CHECK-LABEL: f1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    alfi %r3, 1
; CHECK-NEXT:    ipm %r0
; CHECK-NEXT:    risbg %r2, %r0, 63, 191, 35
; CHECK-NEXT:    st %r3, 0(%r4)
; CHECK-NEXT:    br %r14
  %t = call {i32, i1} @llvm.uadd.with.overflow.i32(i32 %a, i32 1)
  %val = extractvalue {i32, i1} %t, 0
  %obit = extractvalue {i32, i1} %t, 1
  store i32 %val, ptr %res
  ret i1 %obit
}

; Check the high end of the ALFI range.
define zeroext i1 @f2(i32 %dummy, i32 %a, ptr %res) {
; CHECK-LABEL: f2:
; CHECK:       # %bb.0:
; CHECK-NEXT:    alfi %r3, 4294967295
; CHECK-NEXT:    ipm %r0
; CHECK-NEXT:    risbg %r2, %r0, 63, 191, 35
; CHECK-NEXT:    st %r3, 0(%r4)
; CHECK-NEXT:    br %r14
  %t = call {i32, i1} @llvm.uadd.with.overflow.i32(i32 %a, i32 4294967295)
  %val = extractvalue {i32, i1} %t, 0
  %obit = extractvalue {i32, i1} %t, 1
  store i32 %val, ptr %res
  ret i1 %obit
}

; Check that negative values are treated as unsigned
define zeroext i1 @f3(i32 %dummy, i32 %a, ptr %res) {
; CHECK-LABEL: f3:
; CHECK:       # %bb.0:
; CHECK-NEXT:    alfi %r3, 4294967295
; CHECK-NEXT:    ipm %r0
; CHECK-NEXT:    risbg %r2, %r0, 63, 191, 35
; CHECK-NEXT:    st %r3, 0(%r4)
; CHECK-NEXT:    br %r14
  %t = call {i32, i1} @llvm.uadd.with.overflow.i32(i32 %a, i32 -1)
  %val = extractvalue {i32, i1} %t, 0
  %obit = extractvalue {i32, i1} %t, 1
  store i32 %val, ptr %res
  ret i1 %obit
}

; Check using the overflow result for a branch.
define void @f4(i32 %dummy, i32 %a, ptr %res) {
; CHECK-LABEL: f4:
; CHECK:       # %bb.0:
; CHECK-NEXT:    alfi %r3, 1
; CHECK-NEXT:    st %r3, 0(%r4)
; CHECK-NEXT:    jgnle foo@PLT
; CHECK-NEXT:  .LBB3_1: # %exit
; CHECK-NEXT:    br %r14
  %t = call {i32, i1} @llvm.uadd.with.overflow.i32(i32 %a, i32 1)
  %val = extractvalue {i32, i1} %t, 0
  %obit = extractvalue {i32, i1} %t, 1
  store i32 %val, ptr %res
  br i1 %obit, label %call, label %exit

call:
  tail call i32 @foo()
  br label %exit

exit:
  ret void
}

; ... and the same with the inverted direction.
define void @f5(i32 %dummy, i32 %a, ptr %res) {
; CHECK-LABEL: f5:
; CHECK:       # %bb.0:
; CHECK-NEXT:    alfi %r3, 1
; CHECK-NEXT:    st %r3, 0(%r4)
; CHECK-NEXT:    jgle foo@PLT
; CHECK-NEXT:  .LBB4_1: # %exit
; CHECK-NEXT:    br %r14
  %t = call {i32, i1} @llvm.uadd.with.overflow.i32(i32 %a, i32 1)
  %val = extractvalue {i32, i1} %t, 0
  %obit = extractvalue {i32, i1} %t, 1
  store i32 %val, ptr %res
  br i1 %obit, label %exit, label %call

call:
  tail call i32 @foo()
  br label %exit

exit:
  ret void
}

declare {i32, i1} @llvm.uadd.with.overflow.i32(i32, i32) nounwind readnone

