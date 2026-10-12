#!/usr/bin/env python3
"""
Generates I/O test values for the convolution tests.

Matrix values are stored in './input/test[X].in' where X is the test number.
Kernel values are stored in './input/test[X].kernel' where X is the test number.
Expected convolution output is stored in './output/test[X].out' where X is the test number.

The convolution is between a 13x13 matrix and a 2x2 kernel.

Arguments:
    nr_tests (integer): The number of test cases to generate.
"""

import argparse
import os
import random

# Convolution dimensions
M = 13
K = 2
OUT = M - K   # Output size of convolution (11x11)


def ensure_dirs() -> None:
    """
    Ensure the ./input and ./output directories exist.

    Creates directories if they do not already exist.
    """
    os.makedirs("./input", exist_ok=True)
    os.makedirs("./output", exist_ok=True)


def clamp_int32(x: int) -> int:
    """
    Clamp an integer to signed 32-bit range.

    Arguments:
        x (int): Integer value to clamp.

    Returns:
        The value clamped to signed 32-bit (two's complement) range.
    """
    x &= 0xFFFFFFFF
    if x & 0x80000000:
        x -= 0x100000000
    return x


def write_matrix(path: str, mat: list[list[int]]) -> None:
    """
    Write a 2D integer matrix to a text file.

    Each row is written as space-separated integers.
    Each row ends with a newline.

    Arguments:
        path (str): Output file path.
        mat (list[list[int]]): 2D list of integers (rows x cols).
    """
    with open(path, "w", encoding="utf-8") as f:
        for row in mat:
            f.write("\n".join(str(x) for x in row) + "\n")


def compute_convolution(mat: list[list[int]], kernel: list[list[int]]) -> list[list[int]]:
    """
    Compute the 2D convolution output for a 13x13 matrix and 2x2 kernel.

    The output size is (13-2) x (13-2) = 11 x 11.
    Each output element accumulates:
        sum_{ki=0..1, kj=0..1} mat[i+ki][j+kj] * kernel[ki][kj]

    Results are clamped to signed 32-bit after each output element is computed.

    Arguments:
        mat (list[list[int]]): 13x13 input matrix.
        kernel (list[list[int]]): 2x2 kernel.

    Returns:
        12x12 convolution result matrix with signed 32-bit clamping.
    """
    out = [[0 for _ in range(OUT)] for _ in range(OUT)]
    for i in range(OUT):
        for j in range(OUT):
            acc = 0
            for ki in range(K):
                for kj in range(K):
                    acc += mat[i + ki][j + kj] * kernel[ki][kj]
            out[i][j] = clamp_int32(acc)
    return out


def gen_random_int32(rng: random.Random, low: int = -100, high: int = 100) -> int:
    """
    Generate a random integer in a given range.

    Arguments:
        rng (Random): Random number generator instance.
        low (int): Inclusive lower bound.
        high (int): Inclusive upper bound.

    Returns:
        A random integer between low and high.
    """
    return rng.randint(low, high)

def to_twos_complement_hex(x: int, width_bits: int) -> str:
    """
    Convert integer x to its two's-complement representation as hex for a given width.

    Returns a zero-padded lowercase hex string of exactly width_bits/4 hex digits.
    """
    if width_bits <= 0:
        raise ValueError("width_bits must be > 0")

    min_val = -(1 << (width_bits - 1))
    max_val = (1 << (width_bits - 1)) - 1
    if not (min_val <= x <= max_val):
        raise ValueError(f"x={x} out of range for {width_bits}-bit signed two's complement "
                         f"({min_val}..{max_val})")

    mask = (1 << width_bits) - 1
    twos = x & mask  # works for both positive and negative
    hex_digits = (width_bits + 3) // 4  # round up to full nybbles
    return f"{twos:0{hex_digits}x}"

def generate_tests(nr_tests: int, seed: int | None = None) -> None:
    """
    Generate convolution test cases and write them to ./input and ./output.

    For each test case X in [0, nr_tests-1]:
      - Generates a 13x13 matrix and a 2x2 kernel
      - Computes the expected 12x12 convolution output
      - Writes:
          ./input/test{X}.in
          ./input/test{X}.kernel
          ./output/test{X}.out

    Arguments:
        nr_tests (int): Number of test cases to generate.
        seed (int): Optional RNG seed for reproducibility.
    """
    ensure_dirs()
    rng = random.Random(seed)

    for t in range(nr_tests):
        # Generate matrix and kernel values
        mat = [[gen_random_int32(rng, -100, 100) for _ in range(M)] for _ in range(M)]
        kernel = [[gen_random_int32(rng, -10, 10) for _ in range(K)] for _ in range(K)]

        expected = compute_convolution(mat, kernel)

        # convert to 32-bit two's-complement hex
        mat_hex = [[to_twos_complement_hex(x, 32) for x in row] for row in mat]
        kernel_hex = [[to_twos_complement_hex(x, 32) for x in row] for row in kernel]
        expected_hex = [[to_twos_complement_hex(x, 32) for x in row] for row in expected]

        in_path = f"./input/test{t}.in"
        ker_path = f"./input/test{t}.kernel"
        out_path = f"./output/test{t}.out"

        flat_mat_hex      = [v for row in mat_hex      for v in row]
        flat_kernel_hex   = [v for row in kernel_hex   for v in row]
        flat_expected_hex = [v for row in expected_hex for v in row]

        with open(in_path, "w", encoding="utf-8") as f:
            f.write("\n".join(flat_mat_hex) + "\n")
        with open(ker_path, "w", encoding="utf-8") as f:
            f.write("\n".join(flat_kernel_hex) + "\n")
        with open(out_path, "w", encoding="utf-8") as f:
            f.write("\n".join(flat_expected_hex) + "\n")


def main() -> None:
    """
    CLI entry point.

    Parses command line arguments and generates the requested number of tests.
    """
    parser = argparse.ArgumentParser(
        description="Generates I/O test values for convolution tests (13x13 x 2x2)."
    )
    parser.add_argument(
        "nr_tests",
        type=int,
        help="The number of test cases to generate.",
    )
    parser.add_argument(
        "--seed",
        type=int,
        default=None,
        help="Optional RNG seed for reproducibility.",
    )

    args = parser.parse_args()

    if args.nr_tests <= 0:
        raise SystemExit("nr_tests must be > 0")

    generate_tests(args.nr_tests, seed=args.seed)


if __name__ == "__main__":
    main()
