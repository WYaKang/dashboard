I will implement a vocabulary learning module within the existing FastAPI backend.

### 1. Database Models (`app/models/word.py`)
I will create a new file to define two models:
- **Word**: Stores the vocabulary data.
  - Fields: `id`, `text` (the word itself), `phonetic` (pronunciation), `definition`, `example_sentence`.
- **UserWordProgress**: Tracks a user's learning progress for a specific word.
  - Fields: `id`, `user_id`, `word_id`, `status` (e.g., New, Learning, Mastered), `next_review_at` (timestamp for spaced repetition), `review_count`.

### 2. Pydantic Schemas (`app/schemas/word.py`)
I will create schemas for request and response validation:
- **Word schemas**: `WordCreate`, `WordUpdate`, `WordResponse`.
- **Progress schemas**: `WordProgressUpdate` (to record study results).

### 3. CRUD Operations (`app/crud/crud_word.py`)
I will implement database operations:
- **create_word**: Add new vocabulary.
- **get_words**: List words with pagination.
- **update_learning_status**: Logic to update the word's status and calculate the next review time (simple spaced repetition logic).
- **get_due_reviews**: Retrieve words that are due for review for a specific user.

### 4. API Endpoints (`app/api/v1/endpoints/words.py`)
I will create a new API router with the following endpoints:
- `GET /words`: List available words.
- `POST /words`: Add a new word (Admin only).
- `POST /words/{word_id}/study`: Record a study attempt (remembered/forgot) and update the schedule.
- `GET /words/review`: Get a list of words currently due for review for the logged-in user.

### 5. Integration
- **Register Models**: Add the new models to `app/db/base.py` so Alembic/SQLAlchemy detects them.
- **Register Router**: Add the new `words` router to `app/api/v1/api.py`.

This approach fits seamlessly into your existing `backend` structure.
