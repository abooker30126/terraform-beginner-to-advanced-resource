# HashiCorp Certified Terraform: Associate

This repository contains all the code files, labs, and reference documentation used throughout the **HashiCorp Certified Terraform Associate** course by Zeal Vora.

<p align="center">
  <img width="460" height="300" src="https://i.ibb.co/b3jFkkk/discord-terraform.png">
</p>

---

## Table of Contents

- [About This Repository](#about-this-repository)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Clone the Repository](#clone-the-repository)
- [Project Structure](#project-structure)
- [Course Navigation](#course-navigation)
- [Community & Support](#community--support)
- [About the Me](#about-the-author)

---

## About This Repository

This Git repository is a companion to the HashiCorp Certified Terraform Associate course. Each section folder corresponds to a module in the course and contains:

- **Markdown documentation** (`.md` files) with explanations and notes
- **Terraform configuration files** (`.tf` files) for hands-on practice

---

## Getting Started

### Prerequisites

Before using this repository, make sure you have the following installed:

| Tool | Recommended Version | Notes |
|------|---------------------|-------|
| [Terraform](https://developer.hashicorp.com/terraform/downloads) | >= 1.0 | HashiCorp Terraform CLI |
| [AWS CLI](https://aws.amazon.com/cli/) | >= 2.x | Required for AWS-based labs |
| Git | Any recent version | For cloning the repository |

You will also need:
- An **AWS account** with appropriate IAM permissions for the hands-on labs
- AWS credentials configured locally (`aws configure` or environment variables)

### Clone the Repository

```sh
git clone https://github.com/abooker30126/terraform-beginner-to-advanced-resource.git
cd terraform-beginner-to-advanced-resource
```

Each section folder is self-contained. Navigate to the relevant section and follow the documentation files for that module.

---

## Project Structure

```
terraform-beginner-to-advanced-resource/
├── Section 1 - Deploying Infrastructure with Terraform/
│   ├── Readme.md              # Section overview and video-document map
│   ├── first-ec2.md           # Launching first EC2 instance
│   ├── resource-providers.md  # Resources and providers overview
│   └── ...                    # Additional lab files
├── Section 2 - Read, Generate, Modify Configurations/
│   ├── Readme.md
│   ├── terraform-variables.md
│   └── ...
├── Section 3 - Terraform Provisioners/
│   ├── Readme.md
│   └── ...
├── Section 4 - Terraform Modules & Workspaces/
│   ├── Readme.md
│   └── ...
├── Section 5 - Remote State Management/
│   └── ...
├── Section 6 - Security Primer/
│   ├── Readme.md
│   └── ...
└── Section 7 - Terraform Cloud & Enterprise Capabilities/
    ├── Readme.md
    └── ...
```

---

## Course Navigation

Each section has its own `Readme.md` that provides a **Video-Document Mapper** table linking course videos to the corresponding documentation files in this repository.

| Section | Topic |
|---------|-------|
| [Section 1](./Section%201%20-%20Deploying%20Infrastructure%20with%20Terraform/Readme.md) | Deploying Infrastructure with Terraform |
| [Section 2](./Section%202%20-%20Read%2C%20Generate%2C%20Modify%20Congiruations/Readme.md) | Read, Generate, Modify Configurations |
| [Section 3](./Section%203%20-%20Terraform%20Provisioners/Readme.md) | Terraform Provisioners |
| [Section 4](./Section%204%20-%20Terraform%20Modules%20%26%20Workspaces/Readme.md) | Terraform Modules & Workspaces |
| Section 5 | Remote State Management |
| [Section 6](./Section%206%20-%20Security%20Primer/Readme.md) | Security Primer |
| [Section 7](./Section%207%20-%20Terraform%20Cloud%20%26%20Enterprise%20Capabilities/Readme.md) | Terraform Cloud & Enterprise Capabilities |

---

## Community & Support

We have a Discord community for support and to connect with other students taking the same course. Feel free to join!

```
https://kplabs.in/chat
```

Welcome to the community, and we look forward to seeing you certified! 🎉

---

## About Me

<details>
<summary>👋 Tony Booker</summary>

**AI Security • Cloud Security • Autonomous Systems • Drone Engineering**

I'm a security-minded engineer pursuing my Master's in Artificial Intelligence, specializing in autonomous vehicle flight security. My work sits at the intersection of AI, cloud security, and autonomous systems.

**My Mission:** To help shape the future of secure autonomous flight, ensuring that AI-driven systems are resilient, trustworthy, and safe.

### 🚀 Featured Projects

- **config-rules-terraform/** — Terraform templates for AWS Config Rules across multi-region AWS Organizations
- **my-arsenal-of-aws-security-tools/** — Curated collection of open-source AWS security tools and frameworks
- **AI Forensics Labs** — Hands-on security testing and adversarial analysis exercises
- **Autonomous Flight Security** — Research and tools for secure drone platform development

### 🏗️ What I'm Working On

- 🎓 Advancing graduate research in autonomous vehicle flight security
- 🧪 Hands-on labs in AI forensics, container vulnerabilities, and cloud incident response
- 🔬 Exploring PyRIT and other AI risk-identification frameworks
- 🚁 Building and securing custom drone platforms
- ⚙️ Developing automation workflows for security operations (SOAR)

### 🧠 Technical Skills

**AI/ML Security**
- Adversarial ML testing and robustness evaluation
- LLM security and prompt injection analysis
- AI forensics and model interpretation
- PyRIT and other red teaming frameworks

**Cloud Security (AWS, Azure)**
- AWS Config Rules and compliance automation
- Identity & Access Management (IAM) optimization
- Container security and vulnerability scanning
- CloudTrail monitoring and incident response
- Infrastructure-as-Code security (Terraform, CloudFormation)

**Autonomous Systems & Flight Safety**
- Drone flight controller programming
- Sensor integration and telemetry systems
- Safety-critical system design
- FAA Part 107 Flight Operations

### 🛠️ Tools & Technologies

| Category | Tools & Frameworks |
|----------|--------------------|
| Security & Cloud | Prisma (AIRS), XSOAR automation, Terraform, AWS Config, HashiCorp Vault |
| AI & Data | Python, PyTorch, PyRIT, LLM evaluation frameworks, TensorFlow |
| Automation | Scripting (Bash, Python), Workflow engines, GitHub Actions, CI/CD |
| Container & API | Docker, Kubernetes, API Gateway security, Falco |
| Hardware & Flight | Custom drone builds, Pixhawk controllers, MAVLink telemetry, PX4 firmware |

### 📜 Certifications

- ✈️ **FAA Part 107 Commercial Drone Pilot** — Certified for commercial UAS operations
- 🎓 **Master's in Artificial Intelligence** (In Progress) — Focus on autonomous systems security
- 📚 Additional certifications in cloud security and DevSecOps available upon request

### 🥁 Interests & Hobbies

- 🎸 Playing drums and bass guitar — rhythm keeps me grounded
- 🚁 Building and experimenting with autonomous flight, sensors, and safety systems
- 📹 Flying FPV and cinematic drones — combining engineering with creative storytelling
- 🤖 Learning new ways to merge AI with real-world robotics

### 📬 Connect
- 🐙 [GitHub](https://github.com/abooker30126) — Code and projects

</details>
