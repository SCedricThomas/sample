# Rust Dockerfile sample for Scalingo

This branch contains a standalone Rust HTTP application and a
single-stage Dockerfile that builds it from source. The `go`, `rust`, and `java`
branches are independent deployment examples.

## Run locally

```sh
docker build -t scalingo-sample-rust .
docker run --rm --user 10000:10000 -e PORT=8080 -p 127.0.0.1:8080:8080 scalingo-sample-rust
```

In another terminal:

```sh
curl http://127.0.0.1:8080/
curl http://127.0.0.1:8080/health
```

The application listens on `0.0.0.0:$PORT` (default `8080`). `/` returns
`Hello from Rust`; `/health` returns `ok`.

## Deploy to Scalingo

1. Publish the companion `scalingo-docker-buildpack` repository to a reachable
   Git URL.
2. Set your app's `BUILDPACK_URL` to that URL:

   ```sh
   scalingo --app YOUR-APP env-set BUILDPACK_URL=https://github.com/YOUR-ORG/scalingo-docker-buildpack
   ```

3. Deploy this branch through Scalingo's Git integration or Git remote. Select
   the `rust` branch when configuring automated deployment.

No `PROJECT_DIR` or Procfile is needed: the Dockerfile is at the root, and the
buildpack derives the default web process from the image's startup command.

The samples passed local Docker and buildpack integration tests with no Linux
capabilities. Live Scalingo deployment still needs verification; the buildpack
requires permitted tracing of its own child processes (`ptrace`).
