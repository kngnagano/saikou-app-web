"use client";

import { useState } from "react";
import { Task } from "@/lib/types";

interface Props {
  tasks: Task[];
  todayDone: boolean[];
  isCommitted: boolean;
  onToggle: (slotNumber: number) => void;
  onEdit: (slotNumber: number, newText: string) => void;
}

export default function TaskList({
  tasks,
  todayDone,
  isCommitted,
  onToggle,
  onEdit,
}: Props) {
  const [isEditing, setIsEditing] = useState(false);
  const [editValues, setEditValues] = useState<{ [key: number]: string }>({});

  const handleEditStart = () => {
    setIsEditing(true);
    const values: { [key: number]: string } = {};
    tasks.forEach((task) => {
      values[task.slot_number] = task.text;
    });
    setEditValues(values);
  };

  const handleEditSave = () => {
    Object.entries(editValues).forEach(([slotNumber, text]) => {
      onEdit(parseInt(slotNumber), text);
    });
    setIsEditing(false);
  };

  return (
    <div className="card mb-4">
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-lg font-bold">今日のタスク</h2>
        {isEditing ? (
          <button onClick={handleEditSave} className="text-blue-500 text-sm">
            保存
          </button>
        ) : (
          <button onClick={handleEditStart} className="text-blue-500 text-sm">
            編集
          </button>
        )}
      </div>

      <div className="space-y-3">
        {tasks.map((task) => {
          const isChecked = todayDone[task.slot_number - 1] || false;

          return (
            <div key={task.id} className="flex items-center gap-3">
              <input
                type="checkbox"
                checked={isChecked}
                onChange={() => onToggle(task.slot_number)}
                disabled={isCommitted || isEditing}
                className="w-5 h-5 rounded border-gray-300"
              />
              {isEditing ? (
                <input
                  type="text"
                  value={editValues[task.slot_number] || ""}
                  onChange={(e) =>
                    setEditValues({
                      ...editValues,
                      [task.slot_number]: e.target.value,
                    })
                  }
                  className="flex-1 px-3 py-2 border rounded"
                />
              ) : (
                <span
                  className={`flex-1 ${
                    isChecked ? "line-through text-gray-400" : ""
                  }`}
                >
                  {task.text}
                </span>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
}
