"use client";

import { useEffect, useState } from "react";
import { getUser, getFriends, saveFriends } from "@/lib/storage";
import { Friend } from "@/lib/types";
import BottomNav from "@/components/BottomNav";
import ProfileIcon from "@/components/ProfileIcon";

export default function Invite() {
  const [inviteCode, setInviteCode] = useState("");
  const [friendCode, setFriendCode] = useState("");
  const [copied, setCopied] = useState(false);

  useEffect(() => {
    const user = getUser();
    if (user) {
      setInviteCode(user.inviteCode);
    }
  }, []);

  const handleCopy = () => {
    navigator.clipboard.writeText(inviteCode);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const handleAddFriend = () => {
    if (!friendCode.trim()) return;

    const friends = getFriends();
    const newFriend: Friend = {
      id: Date.now().toString(),
      name: friendCode.split("-")[0] || "フレンド",
      streak: 0,
      todayStatus: 0,
    };

    friends.push(newFriend);
    saveFriends(friends);
    setFriendCode("");
    alert("フレンドを追加しました！");
  };

  return (
    <div className="min-h-screen pb-24">
      <div className="max-w-2xl mx-auto p-6">
        <div className="flex justify-between items-center mb-6">
          <h1 className="text-2xl font-bold text-darkGray">招待</h1>
          <ProfileIcon onClick={() => {}} />
        </div>

        <div className="card">
          <h2 className="text-lg font-bold mb-3">あなたの招待コード</h2>
          <div className="bg-gray-100 rounded-lg p-4 text-center mb-4">
            <p className="text-2xl font-mono font-bold text-blue-600">
              {inviteCode}
            </p>
          </div>
          <button onClick={handleCopy} className="btn-primary w-full">
            {copied ? "コピーしました！" : "コピー"}
          </button>
        </div>

        <div className="card">
          <h2 className="text-lg font-bold mb-3">
            コードを入力してフレンド追加
          </h2>
          <input
            type="text"
            placeholder="招待コードを入力"
            value={friendCode}
            onChange={(e) => setFriendCode(e.target.value)}
            className="w-full px-4 py-3 border border-gray-300 rounded-lg mb-4 focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
          <button onClick={handleAddFriend} className="btn-primary w-full">
            追加
          </button>
        </div>

        <p className="text-xs text-gray-500 text-center mt-4">
          ※現在はMVP版のため、フレンド追加は手動です。本番環境では自動同期されます。
        </p>
      </div>

      <BottomNav current="invite" />
    </div>
  );
}
