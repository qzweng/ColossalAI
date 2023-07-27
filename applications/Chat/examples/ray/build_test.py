import colossalai
from colossalai.kernel.op_builder import CPUAdamBuilder

cpu_adam = CPUAdamBuilder().load(verbose=True)
print("BUILD TEST DONE: Colossal._C exists")