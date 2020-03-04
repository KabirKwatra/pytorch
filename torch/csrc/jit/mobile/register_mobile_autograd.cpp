#include <ATen/ATen.h>
#include <ATen/TypeDefault.h>
#include <ATen/core/op_registration/op_registration.h>
#include <ATen/core/stack.h>

using Stack = std::vector<c10::IValue>;
using at::Scalar;
using at::Tensor;

namespace torch {
namespace autograd {
namespace VariableType {
Tensor mul_Tensor(const Tensor& self, const Tensor& other);
Tensor add_Scalar(const Tensor& self, Scalar other, Scalar alpha);
} // namespace VariableType
} // namespace autograd
} // namespace torch

namespace {
static auto registry =
    torch::RegisterOperators()
        .op("_aten::add.Scalar",
            torch::RegisterOperators::options().kernel(
                c10::DispatchKey::VariableTensorId,
                &torch::autograd::VariableType::add_Scalar))
        .op("_aten::mul.Tensor(Tensor self, Tensor other) -> Tensor",
            torch::RegisterOperators::options()
                .kernel(
                    c10::DispatchKey::VariableTensorId,
                    &torch::autograd::VariableType::mul_Tensor)
                .aliasAnalysis(c10::AliasAnalysisKind::FROM_SCHEMA));
}
