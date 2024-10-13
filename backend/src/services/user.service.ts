import { compare, genSalt, hash } from "bcryptjs";
import { DocumentData } from "firebase/firestore";
import FriendModel from "../models/friend.model";
import SquarePostModel from "../models/square_post.model";
import UserModel from "../models/user.model";
import { ServiceResponse } from "./base.service";

interface SignUpResponse extends ServiceResponse {
    id?: string;
    name?: string;
    username?: string;
    profileImage?: string;
}

interface SignInResponse extends ServiceResponse {
    id?: string;
    name?: string;
    username?: string;
    profileImage?: string;
}

interface GetUsersResponse extends ServiceResponse {
    users?: any[];
    user?: String;
    userExists?: boolean;
}

interface GetConnectionsResponse extends ServiceResponse {
    connectionList?: { DocumentID: { username: any; name: any; profile_img: any; } };
}


interface IsOnboardResponse extends ServiceResponse {
    isOnboard?: boolean;
}

interface AcknowledgedSquareRes extends ServiceResponse {
    acknowledgedSquare?: boolean;
}

interface AcknowledgedCampusRes extends ServiceResponse {
    acknowledgedCampus?: boolean;
}

interface AcknowledgedPlaygroundRes extends ServiceResponse {
    acknowledgedPlayground?: boolean;
}

interface AcknowledgedTermsAndConditionsRes extends ServiceResponse {
    acknowledgedTermsAndConditions?: boolean;
}

class UserService {
    private userModel;

    /**
     * Initialize UserService
     * @param {UserModel} userModel - the model that handles the user data
     */
    public constructor(userModel: UserModel) {
        this.userModel = userModel;
    }

    /**
     * Handle signup feature
     * @param {string} id - user id of the user
     * @param {string} name - fullname of the user
     * @param {string} username - username of the user
     * @param {string} password - password of the user
     * @param {string} phone - phone number of the user
     * @returns {SignUpResponse} - an object describing whether signing up is successful or not, and associated messages, and errors
     */
    public async signup(id: string, name: string, profileImage: string, username: string, password: string, phone: string, email: string): Promise<SignUpResponse> {
        try {
            const user: DocumentData = await this.userModel.getUserByUsername(username);

            if (user) {
                // User already exist
                return { success: false, message: "username existed" }
            } else {
                // User not exist
                const salt: string = await genSalt(10);
                // hash password
                const hashedPassword: string = await hash(password, salt);
                const uid: string = await this.userModel.addUser(
                    id,
                    name,
                    profileImage,
                    username,
                    hashedPassword,
                    phone,
                    email
                );
                return {
                    success: true, message: "user added",
                    id: uid, name: name, username: username, profileImage: profileImage
                };
            }
        } catch (error) {
            return { success: false, error };
        }
    }

    /**
     * Handle signin feature
     * @param {string} username - username of the user
     * @param {string} password - password of the user
     * @returns {SignInResponse} - an object describing whether signing up is successful or not, and associated messages, and errors
     */
    public async signin(username: string, password: string): Promise<SignInResponse> {
        try {
            const user: DocumentData = await this.userModel.getUserByUsername(username);

            if (user) {
                // User existed
                const isPasswordMatch: boolean = await compare(
                    password,
                    user.password
                );
                if (isPasswordMatch) {
                    // Password match
                    return {
                        success: true, message: "password matched",
                        id: user.id, name: user.name, username: user.username, profileImage: user.profileImage
                    };
                } else {
                    // Password doesn't match
                    return { success: false, message: "invalid username or password" };
                }
            } else {
                // User doesn't exist (might due to invalid password or username)
                return { success: false, message: "invalid username or password" };
            }
        } catch (error) {
            return { success: false, error };
        }
    }

    /**
     * Get user doc by their id
     * @param {string} userId - userId of user
     * @returns {GetUsersResponse} - the user with the corresponding user id
     */
    public async getUserById(userId: string): Promise<GetUsersResponse> {
        try {
            const user: any = await this.userModel.getUserById(userId);
            if (user == null) {
                // There isn't any user in the system
                return { success: false, message: "users are not available" };
            } else {
                return { success: true, message: "user found", user };
            }
        } catch (error) {
            return { success: false, error };
        }
    }

    /**
     * Get user doc by their username
     * @param {string} username - username of user
     * @returns {GetUsersResponse} - the user with the corresponding user id
     */
    public async usernameExists(username: string): Promise<GetUsersResponse> {
        try {
            const user: any = await this.userModel.getUserByUsername(username);
            if (user == null) {
                // There isn't any user in the system
                return { success: true, message: "username does not exists", userExists: false };
            } else {
                return { success: true, message: "username exists", userExists: true };
            }
        } catch (error) {
            return { success: false, error };
        }
    }

