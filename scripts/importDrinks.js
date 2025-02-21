const admin = require('../config/firebaseAdmin'); // Import Firebase Admin SDK
const drinks = require('../assets/data/drinks.json'); // Path to drinks.json

const db = admin.firestore(); // Firestore reference

// Function to delete all drinks
async function deleteAllDrinks() {
    try {
        const drinksCollection = db.collection('drinks');
        const snapshot = await drinksCollection.get();
        const batch = db.batch();

        snapshot.docs.forEach((doc) => {
            batch.delete(doc.ref);
        });

        await batch.commit();
        console.log('✅ All drinks deleted successfully!');
    } catch (error) {
        console.error('❌ Error deleting drinks:', error);
    }
}

// Function to import drinks
async function importDrinks() {
    try {
        const batch = db.batch();
        const drinksCollection = db.collection('drinks');

        drinks.forEach((drink) => {
            const docRef = drinksCollection.doc(drink.id);
            batch.set(docRef, {
                ...drink,
                quantity: Number(drink.quantity) || 0, // Ensure quantity is a number
            });
        });

        await batch.commit();
        console.log('✅ Drinks imported successfully!');
    } catch (error) {
        console.error('❌ Error importing drinks:', error);
    }
}

// Execute the functions in sequence
async function resetDrinksCollection() {
    await deleteAllDrinks(); // First, delete all drinks
    await importDrinks(); // Then, import fresh data
}

resetDrinksCollection();
