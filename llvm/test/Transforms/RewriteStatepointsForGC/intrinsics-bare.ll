; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -passes=rewrite-statepoints-for-gc -S < %s | FileCheck %s

declare ptr addrspace(1) @llvm.experimental.gc.get.pointer.base.p1.p1(ptr addrspace(1) readnone nocapture) nounwind readnone willreturn
declare void @foo()

define ptr addrspace(1) @test_duplicate_base_generation(ptr addrspace(1) %obj1, ptr addrspace(1) %obj2, i1 %c) gc "statepoint-example" {
; CHECK-LABEL: @test_duplicate_base_generation(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[OBJ1_12:%.*]] = getelementptr inbounds i8, ptr addrspace(1) [[OBJ1:%.*]], i64 12
; CHECK-NEXT:    [[OBJ2_16:%.*]] = getelementptr inbounds i8, ptr addrspace(1) [[OBJ2:%.*]], i64 16
; CHECK-NEXT:    [[SELECTED_BASE:%.*]] = select i1 [[C:%.*]], ptr addrspace(1) [[OBJ2]], ptr addrspace(1) [[OBJ1]], !is_base_value !0
; CHECK-NEXT:    [[SELECTED:%.*]] = select i1 [[C]], ptr addrspace(1) [[OBJ2_16]], ptr addrspace(1) [[OBJ1_12]]
; CHECK-NEXT:    [[STATEPOINT_TOKEN:%.*]] = call token (i64, i32, ptr, i32, i32, ...) @llvm.experimental.gc.statepoint.p0(i64 2882400000, i32 0, ptr elementtype(void ()) @foo, i32 0, i32 0, i32 0, i32 0) [ "gc-live"(ptr addrspace(1) [[SELECTED]], ptr addrspace(1) [[SELECTED_BASE]]) ]
; CHECK-NEXT:    [[SELECTED_RELOCATED:%.*]] = call coldcc ptr addrspace(1) @llvm.experimental.gc.relocate.p1(token [[STATEPOINT_TOKEN]], i32 1, i32 0)
; CHECK-NEXT:    [[SELECTED_BASE_RELOCATED:%.*]] = call coldcc ptr addrspace(1) @llvm.experimental.gc.relocate.p1(token [[STATEPOINT_TOKEN]], i32 1, i32 1)
; CHECK-NEXT:    ret ptr addrspace(1) [[SELECTED_RELOCATED]]
;
entry:
  %obj1.12 = getelementptr inbounds i8, ptr addrspace(1) %obj1, i64 12
  %obj2.16 = getelementptr inbounds i8, ptr addrspace(1) %obj2, i64 16
  %selected = select i1 %c, ptr addrspace(1) %obj2.16, ptr addrspace(1) %obj1.12
  %base = call ptr addrspace(1) @llvm.experimental.gc.get.pointer.base.p1.p1(ptr addrspace(1) %selected)
  call void @foo()
  ret ptr addrspace(1) %selected
}