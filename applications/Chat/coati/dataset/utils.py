import io
import json

import torch.distributed as dist

def is_rank_0() -> bool:
    return not dist.is_initialized() or dist.get_rank() == 0


def _make_r_io_base(f, mode: str):
    if not isinstance(f, io.IOBase):
        f = open(f, mode=mode)
    return f


def jload(data_path, mode="r"):
    """Load a .json file into a dictionary."""
    print("data_path:", data_path)
    f = _make_r_io_base(data_path, mode)
    if str(data_path).endswith("jsonl"):
        print("HERE")
        jdict = [json.loads(line) for line in f]
    else:
        print("THERE")
        jdict = json.load(f)
    f.close()
    return jdict
