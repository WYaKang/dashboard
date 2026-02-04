I will implement the **Repository-Service Pattern** and **Standardized Error Handling** to decouple business logic from database operations, improving maintainability and testability.

### 1. Refactor Architecture (Service Layer)
The current `crud_user.py` mixes database queries with password hashing and authentication logic. I will separate these concerns.

*   **Repository Layer** (`app/crud/base.py`, `app/crud/user.py`):
    *   Create a generic `CRUDBase` class for common operations (get, create, update, delete).
    *   `CRUDUser` will inherit from `CRUDBase` and handle only DB-specific user queries (e.g., `get_by_email`).
    *   **Goal**: Pure database interactions, no business rules.

*   **Service Layer** (`app/services/user_service.py`, `app/services/auth_service.py`):
    *   **UserService**: Handles user creation logic (checking duplicates, hashing passwords) and user management.
    *   **AuthService**: Handles authentication logic (verifying passwords, token generation).
    *   **Goal**: Encapsulate all business logic.

### 2. Standardized Error Handling
*   Create custom exception classes in `app/core/exceptions.py` (e.g., `UserAlreadyExists`, `InvalidCredentials`).
*   Implement a global exception handler in `app/main.py` to catch these exceptions and return consistent JSON error responses.

### 3. Dependency Injection
*   Update `app/api/deps.py` to provide `UserService` and `AuthService` instances to the API endpoints, rather than accessing CRUD directly.

### 4. Implementation Steps
1.  **Base CRUD**: Create `app/crud/base.py` with a generic async repository.
2.  **User Repository**: Refactor `app/crud/crud_user.py` to use the base class and remove auth logic.
3.  **Services**: Implement `UserService` (creation/hashing) and `AuthService` (login/token).
4.  **Exceptions**: Define custom exceptions and handlers.
5.  **API Refactor**: Update `login.py` and `users.py` endpoints to use the new Services.
