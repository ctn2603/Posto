import { Request, Response } from "express";
import { GetPostsResponse, PostService } from "../services/post.service";
import SquarePostService from "./../services/square_post.service";
import PostController from "./post.controller";

class SquarePostController extends PostController {
    /**
     * Initialize SquarePostController
     * @param postService 
     */
    public constructor(postService: PostService) {
        super(postService);
    }

    /**
     * Set up the router of the controller
     */
    public setupRoutes(): void {
        super.setupRoutes();

        this.router.post('/add-post', async (req: Request, res: Response) => {
            const { imageUrl, userId, caption } = req.body;
            const addPostResponse: GetPostsResponse =
                await (this.postService as SquarePostService).addPost({ imageUrl, userId, caption });

            if (addPostResponse.success) {
                res.send({ message: "post added" });
            } else {
                if (addPostResponse.error) {
                    // Some errors in database or so that we do not know in advance
                    res.status(500).send({ message: addPostResponse.error.toString() });
                } else {
                    // Not an error, but can't add the post  
                    res.status(400).send({ message: addPostResponse.message });
                }
            }
        });

        // API: Get partial posts by time and not created by user with a last post id (called initially)
        this.router.get('/posts/not-by-user/:time/:username', async (req: Request, res: Response) => {
            const userName: string = req.params.username as string;
            const time: string = req.params.time as string;

            const getPostsResponse: any = await (this.postService as SquarePostService).getPartialPostsNotByUser(userName, time);

            if (getPostsResponse.success) {
                // Sending message, the posts, the last post id for pagination, and boolean that holds whether there are more posts in the database or not
                res.send({ message: getPostsResponse.message, posts: getPostsResponse.posts, lastPostId: getPostsResponse.lastPostId, hasMorePosts: getPostsResponse.hasMorePosts });
            } else {
                if (getPostsResponse.error) {
                    // Some errors in database or so that we do not know in advance
                    res.status(500).send({ message: getPostsResponse.error.toString() });
                } else {
                    res.status(400).send({ message: getPostsResponse.message });
                }
            }
        });

        // API: Get partial posts by time and not created by user with a last post id (called after scrolling for a bit)
        this.router.get('/posts/not-by-user/:time/:username/:lastPostId', async (req: Request, res: Response) => {
            const lastPostId: string = req.params.lastPostId as string;
            const userName: string = req.params.username as string;
            const time: string = req.params.time as string;

            const getPostsResponse: any = await (this.postService as SquarePostService).getPartialPostsNotByUser(userName, time, lastPostId);

            if (getPostsResponse.success) {
                // Sending message, the posts, the last post id for pagination, and boolean that holds whether there are more posts in the database or not
                res.send({ message: getPostsResponse.message, posts: getPostsResponse.posts, lastPostId: getPostsResponse.lastPostId, hasMorePosts: getPostsResponse.hasMorePosts });
            } else {
                if (getPostsResponse.error) {
                    // Some errors in database or so that we do not know in advance
                    res.status(500).send({ message: getPostsResponse.error.toString() });
                } else {
                    res.status(400).send({ message: getPostsResponse.message });
                }
            }
        });
    }
}

export default SquarePostController;