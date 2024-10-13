import cors from "cors";
import express, { Express } from "express";
import swaggerUi from "swagger-ui-express";

import BaseController from "./controllers/base.controller";
import CampusPostController from "./controllers/campus_post.controller";
import ExtResController from "./controllers/ext_res.controller";
import FriendController from "./controllers/friend.controller";
import PlaygroundPostController from "./controllers/playground_post.controller";
import SquarePostController from "./controllers/square_post.controller";
import UserController from "./controllers/user.controller";
import CampusPostModel from "./models/campus_post.model";
import FirebaseAdmin from "./models/firebase_admin";
import FriendModel from "./models/friend.model";
import PlaygroundPostModel from "./models/playground_post.model";
import SquarePostModel from "./models/square_post.model";
import UserModel from "./models/user.model";
import CampusPostService from "./services/campus_post.service";
import { ExtResService } from "./services/ext_res.service";
import { FriendService } from "./services/friend.service";
import PlaygroundPostService from "./services/playground_post.service";
import SquarePostService from "./services/square_post.service";
import { UserService } from "./services/user.service";
import * as swaggerSettings from "./swagger.json";

class App {
    private app: Express;

    /**
     * Initialize the app
     */
    public constructor() {
        this.app = express();
        this.configureApp();
    }

    /**
     * Setup a specitic router
     * @param {string} path - the URI for the router
     * @param {BaseController} controller - a specific controller
     */
    private setupRouter(path: string, controller: BaseController) {
        this.app.use(path, controller.getRouter());
    }

    /**
     * Setup all API routers in the system
     */
    private setupRouters(): void {
        this.setupRouter("/", new UserController(new UserService(UserModel.getInstance())));
        this.setupRouter("/friend", new FriendController(new FriendService(FriendModel.getInstance())));
        this.setupRouter("/square", new SquarePostController(
            new SquarePostService(SquarePostModel.getInstance(),
                UserModel.getInstance())));
        this.setupRouter("/playground", new PlaygroundPostController(
            new PlaygroundPostService(PlaygroundPostModel.getInstance(), UserModel.getInstance())));
        this.setupRouter("/campus", new CampusPostController(
            new CampusPostService(CampusPostModel.getInstance(),
                UserModel.getInstance())));
        this.setupRouter("/ext-res", new ExtResController(new ExtResService()));
        this.app.use("/docs", swaggerUi.serve, swaggerUi.setup(swaggerSettings));
    }

    /**
     * Configure the application
     */
    public configureApp(): void {
        // Enable cross origin resources sharing
        this.app.use(cors());
        // Parse json body
        this.app.use(express.json());
        // Setup all routers in the app
        this.setupRouters();
        // Init firebase admin
        FirebaseAdmin.initialize();
    }

    /**
     * Start the application
     * @param {any} port - The listening port of the application
     */
    public start(port: any): void {
        this.app.listen(port, () => {
            console.log(`Server is listening at ${port}`);
        });
    }
}

// Initialize and start the server
const PORT: any = process.env.PORT || 3000;
const server: App = new App();
server.start(PORT);
