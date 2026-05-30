FROM python:3.13-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt gunicorn

COPY . .

ENV PORT=80
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 main:app