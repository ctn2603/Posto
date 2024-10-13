import {
    CollectionReference,
    DocumentData,
    DocumentReference,
    DocumentSnapshot, Query,
    QuerySnapshot,
    arrayRemove,
    collection,
    deleteDoc,
    doc,
    getDoc,
    getDocs, limit,
    query,
    setDoc,
    updateDoc,
    where
} from "firebase/firestore";
import { config } from "./../configs/config";
import BaseModel from "./base.model";
import FriendModel from "./friend.model";

class UserModel extends BaseModel {
    private static instance: UserModel;

    /**
     * 
     * Private constructor
     */
    private constructor(name: string) {
        super(name);
    }

    /**
     * 
     * @returns {UserModel} - the instance of the user model
     */
    public static getInstance(): UserModel {
        if (!this.instance) {
            this.instance = new UserModel(config.database_names.users);
        }
        return this.instance;
    }

    /**
     * Get the user collection
     * @returns {CollectionReference<DocumentData>} - the user collection
     */
    public getUserCollection(): CollectionReference<DocumentData> {
        return collection(this.db, config.database_names.users);
    }

    /**
     * Get a user doc by user id
     * @param {string} userId - the id of the user
     * @returns {DocumentReference<DocumentData>} - the data of the user with the given user id
     */
    public getUserDocById(userId: string): DocumentReference<DocumentData> {
        return doc(this.db, this.name, userId);
    }

    /**
     * Get all available users in the system
     * @returns {Promise<any[]>} - an list of users avaiable in the system
     */
    public async getAllUsers(): Promise<any[]> {
        const querySnapshot: QuerySnapshot<DocumentData> = await getDocs(this.getUserCollection());
        return await Promise.all(querySnapshot.docs.map(async (doc) => (await this.getUserById(doc.id))["username"]));
    }

    /**
     * Get all users whose names match a specific string
     * @param {string} userId - the id of the user
     * @param {string} searchString - the search string
     * @returns {Promise<any[]>} - an list of users whose names match a specific string
     */
    public async getUsersBySearchString(userId: string, searchString: string): Promise<any[]> {
        const usersRef = this.getCollection();
        const q = query(usersRef);
        const querySnapshot = await getDocs(q);
        const matchingDocs = querySnapshot.docs.filter((doc) => {
            const name = doc.get("name") as string;
            const username = doc.get("username") as string;
            // TODO: hardcode for POSTO, should manage this instead of hardcode
            return username != "posto" && doc.id != userId && name.toLowerCase().startsWith(searchString.toLowerCase());
        });
        return Promise.all(matchingDocs.map(async (doc) => {
            return {
                ...doc.data(), id: doc.id,
                friendship_status: await FriendModel.getInstance().getFrienshipStatus(userId, doc.id)
            }
        }));
    }

    /**
     * Get user by their id
     * @param {string} userId - id of user
     * @returns {Promise<DocumentData>} - the data of the user in the system
     */
    public async getUserById(userId: string): Promise<DocumentData> {
        // Get snapshot data
        let userSnapshot: DocumentSnapshot<DocumentData> = await getDoc(this.getUserDocById(userId));
        if (userSnapshot.exists()) {
            return { ...userSnapshot.data(), id: userId };
        }
        return null;
    }

    /**
     * Get metadata by their userId
     * @param {string} username 
     * @returns {Promise<DocumentData>} - the metadata of the user in the system
     */
    public async getMetadataByUserId(userId: string): Promise<DocumentData> {
        const user: DocumentData = await this.getUserById(userId);

        if (user.hasOwnProperty("metadata")) {
            return user["metadata"];
        }
        return null;
    }

    /**
     * Add a user to the database
     * @param {string} name - fullname of the user
     * @param {string} username - username of the user
     * @param {string} password - password of the user
     * @param {string} phone - phone number of the user
     * @param {Array} posts - empty array of the user's posts' id
     * @param {string} email - email of user
     * @returns {Promise<string>} - the id the user
     */
    public async addUser(userId: string, name: string, profileImage: string, username: string, password: string, phone: string, email: string): Promise<string> {
        // Initialize empty array for user posts
        let posts: Array<String> = new Array<String>();

        return setDoc(doc(this.db, this.name, userId), {
            name: name,
            profileImage,
            password,
            phone,
            username,
            posts,
            email,
            metadata: {

                is_onboard: true,
                has_posted_today: false,
                acknowledgedSquare: false,
                acknowledgedCampus: false,
                acknowledgedPlayground: false,
                acknowledged_terms_and_conditions: false

            }
        }).then(async (docRef) => {
            await FriendModel.getInstance().initialize_friend(userId);
            return userId; // Added succesfully
        });
    }

