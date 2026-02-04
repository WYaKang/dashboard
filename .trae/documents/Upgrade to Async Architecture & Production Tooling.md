I will upgrade the backend module to a high-performance, production-ready **Async Architecture** with proper **DevOps tooling**.

### 1. Upgrade to Async Database (Performance 🚀)
Switching from synchronous to asynchronous database operations significantly improves throughput for I/O-bound applications.
-   **Dependencies**: Add `aiosqlite` (Async SQLite driver).
-   **Database Session**: Refactor `app/db/session.py` to use `AsyncEngine` and `AsyncSession`.
-   **CRUD & API**: Rewrite `crud_user.py` and API endpoints to use `async/await`.

### 2. Database Migrations (Maintainability 🛠️)
Hardcoded `Base.metadata.create_all()` is not suitable for production.
-   **Tool**: Initialize **Alembic** for schema migrations.
-   **Configuration**: Configure `alembic/env.py` to support asynchronous migrations.

### 3. Production Hardening (Security & Config 🔒)
-   **CORS**: Enable Cross-Origin Resource Sharing in `main.py` to allow frontend communication.
-   **Environment Variables**: Integrate `python-dotenv` to manage secrets (DB URL, Secret Key) securely, replacing hardcoded values.

### 4. Containerization (Deployment 🐳)
-   **Dockerfile**: Create a lightweight, optimized Python image.
-   **Docker Compose**: Define the service stack for one-command startup.

### 5. Dependency Management
-   **Requirements**: Merge existing crawler dependencies with the new backend requirements to ensure a unified environment.
