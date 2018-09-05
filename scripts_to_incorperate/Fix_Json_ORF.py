import json
import collections
import os


output_dir = 'output'


try:
    os.stat(output_dir)
except:
    os.mkdir(output_dir)

json_files = []
for filename in os.listdir(os.getcwd()):
    if filename.lower().endswith('.json'):
        json_files.append(filename)

for filename in json_files:
    with open(filename) as f:
        content = json.loads(f.read(), object_pairs_hook=collections.OrderedDict)

    sample = content['sample']
    for sample_dict in sample:
        for item_key in sample_dict:
            if item_key in ('ORF1p_variants', 'ORF2p_variants'):
                field = next(iter(sample_dict[item_key].values()))
                if type(field) is list:
                    field_len = len(field)
                    result_list = [collections.OrderedDict() for _ in range(field_len)]
                    for field in sample_dict[item_key]:
                        for index in range(field_len):
                            result_list[index][field] = sample_dict[item_key][field][index]
                    sample_dict[item_key] = result_list
                else:
                    sample_dict[item_key] = [sample_dict[item_key]]
    with open(output_dir+'/'+filename, 'w') as f:
        json.dump(content, f, indent=2)
