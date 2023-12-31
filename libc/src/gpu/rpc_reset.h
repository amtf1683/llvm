//===-- Implementation header for RPC functions -----------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIBC_SRC_GPU_RPC_H
#define LLVM_LIBC_SRC_GPU_RPC_H

namespace __llvm_libc {

void rpc_reset(unsigned int num_ports, void *buffer);

} // namespace __llvm_libc

#endif // LLVM_LIBC_SRC_GPU_RPC_H
