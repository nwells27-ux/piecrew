# PieCrew — Phase 1 (Messaging, Announcements, Tasks)

A Flutter + Firebase app to replace Crew for Your Pie's team communication,
starting as a pilot at one location before rolling out to all five.

## What's built

- **Login** — email/password (accounts created by an owner/manager, no self-signup)
- **Announcements feed** — location-scoped, pinnable, priority levels
  (normal/important/urgent), optional "require acknowledgment" with an
  "I HAVE READ THIS" button and a manager-visible acknowledgment count,
  only owners/managers can post
- **Tasks & checklists** — one-time, daily, or weekly recurring tasks,
  optional required note as proof of completion, full completion history
  per period (a daily task automatically resets each day without losing
  its audit trail); only owners/managers create tasks, any team member can
  complete them
- **Maintenance / equipment issues** — anyone can report a broken piece of
  equipment (priority + description), managers move it through status
  (Reported → Manager Reviewing → Vendor Contacted → Repair Scheduled →
  Resolved)
- **Manager log** — a daily end-of-shift log (sales/staffing/customer/
  equipment/general notes) visible only to owners/managers, reachable via
  an icon in the app bar
- **Team chat** — one group channel per location for Phase 1
- **Invite team member** — owners/managers add staff accounts from inside
  the app (name, email, temp password, role)
- **Push notifications** — device registration wired up (server-side send
  trigger is a small Cloud Function, see `firebase/functions_notes.md`)
- **Firestore security rules** — every user only sees data from their own
  `locationId`; only owners/managers can post announcements, create tasks,
  update maintenance status, or write manager-log entries

## Project structure

```
lib/
  models/       PieCrewUser, PieCrewLocation, Announcement, PieCrewTask/TaskCompletion, ChatMessage/Channel
  services/     AuthService, AnnouncementService, TaskService, ChatService, NotificationService
  screens/      LoginScreen, HomeScreen, AnnouncementsScreen, TasksScreen, ChatScreen, InviteStaffScreen
  main.dart     App entry point + auth-state routing
firebase/
  firestore.rules      security rules (deploy with `firebase deploy --only firestore:rules`)
  functions_notes.md   what to build next for push delivery
```

## Setting this up to actually run

Firebase is already fully wired up — project created, Email/Password auth
enabled, Firestore live with security rules deployed, and Android/iOS/Web
apps registered with real config values in `lib/firebase_options.dart`.
Your owner account also already exists (`wells@yourpie.com`, role `owner`,
`locationId: loganville`). What's left is local, on your machine:

1. `flutter create --org com.yourpie --project-name piecrew .` — generates
   the native `ios/` and `android/` folders (not included here; only the
   Dart side is). Safe to run — it won't touch your existing `lib/` files.
2. Follow **ANDROID_SETUP.md** and **IOS_SETUP.md** — a few small Gradle
   edits and copying the two config files from `android-config/` and
   `ios-config/` into place. Both are ready to use as-is, pulled straight
   from the Firebase project.
3. `flutter pub get`
4. Seed your locations: add a doc per location to a `locations` collection
   in Firestore (see `lib/models/location_model.dart` — `seedLocations` has
   your five locations pre-filled; Loganville is the pilot).
5. `flutter run` on a simulator or connected phone, then sign in with
   `wells@yourpie.com`.
6. Once signed in, tap the "invite team member" icon (top right, visible to
   owners/managers) to add your Loganville team.

Note: no Android SHA-1 signing certificate has been added yet — that's only
needed for Google Sign-In, which this app doesn't use, so it's safe to skip
for the pilot.

## Suggested pilot rollout

- Get 2-3 managers/staff at Loganville testing announcements, tasks, and
  chat for a week.
- Once it's stable, move to the next round of features below.

## Testing status

I've run full end-to-end tests directly against the live Firebase backend
after each round of changes.

- **Fixed (earlier round):** the very first time a location's chat channel
  is opened, the existence-check read was being denied by the security
  rules. Corrected and redeployed — chat works correctly on first use.
- **Fixed (this round):** two real bugs found while testing maintenance
  issues and the manager log:
  1. The security rules I'd added for `maintenance_issues` and
     `manager_logs` had never actually published in an earlier session
     (a UI quirk showed a false "published" confirmation). Redeployed
     properly and confirmed via the raw editor document state this time.
  2. **Missing Firestore indexes** — the exact queries the app uses for
     Announcements (`locationId` + `pinned` + `createdAt`) and Manager Log
     (`locationId` + `createdAt`) need composite indexes that didn't exist.
     Without them, both screens would fail to load in the real app. This
     had been silently wrong since Announcements shipped — my earlier
     testing only used a simplified query, not the exact one the screen
     uses. Both indexes are now created and confirmed working.
- **Confirmed working end-to-end:** login, announcements (post, read with
  the real sort order, priority, acknowledgment), tasks (create, complete,
  daily-reset logic), chat (channel creation, send, read), maintenance
  issues (report, read, status update through the full workflow), and
  manager log (post, read with the real sort order).
- **Confirmed:** the location boundary holds throughout — a Loganville
  user cannot read or write another location's data, and only
  owners/managers can create tasks, post announcements, or update
  maintenance status.
- One test maintenance issue (status: resolved) and one test manager log
  entry are sitting in Loganville's data — both are immutable by design
  (no delete/update-after-create permission, same as chat messages, for
  audit-trail integrity), so they're harmless to leave. Two test chat
  messages from an earlier round are similarly harmless and left in place.
  Everything else created during testing was cleaned up.

## Try it without installing Flutter

`piecrew-web-tester.html` is a lightweight web client wired to the same
live Firebase project — open it in a browser and sign in with
`wells@yourpie.com` to try the full feature set without needing Flutter
installed at all: announcements (priority + acknowledgment), tasks
(recurring + completion notes), equipment issue reporting and status
updates, team chat, invite team member, and the manager log. It mirrors
the Flutter app's logic exactly, including the same day/week completion
tracking math for recurring tasks.

Testing note: I verified this version's JS syntax, confirmed the
recurring-task date math matches the Dart original bit-for-bit across
several test dates (including a year boundary), and confirmed every
Firestore write it makes uses the same collection names and field shapes
already live-tested in the Flutter app rounds. I did not click through
the rendered UI in a browser this time — worth a first careful pass
yourself before relying on it, same as any other update.

## Not built yet

Deferred from an initial ChatGPT-drafted master spec so this stays scoped
to your actual need (5 locations, piloting at 1) instead of a sellable
multi-tenant SaaS platform:

- Shift scheduling, open shift claiming, and shift swaps
- Time-off requests
- Recognition & kudos
- Employee surveys
- Admin dashboard / reporting across all five locations
