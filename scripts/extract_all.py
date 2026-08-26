"""Save lark slides XML to a file and then extract speaker notes."""
import subprocess
import json
import re
import html
import os

TEMP = os.environ.get('TEMP', '.')
OUT_JSON = os.path.join(TEMP, 'slides_out.json')

# Step 1: Call lark-cli and save output
print("Calling lark-cli...")
r = subprocess.run(
    [r'C:\Users\91448\AppData\Roaming\npm\lark-cli.cmd', 'slides', 'xml_presentations', 'get', '--as', 'user',
     '--params', json.dumps({'xml_presentation_id': 'ZJUUsTp0rl3H9edH4FccnGMPnjc'})],
    capture_output=True, encoding='utf-8', errors='replace', timeout=30
)
print(f"Return code: {r.returncode}")
print(f"Stdout length: {len(r.stdout)}")

# Save stdout
with open(OUT_JSON, 'w', encoding='utf-8') as f:
    f.write(r.stdout)
print(f"Saved to {OUT_JSON}")

# Step 2: Parse JSON
content = r.stdout
idx = content.find('{')
content = content[idx:]

data = json.loads(content)
if not data.get('ok'):
    print(f"API error: {data.get('error')}")
    exit(1)

xml_pres = data['data']['xml_presentation']
xml_content = xml_pres['content']  # It's a dict with 'content' key

# Step 3: Extract slides and notes
slides = re.findall(r'<slide\s+id="([^"]+)"[^>]*>(.*?)</slide>', xml_content, re.DOTALL)
print(f"\nTotal slides: {len(slides)}\n")

results = []
for i, (slide_id, slide_body) in enumerate(slides, 1):
    # Extract note
    note_match = re.search(r'<note[^>]*>(.*?)</note>', slide_body, re.DOTALL)
    note_text = ''
    if note_match:
        note_raw = note_match.group(1)
        # First extract all text from p tags
        texts = re.findall(r'<p[^>]*>(.*?)</p>', note_raw, re.DOTALL)
        texts_clean = []
        for t in texts:
            # Preserve bold, strip everything else
            t = re.sub(r'<strong>', '**', t)
            t = re.sub(r'</strong>', '**', t)
            # Remove all remaining HTML tags
            t = re.sub(r'<[^>]+>', '', t)
            t = html.unescape(t)
            t = t.strip()
            if t:
                texts_clean.append(t)
        note_text = '  \n'.join(texts_clean)
    
    # Extract title
    body_no_notes = re.sub(r'<note[^>]*>.*?</note>', '', slide_body, re.DOTALL)
    visible_texts = re.findall(r'<p[^>]*>(.*?)</p>', body_no_notes, re.DOTALL)
    titles = []
    for vt in visible_texts[:5]:
        vt = re.sub(r'<[^>]+>', '', vt)
        vt = html.unescape(vt).strip()
        if vt and len(vt) > 1 and vt != '&nbsp;':
            titles.append(vt[:120])
    
    title = ' | '.join(titles[:3])
    
    results.append({'num': i, 'id': slide_id, 'title': title, 'note': note_text})
    
    note_preview = note_text[:100].replace('\n', ' ') + '...' if note_text else '(none)'
    print(f'Slide {i} [{slide_id}] {title[:80]}')
    print(f'  Note: {note_preview}\n')

# Step 4: Write Markdown
MD_PATH = r'c:\Users\91448\Documents\GitHub\critter-home-design\光子PPT_演讲稿.md'
with open(MD_PATH, 'w', encoding='utf-8') as f:
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

print(f'\nMarkdown written to: {MD_PATH}')
print('Done!')
