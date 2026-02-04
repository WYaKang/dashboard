I will implement a comprehensive Ancient Poetry (古诗词) module within your existing FastAPI backend. This will include the full stack from database models to API endpoints.

### 1. Database Model (`app/models/poetry.py`)
I will create a SQLAlchemy model `Poetry` with the following fields:
- `id`: Integer, Primary Key
- `title`: String, Indexed (Title of the poem)
- `author`: String, Indexed (Author name, e.g., "李白")
- `dynasty`: String (e.g., "唐代")
- `content`: Text (The poem content)
- `translation`: Text, Optional (Modern Chinese translation)
- `notes`: Text, Optional (Annotations/Notes)

### 2. Pydantic Schemas (`app/schemas/poetry.py`)
I will define the data validation and serialization schemas:
- `PoetryBase`: Shared properties
- `PoetryCreate`: Properties required for creation
- `PoetryUpdate`: Properties for updates
- `PoetryInDBBase`: Properties shared by models stored in DB
- `Poetry`: Return type for API responses

### 3. CRUD Operations (`app/crud/crud_poetry.py`)
I will implement a `CRUDPoetry` class inheriting from a base generic CRUD class (if available) or implementing standard methods:
- `get_by_id`
- `get_multi` (Pagination support)
- `create`
- `update`
- `delete`
- **New Feature**: `search` (Search by title or author)

### 4. API Endpoints (`app/api/v1/endpoints/poetry.py`)
I will create the following RESTful endpoints:
- `GET /poetry/`: List poems with pagination and optional search query (`q` parameter).
- `POST /poetry/`: Create a new poem (admin/authenticated).
- `GET /poetry/{id}`: Get a specific poem.
- `PUT /poetry/{id}`: Update a poem.
- `DELETE /poetry/{id}`: Delete a poem.

### 5. System Integration
- **Register Router**: Add the poetry router to `app/api/v1/api.py`.
- **Database Registration**: Import the new model in `app/db/base.py` so Alembic migrations can detect it.
- **Migration**: I will guide you on how to generate the migration file (since I cannot execute migration commands that might depend on your local DB state easily, I will prepare the code so running `alembic revision --autogenerate` works).

### 6. Verification
- I will create a test script or use `curl` commands to verify the API works by adding a sample poem (e.g., "静夜思").
