# import_meds_from_excel.py
import os
import json
import math
from glob import glob
import pandas as pd
import firebase_admin
from firebase_admin import credentials, firestore
from slugify import slugify
from datetime import datetime

# ========== CONFIG ==========
SERVICE_ACCOUNT = "serviceAccountKey.json"  # <- update
EXCEL_PATH = "updated_indian_medicine_data.csv"         # <- update
SHEET_NAME = None  # or sheet name if needed
COL_MAP = {
    # map expected file columns to target doc fields
    "id": "source_id",
    "name": "name",
    "price": "price",
    "Is_disconti": "is_discontinued",
    "manufactur": "manufacturer",
    "type": "type",
    "pack_size_l": "pack_size",
    "short_comp": "short_composition",
    "salt_composition": "salt_composition",
    "medicine_c_side_effect": "side_effects",
    "drug_interactions": "drug_interactions",
    # add other columns if available...
}
TARGET_COLLECTION = "medicines"
BATCH_SIZE = 450  # keep < 500
# ===========================

# Init Firebase
cred = credentials.Certificate(SERVICE_ACCOUNT)
firebase_admin.initialize_app(cred)
db = firestore.client()
col_ref = db.collection(TARGET_COLLECTION)

def load_excel(path, sheet_name=None):
    df = pd.read_excel(path, sheet_name=sheet_name, engine="openpyxl")
    df = df.fillna("")  # replace NaN with empty string
    return df

def transform_row(row):
    # row is a pandas Series
    doc = {}
    for src_col, target in COL_MAP.items():
        if src_col in row.index:
            doc[target] = row[src_col]
        else:
            doc[target] = ""  # default

    # Normalize types and text
    # Ensure name is string
    doc['name'] = str(doc.get('name') or "").strip()
    doc['name_lower'] = doc['name'].lower()
    # Add slug/id
    if doc.get('source_id'):
        doc_id = str(doc['source_id'])
    else:
        doc_id = slugify(doc['name']) or None

    # Compose aliases from short_comp or comma separated names if present
    aliases = set()
    sc = str(doc.get('short_composition') or "")
    if sc:
        # sometimes short_comp contains alternative names; split by comma or '/'
        for part in [p.strip() for p in re_split_comma(sc)]:
            if part:
                aliases.add(part)
    # include name variations
    aliases.add(doc['name'])
    doc['aliases'] = list(aliases)

    # Side effects & interactions: try to keep as list if comma separated
    doc['side_effects'] = split_to_list(doc.get('side_effects'))
    doc['drug_interactions'] = parse_jsonish(doc.get('drug_interactions'))

    # price: convert to float if possible
    try:
        doc['price'] = float(str(doc.get('price') or "").strip())
    except:
        doc['price'] = None

    # timestamps
    doc['createdAt'] = firestore.SERVER_TIMESTAMP
    doc['updatedAt'] = firestore.SERVER_TIMESTAMP

    return doc_id, doc

def re_split_comma(text):
    # helper: split by comma, semicolon, slash, ' + ' etc.
    import re
    parts = re.split(r'[,/;|+]', str(text))
    return [p.strip() for p in parts if p and p.strip()]

def split_to_list(value):
    if not value:
        return []
    if isinstance(value, (list, tuple)):
        return list(value)
    # split by common separators
    parts = re_split_comma(value)
    return parts

def parse_jsonish(value):
    # sometimes drug_interactions column may contain JSON-like text; try to load
    if not value:
        return []
    v = str(value).strip()
    try:
        # try JSON
        obj = json.loads(v)
        return obj
    except:
        # fallback to splitting
        return split_to_list(v)

def chunked_iterable(iterable, size):
    it = iter(iterable)
    while True:
        chunk = []
        try:
            for _ in range(size):
                chunk.append(next(it))
        except StopIteration:
            if chunk:
                yield chunk
            break
        yield chunk

def upload_docs(docs_iter):
    batch_count = 0
    for chunk in chunked_iterable(docs_iter, BATCH_SIZE):
        batch = db.batch()
        for doc_id, doc in chunk:
            # if doc_id is None or empty, use auto-ID
            if doc_id:
                # keep doc IDs unique; if duplicates occur, we can append a suffix
                doc_ref = col_ref.document(doc_id)
                batch.set(doc_ref, doc, merge=True)
            else:
                doc_ref = col_ref.document()
                batch.set(doc_ref, doc, merge=True)
        batch.commit()
        batch_count += 1
        print(f"Committed batch {batch_count}, size {len(chunk)}")

def main():
    print("Loading Excel:", EXCEL_PATH)
    df = load_excel(EXCEL_PATH, SHEET_NAME)
    print("Rows read:", len(df))
    docs = []
    for idx, row in df.iterrows():
        doc_id, doc = transform_row(row)
        docs.append((doc_id, doc))
    print("Transformed docs:", len(docs))
    upload_docs(iter(docs))
    print("Done.")

if __name__ == "__main__":
    main()
