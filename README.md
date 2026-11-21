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
- Results are saved as JSON in the output S3 bucket. Each event record is processed,
  and the result preserves the input object's key under `results/`.

### ⚙️ Full CLI Automation

```bash
./install.sh
```
- Creates S3 buckets (input and output)
- Deploys the Lambda function
- Sets up event triggers
- Configures required IAM roles
- Is repeatable and safe to run multiple times

### 🧠 Architecture

![Architecture Diagram](assets/Architecture.png)

**1. Upload**
- A user uploads an image to the input bucket.

**2. S3 Event**
- S3 sends an event to the Lambda function.

**3. Lambda + Rekognition**
- The Lambda reads the object from S3.
- Calls `rekognition:RecognizeCelebrities` on the image.

**4. Result storage**
- The Lambda writes a JSON result to the output bucket under `results/<filename>.json`.


**5. Test automation**
- A shell script that automates testing and automatically creates a `protocols.md` file in the `docs` directory.

### 🧪 Test Workflow

```bash
./scripts/test_flow.sh
```

- Uploads a test image (e.g. Dwayne Johnson)
- Waits for the recognition process
- Downloads and prints the result with name and confidence score

---

## Requirements

- AWS CLI v2 (configured with credentials)
- Bash and `zip`
- AWS IAM permissions (S3, Lambda, Rekognition)
- Git

---

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/Vijiyarathan-Rithush/aws-celebrity-recognition-service.git
cd aws-celebrity-recognition-service
```

### 2. Run Setup

```bash
chmod +x install.sh
chmod +x scripts/*
chmod +x tests.sh
chmod +x edit_config.sh

./install.sh
```

#### 🧾 Example input on first run

```bash
> Enter your AWS Region [e.g. eu-central-1]: eu-central-1
> Input S3 Bucket name: face-recognition-input-2025
> Output S3 Bucket name: face-recognition-output-2025
> Lambda Function name: recognize-celebrities
> Using IAM Role: arn:aws:iam::123456789012:role/LabRole
```

This will:
- Verify AWS CLI configuration
- Create or reuse the S3 buckets
- Set the `OUT_BUCKET` environment variable for the Lambda
- Configure the S3 event trigger on the input bucket

### 3. Configuration

You do **not** need to manually edit `config.env`.

On the **first run**, the configuration loader `config.sh` will ask you once for:

- AWS region  
- Input bucket name  
- Output bucket name  
- Lambda function name  

The Lambda role ARN is **automatically retrieved** from the current AWS CLI session (default: `LabRole`).  
All these values are stored in `config.env`.

On **all later runs**:

- `config.sh` just loads `config.env`
- No more prompts → all scripts and tests run fully automated

#### Editing the configuration later
If you need to change any configuration values after the initial setup, use the helper script:
- Run `./edit_config.sh`
- This opens an interactive editor to modify the existing configuration stored in `config.env` without recreating it

## Directory Structure

```bash
.
├── build/         # Lambda build artifacts (Lambda.zip, etc.)
├── docs/          # Test reports (protocols.md) and screenshots
├── img/           # Sample images for testing (Brad.jpeg, TC.jpeg, ...)
├── iam/           # IAM policies and S3 trigger config
├── scripts/       # Helper scripts (test_single.sh, test_flow.sh, utils.sh, ...)
├── src/           # Lambda source code (handler.py)
├── config.env     # Generated environment configuration (do not commit secrets)
├── config.sh      # Shared configuration loader for all scripts
├── install.sh     # Main installer: creates buckets, Lambda, and triggers
├── tests.sh       # Test runner that generates docs/protocols.md
└── README.md      # This documentation
```

---

## Testing

Run the handler tests locally with Python 3.14 and without AWS credentials:

```bash
python -m unittest discover -s tests
```

The Lambda deployment uses the Python 3.14 runtime. The shell integration tests
below use real AWS resources in the configured account.
For automated testing, a central script called `tests.sh` is used. This script runs all important tests in a fixed order and generates a test report in `docs/protocols.md`.

The following test cases are executed:

- **T01 – Clean install**
First run of `install.sh`. Verifies that the S3 buckets, Lambda function, IAM role, and S3 trigger are created correctly.

- **T02 – Re-run install (idempotent)**
Second run of `install.sh`. Verifies that the setup script can be executed multiple times without errors or duplicate resources.

- **T03 – Single image test**
Uploads a single image to the input bucket and checks that a JSON result is created in the output bucket (detected celebrity name and confidence score).

- **T04 – Multi image test**
Uploads multiple images from the `img/` directory and processes them one by one. For each image, a corresponding JSON result in the output bucket is expected.

- **T05 – No images in `img/` (negative test)**
The `img/` directory is emptied. The script is expected to stop with a clear error message (instead of failing silently).

- **T06 – Wrong `IN_BUCKET_NAME` in `config.env` (negative test)**
The input bucket name in `config.env` is set to an invalid value. The upload should fail with a clear error (bucket does not exist).

The `tests.sh` script collects the exit codes of all tests, evaluates them as **Pass/Fail**, and writes a summary table plus short detail blocks (date, command, expected behavior and result) to `docs/protocols.md`. This makes the testing process reproducible and the generated test protocol can be used directly in the project documentation or as an appendix.

---

### Example Output
A sample JSON output from the Lambda function:

```json
{
  "source_bucket": "<your-input-bucket>",
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

You should see the name of the detected celebrity and confidence score in your terminal.

---

## Authors

- Memeti Rejan
- Vijiyarathan Rithush

---

## Notes
This project was developed as part of the **M346 Cloud Module** at **GBSSG St. Gallen** (Switzerland).
It aims to give hands-on experience with AWS Rekognition and automation best practices.
