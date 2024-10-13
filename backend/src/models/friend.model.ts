import {
    DocumentData,
    DocumentReference,
    DocumentSnapshot,
    Timestamp, arrayUnion, deleteDoc, getDoc,
    setDoc,
    updateDoc
} from "firebase/firestore";
import BaseModel from "./base.model";
import UserModel from "./user.model";
import { config } from "./../configs/config"

class FriendModel extends BaseModel {
    private static instance: FriendModel;

    /**
     * 
     * Private constructor
     */
    private constructor(name: string) {
        super(name);
    }

    /**
     * 
     * @returns {RequestModel} - the instance of the user model
     */
    public static getInstance(): FriendModel {
        if (!this.instance) {
            this.instance = new FriendModel(config.database_names.friends);
        }
        return this.instance;
    }

    /**
     * Initialize the "friends" field in the model
     * @param {string} senderId - sender's id
     * @returns {Promise<void>}
     */
    public async initialize_friend(userId: string): Promise<void> {
        let userDoc = this.getDocById(userId);
        await setDoc(userDoc, {
            friends: new Array<any>(),
            friend_requests_sent: new Array<any>(),
            friend_requests_received: new Array<any>(),
            friendships: new Array<any>(),
        });
    }

    /**
     * get in friend requests
     * @param {string} userID - userID of the user
     * @returns {Promise<any[]>} - the data of the connections of the user
     */
    public async getFriends(userId: string):
        Promise<{ username: any; name: any; profile_img: any; id: string, friendship_status: string }[]> {
        let friendData: DocumentData = await this.getFriendData(userId);

        let friends: { username: any; name: any; profile_img: any; id: string, friendship_status: string }[]
            = await Promise.all(friendData.friends.map(async (friend: any) => {
                let userInfo: any = (await getDoc(friend.profileImageRef)).data();
                delete friend["profileImageRef"];
                return {
                    username: friend.username,
                    name: friend.name,
                    profileImage: userInfo.profileImage,
                    id: friend.id,
                    friendship_status: await this.getFrienshipStatus(userId, friend.id)
                };
            }));
        return friends;
    }

    /**
     * get in friend requests
     * @param {string} userID - userID of the user
     * @returns {Promise<any[]>} - the data of the connections of the user
     */
    public async getFriendRequestsReceived(userId: string):
        Promise<{ username: any; name: any; profile_img: any; senderId: string, friendship_status: string }[]> {
        let friendData: DocumentData = await this.getFriendData(userId);

        let friendRequestsReceived: { username: any; name: any; profile_img: any; senderId: string, friendship_status: string }[]
            = await Promise.all(friendData.friend_requests_received.map(async (friendRequestReceived: any) => {
                let receiverInfo: any = (await getDoc(friendRequestReceived.profileImageRef)).data();
                delete friendRequestReceived["profileImageRef"];
                return {
                    username: friendRequestReceived.username,
                    name: friendRequestReceived.name,
                    profileImage: receiverInfo.profileImage,
                    senderId: friendRequestReceived.senderId,
                    friendship_status: await this.getFrienshipStatus(userId, friendRequestReceived.senderId)
                };
            }));
        return friendRequestsReceived;
    }

    /**
     * Get friend data (friends, friendships, friend_requests_sent, friend_requests_received)
     * @param {string} userId - userId of the user
     * @returns {Promise<DoubleRange>} - the user's friend data
     */
    public async getFriendData(userId: string): Promise<DocumentData> {
        let friendRef: DocumentReference<DocumentData> = this.getDocById(userId);
        let friendSnapshot: DocumentSnapshot<DocumentData> = await getDoc(friendRef);
        let snapShotData: DocumentData = friendSnapshot.data();
        return snapShotData;
    }

