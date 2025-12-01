# slow_import_daily.py
"""
Very-slow Firestore importer for free-tier:
 - Resumes via checkpoint
 - Uploads at most MAX_DAILY_WRITES per run (default 10000)
 - Small BATCH_SIZE with sleep between batches to avoid throttling
 - Exponential backoff on ResourceExhausted
"""

import os
import json
import time
import pandas as pd
import firebase_admin
from firebase_admin import credentials, firestore
from slugify import slugify
from google.api_core import exceptions as google_exceptions

# ========== CONFIG ==========
SERVICE_ACCOUNT = r"E:\medcad\serviceAccountKey.json"   # <-- update
CSV_PATH = r"E:\medcad\updated_indian_medicine_data.csv"  # <-- update
TARGET_COLLECTION = "medicines"

# Very conservative settings for free-tier
BATCH_SIZE = 25                 # small batch to reduce burst
SLEEP_BETWEEN_BATCHES = 5.0     # seconds pause after each batch
MAX_DAILY_WRITES = 10000        # max writes this run (stay under free-tier daily cap)
CHECKPOINT_FILE = "import_checkpoint.json"
MAX_RETRY_ATTEMPTS = 10
RETRY_BASE_SLEEP = 5.0
# ============================

# Init Firebase Admin
cred = credentials.Certificate(SERVICE_ACCOUNT)
firebase_admin.initialize_app(cred)
db = firestore.client()
col_ref = db.collection(TARGET_COLLECTION)

def load_csv(path):
    df = pd.read_csv(path)
    df = df.fillna("")
    return df

def split_values(val):
    if not val:
        return []
    return [x.strip() for x in str(val).replace("/", ",").replace(";", ",").split(",") if x.strip()]

def transform_row(row):
    name = str(row.get("name", "")).strip()
    doc_id = slugify(name) or None
    doc = {
        "name": name,
        "name_lower": name.lower(),
        "price": row.get("price", ""),
        "manufacturer": row.get("manufactur", ""),
        "type": row.get("type", ""),
        "pack_size": row.get("pack_size_l", ""),
        "short_composition": row.get("short_comp", ""),
        "salt_composition": row.get("salt_composition", ""),
        "side_effects": split_values(row.get("medicine_c_side_effect")),
        "drug_interactions": split_values(row.get("drug_interactions")),
        "createdAt": firestore.SERVER_TIMESTAMP,
        "updatedAt": firestore.SERVER_TIMESTAMP,
    }
    return doc_id, doc

def read_checkpoint():
    if os.path.exists(CHECKPOINT_FILE):
        with open(CHECKPOINT_FILE, "r", encoding='utf-8-sig') as fh:
            return json.load(fh)
    return {"last_row_index": 0, "rows_processed_total": 0}

def write_checkpoint(last_row_index, rows_processed_total):
    tmp = {"last_row_index": last_row_index, "rows_processed_total": rows_processed_total}
    with open(CHECKPOINT_FILE + ".tmp", "w", encoding="utf-8") as fh:
        json.dump(tmp, fh)
    os.replace(CHECKPOINT_FILE + ".tmp", CHECKPOINT_FILE)

def commit_with_retry(batch, batch_no):
    attempt = 0
    while True:
        try:
            batch.commit()
            return
        except google_exceptions.ResourceExhausted as e:
            attempt += 1
            if attempt > MAX_RETRY_ATTEMPTS:
                raise
            sleep_for = RETRY_BASE_SLEEP * (2 ** (attempt - 1))
            print(f"[WARN] Batch {batch_no}: ResourceExhausted. Sleeping {sleep_for:.1f}s (attempt {attempt})")
            time.sleep(sleep_for)
        except google_exceptions.GoogleAPICallError as e:
            attempt += 1
            if attempt > MAX_RETRY_ATTEMPTS:
                raise
            sleep_for = RETRY_BASE_SLEEP * (2 ** (attempt - 1))
            print(f"[WARN] Batch {batch_no}: API error {e}. Sleeping {sleep_for:.1f}s (attempt {attempt})")
            time.sleep(sleep_for)

def run_once():
    print("Loading CSV:", CSV_PATH)
    df = load_csv(CSV_PATH)
    total_rows = len(df)
    print("Total rows in CSV:", total_rows)

    checkpoint = read_checkpoint()
    start_idx = checkpoint.get("last_row_index", 0)
    processed_total = checkpoint.get("rows_processed_total", 0)

    print(f"Resuming from row index {start_idx}, previously processed total {processed_total}")

    max_to_do = MAX_DAILY_WRITES
    rows_done_this_run = 0
    batch_no = 0

    idx = start_idx
    batch = db.batch()
    batch_count = 0

    while idx < total_rows and rows_done_this_run < max_to_do:
        row = df.iloc[idx]
        doc_id, doc = transform_row(row)

        if doc_id:
            batch.set(col_ref.document(doc_id), doc)
        else:
            batch.set(col_ref.document(), doc)

        batch_count += 1
        idx += 1
        rows_done_this_run += 1
        processed_total += 1

        if batch_count >= BATCH_SIZE:
            print(f"Committing batch {batch_no} (rows in batch: {batch_count}). Total processed this run: {rows_done_this_run}/{max_to_do}")
            commit_with_retry(batch, batch_no)
            write_checkpoint(idx, processed_total)
            batch_no += 1
            batch = db.batch()
            batch_count = 0
            time.sleep(SLEEP_BETWEEN_BATCHES)

    # commit leftover
    if batch_count > 0 and rows_done_this_run <= max_to_do:
        print(f"Committing final batch {batch_no} (rows: {batch_count}).")
        commit_with_retry(batch, batch_no)
        write_checkpoint(idx, processed_total)

    print(f"Run complete. Processed this run: {rows_done_this_run}. Total processed overall: {processed_total}. Next start index: {idx}")
    if idx >= total_rows:
        print("All rows processed. You are done.")
    else:
        remaining = total_rows - idx
        print(f"Rows remaining: {remaining}. Re-run the script tomorrow to continue.")

if __name__ == "__main__":
    run_once()
