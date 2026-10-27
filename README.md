# Next.js Dockerfile sample for Scalingo

This branch is based on Scalingo's public [Next.js standalone sample](https://github.com/Scalingo/sample-nextjs-standalone)
and its [standalone deployment guide](https://doc.scalingo.com/languages/nodejs/nextjs-standalone).
It is a compact Next.js app with a production build and a post-build asset-copy
step.

The Dockerfile exercises build arguments, dependency installation, cache-friendly
copy layers, a framework build, a Node.js build script, standalone output, and
runtime environment variables. It stays single-stage because multi-stage builds
are not supported by the native Dockerfile buildpack.

## Run locally

```sh
docker build -t scalingo-sample-nextjs .
docker run --rm --user 10000:10000 -e PORT=8080 -p 127.0.0.1:8080:8080 scalingo-sample-nextjs
```

Then open `http://127.0.0.1:8080/` or check `http://127.0.0.1:8080/api/health`.

## Deploy to Scalingo

1. Publish the companion `scalingo-docker-buildpack` repository to a reachable
   Git URL.
2. Set the app's `BUILDPACK_URL` to that URL:

   ```sh
   scalingo --app YOUR-APP env-set BUILDPACK_URL=https://github.com/SCedricThomas/test-buildpack
   ```

3. Deploy this branch through Scalingo's Git integration or Git remote. Select
   the `node` branch for automated deployment.

No `PROJECT_DIR` or Procfile is needed: the Dockerfile is at the root, and the
buildpack derives the web process from the image startup command.

The standalone server listens on `$PORT` and binds to `0.0.0.0`. A successful
deployment with the native runner remains to be verified.