    /**
     * Get all available users in the system
     * @returns {GetUsersResponse} - all available usernames in the system
     */
    public async getAllUsers(): Promise<GetUsersResponse> {
        try {
            const users: any[] = await this.userModel.getAllUsers();
            if (!users.length) {
                // There isn't any user in the system
                return { success: false, message: "users are not available" };
            } else {
                return { success: true, message: "users found", users };
            }
        } catch (error) {
            return { success: false, error };
        }
    }

    /**
     * Get all users whose usernames match a specific string
     * @param {string} searchString 
     * @returns {GetUsersResponse} - all users whose usernames match a specific string
     */
    public async getUsersBySearchString(userId: string, searchString: string): Promise<GetUsersResponse> {
        try {
            if (searchString.trim() == "") {
                return { success: true, message: "users not found:", users: [] };
            } else {
                const users: any[] = await this.userModel.getUsersBySearchString(userId, searchString);
                return { success: true, message: "users found:", users };
            }
        } catch (error) {
            return { success: false, error };
        }
    }

    /**
    * Check if the user is onboard
    * @param {string} userId - user id of user
    * @returns {Promise<IsOnboardResponse>} - user's first time on the app or not
    */
    public async isOnboard(userId: string): Promise<IsOnboardResponse> {
        const metadata: DocumentData = await this.userModel.getMetadataByUserId(userId);
        if (metadata) {
            return { success: true, isOnboard: metadata.isOnboard }
        } else {
            // User doesn't exist (might due to invalid password or username)
            return { success: false, message: "invalid username" };
        }
    }

    /**
    * The user onboarded
    * @param {string} userId - user id of user
    * @returns {Promise<ServiceResponse>} - onboards the user
    */
    public async onboarded(userId: string): Promise<ServiceResponse> {
        try {
            await this.userModel.onboarded(userId);
            return { success: true, message: "user is now active" }
        } catch (error) {
            return { success: false, error };
        }
    }

    /**
     * Has acknowledged the presence of the square section
     * @param {string} userId - user id
     * @returns {Promise<AcknowledgedSquareRes>}
     */
    public async hasAcknowledgedSquare(userId: string): Promise<AcknowledgedSquareRes> {
        // const metadata: DocumentData = await this.userModel.getMetadataByUserId(userId);
        // if (metadata) {

        //     return { success: true, acknowledgeSquare: metadata.acknowledgeSquare }

        // } else {
        //     return { success: false, message: "invalid user id" };
        // }
        return null;
    }

    /**
     * The user acknowledges the presence of the square tab
     * @param {string} userId - user's id
     * @returns {Promise<ServiceResponse>}
     */
    public async acknowledgeSquare(userId: string): Promise<ServiceResponse> {
        try {
            await this.userModel.acknowledgeSquare(userId);
            return { success: true }
        } catch (error) {
            return { success: false, error };
        }
    }

    /**
     * Has acknowledged the presence of the campus section
     * @param {string} userId - user id
     * @returns {Promise<AcknowledgedCampusRes>}
     */
    public async hasAcknowledgedCampus(userId: string): Promise<AcknowledgedCampusRes> {
        // const metadata: DocumentData = await this.userModel.getMetadataByUserId(userId);
        // if (metadata) {

        //     return { success: true, acknowledgeCampus: metadata.acknowledgeCampus }

        // } else {
        //     return { success: false, message: "invalid user id" };
        // }
        return null;
    }

    /**
     * The user acknowledges the presence of the campus tab
     * @param {string} userId - user's id
     * @returns {Promise<ServiceResponse>}
     */
    public async acknowledgeCampus(userId: string): Promise<ServiceResponse> {
        try {
            await this.userModel.acknowledgeCampus(userId);
            return { success: true }
        } catch (error) {
            return { success: false, error };
        }
    }

    /**
     * Has acknowledged the presence of the playground section
     * @param {string} userId - user id
     * @returns {Promise<AcknowledgedPlaygroundRes>}
     */
    public async hasAcknowledgedPlayground(userId: string): Promise<AcknowledgedPlaygroundRes> {
        // const metadata: DocumentData = await this.userModel.getMetadataByUserId(userId);
        // if (metadata) {

        //     return { success: true, acknowledgePlayground: metadata.acknowledgePlayground }

        // } else {
        //     return { success: false, message: "invalid user id" };
        // }
        return null;
    }

    /**
     * The user acknowledges the presence of the playground tab
     * @param {string} userId - user's id
     * @returns {Promise<ServiceResponse>}
     */
    public async acknowledgePlayground(userId: string): Promise<ServiceResponse> {
        try {
            await this.userModel.acknowledgePlayground(userId);
            return { success: true }
        } catch (error) {
            return { success: false, error };
        }
    }

