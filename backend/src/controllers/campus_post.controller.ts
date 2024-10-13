import { Request, Response } from "express";
import { GetPostsResponse, PostService } from "../services/post.service";
import CampusPostService from "./../services/campus_post.service";
import PostController from "./post.controller";

class CampusPostController extends PostController {
    /**
     * Initialize CampusPostController
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
            const { articleUrl, thumbnailUrl, userId, caption } = req.body;
            const addPostResponse: GetPostsResponse =
                await (this.postService as CampusPostService).addPost({
                    articleUrl: articleUrl,
                    thumbnailUrl: thumbnailUrl,
                    userId: userId,
                    caption: caption
                });

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

        // API: get the article link of post
        this.router.get('/article-url/:postId', async (req: Request, res: Response) => {
            const getArticleResponse: any
                = await (this.postService as CampusPostService).getArticleLink(req.params.postId);

            if (getArticleResponse.success) {
                res.send({ message: getArticleResponse.message, url: getArticleResponse.url });
            } else {
                if (getArticleResponse.error) {
                    // Some errors in database or so that we do not know in advance
                    res.status(500).send({ message: JSON.stringify(getArticleResponse.error) });
                } else {
                    // Not an error, but can't get link 
                    res.status(400).send({ message: getArticleResponse.message });
                }
            }
        });
    }
}

export default CampusPostController;