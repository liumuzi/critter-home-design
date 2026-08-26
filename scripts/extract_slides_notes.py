"""Extract slides and speaker notes from lark presentation XML JSON output."""
import json
import re
import html
import sys
from pathlib import Path

def main():
    # Read the JSON from file
    json_path = Path(r'c:\Users\91448\Documents\GitHub\critter-home-design\temp_slides_json.txt')
    
    with open(json_path, 'r', encoding='utf-8-sig') as f:
        content = f.read()
    
    # Strip any warning lines before JSON
    idx = content.find('{')
    if idx > 0:
        content = content[idx:]
    
    # Parse JSON - the XML content has unescaped backslashes in the string
    # We need to use a more lenient approach
    data = json.loads(content)
    
    d = data['data']
    xml_content = d['xml_presentation']
    
    # Parse each slide
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
            # Extract text from p tags inside content
            content_match = re.search(r'<content[^>]*>(.*?)</content>', note_raw, re.DOTALL)
            if content_match:
                note_raw = content_match.group(1)
            texts = re.findall(r'<p[^>]*>(.*?)</p>', note_raw, re.DOTALL)
            texts_clean = []
            for t in texts:
                # Remove span tags but keep text
                t = re.sub(r'<span[^>]*>', '', t)
                t = re.sub(r'</span>', '', t)
                t = re.sub(r'<strong>', '', t)
                t = re.sub(r'</strong>', '', t)
                t = re.sub(r'<br\s*/?>', '', t)
                t = html.unescape(t)
                t = t.strip()
                if t:
                    texts_clean.append(t)
            note_text = '\n'.join(texts_clean)
        
        # Extract title from visible text
        visible_texts = re.findall(r'<p[^>]*>(.*?)</p>', slide_body, re.DOTALL)
        title = ''
        for vt in visible_texts:
            # Skip note content
            if '</note>' in vt or '<note' in vt:
                continue
            vt = re.sub(r'<span[^>]*>', '', vt)
            vt = re.sub(r'</span>', '', vt)
            vt = re.sub(r'<[^>]+>', '', vt)
            vt = html.unescape(vt).strip()
            if vt and len(vt) > 1:
                title = vt
                break
        
        results.append({
            'slide_num': i,
            'slide_id': slide_id,
            'title': title,
            'note': note_text
        })
        
        print(f'--- Slide {i} (id: {slide_id}) ---')
        print(f'Title: {title[:100]}')
        print(f'Note: {note_text[:150]}')
        print()
    
    # Save results
    output_path = Path(r'c:\Users\91448\Documents\GitHub\critter-home-design\data\slides_extracted.json')
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(results, f, ensure_ascii=False, indent=2)
    print(f'Saved {len(results)} slides to {output_path}')
    
    return results

if __name__ == '__main__':
    main()
