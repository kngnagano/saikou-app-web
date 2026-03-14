"use client";

interface Props {
  onClick: () => void;
}

export default function ProfileIcon({ onClick }: Props) {
  return (
    <button
      onClick={onClick}
      className="w-10 h-10 rounded-full bg-gray-300 flex items-center justify-center hover:bg-gray-400 transition"
      aria-label="プロフィール"
    >
      <span className="text-lg">👤</span>
    </button>
  );
}
