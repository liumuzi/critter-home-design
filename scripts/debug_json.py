import os
p = os.path.expandvars(r'%TEMP%\slides_output.json')
print('exists:', os.path.exists(p))
if os.path.exists(p):
    with open(p, 'r', encoding='utf-8-sig') as f:
        c = f.read()
    print('length:', len(c))
    print('first 200:', repr(c[:200]))
