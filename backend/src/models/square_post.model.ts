import {
    DocumentData,
    DocumentReference,
    DocumentSnapshot,
    addDoc,
    arrayUnion,
    deleteDoc,
    getDoc,
    serverTimestamp,
    updateDoc
} from "firebase/firestore";

import { config } from "./../configs/config";
import PostModel from "./post.model";
import UserModel from "./user.model";

class SquarePostModel extends PostModel {
    private static instance: SquarePostModel;

    private constructor(name: string) {
        super(name);
    }

    public static getInstance(): SquarePostModel {
        if (!this.instance) {
            this.instance = new SquarePostModel(config.database_names.square_posts);
        }
        return this.instance;
    }

    /**
     * Get a post by id
     * @param {string} postId - the id of the post
     */
    public async getPostById(postId: string): Promise<DocumentData> {
        // Get snapshot data
        let postSnapshot: DocumentSnapshot<DocumentData> = await getDoc(this.getDocById(postId));
        let snapShotData: DocumentData = postSnapshot.data();

        if (!snapShotData) {
            return null;
        }

        // Format returned profile image of the owner, not returning document reference (pointer) but actual data
        let owner: any = (await getDoc(snapShotData.profileImageRef)).data();
        delete snapShotData["profileImageRef"];

        // Combine all necessary fields of the post object
        let post: any = {
            ...snapShotData,
            profileImageUrl: owner.profileImage,
            postId,
            userId: owner.id,
            createdAt: new Date(snapShotData["createdAt"].seconds * 1000).toISOString()
        };
        return post;
    }

    /**
     * Delete a post
     * @param {string} postId - post id
     * @returns {Promise<void>}
     */
    public async deletePost(postId: string): Promise<void> {
        let postRef: DocumentReference<DocumentData> = this.getDocById(postId);
        await deleteDoc(postRef);
    }

    /**
     * Delete a list of posts based on user id
     * @param {string} userId - user id
     * @returns {Promise<void>}
     */
    public async deletePostsOf(userId: string): Promise<void> {
        let userRef: DocumentReference<DocumentData> = UserModel.getInstance().getUserDocById(userId);
        let userSnapshot: DocumentSnapshot<DocumentData> = await getDoc(userRef);

        if (userSnapshot.exists()) {
            let userData: any = userSnapshot.data();
            let postIds: string[] = userData["posts"];
            await Promise.all(postIds.map(async postId => {
                (await this.deletePost(postId))
            }));
        }
    }

    /**
     * Add a specific post from a user
     * @param {string} imageUrl - the url of the image
     * @param {string} userId - the id of the user
     * @param {string} caption - the caption of the post
     * @returns {Promise<string>} 
     */
    public async addPost(imageUrl: string, userId: string, caption: string): Promise<string> {
        const likes: number = 0;
        const user: DocumentData = await UserModel.getInstance().getUserById(userId);
        const username: string = user.username;
        const name: string = user.name;
        const userRef: DocumentReference<DocumentData> = UserModel.getInstance().getUserDocById(userId);

        const docRef = await addDoc(this.getCollection(), {
            imageUrl,
            username,
            name,
            profileImageRef: userRef,
            caption,
            likes,
            usersLiked: new Array<any>(),
            createdAt: serverTimestamp()
        });

        await updateDoc(userRef, {
            posts: arrayUnion(docRef.id)
        })
        return docRef.id; // Added succesfully
    }
}

export default SquarePostModel;