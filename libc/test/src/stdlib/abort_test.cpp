//===-- Unittests for abort -----------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "src/stdlib/abort.h"
#include "test/UnitTest/Test.h"

#include <signal.h>
#include <stdlib.h>

TEST(LlvmLibcStdlib, abort) {
  // -1 matches against any signal, which is necessary for now until
  // __llvm_libc::abort() unblocks SIGABRT.
  EXPECT_DEATH([] { __llvm_libc::abort(); }, WITH_SIGNAL(-1));
}
