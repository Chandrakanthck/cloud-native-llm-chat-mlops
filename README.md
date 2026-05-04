# Cloud-Native LLM Chat Microservice (FastAPI + Gemini + AWS EKS)

A cloud‑ready AI chat microservice that exposes a `/chat` REST API using **FastAPI**, integrates with the **Google Gemini LLM API**, and is prepared for production deployment on **AWS EKS** using **Docker**, **Kubernetes**, and **Terraform**.

This project is designed to showcase **DevOps + AI (MLOps)** skills for fresher / junior roles.

---

## Architecture Overview

- **Application layer**
  - Python **FastAPI** app with:
    - `POST /chat` – sends the user’s `message` to Gemini and returns the AI reply.
    - `GET /health` – simple health check used by Kubernetes probes.
  - Secrets handled via environment variables / `.env` using `python-dotenv`.

- **Containerization**
  - `Dockerfile` builds a lightweight image running FastAPI with Uvicorn on port `8000`.

- **Kubernetes**
  - `k8s/deployment.yaml` – `Deployment` with:
    - 2 replicas
    - container port `8000`
    - readiness & liveness probes on `/health`
  - `k8s/service.yaml` – `LoadBalancer` `Service` exposing port `80` → pod port `8000`.

- **Infrastructure as Code (Terraform)**
  - `infra/` folder:
    - Provisions a **VPC** (public + private subnets, NAT Gateway).
    - Provisions an **EKS cluster** using official Terraform AWS modules.
    - Tags subnets correctly for Kubernetes load balancers.

- **Target Cloud Platform**
  - **AWS**: ECR (for container images) + EKS (for running the cluster).

---

## Tech Stack

- **Languages & Frameworks**
  - Python, FastAPI, Pydantic, Uvicorn

- **AI / LLM**
  - Google Gemini API (via `google-genai` SDK)

- **DevOps & Cloud**
  - Docker (containerization)
  - Kubernetes (EKS, Deployments, Services, probes)
  - Terraform (VPC + EKS provisioning)
  - AWS: VPC, Subnets, NAT Gateway, ECR, EKS

- **Config & Secrets**
  - `.env` + `python-dotenv` for `GEMINI_API_KEY`

---

## Project Structure

```text
cloud-native-llm-chat-mlops/
├── app/
│   ├── main.py           # FastAPI app (/chat, /health, Gemini integration)
│   └── __init__.py
├── k8s/
│   ├── deployment.yaml   # Kubernetes Deployment (replicas, probes, containerPort)
│   └── service.yaml      # Kubernetes Service (type LoadBalancer, port 80 -> 8000)
├── infra/
│   ├── main.tf           # Terraform: AWS provider, VPC + EKS modules
│   ├── variables.tf      # Terraform input variables (region, CIDRs, tags)
│   └── outputs.tf        # Terraform outputs (cluster name, endpoint, subnets)
├── Dockerfile            # FastAPI container image
├── requirements.txt      # Python dependencies
├── .env                  # Local env file (NOT committed) – holds GEMINI_API_KEY
├── .gitignore
└── README.md
```

---

## 1. Running the API locally (no Docker)

### Prerequisites

