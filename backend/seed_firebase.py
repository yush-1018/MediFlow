import firebase_admin
from firebase_admin import credentials
from firebase_admin import db
import random
import datetime

# Initialize Firebase Admin SDK
# You need to download your serviceAccountKey.json from Firebase Console:
# Project Settings -> Service Accounts -> Generate New Private Key
try:
    cred = credentials.Certificate('serviceAccountKey.json')
    firebase_admin.initialize_app(cred, {
        'databaseURL': 'https://your_project_id.firebaseio.com'
    })
except Exception as e:
    print(f"Error initializing Firebase: {e}")
    print("Please ensure 'serviceAccountKey.json' exists and databaseURL is correct.")
    exit(1)

def seed_data():
    facilities_ref = db.reference('facilities')
    inventory_ref = db.reference('inventory')
    
    facilities = [
        {"id": "f1", "name": "District Hospital City", "lat": 28.6139, "lon": 77.2090, "type": "DH"},
        {"id": "f2", "name": "PHC Rural North", "lat": 28.7041, "lon": 77.1025, "type": "PHC"},
        {"id": "f3", "name": "Community Hospital East", "lat": 28.6500, "lon": 77.3000, "type": "CH"},
    ]

    # Generate more facilities
    for i in range(4, 30):
        facilities.append({
            "id": f"f{i}",
            "name": f"Facility {i} (PHC)",
            "lat": 28.4 + random.random() * 0.4,
            "lon": 77.0 + random.random() * 0.4,
            "type": "PHC"
        })

    # Push facilities
    print("Seeding facilities...")
    for f in facilities:
        facilities_ref.child(f['id']).set(f)

    # Generate Inventory
    drugs = ['Insulin', 'Paracetamol', 'Amoxicillin', 'Azithromycin', 'Metformin', 'Amlodipine']
    print("Seeding inventory...")
    for f in facilities:
        for drug in drugs:
            if random.random() > 0.3:
                qty = random.randint(10, 500)
                expiry_offset = random.randint(-30, 120)
                expiry_date = datetime.datetime.now() + datetime.timedelta(days=expiry_offset)
                
                item_id = f"i-{f['id']}-{drug}"
                inventory_ref.child(f['id']).child(item_id).set({
                    "id": item_id,
                    "name": drug,
                    "quantity": qty,
                    "expiryDate": expiry_date.isoformat(),
                    "batchNo": f"BATCH-{random.randint(1000, 9999)}"
                })

    print("Success! Firebase project seeded with mock network data.")

if __name__ == '__main__':
    seed_data()
