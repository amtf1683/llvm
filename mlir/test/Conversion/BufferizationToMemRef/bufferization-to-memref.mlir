// RUN: mlir-opt -verify-diagnostics -convert-bufferization-to-memref -split-input-file %s | FileCheck %s

// CHECK-LABEL: @conversion_static
func.func @conversion_static(%arg0 : memref<2xf32>) -> memref<2xf32> {
  %0 = bufferization.clone %arg0 : memref<2xf32> to memref<2xf32>
  memref.dealloc %arg0 : memref<2xf32>
  return %0 : memref<2xf32>
}

// CHECK:      %[[ALLOC:.*]] = memref.alloc
// CHECK-NEXT: memref.copy %[[ARG:.*]], %[[ALLOC]]
// CHECK-NEXT: memref.dealloc %[[ARG]]
// CHECK-NEXT: return %[[ALLOC]]

// -----

// CHECK-LABEL: @conversion_dynamic
func.func @conversion_dynamic(%arg0 : memref<?xf32>) -> memref<?xf32> {
  %1 = bufferization.clone %arg0 : memref<?xf32> to memref<?xf32>
  memref.dealloc %arg0 : memref<?xf32>
  return %1 : memref<?xf32>
}

// CHECK:      %[[CONST:.*]] = arith.constant
// CHECK-NEXT: %[[DIM:.*]] = memref.dim %[[ARG:.*]], %[[CONST]]
// CHECK-NEXT: %[[ALLOC:.*]] = memref.alloc(%[[DIM]])
// CHECK-NEXT: memref.copy %[[ARG]], %[[ALLOC]]
// CHECK-NEXT: memref.dealloc %[[ARG]]
// CHECK-NEXT: return %[[ALLOC]]

// -----

func.func @conversion_unknown(%arg0 : memref<*xf32>) -> memref<*xf32> {
// expected-error@+1 {{failed to legalize operation 'bufferization.clone' that was explicitly marked illegal}}
  %1 = bufferization.clone %arg0 : memref<*xf32> to memref<*xf32>
  memref.dealloc %arg0 : memref<*xf32>
  return %1 : memref<*xf32>
}

// -----

// CHECK-LABEL: func @conversion_with_layout_map(
//  CHECK-SAME:     %[[ARG:.*]]: memref<?xf32, strided<[?], offset: ?>>
//       CHECK:   %[[C0:.*]] = arith.constant 0 : index
//       CHECK:   %[[DIM:.*]] = memref.dim %[[ARG]], %[[C0]]
//       CHECK:   %[[ALLOC:.*]] = memref.alloc(%[[DIM]]) : memref<?xf32>
//       CHECK:   %[[CASTED:.*]] = memref.cast %[[ALLOC]] : memref<?xf32> to memref<?xf32, strided<[?], offset: ?>>
//       CHECK:   memref.copy
//       CHECK:   memref.dealloc
//       CHECK:   return %[[CASTED]]
func.func @conversion_with_layout_map(%arg0 : memref<?xf32, strided<[?], offset: ?>>) -> memref<?xf32, strided<[?], offset: ?>> {
  %1 = bufferization.clone %arg0 : memref<?xf32, strided<[?], offset: ?>> to memref<?xf32, strided<[?], offset: ?>>
  memref.dealloc %arg0 : memref<?xf32, strided<[?], offset: ?>>
  return %1 : memref<?xf32, strided<[?], offset: ?>>
}

// -----

// This bufferization.clone cannot be lowered because a buffer with this layout
// map cannot be allocated (or casted to).

func.func @conversion_with_invalid_layout_map(%arg0 : memref<?xf32, strided<[10], offset: ?>>)
    -> memref<?xf32, strided<[10], offset: ?>> {
// expected-error@+1 {{failed to legalize operation 'bufferization.clone' that was explicitly marked illegal}}
  %1 = bufferization.clone %arg0 : memref<?xf32, strided<[10], offset: ?>> to memref<?xf32, strided<[10], offset: ?>>
  memref.dealloc %arg0 : memref<?xf32, strided<[10], offset: ?>>
  return %1 : memref<?xf32, strided<[10], offset: ?>>
}
// -----

// CHECK-LABEL: func @conversion_dealloc_empty
func.func @conversion_dealloc_empty() {
  // CHECK-NEXT: return
  bufferization.dealloc
  return
}

// -----

// CHECK-NOT: func @deallocHelper
// CHECK-LABEL: func @conversion_dealloc_simple
// CHECK-SAME: [[ARG0:%.+]]: memref<2xf32>
// CHECK-SAME: [[ARG1:%.+]]: i1
func.func @conversion_dealloc_simple(%arg0: memref<2xf32>, %arg1: i1) {
  bufferization.dealloc (%arg0 : memref<2xf32>) if (%arg1)
  return
}

//      CHECk: scf.if [[ARG1]] {
// CHECk-NEXT:   memref.dealloc [[ARG0]] : memref<2xf32>
// CHECk-NEXT: }
// CHECk-NEXT: return

// -----

