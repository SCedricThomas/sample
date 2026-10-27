export default function Home() {
  return (
    <main>
      <img src="/scalingo.svg" alt="Scalingo" width="184" height="48" />
      <h1>Next.js standalone on Scalingo</h1>
      <p>
        This page is rendered by Next.js. Its production bundle and static
        assets were prepared during the Dockerfile build.
      </p>
      <a href="/api/health">Check the runtime health route</a>
    </main>
  );
}
