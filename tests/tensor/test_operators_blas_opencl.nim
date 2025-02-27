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

# Please compile with -d:opencl switch
import ../../src/arraymancer
import unittest

testSuite "OpenCL BLAS operations (Basic Linear Algebra Subprograms)":
  test "GEMM - General Matrix to Matrix Multiplication":
    ## TODO: test with slices
    let a = [[1.0,2,3],
             [4.0,5,6]].toTensor().asType(float32).opencl()

    let b = [[7.0,  8],
             [9.0, 10],
             [11.0,12]].toTensor().asType(float32).opencl()

    let ab = [[ 58.0, 64],
              [139.0,154]].toTensor().asType(float32)

    check: (a * b).cpu == ab

    # example from http://www.intmath.com/matrices-determinants/matrix-multiplication-examples.php
    # (M x K) * (K x N) with M < N
    let u = [[-2,-3,-1],
             [ 3, 0, 4]].toTensor().asType(float32).opencl()
    let v = [[ 1, 5, 2,-1],
             [-3, 0, 3, 4],
             [ 6,-2, 7,-4]].toTensor().asType(float32).opencl()

    let uv = [[ 1,-8,-20, -6],
              [27, 7, 34,-19]].toTensor().asType(float32)

    check: (u * v).cpu == uv

    # from http://www.calcul.com/show/calculator/matrix-multiplication_;5;5;5;5?matrix1=[[%225%22,%226%22,%225%22,%228%22],[%228%22,%222%22,%228%22,%228%22],[%220%22,%225%22,%224%22,%220%22],[%224%22,%220%22,%225%22,%226%22],[%224%22,%225%22,%220%22,%223%22]]&matrix2=[[%225%22,%223%22,%226%22,%220%22],[%225%22,%222%22,%223%22,%223%22],[%228%22,%228%22,%222%22,%220%22],[%227%22,%227%22,%220%22,%220%22]]&operator=*
    # (M x K) * (K x N) with M > N and M > block-size (4x4)
    let m1 = [[5,6,5,8],
              [8,2,8,8],
              [0,5,4,0],
              [4,0,5,6],
              [4,5,0,3]].toTensor().asType(float).opencl()
    let m2 = [[5,3,6,0],
              [5,2,3,3],
              [8,8,2,0],
              [7,7,0,0]].toTensor().asType(float).opencl()

    let m1m2 = [[151,123,58,18],
                [170,148,70, 6],
                [ 57, 42,23,15],
                [102, 94,34, 0],
                [ 66, 43,39,15]].toTensor().asType(float)

    check: (m1 * m2).cpu == m1m2

    # from http://www.calcul.com/show/calculator/matrix-multiplication?matrix1=[[%222%22,%224%22,%223%22,%221%22,%223%22,%221%22,%223%22,%221%22],[%221%22,%222%22,%221%22,%221%22,%222%22,%220%22,%224%22,%223%22],[%222%22,%220%22,%220%22,%223%22,%220%22,%224%22,%224%22,%221%22],[%221%22,%221%22,%224%22,%220%22,%223%22,%221%22,%223%22,%220%22],[%223%22,%224%22,%221%22,%221%22,%224%22,%222%22,%223%22,%224%22],[%222%22,%224%22,%220%22,%222%22,%223%22,%223%22,%223%22,%224%22],[%223%22,%220%22,%220%22,%223%22,%221%22,%224%22,%223%22,%221%22],[%224%22,%223%22,%222%22,%224%22,%221%22,%220%22,%220%22,%220%22]]&matrix2=[[%222%22,%222%22,%220%22,%224%22,%220%22,%220%22,%224%22,%222%22],[%222%22,%220%22,%220%22,%221%22,%221%22,%221%22,%223%22,%221%22],[%220%22,%222%22,%222%22,%220%22,%222%22,%222%22,%223%22,%223%22],[%220%22,%220%22,%221%22,%220%22,%224%22,%222%22,%224%22,%221%22],[%220%22,%220%22,%221%22,%223%22,%224%22,%222%22,%224%22,%222%22],[%224%22,%223%22,%224%22,%221%22,%224%22,%224%22,%220%22,%223%22],[%223%22,%223%22,%220%22,%222%22,%221%22,%222%22,%223%22,%223%22],[%222%22,%221%22,%222%22,%221%22,%222%22,%224%22,%224%22,%221%22]]&operator=*
    # (N x N) * (N x N) with N multiple of block size

    let n1 = [[2, 4,  3,  1,  3,  1,  3,  1],
              [1, 2,  1,  1,  2,  0,  4,  3],
              [2, 0,  0,  3,  0,  4,  4,  1],
              [1, 1,  4,  0,  3,  1,  3,  0],
              [3, 4,  1,  1,  4,  2,  3,  4],
              [2, 4,  0,  2,  3,  3,  3,  4],
              [3, 0,  0,  3,  1,  4,  3,  1],
              [4, 3,  2,  4,  1,  0,  0,  0]].toTensor().asType(float32).opencl()


    let n2 = [[2, 2,  0,  4,  0,  0,  4,  2],
              [2, 0,  0,  1,  1,  1,  3,  1],
              [0, 2,  2,  0,  2,  2,  3,  3],
              [0, 0,  1,  0,  4,  2,  4,  1],
              [0, 0,  1,  3,  4,  2,  4,  2],
              [4, 3,  4,  1,  4,  4,  0,  3],
              [3, 3,  0,  2,  1,  2,  3,  3],
              [2, 1,  2,  1,  2,  4,  4,  1]].toTensor().asType(float32).opencl()

    let n1n2 = [[27,23,16,29,35,32,58,37],
                [24,19,11,23,26,30,49,27],
                [34,29,21,21,34,34,36,32],
                [17,22,15,21,28,25,40,33],
                [39,27,23,40,45,46,72,41],
                [41,26,25,34,47,48,65,38],
                [33,28,22,26,37,34,41,33],
                [14,12, 9,22,27,17,51,23]].toTensor().asType(float32)

    check: (n1 * n2).cpu == n1n2

  test "GEMM - Bounds checking":
    let c = @[@[1'f32,2,3],@[4'f32,5,6]].toTensor().opencl()

    expect(IndexDefect):
      discard c * c

  test "GEMV - General Matrix to Vector Multiplication - float32":
    ## TODO: test with slices
    ## TODO: support and test non-contiguous tensors

    let d = [[float32 1,-1,2], [float32 0.0,-3,1]].toTensor().opencl()
    let e = [float32 2, 1, 0].toTensor().opencl()

    check: (d * e).cpu ==  [float32 1, -3].toTensor()

  test "GEMV - General Matrix to Vector Multiplication - float64":
    ## TODO: test with slices
    ## TODO: support and test non-contiguous tensors

    let d = [[float64 1,-1,2], [float64 0.0,-3,1]].toTensor().opencl()
    let e = [float64 2, 1, 0].toTensor().opencl()

    check: (d * e).cpu ==  [float64 1, -3].toTensor()

  test "Matrix and vector addition":
    let u = @[float32 1, 3, -5].toTensor.opencl
    let v = @[float32 1, 1, 1].toTensor.opencl

    check: (u + v).cpu == @[2'f32, 4, -4].toTensor()

    let a = @[7.0, 4.0, 3.0, 1.0, 8.0, 6.0, 8.0, 1.0, 6.0, 2.0].toTensor.reshape([5,2]).opencl
    let b = @[6.0, 6.0, 2.0, 0.0, 4.0, 3.0, 2.0, 0.0, 0.0, 3.0].toTensor.reshape([5,2]).opencl

    let apb = @[13.0, 10.0, 5.0, 1.0, 12.0, 9.0, 10.0, 1.0, 6.0, 5.0].toTensor.reshape([5,2])

    check: (a + b).cpu == apb

    # Check size mismatch
    expect(ValueError):
      discard a + b.cpu[0..1, 0..1].opencl

  test "Matrix and vector substraction":
    let u = @[float32 1, 3, -5].toTensor.opencl
    let v = @[float32 1, 1, 1].toTensor.opencl

    check: (u - v).cpu == @[float32 0, 2, -6].toTensor()

    let a = @[7.0, 4.0, 3.0, 1.0, 8.0, 6.0, 8.0, 1.0, 6.0, 2.0].toTensor.reshape([5,2]).opencl
    let b = @[6.0, 6.0, 2.0, 0.0, 4.0, 3.0, 2.0, 0.0, 0.0, 3.0].toTensor.reshape([5,2]).opencl

    let amb = @[1.0, -2.0, 1.0, 1.0, 4.0, 3.0, 6.0, 1.0, 6.0, -1.0].toTensor.reshape([5,2])

    check: (a - b).cpu == amb

    # Check size mismatch
    expect(ValueError):
      discard a + b.cpu[0..1, 0..1].opencl

  test "Scalar/dot product":
    let u = @[float32 1, 3, -5].toTensor().opencl()
    let v = @[float32 4, -2, -1].toTensor().opencl()

    check: dot(u,v) == 3.0'f32


  test "Matrix and Vector in-place addition":
    var u = @[float64 1, 3, -5].toTensor().opencl()
    let v = @[float64 4, -2, -1].toTensor().opencl()

    u += v

    check: u.cpu() == @[5'f64, 1, -6].toTensor()


    # Check require var input
    let w = @[1'f64, 3, -5].toTensor().opencl()
    when compiles(w += v):
      check: false


    let vandermonde = [[1,1,1],
                       [2,4,8],
                       [3,9,27]]

    let t = vandermonde.toTensor.asType(float32)

    var z = t.transpose.opencl()
    z += z

    check: z.cpu == [[2,4,6],
                     [2,8,18],
                     [2,16,54]].toTensor.asType(float32)

    let t2 = vandermonde.toTensor.asType(float32).opencl
    z += t2

    check: z.cpu == [[3,5,7],
                     [4,12,26],
                     [5,25,81]].toTensor.asType(float32)

    # Check size mismatch
    expect(ValueError):
      z += t2.cpu[0..1,0..1].opencl

  test "Matrix and Vector in-place substraction":
    var u = @[float32 1, 3, -5].toTensor.opencl
    let v = @[float32 1, 1, 1].toTensor.opencl

    u -= v

    check: u.cpu == @[0'f32, 2, -6].toTensor()

    # Check require var input
    let w = @[1'f64, 3, -5].toTensor().opencl()
    when compiles(w -= v):
      check: false

    var a = @[7.0, 4.0, 3.0, 1.0, 8.0, 6.0, 8.0, 1.0, 6.0, 2.0].toTensor.reshape([5,2]).opencl
    let b = @[6.0, 6.0, 2.0, 0.0, 4.0, 3.0, 2.0, 0.0, 0.0, 3.0].toTensor.reshape([5,2]).opencl

    let amb = @[1.0, -2.0, 1.0, 1.0, 4.0, 3.0, 6.0, 1.0, 6.0, -1.0].toTensor.reshape([5,2])

    a -= b

    check: a.cpu == amb

    # Check size mismatch
    expect(ValueError):
      a += b.cpu[0..1,0..1].opencl

  test "Matrix and vector addition":
    let u = @[float32 1, 3, -5].toTensor.opencl
    let v = @[float32 1, 1, 1].toTensor.opencl

    check: (u + v).cpu == @[2'f32, 4, -4].toTensor()

    let a = @[7.0, 4.0, 3.0, 1.0, 8.0, 6.0, 8.0, 1.0, 6.0, 2.0].toTensor.reshape([5,2]).opencl
    let b = @[6.0, 6.0, 2.0, 0.0, 4.0, 3.0, 2.0, 0.0, 0.0, 3.0].toTensor.reshape([5,2]).opencl

    let apb = @[13.0, 10.0, 5.0, 1.0, 12.0, 9.0, 10.0, 1.0, 6.0, 5.0].toTensor.reshape([5,2])

    check: (a + b).cpu == apb

    # Check size mismatch
    expect(ValueError):
      discard a + b.cpu[0..1, 0..1].opencl

  test "Matrix and vector substraction":
    let u = @[float32 1, 3, -5].toTensor.opencl
    let v = @[float32 1, 1, 1].toTensor.opencl

    check: (u - v).cpu == @[0'f32, 2, -6].toTensor()

    let a = @[7.0, 4.0, 3.0, 1.0, 8.0, 6.0, 8.0, 1.0, 6.0, 2.0].toTensor.reshape([5,2]).opencl
    let b = @[6.0, 6.0, 2.0, 0.0, 4.0, 3.0, 2.0, 0.0, 0.0, 3.0].toTensor.reshape([5,2]).opencl

    let amb = @[1.0, -2.0, 1.0, 1.0, 4.0, 3.0, 6.0, 1.0, 6.0, -1.0].toTensor.reshape([5,2])

    check: (a - b).cpu == amb

    # Check size mismatch
    expect(ValueError):
      discard a + b.cpu[0..1, 0..1].opencl
