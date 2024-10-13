import { DocumentData } from "firebase/firestore";
import PlaygroundPostModel from "./../models/playground_post.model";
import UserModel from "./../models/user.model";
import { AddPostResponse, PostService } from "./post.service";

class PlaygroundPostService extends PostService {
    /**
     * Initialize PostsService
     * @param {PlaygroundPostModel} postModel - the model that handles the posts
     * @param {UserModel} postModel - the model that handles the users
     */
    public constructor(postModel: PlaygroundPostModel, userModel: UserModel) {
        super(postModel, userModel);
    }

    /**
     * Add post to database
     * @param {string} imageUrl - url of user's post
     * @param {string} userId - user id
     * @returns {AddPostResponse} - adding post to database response
     */
    public async addPost({
        imageUrl,
        userId
    }: {
        imageUrl: string,
        userId: string,
    }): Promise<AddPostResponse> {
        try {
            await (this.postModel as PlaygroundPostModel).addPost(imageUrl, userId);
            return { success: true, message: "added post" };

            // const user: DocumentData = await this.userModel.getUserById(userId);
            // if (user) {
            //     // User exists
            //     await (this.postModel as PlaygroundPostModel).addPost(imageUrl, userId);
            //     return { success: true, message: "added post" };
            // } else {
            //     return { success: false, message: "invalid user" };
            // }
        }
        catch (error) {
            return { success: false, error };
        }
    }
}

export default PlaygroundPostService;