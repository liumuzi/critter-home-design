import json, os

TEMP = os.environ.get('TEMP', '.')
with open(os.path.join(TEMP, 'slides_out.json'), 'r', encoding='utf-8') as f:
    content = f.read()

idx = content.find('{')
data = json.loads(content[idx:])
d = data['data']
print('data keys:', list(d.keys()))
for k, v in d.items():
    print(f'{k}: type={type(v).__name__}', end='')
    if isinstance(v, str):
        print(f', len={len(v)}, first100={repr(v[:100])}')
    elif isinstance(v, dict):
        print(f', subkeys={list(v.keys())}')
    else:
        print(f', value={repr(v)[:100]}')
    print()
