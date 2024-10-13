import {
    DocumentData,
    DocumentReference,
    DocumentSnapshot,
    addDoc,
    getDoc,
    serverTimestamp
} from "firebase/firestore";

import { config } from "./../configs/config";
import PostModel from "./post.model";
// import UserModel from "./user.model";

class CampusPostModel extends PostModel {
    private static instance: CampusPostModel;

    private constructor(name: string) {
        super(name);
    }

    public static getInstance(): CampusPostModel {
        if (!this.instance) {
            this.instance = new CampusPostModel(config.database_names.campus_posts);
        }
        return this.instance;
    }

    /**
     * Add a specific post from a user
     * @param {string} articleUrl - the url of the image
     * @param {string} thumbnailUrl - the url of the image
     * @param {string} userId - the id of the user
     * @param {string} caption - the caption of the post
     * @returns {Promise<string>} 
     */
    public async addPost(articleUrl: string, thumbnailUrl: string, userId: string, caption: string): Promise<string> {
        const likes: number = 0;
        // const user: DocumentData = await UserModel.getInstance().getUserById(userId);
        // const username: string = user.username;
        // const name: string = user.name;
        // const userRef: DocumentReference<DocumentData> = UserModel.getInstance().getUserDocById(userId);
        const docRef = await addDoc(this.getCollection(), {
            articleUrl,
            thumbnailUrl,
            // username,
            // name,
            // profileImageRef: userRef,
            caption,
            likes,
            usersLiked: new Array<any>(),
            createdAt: serverTimestamp()
        });

        // TODO: Users collection or something else have to reference to this post id
        return docRef.id; // Added succesfully
    }

    /**
    * Get article link of specific campus post
    * @param {string} postId - the post id string
    * @returns {Promise<String>} - the url of the linked article
    */
    public async getArticleLink(postId: string): Promise<String> {
        const postDoc: DocumentReference<DocumentData> = await this.getDocById(postId);
        const postSnap: DocumentSnapshot<DocumentData> = await getDoc(postDoc);
        const articleLink: string = postSnap.data()['articleLink'];
        return articleLink;
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

        // Combine all necessary fields of the post object
        let post: any = {
            ...snapShotData,
            postId,
            createdAt: new Date(snapShotData["createdAt"].seconds * 1000).toISOString()
        };
        return post;
    }
}

export default CampusPostModel;