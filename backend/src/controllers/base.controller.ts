import { Router } from "express";

abstract class BaseController {
    protected router: Router

    constructor() {
        this.router = Router();
        this.setupRoutes();
    }

    /**
     * Get the router that the controller manages
     * @returns {Router} - The router that the controller manages
     */
    public getRouter(): Router {
        return this.router;
    }

    abstract setupRoutes(): void;
}

export default BaseController;