func.func @conversion_dealloc_multiple_memrefs_and_retained(%arg0: memref<2xf32>, %arg1: memref<5xf32>, %arg2: memref<1xf32>, %arg3: i1, %arg4: i1, %arg5: memref<2xf32>) -> (i1, i1) {
  %0:2 = bufferization.dealloc (%arg0, %arg1 : memref<2xf32>, memref<5xf32>) if (%arg3, %arg4) retain (%arg2, %arg5 : memref<1xf32>, memref<2xf32>)
  return %0#0, %0#1 : i1, i1
}

// CHECK-LABEL: func @conversion_dealloc_multiple_memrefs_and_retained
// CHECK-SAME: ([[ARG0:%.+]]: memref<2xf32>, [[ARG1:%.+]]: memref<5xf32>,
// CHECK-SAME: [[ARG2:%.+]]: memref<1xf32>, [[ARG3:%.+]]: i1, [[ARG4:%.+]]: i1,
// CHECK-SAME: [[ARG5:%.+]]: memref<2xf32>)
//      CHECK: [[TO_DEALLOC_MR:%.+]] = memref.alloc() : memref<2xindex>
//      CHECK: [[CONDS:%.+]] = memref.alloc() : memref<2xi1>
//      CHECK: [[TO_RETAIN_MR:%.+]] = memref.alloc() : memref<2xindex>
//  CHECK-DAG: [[V0:%.+]] = memref.extract_aligned_pointer_as_index [[ARG0]]
//  CHECK-DAG: [[C0:%.+]] = arith.constant 0 : index
//  CHECK-DAG: memref.store [[V0]], [[TO_DEALLOC_MR]][[[C0]]]
//  CHECK-DAG: [[V1:%.+]] = memref.extract_aligned_pointer_as_index [[ARG1]]
//  CHECK-DAG: [[C1:%.+]] = arith.constant 1 : index
//  CHECK-DAG: memref.store [[V1]], [[TO_DEALLOC_MR]][[[C1]]]
//  CHECK-DAG: [[C0:%.+]] = arith.constant 0 : index
//  CHECK-DAG: memref.store [[ARG3]], [[CONDS]][[[C0]]]
//  CHECK-DAG: [[C1:%.+]] = arith.constant 1 : index
//  CHECK-DAG: memref.store [[ARG4]], [[CONDS]][[[C1]]]
//  CHECK-DAG: [[V2:%.+]] = memref.extract_aligned_pointer_as_index [[ARG2]]
//  CHECK-DAG: [[C0:%.+]] = arith.constant 0 : index
//  CHECK-DAG: memref.store [[V2]], [[TO_RETAIN_MR]][[[C0]]]
//  CHECK-DAG: [[V3:%.+]] = memref.extract_aligned_pointer_as_index [[ARG5]]
//  CHECK-DAG: [[C1:%.+]] = arith.constant 1 : index
//  CHECK-DAG: memref.store [[V3]], [[TO_RETAIN_MR]][[[C1]]]
//  CHECK-DAG: [[CAST_DEALLOC:%.+]] = memref.cast [[TO_DEALLOC_MR]] : memref<2xindex> to memref<?xindex>
//  CHECK-DAG: [[CAST_CONDS:%.+]] = memref.cast [[CONDS]] : memref<2xi1> to memref<?xi1>
//  CHECK-DAG: [[CAST_RETAIN:%.+]] = memref.cast [[TO_RETAIN_MR]] : memref<2xindex> to memref<?xindex>
//      CHECK: [[DEALLOC_CONDS:%.+]] = memref.alloc() : memref<2xi1>
//      CHECK: [[RETAIN_CONDS:%.+]] = memref.alloc() : memref<2xi1>
//      CHECK: [[CAST_DEALLOC_CONDS:%.+]] = memref.cast [[DEALLOC_CONDS]] : memref<2xi1> to memref<?xi1>
//      CHECK: [[CAST_RETAIN_CONDS:%.+]] = memref.cast [[RETAIN_CONDS]] : memref<2xi1> to memref<?xi1>
//      CHECK: call @dealloc_helper([[CAST_DEALLOC]], [[CAST_RETAIN]], [[CAST_CONDS]], [[CAST_DEALLOC_CONDS]], [[CAST_RETAIN_CONDS]])
//      CHECK: [[C0:%.+]] = arith.constant 0 : index
//      CHECK: [[SHOULD_DEALLOC_0:%.+]] = memref.load [[DEALLOC_CONDS]][[[C0]]]
//      CHECK: scf.if [[SHOULD_DEALLOC_0]] {
//      CHECK:   memref.dealloc %arg0
//      CHECK: }
//      CHECK: [[C1:%.+]] = arith.constant 1 : index
//      CHECK: [[SHOULD_DEALLOC_1:%.+]] = memref.load [[DEALLOC_CONDS]][[[C1]]]
//      CHECK: scf.if [[SHOULD_DEALLOC_1]]
//      CHECK:   memref.dealloc [[ARG1]]
//      CHECK: }
//      CHECK: [[C0:%.+]] = arith.constant 0 : index
//      CHECK: [[OWNERSHIP0:%.+]] = memref.load [[RETAIN_CONDS]][[[C0]]]
//      CHECK: [[C1:%.+]] = arith.constant 1 : index
//      CHECK: [[OWNERSHIP1:%.+]] = memref.load [[RETAIN_CONDS]][[[C1]]]
//      CHECK: memref.dealloc [[TO_DEALLOC_MR]]
//      CHECK: memref.dealloc [[TO_RETAIN_MR]]
//      CHECK: memref.dealloc [[CONDS]]
//      CHECK: memref.dealloc [[DEALLOC_CONDS]]
//      CHECK: memref.dealloc [[RETAIN_CONDS]]
//      CHECK: return [[OWNERSHIP0]], [[OWNERSHIP1]]