    /**
     * get out friend requests
     * @param {string} userID - userID of the user
     * @returns {Promise<any[]>} - the data of the connections of the user
     */
    public async getFriendRequestsSent(userId: string):
        Promise<{ username: any; name: any; profile_img: any; receiverId: string, friendship_status: string }[]> {
        let friendData: DocumentData = await this.getFriendData(userId);

        let friendRequestsSent: { username: any; name: any; profile_img: any; receiverId: string, friendship_status: string }[]
            = await Promise.all(friendData.friend_requests_sent.map(async (friendRequestSent: any) => {
                let receiverInfo: any = (await getDoc(friendRequestSent.profileImageRef)).data();
                delete friendRequestSent["profileImageRef"];
                return {
                    username: friendRequestSent.username,
                    name: friendRequestSent.name,
                    profileImage: receiverInfo.profileImage,
                    receiverId: friendRequestSent.receiverId,
                    friendship_status: await this.getFrienshipStatus(userId, friendRequestSent.receiverId)
                };
            }));
        return friendRequestsSent;
    }

    /**
     * Add a friendship request to the friend collection
     * @param {string} senderId - sender's id
     * @param {string} receiverId - receiver's id
     * @returns {Promise<void>}
     */
    public async addFriendRequest(senderId: string, receiverId: string): Promise<void> {
        let receiverData: any = await UserModel.getInstance().getUserById(receiverId);
        let senderData: any = await UserModel.getInstance().getUserById(senderId)

        let friendRequestsSent: any[] = (await this.getFriendData(senderId))["friend_requests_sent"];
        let friendRequestsReceived: any[] = (await this.getFriendData(receiverId))["friend_requests_received"];

        friendRequestsSent = friendRequestsSent.filter(friendRequestSent => friendRequestSent.receiverId != receiverId);
        friendRequestsSent.push({
            receiverId: receiverId,
            username: receiverData["username"],
            name: receiverData["name"],
            profileImageRef: UserModel.getInstance().getUserDocById(receiverId),
            timestamp: Timestamp.now()
        });
        await updateDoc(this.getDocById(senderId), {
            friend_requests_sent: friendRequestsSent
        });

        friendRequestsReceived = friendRequestsReceived.filter(friendRequestReceive =>
            friendRequestReceive.senderId != senderId)
        friendRequestsReceived.push({
            senderId: senderId,
            username: senderData["username"],
            name: senderData["name"],
            profileImageRef: UserModel.getInstance().getUserDocById(senderId),
            timestamp: Timestamp.now()
        });
        await updateDoc(this.getDocById(receiverId), {
            friend_requests_received: friendRequestsReceived
        });
    }

    /**
     * Update friendship status of user a to user b in doc of "a"
     * @param {string} aid - user a's id
     * @param {string} bid - user b's id
     * @param {string} status - the new status of a friendship
     * @returns {Promise<void>}
     */
    public async updateFriendshipStatus(aid: string, bid: string, status: string): Promise<void> {
        let userDoc = this.getDocById(aid);
        let userData = (await getDoc(userDoc)).data();
        let friendships: any[] = userData["friendships"];
        const index = friendships.findIndex(friendship => friendship.id == bid)
        if (index != - 1) {
            friendships[index] = {
                id: friendships[index].id,
                status: status
            };
            await updateDoc(userDoc, { friendships });
        } else {
            await updateDoc(userDoc, {
                friendships: arrayUnion({
                    id: bid,
                    status: status
                })
            });
        }
    }

    /**
     * Update friendship status of user a to user b in doc of "a"
     * @param {string} aid - user a's id
     * @param {string} bid - user b's id
     * @returns {Promise<string>} - the status of the friendship of a to b (not b to a)
     */
    public async getFrienshipStatus(aid: string, bid: string): Promise<string> {
        let userDoc = this.getDocById(aid);
        let userData = (await getDoc(userDoc)).data();
        let friendships: any[] = userData["friendships"];
        const index = friendships.findIndex(friendship => friendship.id == bid)
        if (index != - 1) {
            return friendships[index].status;
        }
        return "unconnect";
    }

    /**
     * Delete a friend request from the friend collection
     * @param {string} senderId - sender's id
     * @param {string} receiverId - receiver's id
     * @returns {Promise<void>}
     */
    public async deleteFriendRequest(senderId: string, receiverId: string): Promise<void> {
        let senderDoc = this.getDocById(senderId);
        let senderSnapshot: DocumentSnapshot<DocumentData> = await getDoc(senderDoc);
        let receiverDoc = this.getDocById(receiverId);
        let receiverSnapshot: DocumentSnapshot<DocumentData> = await getDoc(receiverDoc);

        if (senderSnapshot.exists() && receiverSnapshot.exists()) {
            let senderData = (await getDoc(senderDoc)).data();
            await updateDoc(senderDoc, {
                friend_requests_sent: senderData["friend_requests_sent"]
                    .filter((item: any) => item.receiverId != receiverId),
            });

            let receiverData = (await getDoc(receiverDoc)).data();
            await updateDoc(receiverDoc, {
                friend_requests_received: receiverData["friend_requests_received"]
                    .filter((item: any) => item.senderId != senderId),
            });
        }
    }

