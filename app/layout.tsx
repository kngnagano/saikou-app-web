import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Saikou!",
  description: "習慣継続アプリ",
  manifest: "/manifest.json",
  themeColor: "#f5f5f5",
  viewport: "width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="ja">
      <body className="concrete-texture">{children}</body>
    </html>
  );
}
