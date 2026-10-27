FROM python:3.13-slim-bookworm
WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
COPY requirements.txt ./
RUN python -m pip install --no-cache-dir -r requirements.txt
COPY manage.py ./
COPY config/ ./config/
COPY web/ ./web/
RUN python manage.py collectstatic --noinput
ENV PORT=8080
EXPOSE 8080
CMD ["/bin/sh", "-c", "exec python -m gunicorn config.wsgi:application --bind 0.0.0.0:${PORT:-8080}"]