    /**
     * Add a friendship to the friend collection
     * @param {string} senderId - sender's id
     * @param {string} receiverId - receiver's id
     * @returns {Promise<void>}
     */
    public async addFriend(senderId: string, receiverId: string): Promise<void> {
        let senderData: any = await UserModel.getInstance().getUserById(senderId);
        let receiverData: any = await UserModel.getInstance().getUserById(receiverId);
        let senderDoc = this.getDocById(senderId);
        let receiverDoc = this.getDocById(receiverId);

        await updateDoc(senderDoc, {
            friends: arrayUnion({
                id: receiverId,
                username: receiverData["username"],
                name: receiverData["name"],
                profileImageRef: UserModel.getInstance().getUserDocById(receiverId),
                timestamp: Timestamp.now()
            })
        });
        await updateDoc(receiverDoc, {
            friends: arrayUnion({
                id: senderId,
                username: senderData["username"],
                name: senderData["name"],
                profileImageRef: UserModel.getInstance().getUserDocById(senderId),
                timestamp: Timestamp.now()
            })
        });
    }

    /**
     * Delete all friends of the current user
     * @param {string} userId - user id
     * @returns {Promise<void>}
     */
    public async deleteFriendsOf(userId: string): Promise<void> {
        let userRef: DocumentReference<DocumentData> = this.getDocById(userId);
        let userSnapshot: DocumentSnapshot<DocumentData> = await getDoc(userRef);

        if (userSnapshot.exists()) {
            let userData: DocumentData = userSnapshot.data();

            // Delete the current user in user's friends
            await Promise.all(userData["friends"].map(async (friend: any) => {
                let friendRef: DocumentReference<DocumentData> = this.getDocById(friend.id);
                let friendSnapshot: DocumentSnapshot<DocumentData> = await getDoc(friendRef);
                let friendData: DocumentData = friendSnapshot.data();
                await updateDoc(friendRef, {
                    friends: friendData["friends"]
                        .filter((item: any) => item.id != userId),
                });
            }
            ));

            // Delete the current user in user's friendships
            await Promise.all(userData["friendships"].map(async (friendship: any) => {
                let friendRef: DocumentReference<DocumentData> = this.getDocById(friendship.id);
                let friendSnapshot: DocumentSnapshot<DocumentData> = await getDoc(friendRef);
                let friendData: DocumentData = friendSnapshot.data();
                await updateDoc(friendRef, {
                    friendships: friendData["friendships"]
                        .filter((item: any) => item.id != userId),
                });
            }
            ));

            // Delete the current user in user's friend requests sent
            await Promise.all(userData["friend_requests_received"].map(async (friendRequestReceive: any) => {
                let friendRef: DocumentReference<DocumentData> = this.getDocById(friendRequestReceive.senderId);
                let friendSnapshot: DocumentSnapshot<DocumentData> = await getDoc(friendRef);
                let friendData: DocumentData = friendSnapshot.data();
                await updateDoc(friendRef, {
                    friend_requests_sent: friendData["friend_requests_sent"]
                        .filter((item: any) => item.receiverId != userId),
                });
            }
            ));

            // Delete the current user in user's friend requests received
            await Promise.all(userData["friend_requests_sent"].map(async (friend_requests_sent: any) => {
                let friendRef: DocumentReference<DocumentData> = this.getDocById(friend_requests_sent.receiverId);
                let friendSnapshot: DocumentSnapshot<DocumentData> = await getDoc(friendRef);
                let friendData: DocumentData = friendSnapshot.data();
                await updateDoc(friendRef, {
                    friend_requests_received: friendData["friend_requests_received"]
                        .filter((item: any) => item.senderId != userId)
                });
            }
            ));

            // Delete all friends, friend requests, ... of users
            await deleteDoc(userRef);
        }
    }
}

export default FriendModel;
