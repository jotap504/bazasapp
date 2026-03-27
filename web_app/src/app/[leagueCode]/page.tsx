'use client';

import { useEffect, useState, use } from 'react';
import { supabase } from '@/lib/supabase';
import { Group, GroupMember } from '@/types/database';

export default function LeagueDashboard({ params }: { params: Promise<{ leagueCode: string }> }) {
  const { leagueCode } = use(params);
  const [group, setGroup] = useState<Group | null>(null);
  const [members, setMembers] = useState<GroupMember[]>([]);
  const [matches, setMatches] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState('ranking');
  const [expandedMatch, setExpandedMatch] = useState<string | null>(null);

  useEffect(() => {
    async function fetchData() {
      try {
        setLoading(true);
        // 1. Get Group by invite_code OR id
        let groupData: Group | null = null;
        const { data: byCode } = await supabase
          .from('groups')
          .select('*')
          .eq('invite_code', leagueCode.toUpperCase())
          .maybeSingle();

        if (byCode) {
          groupData = byCode;
        } else {
          // Intento por ID directo (UUID)
          const { data: byId } = await supabase
            .from('groups')
            .select('*')
            .eq('id', leagueCode)
            .maybeSingle();
          groupData = byId;
        }

        if (!groupData) throw new Error('Liga no encontrada');
        setGroup(groupData);

        // 2. Get Members (con perfil, sin el admin creador)
        const { data: memberData } = await supabase
          .from('group_members')
          .select('*, profile:profiles(display_name, nickname, avatar_url)')
          .eq('group_id', groupData.id)
          .order('total_championship_points', { ascending: false });

        // Excluir al creator/admin usando created_by del mismo groupData
        const adminUserId = (groupData as any).created_by;
        const filteredMembers = (memberData || []).filter((m: GroupMember) =>
          !adminUserId || m.user_id !== adminUserId
        );
        setMembers(filteredMembers);

        // 3. Get Matches con resultados y perfiles anidados
        const { data: matchData } = await supabase
          .from('matches')
          .select(`
            *,
            results:match_results(
              id,
              position_in_match,
              earned_championship_points,
              osadia_points,
              accuracy_percent,
              exact_predictions,
              total_match_rounds,
              requested_bazas,
              osadia_bazas_won,
              user_id,
              guest_member_id,
              profile:profiles(display_name, nickname)
            )
          `)
          .eq('group_id', groupData.id)
          .order('played_at', { ascending: false })
          .limit(20);

        setMatches(matchData || []);
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    }

    fetchData();
  }, [leagueCode]);

  if (loading) {
    return (
      <div className="full-viewport flex-center">
        <div className="neon-text-cyan heading heading-medium">CARGANDO...</div>
      </div>
    );
  }

  if (!group) {
    return (
      <div className="full-viewport flex-column flex-center p-24 text-center">
        <h2 className="neon-text-orange m-b-16">LIGA NO ENCONTRADA</h2>
        <p className="text-secondary m-b-32">El código {leagueCode} no corresponde a ninguna liga activa.</p>
        <button className="button-primary glass" onClick={() => window.location.href = '/'}>VOLVER</button>
      </div>
    );
  }

  return (
    <div className="p-layout">
      <header className="m-b-32">
        <div className="flex-between m-b-8">
          <h1 className="neon-text-cyan heading-large">{group.name}</h1>
          <div className={`badge ${group.status === 'closed' ? 'badge-orange' : 'badge-green'}`}>
            {group.status === 'closed' ? 'FINALIZADO' : 'EN CURSO'}
          </div>
        </div>
        <p className="text-muted text-xs" style={{ letterSpacing: '1px' }}>CÓDIGO: {group.invite_code}</p>
      </header>

      <div className="tab-bar">
        <div className={`tab-item ${activeTab === 'ranking' ? 'active' : ''}`} onClick={() => setActiveTab('ranking')}>RANKING</div>
        <div className={`tab-item ${activeTab === 'partidas' ? 'active' : ''}`} onClick={() => setActiveTab('partidas')}>PARTIDAS</div>
        <div className={`tab-item ${activeTab === 'hof' ? 'active' : ''}`} onClick={() => setActiveTab('hof')}>H.O.F</div>
      </div>

      <section>
        {activeTab === 'ranking' && <RankingTab members={members} group={group} />}
        {activeTab === 'partidas' && (
          <MatchesSection
            matches={matches}
            members={members}
            expandedMatch={expandedMatch}
            setExpandedMatch={setExpandedMatch}
            createdBy={(group as any).created_by}
          />
        )}
        {activeTab === 'hof' && <HallOfFameSection members={members} />}
      </section>
    </div>
  );
}

function RankingTab({ members, group }: { members: GroupMember[], group: Group }) {
  const sortedByPoints = [...members].sort((a, b) => b.total_championship_points - a.total_championship_points);
  const sortedByEffectiveness = [...members]
    .filter(m => (m.total_matches_played / (group.match_count || 1)) >= (group.min_attendance_pct / 100))
    .sort((a, b) => b.effective_avg_percent - a.effective_avg_percent);
  const sortedByOsadia = [...members].sort((a, b) => b.total_osadia_points - a.total_osadia_points);

  return (
    <div className="flex-between" style={{ alignItems: 'flex-start', gap: '8px' }}>
      <RankingColumn title="PTS" icon="🏆" color="var(--neon-cyan)" members={sortedByPoints} valueKey="total_championship_points" />
      <RankingColumn title="EFECT" icon="🎯" color="var(--neon-green)" members={sortedByEffectiveness} valueKey="effective_avg_percent" isPercent />
      <RankingColumn title="OSADÍA" icon="⚡" color="var(--neon-orange)" members={sortedByOsadia} valueKey="total_osadia_points" />
    </div>
  );
}

function RankingColumn({ title, icon, color, members, valueKey, isPercent }: any) {
  return (
    <div style={{ flex: 1, minWidth: 0 }}>
      <div className="flex-column flex-center m-b-16" style={{ gap: '4px' }}>
        <span style={{ fontSize: '20px' }}>{icon}</span>
        <span className="heading text-xs" style={{ color }}>{title}</span>
      </div>
      {members.map((m: any, i: number) => (
        <div key={m.id} className="flex-column flex-center m-b-8">
          <div className="text-tiny heading" style={{ color: i === 0 ? 'var(--neon-orange)' : 'white' }}>
            {m.profile?.nickname || m.guest_nickname || 'Inv.'}
          </div>
          <div className="text-xs" style={{ color, fontWeight: 'bold' }}>
            {isPercent ? `${Math.round(m[valueKey])}%` : Math.round(m[valueKey])}
          </div>
        </div>
      ))}
    </div>
  );
}

function getResultName(res: any, members: GroupMember[]): string {
  // 1. Si tiene perfil anidado (usuario registrado)
  if (res.profile?.nickname) return res.profile.nickname;
  if (res.profile?.display_name) return res.profile.display_name;
  // 2. Si es invitado, buscar en la lista de miembros por guest_member_id
  if (res.guest_member_id) {
    const guestMember = members.find(m => m.id === res.guest_member_id);
    if (guestMember) return guestMember.guest_nickname || guestMember.guest_full_name || 'Invitado';
  }
  return 'Jugador';
}

function MatchesSection({ matches, members, expandedMatch, setExpandedMatch, createdBy }: {
  matches: any[], members: GroupMember[], expandedMatch: string | null, setExpandedMatch: (id: string | null) => void, createdBy?: string
}) {
  if (matches.length === 0) {
    return <div className="p-24 text-center text-muted">No hay partidas registradas aún.</div>;
  }

  return (
    <div className="flex-column">
      {matches.map((match) => {
        const dateStr = new Date(match.played_at).toLocaleDateString('es-AR', { day: '2-digit', month: '2-digit', year: '2-digit' });
        const isExpanded = expandedMatch === match.id;
        // Filtrar al admin del desglose
        const results = (match.results || [])
          .filter((r: any) => r.user_id !== createdBy)
          .sort((a: any, b: any) => a.position_in_match - b.position_in_match);

        return (
          <div key={match.id} className="glass m-b-16" style={{ borderRadius: '16px', overflow: 'hidden' }}>
            {/* Header de la partida */}
            <div
              className="flex-between p-24"
              style={{ cursor: 'pointer', borderBottom: isExpanded ? '1px solid rgba(255,255,255,0.1)' : 'none' }}
              onClick={() => setExpandedMatch(isExpanded ? null : match.id)}
            >
              <div>
                <div className="heading text-small neon-text-cyan">{dateStr}</div>
                <div className="text-xs text-muted" style={{ marginTop: '4px' }}>
                  {results.length} jugadores · {match.is_official ? '✅ OFICIAL' : '⏳ RECREATIVA'}
                </div>
              </div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                {/* Top 3 resumen */}
                <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-end', gap: '2px' }}>
                  {results.slice(0, 3).map((r: any) => (
                    <div key={r.id} className="text-tiny" style={{ color: r.position_in_match === 1 ? 'var(--neon-orange)' : 'var(--text-secondary)' }}>
                      {r.position_in_match}º {getResultName(r, members)}
                    </div>
                  ))}
                </div>
                <span className="text-muted text-xs">{isExpanded ? '▲' : '▼'}</span>
              </div>
            </div>

            {/* Desglose expandible */}
            {isExpanded && (
              <div className="p-24">
                <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '12px' }}>
                  <thead>
                    <tr style={{ borderBottom: '1px solid rgba(255,255,255,0.1)' }}>
                      <th style={{ textAlign: 'left', padding: '4px 0', color: 'var(--text-muted)', letterSpacing: '1px' }}>JUGADOR</th>
                      <th style={{ textAlign: 'center', padding: '4px', color: 'var(--neon-cyan)' }}>🏆 PTS</th>
                      <th style={{ textAlign: 'center', padding: '4px', color: 'var(--neon-orange)' }}>⚡ OSA</th>
                      <th style={{ textAlign: 'center', padding: '4px', color: 'var(--neon-green)' }}>🎯 EFE</th>
                    </tr>
                  </thead>
                  <tbody>
                    {results.map((r: any) => {
                      const name = getResultName(r, members);
                      const isWinner = r.position_in_match === 1;
                      const champPts = Math.round(r.earned_championship_points || 0);
                      const osaPts = Math.round(r.osadia_points || 0);
                      const accuracy = Math.round(r.accuracy_percent || 0);

                      return (
                        <tr key={r.id} style={{ borderBottom: '1px solid rgba(255,255,255,0.05)' }}>
                          <td style={{ padding: '8px 0' }}>
                            <span className="heading" style={{ color: isWinner ? 'var(--neon-orange)' : 'white', marginRight: '6px' }}>{r.position_in_match}º</span>
                            <span style={{ color: isWinner ? 'var(--neon-orange)' : 'white' }}>{name}</span>
                          </td>
                          <td style={{ textAlign: 'center', padding: '8px 4px', color: 'var(--neon-cyan)', fontWeight: 'bold' }}>{champPts}</td>
                          <td style={{ textAlign: 'center', padding: '8px 4px', color: 'var(--neon-orange)' }}>{osaPts}</td>
                          <td style={{ textAlign: 'center', padding: '8px 4px', color: 'var(--neon-green)' }}>{accuracy}%</td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        );
      })}
    </div>
  );
}

function HallOfFameSection({ members }: { members: GroupMember[] }) {
  const maxPlayed = Math.max(...members.map(m => m.total_matches_played), 0);
  const mostPlayed = members.filter(m => m.total_matches_played === maxPlayed && maxPlayed > 0);

  const maxFailed = Math.max(...members.map(m => m.total_failed_osadia), 0);
  const mostReckless = members.filter(m => m.total_failed_osadia === maxFailed && maxFailed > 0);

  const maxChamullero = Math.max(...members.map(m => m.total_chamullero_score || 0), 0);
  const mostChamullero = members.filter(m => (m.total_chamullero_score || 0) === maxChamullero && maxChamullero > 0);

  return (
    <div className="flex-column">
      <HofTile title="ASISTENCIA PERFECTA" winners={mostPlayed} stat={`${maxPlayed} partidas`} color="var(--neon-cyan)" />
      <HofTile title="EL CHARLATÁN" winners={mostReckless} stat={`${maxFailed} fallidas`} color="var(--neon-orange)" />
      <HofTile title="EL CHAMULLERO" winners={mostChamullero} stat={`${maxChamullero} bazas`} color="#90a4ae" />
    </div>
  );
}

function HofTile({ title, winners, stat, color }: { title: string, winners: GroupMember[], stat: string, color: string }) {
  if (winners.length === 0) return null;
  const names = winners.map(m => m.profile?.nickname || m.guest_nickname).join(', ');

  return (
    <div className="glass card m-b-16" style={{ borderLeft: `4px solid ${color}` }}>
      <div className="text-xs heading m-b-8" style={{ color, letterSpacing: '1px' }}>{title}</div>
      <div className="heading heading-medium m-b-8">{names}</div>
      <div className="text-secondary text-tiny">{stat}</div>
    </div>
  );
}
