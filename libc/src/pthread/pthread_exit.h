//===-- Implementation header for pthread_exit function ---------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIBC_SRC_THREADS_PTHREAD_EXIT_H
#define LLVM_LIBC_SRC_THREADS_PTHREAD_EXIT_H

#include <pthread.h>

namespace __llvm_libc {

[[noreturn]] void pthread_exit(void *retval);

} // namespace __llvm_libc

#endif // LLVM_LIBC_SRC_THREADS_PTHREAD_EXIT_H
