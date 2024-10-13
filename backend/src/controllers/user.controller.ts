import { Request, Response } from "express";
import BaseController from "../controllers/base.controller";
import { signinSchema, signupSchema } from "../schema/user.schema";
import { ServiceResponse } from "../services/base.service";

import { AcknowledgedSquareRes, AcknowledgedCampusRes, AcknowledgedPlaygroundRes, AcknowledgedTermsAndConditionsRes, GetUsersResponse, IsOnboardResponse, SignInResponse, SignUpResponse, UserService } from "../services/user.service";


class UserController extends BaseController {
    private userService: UserService;

    /**
     * Initialize UserController
     * @param userService 
     */
    public constructor(userService: UserService) {
        super();
        this.userService = userService;
    }

    /**
     * Set up the router of the controller
     */
    public setupRoutes(): void {
        // API: Sign up
        this.router.post("/signup", async (req: Request, res: Response) => {
            // Validate the request body data
            const { error } = signupSchema.validate(req.body);
            if (error) {
                // The request body doesn't match the expected format
                res.status(400).send({ message: error });
            } else {
                // The request body matches the expected format
                const { id, name, username, password, phone, email, profileImage } = req.body;
                const signupResponse: SignUpResponse = await this.userService.signup(id, name, profileImage, username, password, phone, email);
                if (signupResponse.success) {
                    res.send({
                        message: signupResponse.message, name: signupResponse.name, username: signupResponse.username,
                        id: signupResponse.id, profileImage: signupResponse.profileImage,
                        email: email
                    });
                } else {

                    if (signupResponse.error) {
                        // Some errors in database or so that we do not know in advance
                        res.status(500).send({ message: signupResponse.error.toString() });
                    } else {
                        // Not an error, but can't add the user (might alreay exist, .etc)
                        res.status(400).send({ message: signupResponse.message });
                    }
                }
            }
        });

        // API: Sign in
        this.router.post("/signin", async (req: Request, res: Response) => {
            // Validate the request body data
            const { error } = signinSchema.validate(req.body);
            if (error) {
                // The request body doesn't match the expected format
                res.status(400).send({ message: error });
            } else {
                // The request body matches the expected format
                const { username, password } = req.body;
                const signinResponse: SignInResponse = await this.userService.signin(username, password);

                if (signinResponse.success) {
                    res.send({
                        message: "Signin succesfully", name: signinResponse.name, username: signinResponse.username,
                        id: signinResponse.id, profileImage: signinResponse.profileImage
                    });
                } else {
                    if (signinResponse.error) {
                        // Some errors in database or so that we do not know in advance
                        res.status(500).send({ message: signinResponse.error.toString() });
                    } else {
                        // Not an error, but can't add the user (might alreay exist, .etc)
                        res.status(400).send({ message: signinResponse.message });
                    }
                }
            }
        });

        // API: Get all users
        this.router.get('/users', async (req: Request, res: Response) => {
            const getUsersResponse: GetUsersResponse = await this.userService.getAllUsers();
            if (getUsersResponse.success) {
                res.send({ message: getUsersResponse.message, users: getUsersResponse.users });
            } else {
                if (getUsersResponse.error) {
                    // Some errors in database or so that we do not know in advance
                    res.status(500).send({ message: getUsersResponse.error.toString() });
                } else {
                    // Not an error, but can't add the user (might alreay exist, .etc)
                    res.status(400).send({ message: getUsersResponse.message });
                }
            }
        });

        // API: Get user by id
        this.router.get('/user/:userId', async (req: Request, res: Response) => {
            const getUserResponse: GetUsersResponse = await this.userService.getUserById(req.params.userId);
            if (getUserResponse.success) {
                res.send({ message: getUserResponse.message, user: getUserResponse.user });
            } else {
                if (getUserResponse.error) {
                    // Some errors in database or so that we do not know in advance
                    res.status(500).send({ message: getUserResponse.error.toString() });
                } else {
                    // Not an error, but can't add the user (might alreay exist, .etc)
                    res.status(400).send({ message: getUserResponse.message });
                }
            }
        });

        // API: Check if username exists
        this.router.get('/username_exists/:username', async (req: Request, res: Response) => {
            const userExistsResponse: GetUsersResponse = await this.userService.usernameExists(req.params.username);
            if (userExistsResponse.success) {
                res.send({ message: userExistsResponse.message, user_exists: userExistsResponse.userExists });
            } else {
                if (userExistsResponse.error) {
                    // Some errors in database or so that we do not know in advance
                    res.status(500).send({ message: userExistsResponse.error.toString() });
                } else {
                    // Not an error, but can't add the user (might alreay exist, .etc)
                    res.status(400).send({ message: userExistsResponse.message });
                }
            }
        });

        // API: Get all users from search string
        this.router.get('/users/:userId/:str', async (req: Request, res: Response) => {
            const getUsersResponse: GetUsersResponse =
                await this.userService.getUsersBySearchString(req.params.userId, req.params.str);
            if (getUsersResponse.success) {
                res.send({ message: getUsersResponse.message, users: getUsersResponse.users });
            } else {
                if (getUsersResponse.error) {
                    // Some errors in database or so that we do not know in advance
                    res.status(500).send({ message: getUsersResponse.error.toString() });
                } else {
                    // Not an error, but can't add the user (might alreay exist, .etc)
                    res.status(400).send({ message: getUsersResponse.message });
                }
            }
        });

        // API: Check if the user is onboard
        this.router.get('/onboard/:userId', async (req: Request, res: Response) => {
            const response: IsOnboardResponse = await this.userService.isOnboard(req.params.userId);

            if (response.success) {
                res.send({ isOnboard: response.isOnboard });
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


        // API: Update onboard
        this.router.patch('/onboard', async (req: Request, res: Response) => {
            const { userId } = req.body;
            const response: ServiceResponse = await this.userService.onboarded(userId);

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

        // API: Check if the user has acknowledged the presence of the square tab

        this.router.get('/acknowledge-square/:userId', async (req: Request, res: Response) => {
            // const response: AcknowledgedSquareRes = await this.userService.hasAcknowledgedSquare(req.params.userId);

            // if (response.success) {
            //     res.send({ acknowledgeSquare: response.acknowledgeSquare });
            // } else {
            //     if (response.error) {
            //         // Some errors in database or so that we do not know in advance
            //         res.status(500).send({ message: response.error.toString() });
            //     } else {
            //         // Not an error, but can't retrieve the user (might not exist, etc.)
            //         res.status(400).send({ message: response.message });
            //     }
            // }
        });

        // API: Update acknowledge square

        this.router.patch('/acknowledged-square', async (req: Request, res: Response) => {
            // const { userId } = req.body;
            // const response: ServiceResponse = await this.userService.ack(userId);


            // if (response.success) {
            //     res.sendStatus(200);
            // } else {
            //     if (response.error) {
            //         // Some errors in database or so that we do not know in advance
            //         res.status(500).send({ message: response.error.toString() });
            //     } else {
            //         // Not an error, but can't retrieve the user (might not exist, etc.)
            //         res.status(400).send({ message: response.message });
            //     }
            // }
        });

        // API: Check if the user has acknowledged the presence of the playground tab

        this.router.get('/acknowledge-campus/:userId', async (req: Request, res: Response) => {
            // const response: AcknowledgedCampusRes = await this.userService.hasAcknowledgedCampus(req.params.userId);

            // if (response.success) {
            //     res.send({ acknowledgeCampus: response.acknowledgeCampus });

            // } else {
            //     if (response.error) {
            //         // Some errors in database or so that we do not know in advance
            //         res.status(500).send({ message: response.error.toString() });
            //     } else {
            //         // Not an error, but can't retrieve the user (might not exist, etc.)
            //         res.status(400).send({ message: response.message });
            //     }
            // }
            return null;
        });


        // API: Update acknowledge campus

        this.router.patch('/acknowledged-campus', async (req: Request, res: Response) => {
            // const { userId } = req.body;
            // const response: ServiceResponse = await this.userService.acknowledgedCampus(userId);


            // if (response.success) {
            //     res.sendStatus(200);
            // } else {
            //     if (response.error) {
            //         // Some errors in database or so that we do not know in advance
            //         res.status(500).send({ message: response.error.toString() });
            //     } else {
            //         // Not an error, but can't retrieve the user (might not exist, etc.)
            //         res.status(400).send({ message: response.message });
            //     }
            // }
            return null;
        });

        // API: Check if the user has acknowledged the presence of the playground tab

        this.router.get('/acknowledge-playground/:userId', async (req: Request, res: Response) => {
            // const response: AcknowledgedPlaygroundRes = await this.userService.hasAcknowledgedPlayground(req.params.userId);

            // if (response.success) {
            //     res.send({ acknowledgePlayground: response.acknowledgePlayground });

            // } else {
            //     if (response.error) {
            //         // Some errors in database or so that we do not know in advance
            //         res.status(500).send({ message: response.error.toString() });
            //     } else {
            //         // Not an error, but can't retrieve the user (might not exist, etc.)
            //         res.status(400).send({ message: response.message });
            //     }
            // }

            return null;
        });

        // API: Update acknowledge playground

        this.router.patch('/acknowledged-playground', async (req: Request, res: Response) => {
            // const { userId } = req.body;
            // const response: ServiceResponse = await this.userService.acknowledgedPlayground(userId);

            // if (response.success) {
            //     res.sendStatus(200);
            // } else {
            //     if (response.error) {
            //         // Some errors in database or so that we do not know in advance
            //         res.status(500).send({ message: response.error.toString() });
            //     } else {
            //         res.status(400).send({ message: response.message });
            //     }
            // }
            return null;
        });

        // API: Check if the user has acknowledged the terms and conditions
        this.router.get('/acknowledged-terms-and-conditions/:user_id', async (req: Request, res: Response) => {
            const response: AcknowledgedTermsAndConditionsRes = await this.userService.hasAcknowledgedTermsAndConditions(req.params.user_id);
        
            if (response.success) {
                res.send({ acknowledged_terms_and_conditions: response.acknowledgedTermsAndConditions });
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
        
        // API: Update acknowledge terms and conditions
        this.router.patch('/acknowledge-terms-and-conditions', async (req: Request, res: Response) => {
            const { user_id } = req.body;
            const response: ServiceResponse = await this.userService.acknowledgeTermsAndConditions(user_id);
        
            if (response.success) {
                res.sendStatus(200);
            } else {
                if (response.error) {
                    // Some errors in database or so that we do not know in advance
                    res.status(500).send({ message: response.error.toString() });
                } else {
                    res.status(400).send({ message: response.message });
                }
            }
        });

        // API: Update user profile pic
        this.router.put('/profile-pic-update/:userId/', async (req: Request, res: Response) => {
            const { img_url } = req.body;
            const response: ServiceResponse = await this.userService.updateProfileImage(req.params.userId, img_url);

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
        // API: Update user name
        this.router.put('/name-update/:userId/', async (req: Request, res: Response) => {
            const { name } = req.body;
            const response: ServiceResponse = await this.userService.updateName(req.params.userId, name);

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

        // API: Update user username
        this.router.put('/user-name-update/:userId/', async (req: Request, res: Response) => {
            const { username } = req.body;
            const response: ServiceResponse = await this.userService.updateUserName(req.params.userId, username);

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

        // API: Get user from email
        this.router.get('/email/:str', async (req: Request, res: Response) => {
            const getUsersResponse: GetUsersResponse = await this.userService.getUsernameByEmail(req.params.str);
            if (getUsersResponse.success) {
                res.send({ message: getUsersResponse.message, user: getUsersResponse.users });
            } else {
                if (getUsersResponse.error) {
                    // Some errors in database or so that we do not know in advance
                    res.status(500).send({ message: getUsersResponse.error.toString() });
                } else {
                    // Not an error, but can't retrieve the user (might not exist, etc.)
                    res.status(400).send({ message: getUsersResponse.message });
                }
            }
        });

        // API: Get pfp from email
        this.router.get('/name/:email', async (req: Request, res: Response) => {
            const getUsersResponse: GetUsersResponse = await this.userService.getNameByEmail(req.params.email);
            if (getUsersResponse.success) {
                res.send({ message: getUsersResponse.message, user: getUsersResponse.users[0] });
            } else {
                if (getUsersResponse.error) {
                    // Some errors in database or so that we do not know in advance
                    res.status(500).send({ message: getUsersResponse.error.toString() });
                } else {
                    // Not an error, but can't retrieve the user (might not exist, etc.)
                    res.status(400).send({ message: getUsersResponse.message });
                }
            }
        });

        // API: Get user from email
        this.router.get('/userid/:email', async (req: Request, res: Response) => {
            const getUsersResponse: GetUsersResponse = await this.userService.getUserIdByEmail(req.params.email);

            if (getUsersResponse.success) {
                res.send({ message: getUsersResponse.message, user: getUsersResponse.user });
            } else {
                if (getUsersResponse.error) {
                    // Some errors in database or so that we do not know in advance
                    res.status(500).send({ message: getUsersResponse.error.toString() });
                } else {
                    // Not an error, but can't retrieve the user (might not exist, etc.)
                    res.status(400).send({ message: getUsersResponse.message });
                }
            }
        });

        // API: Get pfp from email
        this.router.get('/pf-image/:email', async (req: Request, res: Response) => {
            const getUsersResponse: GetUsersResponse = await this.userService.getProfileImageByEmail(req.params.email);
            if (getUsersResponse.success) {
                res.send({ message: getUsersResponse.message, user: getUsersResponse.users[0] });
            } else {
                if (getUsersResponse.error) {
                    // Some errors in database or so that we do not know in advance
                    res.status(500).send({ message: getUsersResponse.error.toString() });
                } else {
                    // Not an error, but can't retrieve the user (might not exist, etc.)
                    res.status(400).send({ message: getUsersResponse.message });
                }
            }
        });

        // API: Delete user account
        this.router.get('/delete-user-account/:userId', async (req: Request, res: Response) => {
            const getUsersResponse: GetUsersResponse = await this.userService.deleteUserAccount(req.params.userId);
            if (getUsersResponse.success) {
                res.send({ message: getUsersResponse.message });
            } else {
                if (getUsersResponse.error) {
                    // Some errors in database or so that we do not know in advance
                    res.status(500).send({ message: getUsersResponse.error.toString() });
                } else {
                    // Not an error, but can't retrieve the user (might not exist, etc.)
                    res.status(400).send({ message: getUsersResponse.message });
                }
            }
        });
    }
}

export default UserController;
