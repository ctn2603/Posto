import { Request, Response } from "express";
import { GetPostsResponse, PostService } from "../services/post.service";
import PlaygroundPostService from "./../services/playground_post.service";
import PostController from "./post.controller";

class PlaygroundPostController extends PostController {
    /**
     * Initialize PlaygroundPostController
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
                const { imageUrl, userId } = req.body;
                const addPostResponse: GetPostsResponse =
                    await (this.postService as PlaygroundPostService).addPost({ imageUrl, userId });

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
            }
        );
    }
}

export default PlaygroundPostController;