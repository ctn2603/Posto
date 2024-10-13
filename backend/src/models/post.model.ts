import "firebase/compat/firestore";
import {
    DocumentData,
    DocumentReference,
    DocumentSnapshot,
    Query,
    QueryDocumentSnapshot,
    QuerySnapshot,
    arrayRemove,
    arrayUnion,
    deleteDoc,
    getDoc,
    getDocs, limit,
    orderBy,
    query,
    startAfter,
    updateDoc,
    where
} from "firebase/firestore";
import BaseModel from "./base.model";
import UserModel from "./user.model";

abstract class PostModel extends BaseModel {
    /**
     * 
     * @returns {PostModel} - the instance of the post model
     */
    protected getInstance(): PostModel {
        throw new Error("getInstance must be implemented");
    }

    /**
     * Get a post by id
     * @param {string} postId - the id of the post
     */
    public abstract getPostById(postId: string): Promise<DocumentData>;

    /**
     * Delete a post by id
     * @param {string} postId - the id of the post
     */
    public async removePostById(postId: string): Promise<void> {
        const postDoc: DocumentReference<DocumentData> = this.getDocById(postId);
        await deleteDoc(postDoc);
    }

    /**
     * Get all available posts in the system
     * @returns {Promise<any[]>} - an list of posts avaiable in the system
     */
    public async getAllPosts(): Promise<any[]> {
        const querySnapshot: QuerySnapshot<DocumentData> = await getDocs(this.getCollection());
        return await Promise.all(querySnapshot.docs.map((doc) => this.getPostById(doc.id)));
    }

    /**
     * Get partial amount of available posts in the system
     * @param {string} lastPostId- the last page number of the current posts displayed on feed
     * @returns {Promise<any>} - a list of posts avaiable in the system
     */
    public async getPartialPosts(lastPostId: string): Promise<any> {
        // number of posts to load on to the feed
        const postsPerPage = 50 // SETTING IT TO 50 FOR NOW, IN CASE THERE ARE MORE THAN 10 POSTS ON CAMPUS/PLAYGROUND SINCE PARTIAL POSTS ISNT IMPLEMENTED

        // Appending ten posts to the feed based of the page user is on
        let queriedPosts: Query<DocumentData>;

        if (lastPostId) {
            let lastPostSnapshot: DocumentSnapshot<DocumentData> = await getDoc(this.getDocById(lastPostId));

            queriedPosts = query(
                this.getCollection(),
                orderBy('createdAt', 'desc'),
                startAfter(lastPostSnapshot),
                limit(postsPerPage)
            );
        } else {
            queriedPosts = query(
                this.getCollection(),
                orderBy('createdAt', 'desc'),
                limit(postsPerPage)
            );
        }

        const postsSnapshot: QuerySnapshot<DocumentData> = await getDocs(queriedPosts);

        if (!postsSnapshot.empty) {
            const lastPostSnapshot: QueryDocumentSnapshot<DocumentData>
                = postsSnapshot.docs[postsSnapshot.docs.length - 1];
            lastPostId = lastPostSnapshot.id

            return {
                posts: await Promise.all(postsSnapshot.docs.map(async (doc) => {
                    return this.getPostById(doc.id);
                })),
                lastPostId: lastPostId
            }
        } else {
            return {
                posts: [],
                lastPostId: lastPostId
            }
        }
    }

