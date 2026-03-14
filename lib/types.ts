export interface Task {
  id: string;
  slot_number: number;
  text: string;
}

export interface DailyRecord {
  date: string;
  done: boolean[];
  done_count: number;
  committed: boolean;
}

export interface User {
  id: string;
  displayName: string;
  inviteCode: string;
  tasks: Task[];
  history: DailyRecord[];
}

export interface Friend {
  id: string;
  name: string;
  streak: number;
  todayStatus: 0 | 1 | 2 | 3;
}
