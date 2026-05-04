# Use an official Python image
FROM python:3.12-slim

# Set work directory inside container
WORKDIR /app

# Copy dependency file and install
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY ./app ./app

# Expose port FastAPI will run on
EXPOSE 8000

# Environment variable for FastAPI/uvicorn (optional)
ENV PYTHONUNBUFFERED=1

# Run the app with uvicorn
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]