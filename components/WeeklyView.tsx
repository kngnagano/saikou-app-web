"use client";

import { DailyRecord } from "@/lib/types";
import { getLast7Days, getDayOfWeekJP, getTodayString } from "@/lib/storage";

interface Props {
  history: DailyRecord[];
}

export default function WeeklyView({ history }: Props) {
  const last7Days = getLast7Days();
  const today = getTodayString();

  const getStatusForDay = (date: string) => {
    const record = history.find((r) => r.date === date);
    if (!record || !record.committed) return "empty";

    const doneCount = record.done_count;
    if (doneCount === 0) return "empty";
    if (doneCount === 3) return "star";
    return "circle";
  };

  return (
    <div className="card">
      <div className="flex justify-around items-center">
        {last7Days.map((date) => {
          const status = getStatusForDay(date);
          const isToday = date === today;

          return (
            <div key={date} className="text-center">
              <p className="text-xs text-gray-500 mb-1">
                {getDayOfWeekJP(date)}
              </p>
              <div
                className={`w-10 h-10 flex items-center justify-center rounded-full ${
                  isToday ? "ring-2 ring-red-500" : ""
                }`}
              >
                {status === "empty" && (
                  <div className="w-8 h-8 rounded-full border-2 border-gray-300"></div>
                )}
                {status === "circle" && (
                  <div className="w-8 h-8 rounded-full bg-blue-500"></div>
                )}
                {status === "star" && (
                  <span className="text-2xl text-yellow-500">★</span>
                )}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
