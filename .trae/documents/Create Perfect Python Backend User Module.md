I will implement a production-ready, "perfect" Python backend user module using **FastAPI**. This stack is chosen for its modern features, high performance, automatic documentation, and type safety.

The implementation will follow **Clean Architecture** principles to ensuring scalability and maintainability.

### 1. Technology Stack
-   **Framework**: `FastAPI` (Modern, fast, web framework)
-   **Database**: `SQLite` (Easy setup) with `SQLAlchemy` (ORM)
-   **Validation**: `Pydantic` (Data validation and settings management)
-   **Security**: `Passlib` (Password hashing with bcrypt), `Python-Jose` (JWT Authentication)
-   **Testing**: `Pytest`

### 2. Directory Structure
I will create a `backend` directory with the following structure:
```text
backend/
├── app/
│   ├── __init__.py
│   ├── main.py              # Application entry point
│   ├── core/                # Core config and security
│   │   ├── config.py
│   │   └── security.py
│   ├── db/                  # Database connectivity
│   │   ├── base.py
│   │   └── session.py
│   ├── models/              # Database Models
│   │   └── user.py
│   ├── schemas/             # Pydantic Schemas (Data Transfer Objects)
│   │   ├── user.py
│   │   └── token.py
│   ├── crud/                # Database Operations (Create, Read, Update, Delete)
│   │   └── crud_user.py
│   └── api/                 # API Routes
│       ├── deps.py          # Dependencies (e.g., get_current_user)
│       └── v1/
│           ├── api.py
│           └── endpoints/
│               ├── login.py
│               └── users.py
├── tests/                   # Unit and Integration Tests
├── requirements.txt
└── run.sh                   # Helper script to run the server
```

### 3. Implementation Steps
1.  **Setup**: Initialize project structure and `requirements.txt`.
2.  **Core & Database**: Configure environment settings, database session, and base SQLAlchemy model.
3.  **Domain Modeling**:
    -   Create `User` model (SQLAlchemy) with fields: `id`, `email`, `hashed_password`, `is_active`, `full_name`.
    -   Create Pydantic schemas for `UserCreate`, `UserUpdate`, `UserResponse`, and `Token`.
4.  **Security Logic**: Implement password hashing (`bcrypt`) and JWT token creation/validation.
5.  **CRUD Layer**: Implement separated logic for user creation and authentication.
6.  **API Layer**:
    -   `POST /register`: Register a new user.
    -   `POST /login`: Authenticate and receive an access token.
    -   `GET /users/me`: Retrieve the currently logged-in user's profile (protected route).
7.  **Testing**: Add basic tests to verify registration and login flows.
