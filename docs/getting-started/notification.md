---
title: Notification Setup
description: Learn about the notification capabilities of Sprout.
---

<style>
.md-content__inner table td:first-child {
  white-space: nowrap;
}
</style>

# Self-Hosted Push Notifications

By default, Sprout retrieves notifications from the server API whenever you open the app or view the notification menu.

**Configuring Firebase is optional**. You only need to follow these steps if you want to receive instant Push Notifications on your device while the app is running in the background or closed.

!!! note "Optional Configuration"

    If you skip this section, notifications will still work perfectly fine inside the app. You just won't get the buzz/ding on your phone when the app is closed.

!!! note "Authentication"

    Sprout has to be logged in at-least once to obtain the necessary firebase configuration. Additionally, if your token ever expires (for either `OIDC` or `Local`), notifications will not be gathered.

## Prerequisite: Firebase Project

To enable push notifications, you must link your self-hosted Sprout instance to Google Firebase.

1. Go to the **Firebase Console**.
2. Click **Add project**.
3. Name your project (e.g., `sprout-selfhosted`) and follow the setup steps.
    - Note: Google Analytics is not required for notifications.

## Part 1: Public Client Credentials

These credentials allow the Flutter frontend to register itself with Firebase. These are considered "public" configuration, but are secured via Google Cloud Console restrictions.

1. **Register the Android App**
    1. In your new Firebase project, click the **Android icon** to add an app.
    2. Enter the **Package Name**: `net.croudebush.sprout` (or your custom package name if you modified the build).
    3. **App Nickname**: Sprout.
    4. Click **Register app**.
    5. **Download google-services.json**: Skip this step. We configure this manually via environment variables.
    6. Click Next through the remaining steps until you finish the wizard.
2. **Configure the API Key (Crucial)**

Because Sprout initializes Firebase manually on the client, you must configure a specific API Key in the Google Cloud Console with the correct permissions.

!!! warning "Do not use the default Web API Key"

    The default "Web API Key" found in Firebase settings often lacks the permissions required for device registration. You must follow the steps below to create a compatible key.

1. Go to the [Google Cloud Console Credentials Page](https://console.cloud.google.com/apis/credentials).
2. Ensure your Firebase project is selected in the top dropdown.
3. You should see an "Auto-created" API key (or create a new one). Click the **Edit** icon.
4. **Enable Required APIs**:
    - Go to the [API Library](https://console.cloud.google.com/apis/library).
    - Search for and **Enable** these two APIs:
        - **Firebase Installations API** (Required for device registration)
        - **Firebase Cloud Messaging API**
5. **Restrict the API Key (Highly Recommended)**:
    - Select Restrict key and select the two APIs enabled above (**Firebase Installations** and **Firebase Cloud Messaging**).
6. **Gather Client Values**

You will need the following values for your server configuration.

| Variable           |            Description            |                                          Where to find it                                           |
| ------------------ | :-------------------------------: | :-------------------------------------------------------------------------------------------------: |
| **Project ID**     |  The unique ID of your project.   |                  Firebase Console -> **Project settings** (Gear icon) -> General.                   |
| **Project Number** |          The numeric ID.          |                        Firebase Console -> **Project settings** -> General.                         |
| **App ID**         |        The mobile app ID.         |              Firebase Console -> **Project settings** -> General -> Your apps section.              |
| **API Key**        | The credential created in Step 2. | [Google Cloud Credentials](https://console.cloud.google.com/apis/credentials). Copy the Key string. |

## Part 2: Private Backend Credentials

To send notifications, your **Sprout** needs **Admin Access**. This requires a Service Account.

!!! danger "Security Warning"

    The Service Account Key contains a Private Key. Never expose this to anyone else. Keep it secure. Sprout will not make this available. It is purely used in the backend.

1. **Generate Service Account**

    1. Go to the [Firebase Console](https://console.firebase.google.com/).
    2. Click the **Gear Icon** -> **Project Settings**.
    3. Go to the **Service Accounts** tab.
    4. Click **Generate new private key**.
    5. Confirm by clicking **Generate Key**. This will download a `.json` file.

2. Extract Private Values

Open the downloaded JSON file. You need two specific fields:

| Variable       |        Description         |                                       Format Note                                       |
| -------------- | :------------------------: | :-------------------------------------------------------------------------------------: |
| `client_email` | The service account email. |            Firebase Console -> **Project settings** (Gear icon) -> General.             |
| `private_key`  |    The RSA private key.    | Includes `-----BEGIN PRIVATE KEY-----` and `\n` characters. **Copy the entire string**. |

## Part 3: Server Configuration

To enable Firebase, update your **backend environment variables** (e.g., in your `docker-compose.yml` or `.env` file).

You must set `enabled` to `true` and provide all credential fields.

```yml
# Enable the Firebase integration
sprout_server_notification_firebase_enabled=true

# --- Public Client Configuration ---
# From Part 1, Step 3
sprout_server_notification_firebase_apiKey=AIzaSy...
sprout_server_notification_firebase_appId=1:123456789:android:xyz...
sprout_server_notification_firebase_projectId=sprout-selfhosted
sprout_server_notification_firebase_projectNumber=123456789

# --- Private Backend Configuration ---
# From Part 2, Step 2
sprout_server_notification_firebase_clientEmail=firebase-adminsdk-xxxxx@sprout-selfhosted.iam.gserviceaccount.com
sprout_server_notification_firebase_privateKey="-----BEGIN PRIVATE KEY-----\nMIIEvQIBA...\n-----END PRIVATE KEY-----\n"
```

## Troubleshooting

### Client: 403 Forbidden Error

If the app logs show "**Permission Denied**" or "**403**" when registering, your API Key is missing the Firebase Installations API permission.

-   Fix: Go to Google Cloud Console → API Library and **enable** "**Firebase Installations API**".

### Backend: Error parsing private key

If the Sprout backend fails to start while parsing the private key:

-   Fix: Check **sprout_server_notification_firebase_privateKey**. It must include the header `-----BEGIN PRIVATE KEY-----` and footer `-----END PRIVATE KEY-----`. Ensure the newlines are represented as `\n` characters if using a single-line string.
