const { cp } = require("node:fs/promises");
const path = require("node:path");

const root = process.cwd();

async function main() {
  await Promise.all([
    cp(path.join(root, ".next/static"), path.join(root, ".next/standalone/.next/static"), {
      recursive: true,
    }),
    cp(path.join(root, "public"), path.join(root, ".next/standalone/public"), {
      recursive: true,
    }),
  ]);

  console.log("Copied Next.js static and public assets into the standalone output.");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
