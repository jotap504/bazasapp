export interface Group {
  id: string;
  name: string;
  description?: string;
  invite_code: string;
  status: 'open' | 'closed';
  min_quorum: number;
  min_attendance_pct: number;
  osadia_multiplier: number;
  f1_points_system?: number[];
  created_by?: string;
  created_at: string;
  closed_at?: string;
  match_count?: number;
}

export interface GroupMember {
  id: string;
  user_id?: string;
  guest_nickname?: string;
  guest_full_name?: string;
  role: string;
  total_championship_points: number;
  total_osadia_points: number;
  total_wins: number;
  total_matches_played: number;
  total_failed_osadia: number;
  total_chamullero_score: number;
  effective_avg_percent: number;
  count_accuracy_matches: number;
  sum_accuracy_percent: number;
  current_position?: number;
  previous_position?: number;
  profile?: {
    display_name?: string;
    nickname?: string;
    avatar_url?: string;
  };
}

export interface Match {
  id: string;
  group_id: string;
  played_at: string;
  location?: string;
  is_official: boolean;
  notes?: string;
  created_at: string;
  results?: MatchResult[];
}

export interface MatchResult {
  id: string;
  match_id: string;
  user_id?: string;
  guest_member_id?: string;
  position_in_match: number;
  exact_predictions: number;
  total_match_rounds: number;
  requested_bazas?: number;
  osadia_bazas_won?: number;
  accuracy_percent: number;
  earned_championship_points: number;
  osadia_points: number;
  profile?: {
    display_name?: string;
    nickname?: string;
  };
}
