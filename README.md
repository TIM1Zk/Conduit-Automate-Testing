# Conduit Automate Testing

This project provides automated testing for the [Conduit (RealWorld)](https://demo.realworld.show/) application using **Robot Framework** and the **Browser** (Playwright-based) library. 

The test suite covers essential user flows like Sign In, Sign Up, and **New Article** creation using data-driven testing techniques.

## 🚀 Prerequisites

Before running the tests, ensure you have the following installed:

- **Python 3.8+**
- **Node.js** (required for the Browser library)

## 📦 Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/TIM1Zk/Conduit-Automate-Testing-.git
   cd Conduit-Automate-Testing-
   ```

2. **Install the required Python packages:**
   ```bash
   pip install robotframework robotframework-browser robotframework-datadriver[xlsx] robotframework-excellibrary
   ```

3. **Initialize the Browser library:**
   ```bash
   rfbrowser init
   ```

## 📁 Project Structure

- `testcase/`: Contains the actual test files (e.g., `signin.robot`, `new_article.robot`).
- `Resource/`: Shared keywords and library initializations (e.g., `Keyword.robot`).
- `Variable/`: Global or project-specific variables (e.g., `variable.robot`).
- `Testdata/`: Excel files for data-driven testing (e.g., `testdata_signup.xlsx`, `testdata_article.xlsx`).
- `results/`: Directory where test reports and logs are generated.

## ✨ Features

- **Data-Driven Testing:** Uses Excel files to run tests with multiple sets of data.
- **Automated Results Logging:** Test outcomes (PASS/FAIL) are automatically written back to the 'Result' column in the corresponding Excel data files after execution.

## 🛠️ How to Run Tests

To execute all tests and save results in the `results` folder, run:

```bash
robot -d results testcase/
```

## 📊 Viewing Results

After the tests complete, you can find the detailed reports in the `results/` directory:
- `report.html`: High-level summary of test execution.
- `log.html`: Detailed log of every step taken during the test.

---

## 👨‍💻 Credits

Created by **TIM1Zk**
