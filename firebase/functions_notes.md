# Cloud Functions to add once the pilot is live

The app itself doesn't send pushes — a Cloud Function watching Firestore does.
Not required to start testing chat/announcements locally, but needed before
staff get notified without having the app open.

1. **On new announcement** (`onCreate` trigger on `announcements/{id}`):
   - Look up all users where `locationId` matches the announcement's location.
   - Send an FCM push to each user's `fcmToken` with the announcement title/body.

2. **On new chat message** (`onCreate` trigger on `channels/{channelId}/messages/{id}`):
   - Look up the channel's `locationId`, then all users at that location except the sender.
   - Send an FCM push "New message from {senderName}".

Both are small (~30 line) functions using `firebase-admin` and
`firebase-functions`. Deploy with `firebase deploy --only functions` once
you're ready — happy to write these out fully when you get there.
