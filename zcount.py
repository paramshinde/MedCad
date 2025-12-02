import firebase_admin
from firebase_admin import credentials, firestore

SERVICE_ACCOUNT = r"E:\medcad\serviceAccountKey.json"

cred = credentials.Certificate(SERVICE_ACCOUNT)
firebase_admin.initialize_app(cred)

db = firestore.client()
col_ref = db.collection("medicines")

agg = col_ref.count().get()

# Handle nested list [[result]]
count_value = agg[0][0].value

print("Total documents in 'medicines':", count_value)
