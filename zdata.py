import firebase_admin
from firebase_admin import credentials, firestore

SERVICE_ACCOUNT = r"E:\medcad\serviceAccountKey.json"

# Initialize Firebase
cred = credentials.Certificate(SERVICE_ACCOUNT)
firebase_admin.initialize_app(cred)

db = firestore.client()

# ----- Change this to your collection name -----
collection_name = "medicines"
# ------------------------------------------------

col_ref = db.collection(collection_name)
docs = col_ref.stream()

print(f"\n📌 All documents in '{collection_name}':\n")

empty = True
for doc in docs:
    empty = False
    print(f"Document ID: {doc.id}")
    print("Data:", doc.to_dict())
    print("-" * 50)

if empty:
    print("⚠ The collection is empty.")
    
    #azzy-500mg-tablet
