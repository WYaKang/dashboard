I will upgrade the crawler module to be more robust, stealthy, and feature-rich. The optimization will focus on three key areas: **Anti-Detection**, **Login Persistence**, and **Rich Data Extraction**.

### 🚀 Optimization Plan

1.  **Enhance Anti-Detection (Stealth Mode)**
    *   Integrate `playwright-stealth` to mask automation signals (webdriver flags, permissions).
    *   Add **Randomized User-Agent** rotation.
    *   Implement **Human-like Interactions**: Random mouse movements and variable scroll delays to avoid behavior-based blocking.

2.  **Implement Login Persistence (Cookies)**
    *   Add functionality to **save cookies** after a successful login/session.
    *   Automatically **load cookies** on startup to maintain login state, avoiding repeated QR code scans or CAPTCHAs.
    *   Add a `--login` flag to `main.py` specifically for performing a manual login and saving the session.

3.  **Rich Data Extraction & Robustness**
    *   **Douyin**: Extract **Like Counts**, **Reply Counts**, and **Timestamps** (converting relative time like "2 days ago" to absolute dates).
    *   **Xiaohongshu**: Improve parsing for nested comments and handle the "Login to view more" modal more gracefully.
    *   **Error Handling**: Add retry logic for network timeouts and element selection failures.
    *   **Logging**: Replace `print` statements with a proper `logging` setup for better debugging.

### 📂 File Changes
*   `requirements.txt`: Add `playwright-stealth`.
*   `base_crawler.py`: Add stealth context creation, cookie management (save/load), and human-like delay helpers.
*   `douyin_crawler.py` & `xhs_crawler.py`: Update selectors and parsing logic for detailed data.
*   `main.py`: Add CLI arguments for `--login` mode.
*   `config.py`: Add cookie file paths and random delay ranges.
