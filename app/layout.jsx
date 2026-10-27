import "./styles.css";

export const metadata = {
  title: "Scalingo Next.js Dockerfile sample",
  description: "A standalone Next.js app built from a Dockerfile.",
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
