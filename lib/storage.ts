import { supabase, DbUser, DbTask, DbDailyStatus } from './supabase';
import { User, Task, DailyRecord, Friend } from './types';

const USER_ID_KEY = 'saikou_user_id';
const FRIENDS_KEY = 'saikou_friends';

export const getUserId = (): string | null => {
  if (typeof window === 'undefined') return null;
  return localStorage.getItem(USER_ID_KEY);
};

export const saveUserId = (userId: string) => {
  if (typeof window === 'undefined') return;
  localStorage.setItem(USER_ID_KEY, userId);
};

export const createUser = async (displayName: string): Promise<User | null> => {
  const inviteCode = `${displayName.slice(0, 3)}-${Math.floor(1000 + Math.random() * 9000)}`;
  
  const { data: userData, error: userError } = await supabase
    .from('users')
    .insert([{ display_name: displayName, invite_code: inviteCode }])
    .select()
    .single();

  if (userError || !userData) {
    console.error('Error creating user:', userError);
    return null;
  }

  const defaultTasks = [
    { user_id: userData.id, slot_number: 1, task_text: '朝の運動' },
    { user_id: userData.id, slot_number: 2, task_text: '読書30分' },
    { user_id: userData.id, slot_number: 3, task_text: '瞑想10分' },
  ];

  const { error: tasksError } = await supabase
    .from('tasks')
    .insert(defaultTasks);

  if (tasksError) {
    console.error('Error creating tasks:', tasksError);
  }

  saveUserId(userData.id);

  return {
    id: userData.id,
    displayName: userData.display_name,
    inviteCode: userData.invite_code,
    tasks: defaultTasks.map((t, i) => ({
      id: `temp-${i}`,
      slot_number: t.slot_number,
      text: t.task_text,
    })),
    history: [],
  };
};

export const loadUser = async (userId: string): Promise<User | null> => {
  const { data: userData, error: userError } = await supabase
    .from('users')
    .select('*')
    .eq('id', userId)
    .single();

  if (userError || !userData) {
    console.error('Error loading user:', userError);
    return null;
  }

  const { data: tasksData, error: tasksError } = await supabase
    .from('tasks')
    .select('*')
    .eq('user_id', userId)
    .order('slot_number', { ascending: true });

  if (tasksError) {
    console.error('Error loading tasks:', tasksError);
    return null;
  }

  const { data: statusData, error: statusError } = await supabase
    .from('daily_status')
    .select('*')
    .eq('user_id', userId)
    .order('date', { ascending: false })
    .limit(30);

  if (statusError) {
    console.error('Error loading daily status:', statusError);
  }

  const history: DailyRecord[] = (statusData || []).map((s) => ({
    date: s.date,
    done: [s.task_1_done, s.task_2_done, s.task_3_done],
    done_count: s.done_count,
    committed: s.is_committed,
  }));

  return {
    id: userData.id,
    displayName: userData.display_name,
    inviteCode: userData.invite_code,
    tasks: tasksData.map((t) => ({
      id: t.id,
      slot_number: t.slot_number,
      text: t.task_text,
    })),
    history,
  };
};

export const updateTask = async (
  userId: string,
  slotNumber: number,
  newText: string
): Promise<boolean> => {
  const { error } = await supabase
    .from('tasks')
    .update({ task_text: newText })
    .eq('user_id', userId)
    .eq('slot_number', slotNumber);

  if (error) {
    console.error('Error updating task:', error);
    return false;
  }

  return true;
};

export const getTodayStatus = async (
  userId: string,
  date: string
): Promise<DbDailyStatus | null> => {
  const { data, error } = await supabase
    .from('daily_status')
    .select('*')
    .eq('user_id', userId)
    .eq('date', date)
    .single();

  if (error && error.code !== 'PGRST116') {
    console.error('Error loading today status:', error);
  }

  return data || null;
};

export const upsertDailyStatus = async (
  userId: string,
  date: string,
  done: boolean[],
  isCommitted: boolean
): Promise<boolean> => {
  const doneCount = done.filter(Boolean).length;

  const { error } = await supabase
    .from('daily_status')
    .upsert(
      {
        user_id: userId,
        date,
        task_1_done: done[0] || false,
        task_2_done: done[1] || false,
        task_3_done: done[2] || false,
        done_count: doneCount,
        is_committed: isCommitted,
      },
      { onConflict: 'user_id,date' }
    );

  if (error) {
    console.error('Error upserting daily status:', error);
    return false;
  }

  return true;
};

export const calculateStreak = (history: DailyRecord[]): number => {
  const sorted = [...history]
    .filter((h) => h.committed)
    .sort((a, b) => b.date.localeCompare(a.date));

  let streak = 0;

  for (let i = 0; i < sorted.length; i++) {
    const record = sorted[i];
    if (record.done_count >= 1) {
      streak++;
    } else {
      break;
    }

    if (i < sorted.length - 1) {
      const current = new Date(record.date);
      const next = new Date(sorted[i + 1].date);
      const diffDays = Math.floor(
        (current.getTime() - next.getTime()) / (1000 * 60 * 60 * 24)
      );
      if (diffDays > 1) break;
    }
  }

  return streak;
};

export const getNextGoal = (streak: number): number => {
  return Math.ceil((streak + 1) / 10) * 10;
};

export const getTodayString = (): string => {
  const today = new Date();
  return today.toISOString().split('T')[0];
};

export const getLast7Days = (): string[] => {
  const days = [];
  for (let i = 6; i >= 0; i--) {
    const date = new Date();
    date.setDate(date.getDate() - i);
    days.push(date.toISOString().split('T')[0]);
  }
  return days;
};

export const getDayOfWeekJP = (dateString: string): string => {
  const days = ['日', '月', '火', '水', '木', '金', '土'];
  const date = new Date(dateString);
  return days[date.getDay()];
};

export const getFriends = (): Friend[] => {
  if (typeof window === 'undefined') return [];
  const data = localStorage.getItem(FRIENDS_KEY);
  return data ? JSON.parse(data) : [];
};

export const saveFriends = (friends: Friend[]) => {
  if (typeof window === 'undefined') return;
  localStorage.setItem(FRIENDS_KEY, JSON.stringify(friends));
};
