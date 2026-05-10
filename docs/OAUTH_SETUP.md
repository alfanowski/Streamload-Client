# GitHub OAuth + Plugin Access Setup

Operator runbook for the OAuth App, inviting users to the plugin pack, and revoking access.

## 1. OAuth App (one-time)

1. Open https://github.com/settings/developers → **New OAuth App**.
2. Application name: `Streamload`.
3. Homepage URL: `https://streamload.alfanowski.it` (placeholder; not used).
4. Authorization callback URL: `http://localhost` (required field; not used in device flow).
5. Tick **Enable Device Flow** ✅.
6. **Register application**.
7. Copy the Client ID and paste it into `lib/plugins/github_oauth_config.dart` (constant `kGithubOAuthClientId`). The Client ID is public by design — no client_secret is generated or needed for device flow.

The currently configured Client ID is `Ov23liocgW9mW4skr2Fs`.

## 2. Inviting a user (per user, ~30 seconds)

1. Open https://github.com/alfanowski/streamload-plugins/settings/access.
2. **Add people** → username or email of the new user.
3. Role: **Read**.
4. **Add to repository**.
5. The user receives an email invitation. Once they accept, they can launch the app, click "Accedi con GitHub", authorize, and the plugin registry will be available to them automatically.

If the user has never used the app before:
- They register/login on the Streamload backend (username/password) to create their account on the operator's server.
- Then they hit the GitHub onboarding screen.
- They click "Accedi con GitHub" → app shows a 6-character code (e.g. `ABCD-1234`) and opens `https://github.com/login/device` in their browser.
- They paste the code, authorize the **Streamload** OAuth App.
- The app finishes the polling, saves the token, fetches the registry, mounts the plugins, and lands on `/home`.

If the user is NOT invited (or you've revoked access), the same flow runs but the registry fetch returns 404. The app silently switches to **browse-only mode**: catalog browsing works, the Watch button is hidden, the Plugins settings page shows a "Pacchetto plugin non disponibile" empty-state.

## 3. Revoking a user's access

1. Same page as above (https://github.com/alfanowski/streamload-plugins/settings/access).
2. Click the `×` next to their entry → **Remove**.
3. Their next plugin refresh (every 30 minutes while the app is open, or on next launch) will return 404 from the registry endpoint. The app silently degrades to browse-only mode.

The user's saved OAuth token still exists in their Keychain — it just no longer grants access to the plugin repo. If you want to also force them to re-authenticate from scratch, instruct them to use **Settings → Plugin → Cambia account GitHub** to clear the local token.

## 4. Rotating the OAuth App

If the Client ID needs to be rotated (compromise, account migration, etc.):

1. Create a new OAuth App with a different name.
2. Update the `kGithubOAuthClientId` const in `lib/plugins/github_oauth_config.dart`.
3. Build and ship a new app version.
4. Old tokens issued under the previous OAuth App remain valid against the GitHub API until users re-login or revoke them via https://github.com/settings/applications.

## 5. Troubleshooting

**"Pacchetto plugin non disponibile" but I'm sure the user was invited**
- Confirm the user accepted the email invite. Until they accept, GitHub returns 404.
- Confirm the OAuth App is listed under their authorized OAuth Apps at https://github.com/settings/applications. If not, they need to re-run the device flow.

**"Errore di connessione" on the Plugin settings page**
- The registry fetch hit a network error (no internet, GitHub outage, etc.). The "Riprova" button calls the loader again. The app stays in browse-only mode until a successful refresh classifies access correctly.

**User wants to switch GitHub accounts**
- Settings → Plugin → **Cambia account GitHub**. This clears the saved token and routes back to `/onboarding/github` for a fresh device flow.
