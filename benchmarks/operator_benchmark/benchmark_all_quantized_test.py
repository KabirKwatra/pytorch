from __future__ import absolute_import
from __future__ import division
from __future__ import print_function
from __future__ import unicode_literals

import operator_benchmark as op_bench
from pt import qactivation_test
from pt import qarithmetic_test
from pt import qbatchnorm_test
from pt import qcat_test
from pt import qcomparators_test
from pt import qconv_test
from pt import qinterpolate_test
from pt import qlinear_test
from pt import qobserver_test
from pt import qpool_test
from pt import qrnn_test
from pt import qtensor_method_test
from pt import quantization_test
from pt import qunary_test


if __name__ == "__main__":
    op_bench.benchmark_runner.main()
