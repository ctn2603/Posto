import { DocumentData, DocumentReference, DocumentSnapshot, addDoc, getDoc, serverTimestamp } from "firebase/firestore";
import { config } from "./../configs/config";
import PostModel from "./post.model";
import UserModel from "./user.model";

class PlaygroundPostModel extends PostModel {
    private static instance: PlaygroundPostModel;

    private constructor(name: string) {
        super(name);
    }

    public static getInstance(): PlaygroundPostModel {
        if (!this.instance) {
            this.instance = new PlaygroundPostModel(config.database_names.playground_posts);
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

        // Combine all necessary fields of the post object
        let post: any = {
            ...snapShotData,
            postId,
            createdAt: new Date(snapShotData["createdAt"].seconds * 1000).toISOString()
        };
        return post;
    }

    /**
     * Add a specific post from a user
     * @param {string} imageUrl - the url of the image
     * @param {string} userId - the id of the user
     * @returns {Promise<string>} 
     */
    public async addPost(imageUrl: string, userId: string): Promise<string> {
        const likes: number = 0;
        // const user: DocumentData = await UserModel.getInstance().getUserById(userId);
        // const username: string = user.username;
        // const name: string = user.name;
        // const userRef: DocumentReference<DocumentData> = UserModel.getInstance().getUserDocById(userId);

        const docRef = await addDoc(this.getCollection(), {
            imageUrl,
            // username,
            // name,
            // profileImageRef: userRef,
            likes,
            usersLiked: new Array<any>(),
            createdAt: serverTimestamp()
        });
        
        // TODO: Users collection or something else have to reference to this post id
        return docRef.id; // Added succesfully
    }
}

export default PlaygroundPostModel;