- Python 3.10+  
- Google Gemini API key (from [Google AI Studio](https://aistudio.google.com))

### Steps

1. **Clone the repo**

   ```bash
   git clone https://github.com/Chandrakanthck/cloud-native-llm-chat-mlops.git
   cd cloud-native-llm-chat-mlops
   ```

2. **Create `.env` file**

   In the project root:

   ```bash
   echo "GEMINI_API_KEY=your_real_key_here" > .env
   ```

3. **Install dependencies**

   ```bash
   pip install -r requirements.txt
   ```

4. **Run the FastAPI app**

   ```bash
   python -m uvicorn app.main:app --reload
   ```

5. **Test in browser**

   - Open: `http://127.0.0.1:8000/docs`
   - Use `POST /chat` with a JSON body, for example:

     ```json
     {
       "message": "Explain Kubernetes in simple words."
     }
     ```

   - You should receive an AI-generated `"reply"` from Gemini.
   - Check `GET /health` to see `{ "status": "ok" }`.

---

## 2. Docker (containerization)

> Note: Docker build/run can be executed on a machine with Docker installed (local or cloud VM).

### Build image

```bash
docker build -t gemini-chat-api:latest .
```

### Run container

```bash
docker run -p 8000:8000 --env-file .env gemini-chat-api:latest
```

Then:

- Visit `http://127.0.0.1:8000/docs` → test `/chat` and `/health` as before.

---

## 3. Kubernetes manifests (EKS-ready)

The `k8s/` directory contains manifests that can be applied to any Kubernetes cluster (Minikube, kind, EKS, etc.) once an image is available in a registry (e.g., ECR).

### Requirements

- A built image pushed to a registry, e.g.:

  ```text
  <aws-account-id>.dkr.ecr.<region>.amazonaws.com/gemini-chat-api:latest
  ```

- `kubectl` configured to talk to your cluster.

### Update image in `deployment.yaml`

Set the correct image:

```yaml
containers:
  - name: gemini-chat-container
    image: <aws-account-id>.dkr.ecr.<region>.amazonaws.com/gemini-chat-api:latest
    # ...
```

### Apply manifests

```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

- Check resources:

  ```bash
  kubectl get pods
  kubectl get svc
  ```

- When `Service` type `LoadBalancer` gets an external IP / hostname, test:

  - `http://<EXTERNAL-ADDRESS>/health`  
  - `http://<EXTERNAL-ADDRESS>/docs`

---

## 4. Terraform – AWS VPC + EKS

The `infra/` folder holds **Infrastructure as Code** for a minimal EKS cluster using official Terraform AWS modules.

> Recommended to run from **AWS Cloud9** or a small EC2 dev instance with Terraform and AWS CLI installed.

### Prerequisites

- Terraform 1.5+  
- AWS CLI configured (`aws configure`)  
- Sufficient IAM permissions for VPC + EKS + IAM + EC2

### Initialize and review

```bash
cd infra
terraform init
terraform plan
```

### Apply (creates VPC + EKS cluster)

```bash
terraform apply
```

After creation, outputs will include:

- `eks_cluster_name`  
- `eks_cluster_endpoint`  
- `vpc_id`, `private_subnets`, `public_subnets`

### Connect `kubectl` to EKS

Once the cluster exists:

```bash
aws eks update-kubeconfig \
  --region <your-region> \
  --name gemini-chat-eks
```

Now:

```bash
kubectl get nodes
```

should show your EKS worker nodes. Then apply the `k8s/` manifests as in section 3.

---

## 5. What this project demonstrates (for recruiters / interviewers)

This project is designed to prove the following skills:

- **AI Integration**
  - Calling a real LLM (Google Gemini) from a backend microservice.
  - Handling prompts, responses, and error handling in Python.

- **Backend Engineering**
  - FastAPI application design with typed request models (`ChatRequest`).
  - REST endpoints (`/chat`, `/health`) and OpenAPI docs (`/docs`).

- **DevOps / MLOps Fundamentals**
  - Containerizing the service with Docker for consistent deployment.
  - Writing Kubernetes manifests:
    - Deployments with replicas and probes.
    - Services (LoadBalancer) mapping port 80 → 8000.

- **Infrastructure as Code / Cloud**
  - Using Terraform to define AWS VPC networking (CIDRs, subnets, NAT).
  - Using Terraform to create an EKS cluster via well-known AWS modules.
  - Preparing the app to run as a managed Kubernetes workload on AWS.

---

## Future Improvements

- Add CI/CD (GitHub Actions or Jenkins) to build & push images to ECR on each commit.
- Add Prometheus metrics and a Grafana dashboard for observability.
- Add authentication (e.g., API key or JWT) around `/chat`.
- Add logging and request tracing for production debugging.

---

## License

This project is for learning and portfolio purposes. Feel free to explore the code and adapt it for your own educational use.