    /**
     * TODO: implement the function
     */
    public async deleteUserById(): Promise<void> {
        // TODO: implement the function
    }

    /**
     * User onboarded
     * @param {string} userId - user's id
     * @returns {Promise<void>}
     */
    public async onboarded(userId: string): Promise<void> {
        let userRef: DocumentReference<DocumentData> = this.getUserDocById(userId);
        let userSnapshot: DocumentSnapshot<DocumentData> = await getDoc(userRef);
        await updateDoc(userRef, { metadata: { ...userSnapshot.data()["metadata"], isOnboard: false } });
    }

    /**
     * User acknowledges square
     * @param {string} userId - user's id
     * @returns {Promise<void>}
     */
    public async acknowledgeSquare(userId: string): Promise<void> {
        let userRef: DocumentReference<DocumentData> = this.getUserDocById(userId);
        let userSnapshot: DocumentSnapshot<DocumentData> = await getDoc(userRef);

        await updateDoc(userRef, { metadata: { ...userSnapshot.data()["metadata"], acknowledgeSquare: true } });

    }

    /**
     * User acknowledges campus
     * @param {string} userId - user's id
     * @returns {Promise<void>}
     */
    public async acknowledgeCampus(userId: string): Promise<void> {
        let userRef: DocumentReference<DocumentData> = this.getUserDocById(userId);
        let userSnapshot: DocumentSnapshot<DocumentData> = await getDoc(userRef);

        await updateDoc(userRef, { metadata: { ...userSnapshot.data()["metadata"], acknowledgeCampus: true } });

    }

    /**
     * User acknowledges playground
     * @param {string} userId - user's id
     * @returns {Promise<void>}
     */
    public async acknowledgePlayground(userId: string): Promise<void> {
        let userRef: DocumentReference<DocumentData> = this.getUserDocById(userId);
        let userSnapshot: DocumentSnapshot<DocumentData> = await getDoc(userRef);

        await updateDoc(userRef, { metadata: { ...userSnapshot.data()["metadata"], acknowledgedPlayground: true } });
    }

    /**
     * User acknowledges terms and conditions, sets user.metadata.acknowledge_terms_and_conditions to true
     * @param {string} userId - user's id
     * @returns {Promise<void>}
     */
    public async acknowledgeTermsAndConditions(userId: string): Promise<void> {
        let userRef: DocumentReference<DocumentData> = this.getUserDocById(userId);
        let userSnapshot: DocumentSnapshot<DocumentData> = await getDoc(userRef);
        await updateDoc(userRef, { metadata: { ...userSnapshot.data()["metadata"], acknowledged_terms_and_conditions: true } });
    }

    /**
     * Update has posted today flag
     * @param {string} userId - the id of the user
     * @param {boolean} hasPostedToday - the flag indicating if the user has posted today
     * @returns {Promise<void>}
     */
    public async updatePostStatus(userId: string, hasPostedToday: boolean): Promise<void> {
        let userRef: DocumentReference<DocumentData> = this.getUserDocById(userId);
        let userSnapshot: DocumentSnapshot<DocumentData> = await getDoc(userRef);
        await updateDoc(userRef, { metadata: { ...userSnapshot.data()["metadata"], has_posted_today: hasPostedToday } });

    }

    /**
     * Get firebase messaging tokens of all devices that the users use
     * @param {string} email - email of the user
     * @returns {Promise<any[]>} - the data of the user in the system
     */
    public async getFcmToken(userId: string): Promise<any[]> {
        let userRef: DocumentReference<DocumentData> = this.getUserDocById(userId);
        let tokenCollectionRef: CollectionReference<DocumentData> = collection(userRef, "fcm_tokens");
        let tokenQuerySnapshot = await getDocs(tokenCollectionRef);
        return tokenQuerySnapshot.docs.map((doc) => doc.data()["token"]);
    }

    /**
    * Update profile image
    * @param {string} userId - the id of the user
    * @param {string} imgUrl - url of profile images
    * @returns {Promise<void>}
    */
    public async updateProfileImage(userId: string, imgUrl: string): Promise<void> {
        let userRef: DocumentReference<DocumentData> = this.getUserDocById(userId);
        await updateDoc(userRef, { profileImage: imgUrl });
    }

