import { FirebaseApp, FirebaseOptions, initializeApp } from "firebase/app";
import { Firestore, getFirestore } from "firebase/firestore";

class Firebase {
	private db: Firestore;
	private static instance: Firebase;

	/**
	 * Initialize firebase database
	 */
	private constructor() {
		const firebaseConfig: FirebaseOptions = {
			apiKey: "AIzaSyCnOzXitNGKKLdmP642PS8ftjDM2IADUXM",
			authDomain: "posto-e4bc1.firebaseapp.com",
			databaseURL: "https://posto-e4bc1-default-rtdb.firebaseio.com",
			projectId: "posto-e4bc1",
			storageBucket: "posto-e4bc1.appspot.com",
			messagingSenderId: "1042436692490",
			appId: "1:1042436692490:web:7c79dc8f8e48aef1931df3",
			measurementId: "G-MYCGJY24PC",
		};
		const fb: FirebaseApp = initializeApp(firebaseConfig);
		this.db = getFirestore(fb);
	}

	/**
	 * Get the single instance of Firebase
	 * @returns {Firebase} - the single instance of the Firebase
	 */
	public static getInstance(): Firebase {
		if (!this.instance) {
			Firebase.instance = new Firebase();
		}
		return Firebase.instance;
	}

	/**
	 * Return the database
	 * @returns {Firestore} - the firestore database
	 */
	public getDb(): Firestore {
		return this.db;
	}
}

export default Firebase;
