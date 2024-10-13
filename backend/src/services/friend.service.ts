import { messaging } from "firebase-admin";
import FriendModel from "../models/friend.model";
import UserModel from "../models/user.model";
import { ServiceResponse } from "./base.service";

class FriendService {
    private friendModel;

    /**
     * Initialize RequestService
     * @param {RequestModel} requestModel - the model that handles the user data
     */
    public constructor(friendModel: FriendModel) {
        this.friendModel = friendModel;
    }

    /**
     * Has posted in 24 hours
     * @param {string} email - email of the user
     * @returns {Promise<any[]>} - the data of the user in the system
     */
    private async sendFriendRequestNotification(senderId: string, receiverId: string): Promise<void> {
        let receiver_fcm_tokens: string[] = await UserModel.getInstance().getFcmToken(receiverId);
        
        if (receiver_fcm_tokens.length != 0) {
            const message = {
                // Enable this notification block if need pop up notifications
                // notification: {
                //     title: 'TODO: ADD TITLE HERE',
                //     body: 'TODO: ADD BODY HERE'
                // },
                data: {
                    type: 'connection_notification'
                },
                tokens: receiver_fcm_tokens
            }
    
            messaging().sendEachForMulticast(message).then((response: any) => {
                return response;
            }).catch((error: any) => {
                console.log('Error sending push:', error);
            })
        }
    }

    /**
     * Retrieves all friends of a user
     * @param {string} userId - the id of the user
     * @returns {Promise<any>} - success and the list of friends
     */
    public async getFriends(userId: string): Promise<any> {
        try {
            // Add friend request to the database
            const friends = await this.friendModel.getFriends(userId);
            return { success: true, friends: friends }
        } catch (error) {
            return { success: false, error };
        }
    }

    /**
     * Retrieves In Friend Requests
     * @param {string} userId - the id of the user
     * @returns {Promise<any>} - success and the list of in friend requests
     */
    public async getFriendRequestsReceived(userId: string): Promise<any> {
        try {
            // Add friend request to the database
            const friendRequestsReceived = await this.friendModel.getFriendRequestsReceived(userId);
            return { success: true, friend_requests_received: friendRequestsReceived }
        } catch (error) {
            return { success: false, error };
        }
    }

    /**
     * Retrieves Out Friend Requests
     * @param {string} userId - the id of the user
     * @returns {Promise<any>} - success and the list of out friend requests
     */
    public async getFriendRequestsSent(userId: string): Promise<any> {
        try {
            // Add friend request to the database
            const friendRequestsSent = await this.friendModel.getFriendRequestsSent(userId);
            return { success: true, friend_requests_sent: friendRequestsSent }
        } catch (error) {
            return { success: false, error };
        }
    }

    /**
     * Add friend request to the database
     * @param {string} senderId - the id of the sender
     * @param {string} receiverId - the id of the receiver
     * @returns {Promise<ServiceResponse>} - success and message
     */
    public async friendRequest(senderId: string, receiverId: string): Promise<ServiceResponse> {
        try {
            // Add friend request to the database
            let status = await this.friendModel.getFrienshipStatus(senderId, receiverId);
            if (status == "received") {
                await this.acceptFriendRequest(receiverId, senderId);
                return { success: true, message: "request accepted" }
            }
            await this.friendModel.addFriendRequest(senderId, receiverId);
            await this.friendModel.updateFriendshipStatus(senderId, receiverId, "requested");
            await this.friendModel.updateFriendshipStatus(receiverId, senderId, "received");
            // TODO: temporarily disable this features (Notify friend requests)
            await this.sendFriendRequestNotification(senderId, receiverId);
            return { success: true, message: "request added" }
        } catch (error) {
            return { success: false, error };
        }
    }

    /**
     * Accept friend request
     * @param {string} senderId - the id of the sender
     * @param {string} receiverId - the id of the receiver
     * @returns {Promise<ServiceResponse>} - success and message
     */
    public async acceptFriendRequest(senderId: string, receiverId: string): Promise<ServiceResponse> {
        try {
            await this.friendModel.addFriend(senderId, receiverId);
            await this.friendModel.deleteFriendRequest(senderId, receiverId);
            await this.friendModel.updateFriendshipStatus(senderId, receiverId, "connect");
            await this.friendModel.updateFriendshipStatus(receiverId, senderId, "connect");
            return { success: true, message: "request accepted" }
        } catch (error) {
            return { success: false, error };
        }
    }

    /**
     * Delete the friend request in the friend database
     * @param {string} senderId - the id of the sender
     * @param {string} receiverId - the id of the receiver
     * @returns {Promise<ServiceResponse>} - success and message
     */
    public async deleteFriendRequest(senderId: string, receiverId: string): Promise<ServiceResponse> {
        try {
            await this.friendModel.deleteFriendRequest(senderId, receiverId);
            await this.friendModel.updateFriendshipStatus(senderId, receiverId, "declined");
            await this.friendModel.updateFriendshipStatus(receiverId, senderId, "unconnect");
            return { success: true, message: "request rejected" };
        } catch (error) {
            return { success: false, error };
        }
    }
}

export {
    FriendService
};

