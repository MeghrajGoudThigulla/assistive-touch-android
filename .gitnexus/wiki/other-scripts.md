# Other — scripts

# Scripts

This document provides an overview of the utility scripts located in the `/scripts` directory. These scripts are designed for development and operational tasks that support the main application.

## PRD Synchronization (`check_prd`)

The primary script in this module, `check_prd`, provides a mechanism to synchronize a Product Requirements Document (PRD) from Google Docs with a local, version-controlled text file. This ensures that developers have visibility into PRD changes directly within the project's history and can easily check for updates without leaving their development environment.

Two equivalent implementations are provided: Node.js (`check_prd.js`) and Bash (`check_prd.sh`).

### Purpose

-   **Visibility:** Expose changes made to the canonical PRD (a Google Doc) to the development team within the codebase.
-   **Tracking:** Create a "snapshot" of the PRD at different points in time, which can be committed to version control.
-   **Automation:** Provide a simple, runnable script to check for updates, which can be integrated into pre-commit hooks or other development workflows.

### Workflow

Both scripts follow the same logical flow to compare the remote Google Doc with the local tracked version. On the first run, the script establishes a local baseline. On subsequent runs, it fetches the latest version, shows a diff if changes are found, and automatically updates the baseline.

```mermaid
flowchart TD
    A[Start] --> B(Fetch PRD from Google Docs);
    B --> C{Local baseline<br/>`docs/PRD_v1.0_sync.txt`<br/>exists?};
    C -- No --> D[Save fetched text as new baseline];
    C -- Yes --> E[Compare fetched text with baseline];
    E -- No Changes --> F[Log "No changes detected"];
    E -- Changes Found --> G[Log "CHANGES DETECTED" and display diff];
    G --> H[Auto-sync: Update baseline with fetched text];
    D --> Z[End];
    F --> Z;
    H --> Z;
```

### Key Components & Configuration

-   **Google Doc ID:** The script is hardcoded to track a specific document. This is configured via a variable at the top of each script:
    -   `check_prd.js`: `const docId = '1LBk3sP5H48edghAU8TcjxHFcX15pwA7S3fHFAuaE12E';`
    -   `check_prd.sh`: `DOC_ID="1LBk3sP5H48edghAU8TcjxHFcX15pwA7S3fHFAuaE12E"`
    To track a different document, update this ID.

-   **Local Baseline File:** The local snapshot of the PRD is stored at `docs/PRD_v1.0_sync.txt`. This file should be committed to version control. The script automatically creates it on its first run.

-   **Auto-Sync Behavior:** A critical feature of this script is that after detecting and reporting changes, it **automatically updates** the local `PRD_v1.0_sync.txt` file. This means the next time the script runs, it will only report *new* changes made since the last check.

### Implementations

#### `check_prd.js` (Node.js)

This is the primary implementation, using modern JavaScript features.

-   **Entrypoint:** The script executes the `checkPrd()` function when run.
-   **Dependencies:** It relies on the built-in `fetch` API (available in Node.js v18+) for HTTP requests and the `child_process.execSync` function to run the system's `diff` command.
-   **Logic:**
    1.  Fetches the document text from the Google Docs export URL.
    2.  Normalizes line endings by removing carriage returns (`\r`) to ensure clean diffs across different operating systems.
    3.  Compares the fetched text against `localPrdPath` using `diff -u`.
    4.  The `execSync` call is wrapped in a `try...catch` block. The `diff` command exits with status code `1` when differences are found, which `execSync` treats as an error. The `catch` block inspects this error to correctly identify that changes were found.
    5.  If changes are detected, it parses the `diff` output from `error.stdout` to display only the added (`+`) and removed (`-`) lines.

#### `check_prd.sh` (Bash)

A lightweight, portable alternative with no Node.js dependency. It is suitable for environments where only standard Unix/Linux tools are available.

-   **Dependencies:** Requires `curl`, `diff`, `tr`, `grep`, and `mv`.
-   **Logic:**
    1.  Uses `curl` to download the document text to a temporary file (`temp_prd.txt`).
    2.  Uses `tr -d '\r'` to normalize line endings, similar to the Node.js version.
    3.  Runs `diff -u` and redirects the output to another temporary file (`temp_diff.txt`).
    4.  It checks if the diff file has content (`[ -s "$DIFF_FILE" ]`).
    5.  If the diff file is not empty, it uses `grep` to filter and display the change lines before updating the local baseline.

### Usage

To run the check, execute either script from the project root:

**Using Node.js:**

```bash
node scripts/check_prd.js
```

**Using Bash:**

```bash
./scripts/check_prd.sh
# Or, if not executable:
# bash scripts/check_prd.sh
```

**Example Output (with changes):**

```
=> Fetching latest PRD from Google Docs...
=> Comparing latest Google Doc against local tracking version...
========================================
🚨 CHANGES DETECTED IN THE GOOGLE DOC! 🚨
========================================
-The login button should be blue.
+The login button should be green.
+A "Forgot Password" link should be present.
========================================
=> Local PRD automatically synchronized with latest changes.
```