    /**
     * Get partial amount of available posts in the system and filter out posts by the user
     * @param {string} lastPostId- the last page number of the current posts displayed on feed
     * @param {string} userName - the username of the user not to get posts by
     * @param {string} time - the utc timezone of the user
     * @returns {Promise<any>} - a list of posts avaiable in the system
     */
    public async getPartialPostsNotByUser(userName: string, lastPostId: string, time: string): Promise<any> {
        // number of posts to load on to the feed
        const postsPerPage = 10
        const utcDate = new Date(time);
        let queriedPosts: Query<DocumentData>;

        if (lastPostId) {
            let lastPostSnapshot: DocumentSnapshot<DocumentData> = await getDoc(this.getDocById(lastPostId));
            queriedPosts = query(
                this.getCollection(),
                where('createdAt', '>=', utcDate),
                orderBy('createdAt', 'desc'),
                startAfter(lastPostSnapshot),
                limit(postsPerPage + 1) // Fetch one extra post Fetch one extra post to handle edge case
            );
        } else {
            queriedPosts = query(
                this.getCollection(),
                where('createdAt', '>=', utcDate),
                orderBy('createdAt', 'desc'),
                limit(postsPerPage + 1) // Fetch one extra post to handle edge case
            );
        }

        const postsSnapshot: QuerySnapshot<DocumentData> = await getDocs(queriedPosts);
        let hasMorePosts = postsSnapshot.size > postsPerPage; // Determine if there are more posts to send from database
        let results = postsSnapshot.docs;

        // If there are more than postsPerPage posts, slice off the last one
        if (hasMorePosts) {
            results = results.slice(0, -1);
        }

        if (results.length > 0) {
            const lastPostSnapshot: QueryDocumentSnapshot<DocumentData> = results[results.length - 1];
            lastPostId = lastPostSnapshot.id
            return {
                posts: await Promise.all(results.map((doc) => this.getPostById(doc.id))),
                lastPostId: lastPostId,
                userName: userName,
                hasMorePosts: hasMorePosts
            }
        } else {
            return {
                posts: [],
                lastPostId: lastPostId,
                userName: userName,
                hasMorePosts: hasMorePosts
            }
        }
    }

    /**
     * Get all posts made by a specific user based on their userId
     * @param {string} userId - the userId string
     * @returns {Promise<any[]>} - an list of posts by that user
     */
    public async getPostsByUserId(userId: string): Promise<any[]> {
        const userSnapshot: DocumentSnapshot<DocumentData> = await getDoc(UserModel.getInstance().getUserDocById(userId));
        const postIds: any[] = userSnapshot.data()["posts"];
        const postsFound = await Promise.all(postIds.map((doc: any) => this.getPostById(doc)));
        return postsFound.filter(post => post != null);
    }

    /**
     * Add a like to a given post
     * @param {string} postId - the post id string
     * @param {string} userId - the post id string
     */
    public async addLike(postId: string, userId: string) {
        const postDoc: DocumentReference<DocumentData> = await this.getDocById(postId);
        const postSnap: DocumentSnapshot<DocumentData> = await getDoc(postDoc);
        const currLikes: number = postSnap.data()['likes'];
        await updateDoc(postDoc, {
            likes: currLikes + 1,
            usersLiked: arrayUnion(userId)
        });
    }

    /**
    * Remove a like from a given post
    * @param {string} postId - the post id string
    * @param {string} userId - the post id string
    */
    public async removeLike(postId: string, userId: string) {
        const postDoc: DocumentReference<DocumentData> = await this.getDocById(postId);
        const postSnap: DocumentSnapshot<DocumentData> = await getDoc(postDoc);
        const currLikes: number = postSnap.data()['likes'];
        await updateDoc(postDoc, {
            likes: currLikes - 1,
            usersLiked: arrayRemove(userId)
        });
    }

    /**
    * Get all users who liked a specific post
    * @param {string} postId - the post id string
    * @returns {Promise<any[]>} - an list of users who liked post
    */
    public async getUsersLiked(postId: string): Promise<any[]> {
        const postDoc: DocumentReference<DocumentData> = await this.getDocById(postId);
        const postSnap: DocumentSnapshot<DocumentData> = await getDoc(postDoc);
        const currUsersLiked: Array<string> = postSnap.data()['usersLiked'];
        if (currUsersLiked.length > 0) {
            return currUsersLiked;
        }
        return new Array();
    }

    /**
     * Add a comment to a given post
     * @param {string} postId - the post id string
     * @param {string} userId - userId of new comment
     * @param {string} comment - new comment text
     */
    public async addComment(postId: string, userId: string, comment: string) {
        const postDoc: DocumentReference<DocumentData> = await this.getDocById(postId);
        const user: DocumentData = await UserModel.getInstance().getUserById(userId);
        await updateDoc(postDoc, {
            "comments": arrayUnion({
                "username": user.username,
                "profileImageRef": UserModel.getInstance().getUserDocById(userId),
                "comment": comment
            })
        });
    }

    /**
    * Delete a post based on post id
    * @param {string} postId - the post id string
    */
    public async deletePost(postId: string): Promise<void> {
        const postRef: DocumentReference<DocumentData> = await this.getDocById(postId);
        await deleteDoc(postRef);
    }
}

export default PostModel;
