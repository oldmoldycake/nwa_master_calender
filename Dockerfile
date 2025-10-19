# --- STAGE 1: Build the React Frontend (Node/TypeScript) ---
FROM node:20-alpine AS frontend-builder
WORKDIR /nwa_calender/frontend

# Copy and install dependencies first for faster caching
COPY frontend/package.json frontend/package-lock.json ./
RUN npm install

# Copy source and build the app
COPY frontend/ ./
# Run the build command to generate static files
RUN npm run build 

# --- STAGE 2: Run the Flask Backend & Serve Frontend (Python) ---
FROM python:3.11-slim

# Set the Flask application working directory
WORKDIR /nwa_calender

# Install Python dependencies (Flask, Gunicorn)
COPY backend/requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copy Flask backend code
COPY backend/ /app/

# Copy the built React static files into Flask's designated static folder
# Flask typically serves static files from a 'static' folder.
# The 'build' folder created by React is copied inside of Flask's static path.
COPY --from=frontend-builder /nwa_calender/frontend/build /app/static/

# Cloud Run requires the container to listen on the port specified by the PORT environment variable.
ENV PORT 8080
EXPOSE 8080

# Command to start your Flask application with Gunicorn
# 'app' is the module (app.py) and 'app' is the Flask application instance inside the module
#CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"]4