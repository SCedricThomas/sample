# Django Dockerfile sample for Scalingo

This branch contains a small Django application based on Scalingo's public
[Python Django sample](https://github.com/Scalingo/sample-python-django). Its
single-stage Dockerfile installs Python dependencies, copies the Django project,
collects static files, and starts the app with Gunicorn.

## Run locally

```sh
docker build -t scalingo-sample-django .
docker run --rm --user 10000:10000 -e PORT=8080 -p 127.0.0.1:8080:8080 scalingo-sample-django
```

In another terminal:

```sh
curl http://127.0.0.1:8080/
curl http://127.0.0.1:8080/health
```

The application listens on `0.0.0.0:$PORT` (default `8080`). `/` serves the
Django page and `/health` returns a JSON status.

## Deploy to Scalingo

1. Publish the companion `scalingo-docker-buildpack` repository to a reachable
   Git URL.
2. Set your app's `BUILDPACK_URL` to that URL:

   ```sh
   scalingo --app YOUR-APP env-set BUILDPACK_URL=https://github.com/SCedricThomas/test-buildpack
   ```

3. Deploy this branch through Scalingo's Git integration or Git remote. Select
   the `python` branch when configuring automated deployment.

No `PROJECT_DIR` or Procfile is needed: the Dockerfile is at the root, and the
buildpack derives the web process from the image startup command.

The buildpack runs the extracted Python runtime on the Scalingo stack. A
successful deployment with this native runner remains to be verified.
