import { Request, Response } from "express";
import { FriendService } from "../services/friend.service";
import BaseController from "./base.controller";

class FriendController extends BaseController {
    private friendService: FriendService;

    /**
     * Initialize Friend Controller
     * @param requestService 
     */
    public constructor(requestService: FriendService) {
        super();
        this.friendService = requestService;
    }

    /**
     * Set up the router of the controller
     */
    public setupRoutes(): void {
        //API: Get user's friends
        this.router.get('/connections/:userId', async (req: Request, res: Response) => {
            const response: any = await this.friendService.getFriends(req.params.userId);
            if (response.success) {
                res.send({ friends: response.friends });
            } else {
                if (response.error) {
                    // Some errors in database or so that we do not know in advance
                    res.status(500).send({ message: response.error.toString() });
                } else {
                    // Not an error, but can't retrieve the user (might not exist, etc.)
                    res.status(400).send({ message: response.message });
                }
            }
        })

        //API: Get user's in friend request
        this.router.get('/friend-requests-received/:userId', async (req: Request, res: Response) => {
            const response: any = await this.friendService.getFriendRequestsReceived(req.params.userId);

            if (response.success) {
                res.send({ friend_requests_received: response.friend_requests_received });
            } else {
                if (response.error) {
                    // Some errors in database or so that we do not know in advance
                    res.status(500).send({ message: response.error.toString() });
                } else {
                    // Not an error, but can't retrieve the user (might not exist, etc.)
                    res.status(400).send({ message: response.message });
                }
            }
        });

        //API: Get user's friends
        this.router.get('/friend-requests-sent/:userId', async (req: Request, res: Response) => {
            const response: any = await this.friendService.getFriendRequestsSent(req.params.userId);
            if (response.success) {
                res.send({ friend_requests_sent: response.friend_requests_sent });
            } else {
                if (response.error) {
                    // Some errors in database or so that we do not know in advance
                    res.status(500).send({ message: response.error.toString() });
                } else {
                    // Not an error, but can't retrieve the user (might not exist, etc.)
                    res.status(400).send({ message: response.message });
                }
            }
        });

        // API: Send friend request
        this.router.post('/request-connection', async (req: Request, res: Response) => {
            const { senderId, receiverId } = req.body;
            const response: any = await this.friendService.friendRequest(senderId, receiverId);
            if (response.success) {
                res.sendStatus(200);
            } else {
                if (response.error) {
                    // Some errors in database or so that we do not know in advance
                    res.status(500).send({ message: response.error.toString() });
                } else {
                    // Not an error, but can't retrieve the user (might not exist, etc.)
                    res.status(400).send({ message: response.message });
                }
            }
        });

        // API: Send friend request
        this.router.post('/accept-connection', async (req: Request, res: Response) => {
            const { senderId, receiverId } = req.body;
            const response: any = await this.friendService.acceptFriendRequest(senderId, receiverId);

            if (response.success) {
                res.sendStatus(200);
            } else {
                if (response.error) {
                    // Some errors in database or so that we do not know in advance
                    res.status(500).send({ message: response.error.toString() });
                } else {
                    // Not an error, but can't retrieve the user (might not exist, etc.)
                    res.status(400).send({ message: response.message });
                }
            }
        });

        // API: Send friend request
        this.router.post('/delete-connection', async (req: Request, res: Response) => {
            const { senderId, receiverId } = req.body;
            const response: any = await this.friendService.deleteFriendRequest(senderId, receiverId);

            if (response.success) {
                res.sendStatus(200);
            } else {
                if (response.error) {
                    // Some errors in database or so that we do not know in advance
                    res.status(500).send({ message: response.error.toString() });
                } else {
                    // Not an error, but can't retrieve the user (might not exist, etc.)
                    res.status(400).send({ message: response.message });
                }
            }
        });
    }
}

export default FriendController;
