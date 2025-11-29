import firebase_admin
from firebase_admin import credentials, firestore

SERVICE_ACCOUNT = r"E:\medcad\serviceAccountKey.json"

cred = credentials.Certificate(SERVICE_ACCOUNT)
firebase_admin.initialize_app(cred)

db = firestore.client()
col_ref = db.collection("medicines")

agg_query = col_ref.count().get()

# handle a few possible return shapes
count_value = None
try:
    # case: [AggregationResult(...)] or [[Aggregation(...)]]
    if isinstance(agg_query, list):
        # nested list e.g. [[Aggregation,...]]
        first = agg_query[0]
        if isinstance(first, list) or isinstance(first, tuple):
            count_value = first[0].value
        else:
            count_value = first.value
    else:
        # fallback
        count_value = agg_query.value
except Exception:
    # safe fallback: try indexing twice
    try:
        count_value = agg_query[0][0].value
    except Exception as e:
        raise RuntimeError("Unable to parse aggregation result: " + str(e))

print("Total documents in 'medicines':", int(count_value))
