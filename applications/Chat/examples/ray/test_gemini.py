import typing
import collections
import colossalai
from colossalai.zero.gemini import ZeroDDP

colopath = colossalai.__path__[0]
print(f"colossalai path: {colopath}")
print(f"ZeroDDP path: {colopath}/zero/gemini/gemini_ddp.py")

assert ZeroDDP.state_dict_shard.__annotations__['return'] == typing.Iterator[typing.Tuple[collections.OrderedDict]], \
    ZeroDDP.state_dict_shard.__annotations__['return']
