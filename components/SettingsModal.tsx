"use client";

interface Props {
  userName: string;
  onClose: () => void;
}

export default function SettingsModal({ userName, onClose }: Props) {
  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-6">
      <div className="bg-white rounded-xl p-6 max-w-md w-full">
        <h2 className="text-xl font-bold mb-4">設定</h2>

        <div className="mb-4">
          <p className="text-sm text-gray-600 mb-1">表示名</p>
          <p className="font-bold">{userName}</p>
        </div>

        <div className="mb-4">
          <p className="text-sm font-bold mb-2">通知設定（予定）</p>
          <div className="bg-gray-100 rounded-lg p-3 text-sm">
            <p className="mb-1">🌅 朝の通知: 6:00 - 8:00</p>
            <p>🌙 夜の通知: 21:00 - 24:00 (毎時)</p>
          </div>
          <p className="text-xs text-gray-500 mt-2">
            ※現在は表示のみです。プッシュ通知は今後実装予定です。
          </p>
        </div>

        <button onClick={onClose} className="btn-primary w-full">
          閉じる
        </button>
      </div>
    </div>
  );
}
