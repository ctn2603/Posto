import { DocumentData } from "firebase/firestore";
import PostModel from "../models/post.model";
import UserModel from "../models/user.model";
import { ServiceResponse } from "./base.service";

interface GetPostsResponse extends ServiceResponse {
    posts?: any[];
}

interface AddPostResponse extends ServiceResponse {
}

interface LikeResponse extends ServiceResponse {
    postId?: String;
    userId?: String;
}

interface GetUsersLikedResponse extends ServiceResponse {
    usersLiked?: any[];
}

interface AddCommentResponse extends ServiceResponse {
    postId?: String;
}

interface GetArticleResponse extends ServiceResponse {
    url?: String;
}

interface DeletePostResponse extends ServiceResponse {
}

class PostService {
    protected userModel: UserModel;
    protected postModel: PostModel;

    /**
     * Initialize PostsService
     * @param {PostModel} postModel - the model that handles the posts
     * @param {UserModel} postModel - the model that handles the users
     */
    public constructor(postModel: PostModel, userModel: UserModel) {
        this.postModel = postModel;
        this.userModel = userModel;
    }

    /**
     * Get all available posts in the system
     * @returns {GetPostsResponse} - all available posts in the system
     */
    public async getAllPosts(): Promise<GetPostsResponse> {
        try {
            const posts: any[] = await this.postModel.getAllPosts();

            if (!posts.length) {
                // There aren't any posts in the system
                return { success: false, message: "posts are not available" };
            } else {
                return { success: true, message: "posts found", posts };
            }
        } catch (error) {
            return { success: false, error };
        }
    }

    /**
     * Get partial amount of posts
     * @param {string} lastPostId - last post id from previous batch of posts loaded
     * @returns {GetPostsResponse} - batch of posts that are loaded
     */
    public async getPartialPosts(lastPostId: string = null): Promise<GetPostsResponse> {
        try {
            let res: any = await this.postModel.getPartialPosts(lastPostId);

            if (!res.posts.length) {
                return { success: true, message: "no more posts are available", ...res };
            } else {
                return { success: true, message: "posts found", ...res };
            }
        } catch (error) {
            return { success: false, error };
        }
    }

    /**
     * Add a like to specific post
     * @param {string} postId - post id that like will be added to
     * @param {string} userId - user id
     * @returns {LikeResponse} - toggling like response
     */
    public async addLike(postId: string, userId: string): Promise<LikeResponse> {
        try {
            const post: DocumentData = await this.postModel.getPostById(postId);
            const user: DocumentData = await this.userModel.getUserById(userId);
            if (post) {
                // Post exists
                if (user) {
                    // User exists
                    await this.postModel.addLike(postId, userId);
                    return { success: true, message: "added like to: " + postId + " by: " + userId };
                } else {
                    return { success: false, message: "invalid user" };
                }
            } else {
                return { success: false, message: "invalid post" };
            }
        }
        catch (error) {
            return { success: false, error };
        }
    }

    /**
     * Remove a like from specific post
     * @param {string} postId - post id that like will be removed from
     * @param {string} userId - user id
     * @returns {LikeResponse} - toggling like response
     */
    public async removeLike(postId: string, userId: string): Promise<LikeResponse> {
        try {
            const post: DocumentData = await this.postModel.getPostById(postId);
            const user: DocumentData = await this.userModel.getUserById(userId);
            if (post) {
                // Post exists
                if (user) {
                    // User exists
                    await this.postModel.removeLike(postId, userId);
                    return { success: true, message: "removed like from: " + postId + " by: " + userId };
                } else {
                    return { success: false, message: "invalid user" };
                }
            } else {
                return { success: false, message: "invalid post" };
            }
        }
        catch (error) {
            return { success: false, error };
        }
    }

    /**
     * Remove a like from specific post
     * @param {string} postId - post id that like will be removed from
     * @returns {GetUsersLikedResponse} - array of users that liked specific post
     */
    public async getUsersLiked(postId: string): Promise<GetUsersLikedResponse> {
        try {
            const post: DocumentData = await this.postModel.getPostById(postId);
            if (post) {
                // Post exists
                const usersLiked: any[] = await this.postModel.getUsersLiked(postId);
                return { success: true, message: "users liked", usersLiked };
            } else {
                return { success: false, message: "invalid post" };
            }
        }
        catch (error) {
            return { success: false, error };
        }
    }

    /**
     * Add comment to specific post
     * @param {string} postId - post id that comment will be added to
     * @param {string} userId - user id of user who writes the comment
     * @param {string} comment - the text of the comment
     * @returns {AddCommentResponse} - response of adding a comment to specific post
     */
    public async addComment(postId: string, userId: string, comment: string): Promise<AddCommentResponse> {
        try {
            const post: DocumentData = await this.postModel.getPostById(postId);
            if (post) {
                // Post exists
                await this.postModel.addComment(postId, userId, comment);
                return { success: true, message: "added like to:", postId };
            } else {
                return { success: false, message: "invalid post" };
            }
        }
        catch (error) {
            return { success: false, error };
        }
    }

    /**
     * Get all posts of a user from their use if
     * @param {string} userId
     * @returns {GetPostsResponse} - array of posts
     */
    public async getPostsByUserId(userId: string): Promise<GetPostsResponse> {
        try {
            const posts: any[] = await this.postModel.getPostsByUserId(userId);
            return { success: true, message: "posts found", posts };
        } catch (error) {
            return { success: false, error };
        }
    }

    /**
     * Delete a specific post of a user
     * @param {string} userId - user id of user who creates the post
     * @param {string} postId - post id to be deleted
     * @returns {AddCommentResponse} - response of adding a comment to specific post
     */
    public async deletePost({
        userId,
        postId
    }: {
        userId: string,
        postId: string
    }): Promise<DeletePostResponse> {
        try {
            await this.postModel.deletePost(postId);
            await this.userModel.deleteRefToPost(userId, postId);
            return { success: true, message: "post deleted" };
        }
        catch (error) {
            return { success: false, message: "failed to delete post" };
        }
    }
}

export {
    AddCommentResponse, AddPostResponse, GetArticleResponse, GetPostsResponse, GetUsersLikedResponse, LikeResponse, PostService
};