    /**
     * Returns if user has acknowledged the terms and conditions
     * @param {string} userId - user id
     * @returns {Promise<AcknowledgedTermsAndConditionsRes>}
     */
    public async hasAcknowledgedTermsAndConditions(userId: string): Promise<AcknowledgedTermsAndConditionsRes> {
        const metadata: DocumentData = await this.userModel.getMetadataByUserId(userId);
        if (metadata) {
            return { success: true, acknowledgedTermsAndConditions: metadata.acknowledged_terms_and_conditions }
        } else {
            return { success: false, message: "invalid user id" };
        }
    }
    
    /**
     * The user acknowledges the terms and conditions
     * @param {string} userId - user's id
     * @returns {Promise<ServiceResponse>}
     */
    public async acknowledgeTermsAndConditions(userId: string): Promise<ServiceResponse> {
        try {
            await this.userModel.acknowledgeTermsAndConditions(userId);
            return { success: true }
        } catch (error) {
            return { success: false, error };
        }
    }

    /**
     * Update user's profile image
     * @param {string} userId - id of the user
     * @returns {Promise<ServiceResponse>}
     */
    public async updateProfileImage(userId: string, imgUrl: string): Promise<ServiceResponse> {
        try {
            await this.userModel.updateProfileImage(userId, imgUrl);
            return { success: true }
        } catch (error) {
            return { success: false, error };
        }
    }

    /**
    * Has posted in 24 hours
    * @param {string} userId - id of the user
    * @returns {Promise<ServiceResponse>} - the data of the user in the system
    */
    public async updateName(userId: string, name: string): Promise<ServiceResponse> {
        try {
            await this.userModel.updateName(userId, name);
            return { success: true }
        } catch (error) {
            return { success: false, error };
        }
    }

    /**
    * Has posted in 24 hours
    * @param {string} userId - id of the user
    * @returns {Promise<ServiceResponse>} - the data of the user in the system
    */
    public async updateUserName(userId: string, username: string): Promise<ServiceResponse> {
        try {
            const user: DocumentData = await this.userModel.getUserByUsername(username);
            if (user) {
                return { success: false, message: "username exists" }
            }
            else {
                await this.userModel.updateUserName(userId, username);
                return { success: true }
            }
        } catch (error) {
            return { success: false, error };

        }
    }

    /**
     * Get all users whose usernames match a specific string
     * @param {string} email
     * @returns {GetUsersResponse} - all users whose usernames match a specific string
     */
    public async getUsernameByEmail(email: string): Promise<GetUsersResponse> {
        try {
            const users: any[] = await this.userModel.getUsernameByEmail(email);
            return {
                success: true, message: "user found:", users
            };
        } catch (error) {
            return { success: false, error };
        }
    }

    /**
     * Gets user's name by their email
     * @param {string} email
     * @returns {GetUsersResponse} - all users whose usernames match a specific string
     */
    public async getNameByEmail(email: string): Promise<GetUsersResponse> {
        try {
            const users: any[] = await this.userModel.getNameByEmail(email);
            return {
                success: true, message: "user found:", users
            };
        } catch (error) {
            return { success: false, error };
        }
    }

    /**
     * Get all users whose usernames match a specific string
     * @param {string} email
     * @returns {GetUsersResponse} - all users whose usernames match a specific string
     */
    public async getProfileImageByEmail(email: string): Promise<GetUsersResponse> {
        try {
            const users: any[] = await this.userModel.getProfileImageByEmail(email);
            return {
                success: true, message: "user found:", users
            };
        } catch (error) {
            return { success: false, error };
        }
    }

    /**
    * Get all users whose usernames match a specific string
    * @param {string} email
    * @returns {Promise<String>} - corresponding user id
    */
    public async getUserIdByEmail(email: string): Promise<GetUsersResponse> {
        try {
            const user: String = await this.userModel.getUserIdByEmail(email);
            return { success: true, message: "user found:", user };
        }
        catch (error: any) {
            return {
                success: false, error
            };
        }
    }

    /**
    * Delete user account based on given user id
    * @param {string} user id
    * @returns {Promise<GetUsersResponse>} - success or not, and message
    */
    public async deleteUserAccount(userId: string): Promise<GetUsersResponse> {
        try {
            // Find posts and delete posts
            await SquarePostModel.getInstance().deletePostsOf(userId);

            // Find friends and delete friends
            await FriendModel.getInstance().deleteFriendsOf(userId);

            // Delete user account
            await this.userModel.deleteUserAccount(userId);
            return { success: true, message: "user deleted" };
        }
        catch (error: any) {
            return {
                success: false, error
            };
        }
    }
}

export {
    AcknowledgedCampusRes, AcknowledgedTermsAndConditionsRes, 
    AcknowledgedPlaygroundRes, AcknowledgedSquareRes, GetConnectionsResponse, GetUsersResponse,
    IsOnboardResponse, SignInResponse,
    SignUpResponse, UserService

};

