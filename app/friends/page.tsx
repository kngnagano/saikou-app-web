"use client";

import { useEffect, useState } from "react";
import { Friend } from "@/lib/types";
import { getFriends, saveFriends } from "@/lib/storage";
import BottomNav from "@/components/BottomNav";
import ProfileIcon from "@/components/ProfileIcon";

export default function Friends() {
  const [friends, setFriends] = useState<Friend[]>([]);
  const [editingId, setEditingId] = useState<string | null>(null);

  useEffect(() => {
    setFriends(getFriends());
  }, []);

  const updateFriend = (
    id: string,
    updates: Partial<Omit<Friend, "id">>
  ) => {
    const updated = friends.map((f) =>
      f.id === id ? { ...f, ...updates } : f
    );
    setFriends(updated);
    saveFriends(updated);
  };

  const getStatusEmoji = (status: 0 | 1 | 2 | 3) => {
    if (status === 0) return "○";
    if (status === 3) return "★";
    return "●";
  };

  return (
    <div className="min-h-screen pb-24">
      <div className="max-w-2xl mx-auto p-6">
        <div className="flex justify-between items-center mb-6">
          <h1 className="text-2xl font-bold text-darkGray">フレンド</h1>
          <ProfileIcon onClick={() => {}} />
        </div>

        <p className="text-sm text-gray-500 mb-4">
          ※MVP版：フレンドのステータスは手動設定です
        </p>

        {friends.length === 0 ? (
          <div className="card text-center text-gray-500">
            <p>まだフレンドがいません</p>
            <p className="text-sm mt-2">招待ページからフレンドを追加しましょう</p>
          </div>
        ) : (
          friends.map((friend) => (
            <div key={friend.id} className="card">
              {editingId === friend.id ? (
                <div>
                  <input
                    type="text"
                    value={friend.name}
                    onChange={(e) =>
                      updateFriend(friend.id, { name: e.target.value })
                    }
                    className="w-full px-3 py-2 border rounded mb-3"
                    placeholder="名前"
                  />
                  <div className="mb-3">
                    <label className="block text-sm mb-1">継続日数</label>
                    <input
                      type="number"
                      value={friend.streak}
                      onChange={(e) =>
                        updateFriend(friend.id, {
                          streak: parseInt(e.target.value) || 0,
                        })
                      }
                      className="w-full px-3 py-2 border rounded"
                    />
                  </div>
                  <div className="mb-3">
                    <label className="block text-sm mb-2">今日の達成状況</label>
                    <div className="flex gap-2">
                      <button
                        onClick={() =>
                          updateFriend(friend.id, { todayStatus: 0 })
                        }
                        className={`flex-1 py-2 rounded ${
                          friend.todayStatus === 0
                            ? "bg-red-500 text-white"
                            : "bg-gray-200"
                        }`}
                      >
                        未達
                      </button>
                      <button
                        onClick={() =>
                          updateFriend(friend.id, { todayStatus: 1 })
                        }
                        className={`flex-1 py-2 rounded ${
                          friend.todayStatus === 1 || friend.todayStatus === 2
                            ? "bg-blue-500 text-white"
                            : "bg-gray-200"
                        }`}
                      >
                        1-2達成
                      </button>
                      <button
                        onClick={() =>
                          updateFriend(friend.id, { todayStatus: 3 })
                        }
                        className={`flex-1 py-2 rounded ${
                          friend.todayStatus === 3
                            ? "bg-yellow-500 text-white"
                            : "bg-gray-200"
                        }`}
                      >
                        3達成
                      </button>
                    </div>
                  </div>
                  <button
                    onClick={() => setEditingId(null)}
                    className="btn-secondary w-full"
                  >
                    完了
                  </button>
                </div>
              ) : (
                <div className="flex items-center justify-between">
                  <div className="flex-1">
                    <p className="font-bold text-lg">{friend.name}</p>
                    <p className="text-sm text-gray-600">
                      継続: {friend.streak}日
                    </p>
                  </div>
                  <div className="flex items-center gap-3">
                    <span className="text-3xl">
                      {getStatusEmoji(friend.todayStatus)}
                    </span>
                    <button
                      onClick={() => setEditingId(friend.id)}
                      className="text-blue-500 text-sm"
                    >
                      編集
                    </button>
                  </div>
                </div>
              )}
            </div>
          ))
        )}
      </div>

      <BottomNav current="friends" />
    </div>
  );
}
