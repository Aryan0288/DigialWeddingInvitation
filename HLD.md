# High-Level Design (HLD.md): Digital Wedding Invitation Builder (V3)

This document describes the high-level system architecture, user flow, component boundaries, state flow, and data routing for the Digital Wedding Invitation Builder.

---

## 🏛️ System Architecture Overview

The system utilizes a decoupled, high-performance, cross-platform architecture targeting Mobile (iOS/Android) and Web browsers. It integrates a **Dual-Storage Pipeline** to handle lightning-fast offline drafts alongside real-time cloud synchronization:

```text
       ┌────────────────────────────────────────────────────────┐
       │                       PRESENTATION                     │
       │                                                        │
       │     ┌──────────────┐            ┌─────────────────┐    │
       │     │    Views     │ ─────────> │   ViewModels    │    │
       │     │ (Widgets/UI) │ <───────── │ (StateNotifier) │    │
       │     └──────────────┘            └─────────────────┘    │
       └────────────│─────────────────────────────▲─────────────┘
                    │                             │
                    ▼                             │
       ┌──────────────────────────────────────────│─────────────┐
       │                DATA & SERVICES           │             │
       │                                          │             │
       │             ┌────────────────────────┐   │             │
       │             │  InvitationRepository  │ ──┘             │
       │             └───────────┬────────────┘                 │
       │                         │                              │
       │         ┌───────────────┴───────────────┐              │
       │         ▼                               ▼              │
       │  ┌──────────────┐               ┌──────────────┐       │
       │  │ Hive Database│               │   Firebase   │       │
       │  │ (Local NoSQL)│               │  (Firestore) │       │
       │  └──────────────┘               └──────────────┘       │
       └────────────────────────────────────────────────────────┘
```

---

## 🎨 Dynamic Remote Template Engine (Extensible Designs)

To prevent hardcoding design layouts and allow infinite new designs, the app uses a **Remote Design Injection Pattern** to load and render cards dynamically:

```text
  ┌──────────────────┐               ┌─────────────────┐               ┌──────────────────┐
  │ Remote Assets Server│ ─────────────> │  Builder Engine │ ─────────────> │ Dynamic Template │
  │  (Templates API) │  [Fetch JSON] │  (Provider/Ref) │  [Render Skin]  │  (Active Card)   │
  └──────────────────┘               └─────────────────┘               └──────────────────┘
```

1. **Remote Design Fetch**: On startup, the builder queries a remote API or static config URL to fetch a list of available designs (`List<RemoteTemplateModel>`).
2. **Template Metadata Schema**: Each template is defined dynamically in JSON:
   * **Visual Colors**: Base background gradient list, secondary highlights, gold color accents.
   * **Remote Assets**: High-res URLs for corner frames, center mandalas, peacock feathers, or divider dividers.
   * **Typography Profiles**: Specific font families loaded dynamically from Google Fonts (e.g. *Cinzel*, *Great Vibes*, *Montserrat*).
3. **Dynamic Render Skin (`DynamicTemplateWidget`)**: Rather than coding 50 different static widget classes, we build a **single highly-reusable canvas container**. It downloads the required background overlays dynamically using `CachedNetworkImage` and maps the text colors, fonts, and positions in real-time based on the downloaded JSON metadata.
4. **The Value**: We can upload 10 new beautiful cards to our remote site tomorrow, and they will immediately appear as active options in the builder **without needing to update or re-upload the Flutter app to Google Play, the App Store, or Vercel hosting!**

---

## 🔄 Dual-Storage Data Pipeline Design

We decouple persistence operations through the Repository pattern:

1. **Hive (Local NoSQL Object Database)**:
   * **Purpose**: Instantly persists active form states as the user types, acting as a robust offline draft locker.
   * **Lifecycle**: Retains unsaved/offline drafts. If the user accidentally refreshes their browser or closes the app, the draft is loaded automatically from Hive on re-launch.
2. **Firebase Firestore (Real-Time Cloud Document Store)**:
   * **Purpose**: Stores finalized public invitations and collects real-time guest RSVP records.
   * **Lifecycle**: Triggers when clicking "Publish & Generate Link". The invitation is written to the cloud. Guests load the card using Firestore document fetches and write their confirmations to a sub-collection `/invitations/:id/rsvps`.

---

## 🌊 Host-Guest RSVP Data Stream Flow

Real-time sync uses Firestore's Snapshot streams to let hosts monitor guest lists interactively:

1. **Guest Confirmation**: Guest opens the public URL `/invitation/:id`, fills in the RSVP form, and clicks **Confirm RSVP**.
2. **Firestore Write**: The client writes an `RsvpModel` document to the cloud:
   `Firestore.instance.collection('invitations').doc(id).collection('rsvps').add(rsvp.toJson())`
3. **Real-Time Stream Listener**: The Creator's dashboard (inside the Builder Workspace or `/dashboard/:id`) listens to a live stream of this sub-collection:
   `Firestore.instance.collection('invitations').doc(id).collection('rsvps').snapshots()`
4. **Reactive Rebuild**: When a new RSVP document is added, Riverpod receives the updated stream snapshot, maps it to a list of RSVPs, and automatically updates the Host's RSVP Dashboard UI.

---

## 🗺️ Multi-Step Wizard & RSVP Dashboard Route

The builder `/builder` is restructured to support **5 steps** for an all-in-one workspaces experience:

* **Step 1: Choose Template**: Selection cards showing available static and remote templates dynamically.
* **Step 2: Couple Details**: Inputs for Bride/Groom names and custom love message.
* **Step 3: Event Logistics**: Modern Date & Time pickers and Venue Hall inputs.
* **Step 4: Publish & Share**: Generating the Firestore cloud entry and copy-pasting the public link.
* **Step 5: Track RSVPs (Dashboard)**: An interactive chart and scrollable grid showing guests, dietary choices, and headcounts, fueled by a live Riverpod Firestore Stream provider!
