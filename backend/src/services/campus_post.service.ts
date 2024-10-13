import { DocumentData } from "firebase/firestore";
import CampusPostModel from "./../models/campus_post.model";
import PostModel from "./../models/post.model";
import UserModel from "./../models/user.model";
import { AddPostResponse, GetArticleResponse, PostService } from "./post.service";

class CampusPostService extends PostService {
    /**
     * Initialize PostsService
     * @param {PlaygroundPostModel} postModel - the model that handles the posts
     * @param {UserModel} postModel - the model that handles the users
     */
    public constructor(postModel: PostModel, userModel: UserModel) {
        super(postModel, userModel);
    }

    /**
     * Add post to database
     * @param {string} articleUrl - url of the article
     * @param {string} thumbnailUrl - thumbnail url
     * @param {string} userId - user id
     * @returns {AddPostResponse} - adding post to database response
     */
    public async addPost({
        articleUrl,
        thumbnailUrl,
        userId,
        caption
    }: {
        articleUrl: string,
        thumbnailUrl: string,
        userId: string,
        caption: string
    }): Promise<AddPostResponse> {
        try {
            await (this.postModel as CampusPostModel).addPost(articleUrl, thumbnailUrl, userId, caption);
            return { success: true, message: "added post" };

            // const user: DocumentData = await this.userModel.getUserById(userId);
            // if (user) {
            //     // User exists
            //     await (this.postModel as CampusPostModel).addPost(articleUrl, userId, caption);
            //     return { success: true, message: "added post" };
            // } else {
            //     return { success: false, message: "invalid user" };
            // }
        }
        catch (error) {
            return { success: false, error };
        }
    }

    /**
     * Get article link
     * @param {string} postId - post id 
     * @returns {GetArticleResponse} - article url
     *
    */
    public async getArticleLink(postId: string): Promise<GetArticleResponse> {
        try {
            const post: DocumentData = await this.postModel.getPostById(postId);
            if (post) {
                // Post exists
                const url: String = await (this.postModel as CampusPostModel).getArticleLink(postId);
                return { success: true, message: "url:", url };
            } else {
                return { success: false, message: "invalid post" };
            }
        }
        catch (error) {
            return { success: false, error };
        }
    }
}

export default CampusPostService;