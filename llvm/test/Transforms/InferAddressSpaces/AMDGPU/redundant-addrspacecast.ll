; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -mtriple=amdgcn-amd-amdhsa -passes=infer-address-spaces %s | FileCheck %s

%0 = type { i8, i8, i8 }

; Make sure there is only one addrspacecast. The original cast should
; not be cloned to satisfy the second user.
define void @bar(ptr addrspace(1) %orig.ptr) {
; CHECK-LABEL: @bar(
; CHECK-NEXT:  bb:
; CHECK-NEXT:    [[ORIG_CAST:%.*]] = addrspacecast ptr addrspace(1) [[ORIG_PTR:%.*]] to ptr
; CHECK-NEXT:    [[GEP0:%.*]] = getelementptr inbounds [[TMP0:%.*]], ptr [[ORIG_CAST]], i64 0, i32 1
; CHECK-NEXT:    call void @foo(ptr [[GEP0]])
; CHECK-NEXT:    [[GEP1:%.*]] = getelementptr inbounds [[TMP0]], ptr [[ORIG_CAST]], i64 0, i32 2
; CHECK-NEXT:    call void @foo(ptr [[GEP1]])
; CHECK-NEXT:    ret void
;
bb:
  %orig.cast = addrspacecast ptr addrspace(1) %orig.ptr to ptr
  %gep0 = getelementptr inbounds %0, ptr %orig.cast, i64 0, i32 1
  call void @foo(ptr %gep0)
  %gep1 = getelementptr inbounds %0, ptr %orig.cast, i64 0, i32 2
  call void @foo(ptr %gep1)
  ret void
}

declare void @foo(ptr)