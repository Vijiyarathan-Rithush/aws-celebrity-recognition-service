# Face Recognition Cloud Service (AWS Recognition)

## 1. Introduction

This project implements a cloud-based **Face Recognition Service** designed to automatically identify well-known public figures in images using **AWS Rekognition – RecognizeCelebrities**. The goal of this project is to demonstrate the practical application of cloud technologies taught in Module 346 by building a fully automated, deployable, and testable service within the AWS Learner Lab environment.

The product is intended for **learners, instructors, and cloud practitioners** who need a simple yet functional example of how serverless components, object storage, and event-driven processing can be combined into a real-world solution. The service architecture follows a clear and scalable design: images are uploaded to an **input S3 bucket**, which triggers an **AWS Lambda function** responsible for performing the celebrity recognition. The results of the analysis — including detected identities and confidence scores — are then stored as JSON files in an **output S3 bucket**.

For ease of deployment, the entire infrastructure can be set up automatically using a CLI initialization script, allowing users to recreate the environment without manual configuration steps. A separate test script demonstrates the end-to-end functionality by uploading images, waiting for the recognition results, and retrieving the generated output files.

This repository includes all necessary configuration files, source code, scripts, and documentation to install, understand, and operate the service. It is structured to ensure clarity, reproducibility, and professional version control practices, enabling external reviewers and learners to fully follow the implementation and workflow.

---

## 2. Project Objectives

- Build a cloud service that recognizes celebrities on images using AWS Rekognition  
- Automate all required AWS components through scripting  
- Implement an event-driven workflow using S3 and Lambda  
- Provide clear documentation and version control throughout the project  
- Deliver a reproducible setup for examiners and learners  

---

## 3. Architecture Overview

### 3.1 High-Level Diagram

```mermaid
flowchart TD
    A [Upload Image<br>Input S3 Bucket] --> B [Lambda Trigger]
    B --> C [Face Recognition with AWS Rekognition]
    C --> D [JSON Result<br>Output S3 Bucket]
