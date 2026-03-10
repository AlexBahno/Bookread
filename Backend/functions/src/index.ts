import * as functions from "firebase-functions/v1";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

export const createUserDocument = functions.auth.user().onCreate((user) => {
  const userData = {
    uid: user.uid,
    email: user.email || "",
    profileImageUrl: user.photoURL || "",
    username: "",
    followerCount: 0,
    followingCount: 0,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  return db.collection("users").doc(user.uid).set(userData);
});
