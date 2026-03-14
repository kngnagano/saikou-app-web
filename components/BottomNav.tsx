"use client";

import Link from "next/link";

interface Props {
  current: "home" | "friends" | "invite";
}

export default function BottomNav({ current }: Props) {
  const links = [
    { href: "/", label: "ホーム", key: "home" },
    { href: "/friends", label: "フレンド", key: "friends" },
    { href: "/invite", label: "招待", key: "invite" },
  ];

  return (
    <nav className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 shadow-lg bottom-nav-safe">
      <div className="flex justify-around items-center h-16">
        {links.map((link) => (
          <Link
            key={link.key}
            href={link.href}
            className={`flex-1 text-center py-2 transition ${
              current === link.key
                ? "text-blue-600 font-bold"
                : "text-gray-500"
            }`}
          >
            {link.label}
          </Link>
        ))}
      </div>
    </nav>
  );
}