    /**
    * Update name
    * @param {string} userId - the id of the user
    * @param {string} name - name
    * @returns {Promise<void>}
    */
    public async updateName(userId: string, name: string): Promise<void> {
        let userRef: DocumentReference<DocumentData> = this.getUserDocById(userId);
        await updateDoc(userRef, { name: name });
    }

    /**
    * Update username
    * @param {string} userId - the id of the user
    * @param {string} username - username
    * @returns {Promise<void>}
    */
    public async updateUserName(userId: string, username: string): Promise<void> {
        let userRef: DocumentReference<DocumentData> = this.getUserDocById(userId);
        await updateDoc(userRef, { username: username });
    }

    /**
     * Get user by their username
     * @param {string} username 
     * @returns {Promise<DocumentData>} - the data of the user in the system
     */
    public async getUserByUsername(username: string): Promise<DocumentData> {
        const queriedUsers: Query<DocumentData> = query(this.getUserCollection(), where("username", "==", username), limit(1));
        const usersSnapshot: QuerySnapshot<DocumentData> = await getDocs(queriedUsers);
        if (usersSnapshot.docs.length > 0) {
            return usersSnapshot.docs.map((doc) => { return { ...doc.data(), id: doc.id } })[0];
        }
        return null;
    }

    /**
     * Get user by their email
     * @param {string} email - email of the user
     * @returns {Promise<any[]>} - the data of the user in the system
     */
    public async getUsernameByEmail(email: string): Promise<any[]> {
        const queriedUser: Query<DocumentData> = query(this.getUserCollection(), where("email", "==", email), limit(1));
        const usersSnapshot: QuerySnapshot<DocumentData> = await getDocs(queriedUser);
        if (usersSnapshot.docs.length > 0) {
            return usersSnapshot.docs.map((doc) => doc.data()["username"]);
        }
        return null;
    }

    /**
     * Get user by their email
     * @param {string} email - email of the user
     * @returns {Promise<any[]>} - the data of the user in the system
     */
    public async getNameByEmail(email: string): Promise<any[]> {
        const queriedUser: Query<DocumentData> = query(this.getUserCollection(), where("email", "==", email), limit(1));
        const usersSnapshot: QuerySnapshot<DocumentData> = await getDocs(queriedUser);
        if (usersSnapshot.docs.length > 0) {
            return usersSnapshot.docs.map((doc) => doc.data()["name"]);
        }
        return null;
    }

    /**
     * Get user by their email
     * @param {string} email - email of the user
     * @returns {Promise<any[]>} - the data of the user in the system
     */
    public async getProfileImageByEmail(email: string): Promise<any[]> {
        const queriedUser: Query<DocumentData> = query(this.getUserCollection(), where("email", "==", email), limit(1));
        const usersSnapshot: QuerySnapshot<DocumentData> = await getDocs(queriedUser);
        if (usersSnapshot.docs.length > 0) {
            return usersSnapshot.docs.map((doc) => doc.data()["profileImage"]);
        }
        return null;
    }

    /**
     * Get user by their email
     * @param {string} email - email of the user
     * @returns {Promise<string | null>} - the document ID of the user in the system, or null if not found
     */
    public async getUserIdByEmail(email: string): Promise<string | null> {
        const queriedUser: Query<DocumentData> = query(
            this.getUserCollection(),
            where("email", "==", email),
            limit(1)
        );
        const usersSnapshot: QuerySnapshot<DocumentData> = await getDocs(queriedUser);
        if (usersSnapshot.docs.length > 0) {
            return usersSnapshot.docs[0].id; // Return the document ID
        }
        return null;
    }

    /**
     * Delete user account
     * @param {string} userId - user id
     * @returns {Promise<void>}
     */
    public async deleteUserAccount(userId: string): Promise<void> {
        let userRef: DocumentReference<DocumentData> = this.getUserDocById(userId);
        let userSnapshot: DocumentSnapshot<DocumentData> = await getDoc(userRef);

        if (userSnapshot.exists()) {
            // Delete user account
            await deleteDoc(userRef);
        }
    }

    /**
     * Delete reference to a post
     * @param {string} userId - user id
     * @param {string} postId - post id
     * @returns {Promise<void>}
     */
    public async deleteRefToPost(userId: string, postId: string): Promise<void> {
        let userRef: DocumentReference<DocumentData> = this.getUserDocById(userId);
        let userSnapshot: DocumentSnapshot<DocumentData> = await getDoc(userRef);

        if (userSnapshot.exists()) {
            // Delete user account
            await updateDoc(userRef, { posts: arrayRemove(postId) });
        }
    }
}

export default UserModel;
