# Face Recognition Cloud Service (AWS Rekognition)

The **Face Recognition Cloud Service** is a lightweight AWS-based project that automatically detects celebrities in uploaded images.

It was built during a vocational cloud computing module and uses key AWS services to deliver a fully automated image recognition pipeline.

The project is designed for students or developers who want a clean and fast introduction to AWS Rekognition, Lambda, and S3 automation.

---

## Features

### 🔍 Celebrity Recognition

- Upload any image to the `input` S3 bucket
- A Lambda function is triggered automatically
- The function uses **Amazon Rekognition** to detect celebrities
- Results are saved as a `.json` file in the `output` S3 bucket

### ⚙️ Full CLI Automation

```bash
./install.sh
```
- Creates S3 buckets
- Deploys the lambda function
- Sets up event triggers
- Configured required IAM roles
- Read to go in minutes

### 🧪 Test Workflow

```bash
bash scripts/test_flow.sh
```

- Uploads a test image (Dwayne Johnson)
- Waits for the recognition porcess
- Downloads and prints the result with name and confidence score

---

## Requirements
- AWS CLI (configured with credentials)
- AWS IAM permissions (S3, Lambda, Rekognition)
- Git

---

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/Vijiyarathan-Rithush/aws-celebrity-recognition-service.git
cd aws-celebrity-recognition-service
```

## 2. Configuration

You do **not** need to manually edit `config.env`.

During installation, the script will automatically:
- Detect if a configuration file exists
- Prompt you to use the existing one or create a new one
- Let you enter custom values for buckets, region, and Lambda name (or keep the defaults)

This ensures that your setup is customized and repeatable — no need for manual editing.

### 3. Run Setup

```bash
chmod +x install.sh
chmod +x scripts/*
chmod +x tests.sh
./install.sh
```

## Directory Structure

```bash
.
├── build/         # Lambda build files
├── docs/          # Test logs and screenshots
├── examples/      # Sample images for testing
├── iam/           # IAM policies and trust relationships
├── scripts/       # Shell scripts for setup, deployment, testing
├── src/           # Lambda source code
├── .gitignore     # Shell helper config
├── config.env     # Environment configuration
├── config.sh      # Shell helper config
├── install.sh     # Shell helper config
└── README.md      # This documentation
```

---

### Example Output
A sample JSON output from the Lambda function:

```json
{
  "source_bucket": "vijiyarathan-memeit-in2",
  "source_key": "test.jpg",
  "celebrities": [
    {
      "name": "Dwayne Johnson",
      "match_confidence": 99.99396514892578
    }
  ]
}
```

---

```bash
bash scripts/test_flow.sh
```

You should see the name of the detected celebrity and confidence score in your terminal.

---

## Authors

- Memeti Rejan
- Vijiyarathan Rithush

---

## Notes
This project was developed as part of the **M346 Cloud Module** at **GBSSG St. Gallen** (Switzerland).
It aims to give hands-on experience with AWS Rekogntion and automation best practices.