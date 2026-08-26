"""Extract slides and speaker notes from lark slides JSON output."""
import json, re, html, os, sys

# Read the JSON file
json_path = os.path.expandvars(r'%TEMP%\slides_output.json')
if not os.path.exists(json_path):
    print(f'ERROR: {json_path} not found')
    sys.exit(1)

with open(json_path, 'r', encoding='utf-8-sig') as f:
    content = f.read()

# Strip any warning lines before JSON
idx = content.find('{')
content = content[idx:]

data = json.loads(content)
if not data.get('ok'):
    print(f'API error: {data.get("error")}')
    sys.exit(1)

xml_content = data['data']['xml_presentation']

# Parse slides
slides = re.findall(r'<slide\s+id="([^"]+)"[^>]*>(.*?)</slide>', xml_content, re.DOTALL)
print(f'Total slides: {len(slides)}')
print()

results = []
for i, (slide_id, slide_body) in enumerate(slides, 1):
    # Extract speaker note
    note_match = re.search(r'<note[^>]*>(.*?)</note>', slide_body, re.DOTALL)
    note_text = ''
    if note_match:
        note_raw = note_match.group(1)
        # Extract text from p tags
        texts = re.findall(r'<p[^>]*>(.*?)</p>', note_raw, re.DOTALL)
        texts_clean = []
        for t in texts:
            t = re.sub(r'<span[^>]*>', '', t)
            t = re.sub(r'</span>', '', t)
            t = re.sub(r'<strong>', '**', t)
            t = re.sub(r'</strong>', '**', t)
            t = re.sub(r'<br\s*/?>', '', t)
            t = html.unescape(t)
            t = t.strip()
            if t:
                texts_clean.append(t)
        note_text = '  \n'.join(texts_clean)
    
    # Extract title (first meaningful visible text from data section)
    body_no_notes = re.sub(r'<note[^>]*>.*?</note>', '', slide_body, re.DOTALL)
    visible_texts = re.findall(r'<p[^>]*>(.*?)</p>', body_no_notes, re.DOTALL)
    titles = []
    for vt in visible_texts:
        vt = re.sub(r'<span[^>]*>', '', vt)
        vt = re.sub(r'</span>', '', vt)
        vt = re.sub(r'<[^>]+>', '', vt)
        vt = html.unescape(vt).strip()
        if vt and len(vt) > 1:
            titles.append(vt[:100])
    
    title = ' | '.join(titles[:3])
    
    results.append({
        'num': i,
        'id': slide_id,
        'title': title,
        'note': note_text
    })
    
    print(f'Slide {i} [{slide_id}]: {title[:100]}')
    if note_text:
        print(f'  Note: {note_text[:120]}...')
    else:
        print('  (no speaker notes)')
    print()

# Write Markdown
md_path = r'c:\Users\91448\Documents\GitHub\critter-home-design\光子PPT_演讲稿.md'
with open(md_path, 'w', encoding='utf-8') as f:
    f.write('# 光子PPT — 演讲稿（Speaker Notes）\n\n')
    f.write('**演示文稿**: 光子PPT\n\n')
    f.write(f'**总页数**: {len(results)}\n\n')
    f.write('---\n\n')
    
    for r in results:
        f.write(f'## 第 {r["num"]} 页\n\n')
        f.write(f'**Slide ID**: `{r["id"]}`\n\n')
        if r['title']:
            f.write(f'**页面内容**: {r["title"]}\n\n')
        if r['note']:
            f.write(f'**演讲稿**:\n\n{r["note"]}\n\n')
        else:
            f.write('**演讲稿**: （无）\n\n')
        f.write('---\n\n')

print(f'\nWritten to: {md_path}')
print('Done!')
