I will upgrade the current basic Flask backend to a **production-ready FastAPI application**. This will significantly improve performance, type safety, and maintainability. I will also implement a comprehensive handling mechanism for App Store Server Notifications V2.

### 🚀 Optimization Plan

#### 1. Framework Migration (Flask → FastAPI)
*   **Why**: FastAPI is the modern standard for Python APIs, offering async support (crucial for high-concurrency notification handling), automatic data validation (Pydantic), and auto-generated documentation (Swagger UI).
*   **Action**:
    *   Rewrite `main.py` to `app/main.py`.
    *   Create a structured folder hierarchy: `app/api/`, `app/core/`, `app/services/`, `app/models/`.
    *   Update `requirements.txt` (add `fastapi`, `uvicorn`, `pydantic-settings`).

#### 2. Enhanced Notification Handling (Webhook)
*   **Why**: Handling just "success" is not enough. You must handle failures, refunds, and expirations to protect revenue.
*   **Action**: Implement a **Dispatcher Pattern** in `SubscriptionService` to handle:
    *   `DID_RENEW`: Extend subscription.
    *   `DID_FAIL_TO_RENEW`: Enter grace period/retry state.
    *   `EXPIRED`: Revoke access.
    *   `REFUND` / `REVOKE`: Immediate cancellation.
    *   `CONSUMPTION_REQUEST`: Stub for responding to refund requests.

#### 3. Database Abstraction Layer
*   **Why**: The current code has `# TODO` comments. I will replace them with a proper **Repository Pattern**.
*   **Action**:
    *   Create `app/db/mock_db.py`: An in-memory database with JSON file persistence (to simulate a real DB without needing Postgres setup).
    *   It will track: `original_transaction_id` -> `{status, expires_date, product_id}`.

#### 4. Logging & Configuration
*   **Why**: `print()` is not for production.
*   **Action**:
    *   Configure Python's `logging` module to output structured logs (JSON format ready).
    *   Use `pydantic-settings` for robust environment variable management.

### 📂 New Directory Structure
```text
backend/
├── app/
│   ├── __init__.py
│   ├── main.py              # FastAPI Entry Point
│   ├── api/                 # API Routes
│   │   └── v1/
│   │       ├── endpoints/
│   │       │   ├── webhook.py  # Notification Handler
│   │       │   └── status.py   # Status Check
│   │       └── router.py
│   ├── core/                # Config & Security
│   │   ├── config.py
│   │   └── logging.py
│   ├── services/            # Business Logic
│   │   ├── app_store_service.py # API Wrapper
│   │   └── subscription_service.py # Notification Logic
│   └── db/                  # Data Layer
│       └── session.py       # Mock DB implementation
├── tests/                   # Unit Tests
│   └── test_webhook.py
├── requirements.txt
└── .env.example
```

This plan transforms the initial "script-like" backend into a robust microservice architecture.