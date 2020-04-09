from __future__ import absolute_import
from __future__ import division
from __future__ import print_function
from __future__ import unicode_literals

import operator_benchmark as op_bench
from pt import add_test
from pt import as_strided_test
from pt import batchnorm_test
from pt import binary_test
from pt import cat_test
from pt import chunk_test
from pt import conv_test
from pt import diag_test
from pt import embeddingbag_test
from pt import fill_test
from pt import gather_test
from pt import hardsigmoid_test
from pt import hardswish_test
from pt import linear_test
from pt import matmul_test
from pt import pool_test
from pt import softmax_test

if __name__ == "__main__":
    op_bench.benchmark_runner.main()
