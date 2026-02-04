I will optimize the backend to strictly follow Apple's Best Practices by introducing **Idempotency** and **Order Enforcement** mechanisms. I will also replace the `MockDB` with a robust **SQLite-based persistence layer** (using SQLAlchemy) to handle state reliably.

### 🚀 Optimization Plan

#### 1. Replace MockDB with SQLite + SQLAlchemy
*   **Why**: File-based JSON storage (`MockDB`) is not concurrent-safe and cannot handle complex queries efficiently. SQLite is perfect for this scale and requires no extra infrastructure.
*   **Action**:
    *   Add `SQLAlchemy` to `requirements.txt`.
    *   Create `app/db/session.py` to handle SQLite connection.
    *   Create `app/models.py` to define two tables:
        *   `subscriptions`: Stores `original_transaction_id`, `status`, `expires_date`, and crucially **`last_signed_date`**.
        *   `processed_notifications`: Stores `notification_uuid` to prevent duplicate processing.

#### 2. Implement Idempotency (De-duplication)
*   **Why**: Apple retries notifications. Processing the same event twice can lead to incorrect states or side effects.
*   **Action**:
    *   In `SubscriptionService`, check `processed_notifications` table for the incoming `notificationUUID`.
    *   If found, log and return success immediately (do not re-process).
    *   If not found, proceed and save the UUID after successful processing.

#### 3. Enforce Event Ordering (Timestamp Check)
*   **Why**: Network delays can cause notifications to arrive out of order (e.g., `RENEW` arrives *before* `FAIL`).
*   **Action**:
    *   When updating a subscription, compare the incoming `signedDate` with the stored `last_signed_date`.
    *   **Rule**: `if incoming.signedDate <= stored.last_signed_date`: Ignore the update (it's stale).

#### 4. Strict Environment & Bundle ID Checks
*   **Why**: Security. Prevent cross-app replay attacks or Sandbox data leaking into Production.
*   **Action**:
    *   Verify `bundleId` matches `settings.APP_STORE_BUNDLE_ID`.
    *   Verify `environment` matches `settings.APP_STORE_ENVIRONMENT`.

#### 5. Consumption Request Stub
*   **Why**: Apple requires a response for `CONSUMPTION_REQUEST`.
*   **Action**:
    *   Add a handler for `CONSUMPTION_REQUEST` that logs the request.
    *   Add a TODO/Placehoder for the `send_consumption_info` API call (since we don't have the implementation details for that yet).

### 📂 Revised Structure
```text
backend/app/
├── db/
│   ├── session.py       # SQLite Engine
│   └── base.py          # SQLAlchemy Base
├── models/
│   └── subscription.py  # DB Models
└── services/
    └── subscription_service.py # Updated logic with DB session
```