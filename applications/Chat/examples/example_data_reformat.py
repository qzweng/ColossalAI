from pathlib import Path
this_dir = Path(__file__).parent
jsonl_file = this_dir / 'InstructionWild/data/seed_prompts_en.jsonl'  # seed_prompts_en.jsonl or seed_prompts_ch.json from InstructionWild
reformat_file = this_dir / 'InstructionWild/data/prompts_en.jsonl'  # reformat jsonl file used as Prompt dataset in Stage3

jsonl_file = this_dir / 'InstructionWild/data_v2/user_1.jsonl'  # seed_prompts_en.jsonl or seed_prompts_ch.json from InstructionWild
reformat_file = this_dir / 'InstructionWild/data_v2/prompts_user_1.jsonl'  # reformat jsonl file used as Prompt dataset in Stage3


data = ''
with open(jsonl_file, 'r', encoding="utf-8") as f1:
    for jsonstr in f1.readlines():
        jsonstr = '\t' + jsonstr.strip('\n') + ',\n'
        data = data + jsonstr
    data = '[\n' + data + ']'

with open(reformat_file, 'w') as f2:
    f2.write(data)