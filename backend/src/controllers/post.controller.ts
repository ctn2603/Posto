import { Request, Response } from "express";
import { GetPostsResponse, PostService } from "../services/post.service";
import BaseController from "./base.controller";

abstract class PostController extends BaseController {
    protected postService: PostService;

    /**
     * Initialize PostController
     * @param postService 
     */
    public constructor(postService: PostService) {
        super();
        this.postService = postService;
    }

    public setupRoutes(): void {
        // API: Get partial posts (first batch)
        this.router.get('/posts/', async (req: Request, res: Response) => {
            const getPostsResponse: any = await this.postService.getPartialPosts(req.params.time);
            if (getPostsResponse.success) {
                res.send({ message: getPostsResponse.message, posts: getPostsResponse.posts, lastPostId: getPostsResponse.lastPostId });
            } else {
                if (getPostsResponse.error) {
                    // Some errors in database or so that we do not know in advance
                    res.status(500).send({ message: getPostsResponse.error.toString() });
                } else {
                    res.status(400).send({ message: getPostsResponse.message });
                }
            }
        });

        // API: Get partial posts after loading initial posts (currently not in use)
        this.router.get('/posts/:lastPostId', async (req: Request, res: Response) => {
            const getPostsResponse: any = await this.postService.getPartialPosts(req.params.lastPostId);
            if (getPostsResponse.success) {
                res.send({ message: getPostsResponse.message, posts: getPostsResponse.posts, lastPostId: getPostsResponse.lastPostId });
            } else {
                if (getPostsResponse.error) {
                    // Some errors in database or so that we do not know in advance
                    res.status(500).send({ message: getPostsResponse.error.toString() });
                } else {
                    res.status(400).send({ message: getPostsResponse.message });
                }
            }
        });

        // API: Get all posts by userId
        this.router.get('/user-posts/:userId', async (req: Request, res: Response) => {
            const getPostsResponse: GetPostsResponse = await this.postService.getPostsByUserId(req.params.userId);

            if (getPostsResponse.success) {
                res.send({ message: getPostsResponse.message, posts: getPostsResponse.posts });
            } else {
                if (getPostsResponse.error) {
                    // Some errors in database or so that we do not know in advance
                    res.status(500).send({ message: getPostsResponse.error.toString() });
                } else {
                    // Not an error, but can't add the user (might alreay exist, .etc)
                    res.status(400).send({ message: getPostsResponse.message });
                }
            }
        });

        // API: add one more like to the user's post
        this.router.patch('/add-like/:postId', async (req: Request, res: Response) => {
            const { userId } = req.body;
            const postId = req.params.postId;
            const addLikeResponse: any = await this.postService.addLike(postId, userId);

            if (addLikeResponse.success) {
                res.send({ message: "like added by: " + userId });
            } else {
                if (addLikeResponse.error) {
                    // Some errors in database or so that we do not know in advance
                    res.status(500).send({ message: addLikeResponse.error.toString() });
                } else {
                    // Not an error, but can't add the post  
                    res.status(400).send({ message: addLikeResponse.message });
                }
            }
        });

        // API: remove one more like from the user's post
        this.router.patch('/remove-like/:postId', async (req: Request, res: Response) => {
            const { userId } = req.body;
            const postId = req.params.postId;
            const removeLikeResponse: any = await this.postService.removeLike(postId, userId);

            if (removeLikeResponse.success) {
                res.send({ message: "like removed by: " + userId });
            } else {
                if (removeLikeResponse.error) {
                    // Some errors in database or so that we do not know in advance
                    res.status(500).send({ message: JSON.stringify(removeLikeResponse.error) });
                } else {
                    // Not an error, but can't add the post  
                    res.status(400).send({ message: removeLikeResponse.message });
                }
            }
        });

        // API: get the user ids of all users who have liked a post
        this.router.get('/users-liked/:postId', async (req: Request, res: Response) => {
            const getUsersLikedResponse: any = await this.postService.getUsersLiked(req.params.postId);
            if (getUsersLikedResponse.success) {
                res.send({ message: getUsersLikedResponse.message, usersLiked: getUsersLikedResponse.usersLiked });
            } else {
                if (getUsersLikedResponse.error) {
                    // Some errors in database or so that we do not know in advance
                    res.status(500).send({ message: JSON.stringify(getUsersLikedResponse.error) });
                } else {
                    // Not an error, but can't add the post  
                    res.status(400).send({ message: getUsersLikedResponse.message });
                }
            }
        });

        // API: add a comment to the user's post
        this.router.patch('/add-comment/:postId', async (req: Request, res: Response) => {
            const { userId, comment } = req.body;
            const postId: string = req.params.postId;
            const addCommentResponse: any = await this.postService.addComment(postId, userId, comment);

            if (addCommentResponse.success) {
                res.send({ message: "comment added" });
            } else {
                if (addCommentResponse.error) {
                    // Some errors in database or so that we do not know in advance
                    res.status(500).send({ message: addCommentResponse.error.toString() });
                } else {
                    // Not an error, but can't add the post  
                    res.status(400).send({ message: addCommentResponse.message });
                }
            }
        });

        // API: delete a post based on user id and post id
        this.router.delete('/delete-post/users/:userId/posts/:postId', async (req: Request, res: Response) => {
            const userId: string = req.params.userId;
            const postId: string = req.params.postId;
            const deletePostResponse: any = await this.postService.deletePost({ userId: userId, postId: postId });

            if (deletePostResponse.success) {
                res.send({ message: "post deleted" });
            } else {
                if (deletePostResponse.error) {
                    // Some errors in database or so that we do not know in advance
                    res.status(500).send({ message: deletePostResponse.error.toString() });
                } else {
                    // Not an error, but can't add the post  
                    res.status(400).send({ message: deletePostResponse.message });
                }
            }
        });
    }
}

export default PostController;
