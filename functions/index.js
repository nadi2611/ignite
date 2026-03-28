const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

// ─── Helpers ───────────────────────────────────────────────────────────────

async function sendPush(token, title, body, data = {}) {
  if (!token) return;
  try {
    await admin.messaging().send({
      token,
      notification: { title, body },
      data,
      apns: {
        payload: {
          aps: { sound: "default", badge: 1 }
        }
      }
    });
  } catch (err) {
    console.error("FCM send error:", err.message);
  }
}

async function getUser(uid) {
  const doc = await db.collection("users").doc(uid).get();
  return doc.exists ? doc.data() : null;
}

// ─── Match notification ─────────────────────────────────────────────────────
// Fires when a new match document is created in /matches/{matchId}

exports.onMatchCreated = functions.firestore
  .document("matches/{matchId}")
  .onCreate(async (snap, context) => {
    const { users } = snap.data();
    if (!users || users.length < 2) return;

    const [user1, user2] = await Promise.all([
      getUser(users[0]),
      getUser(users[1])
    ]);

    if (!user1 || !user2) return;

    const matchId = context.params.matchId;

    // Notify user1 about user2
    await sendPush(
      user1.fcmToken,
      "It's a Match! 🔥",
      `You and ${user2.name} liked each other`,
      { type: "match", matchId }
    );

    // Notify user2 about user1
    await sendPush(
      user2.fcmToken,
      "It's a Match! 🔥",
      `You and ${user1.name} liked each other`,
      { type: "match", matchId }
    );
  });

// ─── Message notification ───────────────────────────────────────────────────
// Fires when a new message is created in /matches/{matchId}/messages/{messageId}

exports.onMessageSent = functions.firestore
  .document("matches/{matchId}/messages/{messageId}")
  .onCreate(async (snap, context) => {
    const message = snap.data();
    const matchId = context.params.matchId;

    const matchDoc = await db.collection("matches").doc(matchId).get();
    if (!matchDoc.exists) return;

    const users = matchDoc.data().users || [];
    const recipientId = users.find(uid => uid !== message.senderId);
    if (!recipientId) return;

    const [sender, recipient] = await Promise.all([
      getUser(message.senderId),
      getUser(recipientId)
    ]);

    if (!sender || !recipient) return;

    await sendPush(
      recipient.fcmToken,
      sender.name,
      message.text,
      { type: "message", matchId }
    );
  });
