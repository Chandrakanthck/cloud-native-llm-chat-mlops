\# Cloud-Native LLM Chat Microservice (FastAPI + Gemini)



A simple AI chat microservice that exposes a `/chat` REST endpoint using FastAPI and integrates with Google's Gemini API to generate responses from user prompts.



\## Features



\- `POST /chat` endpoint that accepts a JSON body with a `message` field and returns an AI-generated `reply`.

\- `GET /health` endpoint for basic health checks (used by load balancers / Kubernetes probes).

\- Environment-based configuration with `.env` and `GEMINI\_API\_KEY`.

\- (Planned) Containerization with Docker and deployment manifests for Kubernetes/EKS.



\## Tech Stack



\- Python, FastAPI, Uvicorn

\- Google Gemini API (`google-genai`)

\- python-dotenv for environment variables

\- (Planned) Docker, Kubernetes, AWS EKS, Terraform



\## Running Locally



1\. Clone the repository



2\. Create a `.env` file in the project root:



&#x20;  ```bash

&#x20;  GEMINI\_API\_KEY=your\_real\_key\_here

&#x20;  ```



3\. Install dependencies:



&#x20;  ```bash

&#x20;  pip install -r requirements.txt

&#x20;  ```



4\. Start the API:



&#x20;  ```bash

&#x20;  python -m uvicorn app.main:app --reload

&#x20;  ```



5\. Open the docs at:



&#x20;  - `http://127.0.0.1:8000/docs`



&#x20;  Use the `/chat` endpoint with a JSON body like:



&#x20;  ```json

&#x20;  {

&#x20;    "message": "Explain Kubernetes in simple words"

&#x20;  }

&#x20;  ```



\## Kubernetes Manifests



\- `k8s/deployment.yaml` defines a `Deployment` with readiness and liveness probes calling `/health` on port 8000.

\- `k8s/service.yaml` defines a `LoadBalancer` `Service` that exposes the app on port 80 and forwards to 8000.



These are ready to be applied to a cluster (e.g., EKS) once the Docker image is built and published.