//      CHECK: func @dealloc_helper
// CHECK-SAME: ([[TO_DEALLOC_MR:%.+]]: memref<?xindex>, [[TO_RETAIN_MR:%.+]]: memref<?xindex>,
// CHECK-SAME: [[CONDS:%.+]]: memref<?xi1>, [[DEALLOC_CONDS_OUT:%.+]]: memref<?xi1>,
// CHECK-SAME: [[RETAIN_CONDS_OUT:%.+]]: memref<?xi1>)
//      CHECK:   [[TO_DEALLOC_SIZE:%.+]] = memref.dim [[TO_DEALLOC_MR]], %c0
//      CHECK:   [[TO_RETAIN_SIZE:%.+]] = memref.dim [[TO_RETAIN_MR]], %c0
//      CHECK:   scf.for [[ITER:%.+]] = %c0 to [[TO_RETAIN_SIZE]] step %c1 {
// CHECK-NEXT:     memref.store %false, [[RETAIN_CONDS_OUT]][[[ITER]]]
// CHECK-NEXT:   }
//      CHECK:   scf.for [[OUTER_ITER:%.+]] = %c0 to [[TO_DEALLOC_SIZE]] step %c1 {
//      CHECK:     [[TO_DEALLOC:%.+]] = memref.load [[TO_DEALLOC_MR]][[[OUTER_ITER]]]
// CHECK-NEXT:     [[COND:%.+]] = memref.load [[CONDS]][[[OUTER_ITER]]]
// CHECK-NEXT:     [[NO_RETAIN_ALIAS:%.+]] = scf.for [[ITER:%.+]] = %c0 to [[TO_RETAIN_SIZE]] step %c1 iter_args([[ITER_ARG:%.+]] = %true) -> (i1) {
// CHECK-NEXT:       [[RETAIN_VAL:%.+]] = memref.load [[TO_RETAIN_MR]][[[ITER]]] : memref<?xindex>
// CHECK-NEXT:       [[DOES_ALIAS:%.+]] = arith.cmpi eq, [[RETAIN_VAL]], [[TO_DEALLOC]] : index
// CHECK-NEXT:       scf.if [[DOES_ALIAS]]
// CHECK-NEXT:         [[RETAIN_COND:%.+]] = memref.load [[RETAIN_CONDS_OUT]][[[ITER]]]
// CHECK-NEXT:         [[AGG_RETAIN_COND:%.+]] = arith.ori [[RETAIN_COND]], [[COND]] : i1
// CHECK-NEXT:         memref.store [[AGG_RETAIN_COND]], [[RETAIN_CONDS_OUT]][[[ITER]]]
// CHECK-NEXT:       }
// CHECK-NEXT:       [[DOES_NOT_ALIAS:%.+]] = arith.cmpi ne, [[RETAIN_VAL]], [[TO_DEALLOC]] : index
// CHECK-NEXT:       [[AGG_DOES_NOT_ALIAS:%.+]] = arith.andi [[ITER_ARG]], [[DOES_NOT_ALIAS]] : i1
// CHECK-NEXT:       scf.yield [[AGG_DOES_NOT_ALIAS]] : i1
// CHECK-NEXT:     }
// CHECK-NEXT:     [[SHOULD_DEALLOC:%.+]] = scf.for [[ITER:%.+]] = %c0 to [[OUTER_ITER]] step %c1 iter_args([[ITER_ARG:%.+]] = [[NO_RETAIN_ALIAS]]) -> (i1) {
// CHECK-NEXT:       [[OTHER_DEALLOC_VAL:%.+]] = memref.load [[ARG0]][[[ITER]]] : memref<?xindex>
// CHECK-NEXT:       [[DOES_ALIAS:%.+]] = arith.cmpi ne, [[OTHER_DEALLOC_VAL]], [[TO_DEALLOC]] : index
// CHECK-NEXT:       [[AGG_DOES_ALIAS:%.+]] = arith.andi [[ITER_ARG]], [[DOES_ALIAS]] : i1
// CHECK-NEXT:       scf.yield [[AGG_DOES_ALIAS]] : i1
// CHECK-NEXT:     }
// CHECK-NEXT:     [[DEALLOC_COND:%.+]] = arith.andi [[SHOULD_DEALLOC]], [[COND]] : i1
// CHECK-NEXT:     memref.store [[DEALLOC_COND]], [[DEALLOC_CONDS_OUT]][[[OUTER_ITER]]]
// CHECK-NEXT:   }
// CHECK-NEXT:   return
