export const dynamic = "force-dynamic";

export function GET() {
  return Response.json({ status: "ok", port: process.env.PORT ?? "not set" });
}
