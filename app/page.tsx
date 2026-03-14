"use client";

import { useEffect, useState } from "react";
import { User, DailyRecord } from "@/lib/types";
import {
  getUserId,
  loadUser,
  createUser,
  getTodayString,
  calculateStreak,
  getNextGoal,
  updateTask,
  getTodayStatus,
  upsertDailyStatus,
} from "@/lib/storage";
import BottomNav from "@/components/BottomNav";
import ProfileIcon from "@/components/ProfileIcon";
import WeeklyView from "@/components/WeeklyView";
import TaskList from "@/components/TaskList";
import SettingsModal from "@/components/SettingsModal";

export default function Home() {
  const [user, setUser] = useState<User | null>(null);
  const [displayName, setDisplayName] = useState("");
  const [isSetup, setIsSetup] = useState(false);
  const [showSettings, setShowSettings] = useState(false);
  const [todayDone, setTodayDone] = useState<boolean[]>([false, false, false]);
  const [isCommitted, setIsCommitted] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    initApp();
  }, []);

  const initApp = async () => {
    const userId = getUserId();
    if (userId) {
      const userData = await loadUser(userId);
      if (userData) {
        setUser(userData);
        setIsSetup(true);

        const today = getTodayString();
        const todayStatus = await getTodayStatus(userId, today);
        if (todayStatus) {
          setTodayDone([
            todayStatus.task_1_done,
            todayStatus.task_2_done,
            todayStatus.task_3_done,
          ]);
          setIsCommitted(todayStatus.is_committed);
        }
      }
    }
    setLoading(false);
  };

  const handleSetup = async () => {
    if (displayName.trim()) {
      const newUser = await createUser(displayName.trim());
      if (newUser) {
        setUser(newUser);
        setIsSetup(true);
      }
    }
  };

  const handleCommit = async () => {
    if (!user) return;
    const today = getTodayString();

    const success = await upsertDailyStatus(user.id, today, todayDone, true);
    if (success) {
      setIsCommitted(true);
      const updatedUser = await loadUser(user.id);
      if (updatedUser) {
        setUser(updatedUser);
      }
    }
  };

  const handleTaskToggle = async (slotNumber: number) => {
    if (!user || isCommitted) return;

    const newDone = [...todayDone];
    newDone[slotNumber - 1] = !newDone[slotNumber - 1];
    setTodayDone(newDone);

    await upsertDailyStatus(user.id, getTodayString(), newDone, false);
  };

  const handleTaskEdit = async (slotNumber: number, newText: string) => {
    if (!user) return;

    const success = await updateTask(user.id, slotNumber, newText);
    if (success) {
      const updatedUser = await loadUser(user.id);
      if (updatedUser) {
        setUser(updatedUser);
      }
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <p className="text-gray-500">読み込み中...</p>
      </div>
    );
  }

  if (!isSetup) {
    return (
      <div className="min-h-screen flex items-center justify-center p-6">
        <div className="card max-w-md w-full text-center">
          <h1 className="text-3xl font-bold mb-6 text-darkGray">Saikou!</h1>
          <p className="text-gray-600 mb-6">あなたの表示名を入力してください</p>
          <input
            type="text"
            placeholder="表示名"
            value={displayName}
            onChange={(e) => setDisplayName(e.target.value)}
            className="w-full px-4 py-3 border border-gray-300 rounded-lg mb-4 focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
          <button onClick={handleSetup} className="btn-primary w-full">
            始める
          </button>
        </div>
      </div>
    );
  }

  if (!user) return null;

  const streak = calculateStreak(user.history);
  const nextGoal = getNextGoal(streak);
  const daysUntilGoal = nextGoal - streak;

  return (
    <div className="min-h-screen pb-24">
      <div className="max-w-2xl mx-auto p-6">
        <div className="flex justify-between items-center mb-6">
          <h1 className="text-2xl font-bold text-darkGray">Saikou!</h1>
          <ProfileIcon onClick={() => setShowSettings(true)} />
        </div>

        <div className="card text-center">
          <p className="text-4xl font-bold text-blue-600 mb-2">継続日数</p>
          <p className="text-6xl font-extrabold text-darkGray">{streak}日</p>
        </div>

        <WeeklyView history={user.history} />

        <div className="card text-center mb-4">
          <p className="text-gray-600">次の目標まで</p>
          <p className="text-2xl font-bold text-darkGray">あと{daysUntilGoal}日</p>
        </div>

        <TaskList
          tasks={user.tasks}
          todayDone={todayDone}
          isCommitted={isCommitted}
          onToggle={handleTaskToggle}
          onEdit={handleTaskEdit}
        />

        <button
          onClick={handleCommit}
          disabled={isCommitted}
          className="btn-primary w-full text-xl"
        >
          {isCommitted ? "本日は確定済み" : "今日を確定"}
        </button>
      </div>

      <BottomNav current="home" />
      {showSettings && (
        <SettingsModal
          userName={user.displayName}
          onClose={() => setShowSettings(false)}
        />
      )}
    </div>
  );
}
