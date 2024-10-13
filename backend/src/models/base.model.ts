
import {
    CollectionReference,
    DocumentData,
    DocumentReference,
    Firestore,
    collection,
    doc
} from "firebase/firestore";
import Firebase from "./firebase";

abstract class BaseModel {
    protected db: Firestore;
    protected name: string;

    /**
     * Protected constructor
     */
    protected constructor(name: string) {
        this.name = name;
        this.db = Firebase.getInstance().getDb();
    }

    /**
     * @returns {UserModel} - the instance of the user model
     */
    protected getInstance() {
        throw new Error("getInstance must be implemented");
    }

    /**
     * Get the post collection
     */
    protected getCollection(): CollectionReference<DocumentData> {
        return collection(this.db, this.name);
    }

    /**
     * Get a document by id	
     * @param {string} id - the id of a document
     */
    protected getDocById(id: string): DocumentReference<DocumentData> {
        return doc(this.db, this.name, id);
    }
}

export default BaseModel;
