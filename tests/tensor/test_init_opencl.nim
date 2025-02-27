# Copyright 2017 the Arraymancer contributors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import ../../src/arraymancer
import unittest


testSuite "OpenCL init":

  let a =  [[1.0, 2, 3, 4],
            [5.0, 6, 7, 8]].toTensor
  let a_cl = a.opencl

  test ".opencl and .cpu conversion":
    check: a == a_cl.cpu

  test "zeros_like and ones_like":

    let z_cl = zeros_like(a_cl)
    check: z_cl.cpu == [[0.0, 0, 0, 0],
                        [0.0, 0, 0, 0]].toTensor

    let o_cl = ones_like(a_cl)
    check: o_cl.cpu == [[1.0, 1, 1, 1],
                        [1.0, 1, 1, 1]].toTensor
