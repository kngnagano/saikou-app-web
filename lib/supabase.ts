import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

export interface DbUser {
  id: string;
  display_name: string;
  invite_code: string;
  created_at: string;
}

export interface DbTask {
  id: string;
  user_id: string;
  slot_number: number;
  task_text: string;
  created_at: string;
}

export interface DbDailyStatus {
  id: string;
  user_id: string;
  date: string;
  done_count: number;
  task_1_done: boolean;
  task_2_done: boolean;
  task_3_done: boolean;
  is_committed: boolean;
  created_at: string;
}
