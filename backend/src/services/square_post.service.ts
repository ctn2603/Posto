import { DocumentData } from "firebase/firestore";
import PostModel from "./../models/post.model";
import SquarePostModel from "./../models/square_post.model";
import UserModel from "./../models/user.model";
import { AddPostResponse, GetPostsResponse, PostService } from "./post.service";

class SquarePostService extends PostService {
    /**
     * Initialize PostsService
     * @param {SquarePostModel} postModel - the model that handles the posts
     * @param {UserModel} postModel - the model that handles the users
     */
    public constructor(postModel: PostModel, userModel: UserModel) {
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
        userId,
        caption
    }: {
        imageUrl: string,
        userId: string,
        caption: string
    }): Promise<AddPostResponse> {
        try {
            const user: DocumentData = await this.userModel.getUserById(userId);
            if (user) {
                // User exists
                await (this.postModel as SquarePostModel).addPost(imageUrl, userId, caption);
                return { success: true, message: "added post" };
            } else {
                return { success: false, message: "invalid user" };
            }
        }
        catch (error) {
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
                // There aren't any posts in the system
                res.posts = this.filterOutExpiredPosts(res.posts);
                return { success: true, message: "no more posts are available", ...res };
            } else {
                return { success: true, message: "posts found", ...res };
            }
        } catch (error) {
            return { success: false, error };
        }
    }

    private filterOutExpiredPosts(posts: any[]) : any[] {
        let expiredPosts: any[] = [],
        unexpiredPosts: any[] = [],
        now = new Date(),
        creationDate : Date = null,
        expiryDate: Date = null;
        const oneDayInMilliseconds = 24 * 60 * 60 * 1000;

        // Filter posts
        posts.forEach((post, index) => {
            creationDate = post.createdAt.toDate();
            expiryDate = new Date(creationDate.getTime() + oneDayInMilliseconds);

            if (now >= expiryDate) {
                expiredPosts.push(post);
            } else {
                unexpiredPosts.push(post);
            }
        });

        // Delete the expired posts;
        if (expiredPosts.length > 0) {
            expiredPosts.forEach((post) => {
                this.postModel.removePostById(post.postId);
            });
        }

        return unexpiredPosts;
    }

    /**
     * Get partial amount of posts that are not created by user (based by timezone)
     * @param {string} userName - username of user of which we don't want posts from
     * @param {string} lastPostId - last post id from previous batch of posts loaded
     * @param {string} time - Timezone of the user involved
     * @returns {GetPostsResponse} - batch of posts that are loaded
     */
    public async getPartialPostsNotByUser(userName: string = null, time: string = null, lastPostId: string = null): Promise<GetPostsResponse> {
        try {
            const res: any = await this.postModel.getPartialPostsNotByUser(userName, lastPostId, time);

            if (!res.posts.length) {
                // There aren't any posts in the system
                return { success: true, message: "no more posts are available", ...res, hasMorePosts: res.hasMorePosts };
            } else {
                // Filter out posts created by user
                const filteredPosts = {
                    ...res,
                    posts: res.posts.filter((post: any) => post.username !== userName)
                };

                return { success: true, message: "posts found", ...filteredPosts, hasMorePosts: res.hasMorePosts };
            }
        } catch (error) {
            return { success: false, error };
        }
    }
}

export default SquarePostService;