


import { Request, Response } from "express";
import BaseController from "../controllers/base.controller";
import { ExtResService, MetadataResponse } from "../services/ext_res.service";

class ExtResController extends BaseController {
    private extResService: ExtResService;

    /**
     * Initialize ExtResController
     * @param extResService 
     */
    public constructor(extResService: ExtResService) {
        super();
        this.extResService = extResService;
    }

    /**
     * Set up the router of the controller
     */
    public setupRoutes(): void {
        // API: Sign up
        this.router.get("/scrape-link-metadata/:url", async (req: Request, res: Response) => {
            const response: MetadataResponse = await this.extResService.scrapeMetadata(req.params.url);
            if (response.success) {
                res.send({ message: response.message, title: response.title, thumbnailUrl: response.thumbnailUrl });
            } else {
                if (response.error) {
                    // Some errors in database or so that we do not know in advance
                    res.status(500).send({ message: response.error.toString() });
                } else {
                    // Not an error, but can't add the user (might alreay exist, .etc)
                    res.status(400).send({ message: response.message });
                }
            }
        });
    }
}

export default ExtResController;
