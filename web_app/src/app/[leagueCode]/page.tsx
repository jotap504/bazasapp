'use client';

import { useEffect, useState, use } from 'react';
import { supabase } from '@/lib/supabase';
import { Group, GroupMember, Match, MatchResult } from '@/types/database';

export default function LeagueDashboard({ params }: { params: Promise<{ leagueCode: string }> }) {
  const { leagueCode } = use(params);
  const [group, setGroup] = useState<Group | null>(null);
  const [members, setMembers] = useState<GroupMember[]>([]);
  const [matches, setMatches] = useState<Match[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState('ranking');
  const [expandedMatch, setExpandedMatch] = useState<string | null>(null);
  const [selectedMember, setSelectedMember] = useState<GroupMember | null>(null);

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
        const adminUserId = groupData.created_by;
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
          .order('played_at', { ascending: true }); // Orden ascendente para gráficas temporales

        if (matchData) {
          setMatches(matchData as Match[]);
        }
      } catch (err: unknown) {
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

  // Partidas ordenadas en reversa para la pestaña de historial
  const matchesDesc = [...matches].sort((a, b) => new Date(b.played_at).getTime() - new Date(a.played_at).getTime());

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
        <div className={`tab-item ${activeTab === 'stats' ? 'active' : ''}`} onClick={() => setActiveTab('stats')}>ESTADÍSTICAS</div>
        <div className={`tab-item ${activeTab === 'hof' ? 'active' : ''}`} onClick={() => setActiveTab('hof')}>H.O.F</div>
      </div>

      <section>
        {activeTab === 'ranking' && <RankingTab members={members} group={group} onSelectMember={setSelectedMember} />}
        {activeTab === 'partidas' && (
          <MatchesSection
            matches={matchesDesc}
            members={members}
            expandedMatch={expandedMatch}
            setExpandedMatch={setExpandedMatch}
            createdBy={group?.created_by}
            onSelectMember={setSelectedMember}
          />
        )}
        {activeTab === 'stats' && <StatisticsSection members={members} matches={matches} createdBy={group?.created_by} onSelectMember={setSelectedMember} />}
        {activeTab === 'hof' && <HallOfFameSection members={members} onSelectMember={setSelectedMember} />}
      </section>

      {/* MODAL FICHA DE JUGADOR */}
      {selectedMember && (
        <PlayerDetailModal
          member={selectedMember}
          matches={matches}
          members={members}
          onClose={() => setSelectedMember(null)}
        />
      )}
    </div>
  );
}

// ── RESOLUCIÓN DE NOMBRES REALES EN WEB ─────────────────────────────
function getMemberDisplayName(member: GroupMember): string {
  if (member.guest_nickname && member.guest_nickname.trim()) return member.guest_nickname.trim();
  if (member.guest_full_name && member.guest_full_name.trim()) return member.guest_full_name.trim();
  if (member.profile?.nickname && member.profile.nickname.trim()) return member.profile.nickname.trim();
  if (member.profile?.display_name && member.profile.display_name.trim()) return member.profile.display_name.trim();
  return 'Jugador';
}

function getResultName(res: MatchResult, members: GroupMember[]): string {
  if (res.profile?.nickname && res.profile.nickname.trim()) return res.profile.nickname.trim();
  if (res.profile?.display_name && res.profile.display_name.trim()) return res.profile.display_name.trim();
  if (res.guest_member_id) {
    const guestMember = members.find(m => m.id === res.guest_member_id);
    if (guestMember) return getMemberDisplayName(guestMember);
  }
  return 'Jugador';
}

// ── MODAL DINÁMICO DE JUGADOR CON HISTORIAL Y BAZAS ACERTADAS/FALLADAS ──
function PlayerDetailModal({ member, matches, members, onClose }: {
  member: GroupMember; matches: Match[]; members: GroupMember[]; onClose: () => void;
}) {
  const name = getMemberDisplayName(member);

  const history: { match: Match; result: MatchResult; exact: number; failed: number }[] = [];
  let totalExact = 0;
  let totalFailed = 0;
  let totalPodiums = 0;

  const sortedMatches = [...matches].sort((a, b) => new Date(b.played_at).getTime() - new Date(a.played_at).getTime());

  for (const match of sortedMatches) {
    for (const res of match.results || []) {
      const matchesUser = (res.user_id && member.user_id && res.user_id === member.user_id);
      const matchesGuest = (res.guest_member_id && res.guest_member_id === member.id);

      if (matchesUser || matchesGuest) {
        const exact = res.exact_predictions || 0;
        const rounds = res.total_match_rounds || 10;
        const failed = Math.max(0, rounds - exact);

        totalExact += exact;
        totalFailed += failed;
        if (res.position_in_match <= 3) totalPodiums++;

        history.push({ match, result: res, exact, failed });
      }
    }
  }

  return (
    <div style={{
      position: 'fixed', inset: 0, zIndex: 9999, background: 'rgba(0,0,0,0.8)',
      backdropFilter: 'blur(8px)', display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '16px'
    }} onClick={onClose}>
      <div className="glass p-24" style={{
        maxWidth: '520px', width: '100%', maxHeight: '85vh', overflowY: 'auto', borderRadius: '24px',
        border: '1px solid var(--neon-cyan)', background: 'var(--surface-elevated)'
      }} onClick={(e) => e.stopPropagation()}>
        <div className="flex-between m-b-16">
          <div>
            <h2 className="neon-text-cyan heading-medium">{name}</h2>
            <p className="text-muted text-tiny" style={{ letterSpacing: '1px' }}>DESGLOSE DE PARTIDAS Y RENDIMIENTO</p>
          </div>
          <button onClick={onClose} style={{ background: 'none', border: 'none', color: 'white', fontSize: '24px', cursor: 'pointer' }}>✕</button>
        </div>

        <div className="flex-between m-b-24" style={{ gap: '8px' }}>
          <div className="glass p-12 text-center" style={{ flex: 1 }}>
            <div className="text-tiny text-muted">ACERTADAS</div>
            <div className="heading heading-medium" style={{ color: 'var(--neon-green)' }}>{totalExact}</div>
            <div className="text-tiny text-muted">Bazas ok</div>
          </div>
          <div className="glass p-12 text-center" style={{ flex: 1 }}>
            <div className="text-tiny text-muted">FALLADAS</div>
            <div className="heading heading-medium" style={{ color: 'var(--neon-orange)' }}>{totalFailed}</div>
            <div className="text-tiny text-muted">Bazas erradas</div>
          </div>
          <div className="glass p-12 text-center" style={{ flex: 1 }}>
            <div className="text-tiny text-muted">PODIOS</div>
            <div className="heading heading-medium" style={{ color: '#ffd700' }}>{totalPodiums}</div>
            <div className="text-tiny text-muted">Top 3</div>
          </div>
        </div>

        <div className="text-xs heading text-muted m-b-16" style={{ letterSpacing: '1px' }}>
          HISTORIAL FECHA POR FECHA ({history.length} PARTIDAS)
        </div>

        <div className="flex-column" style={{ gap: '10px' }}>
          {history.length === 0 ? (
            <div className="text-center text-muted p-16 text-small">Sin partidas registradas para este jugador.</div>
          ) : (
            history.map(({ match, result, exact, failed }) => {
              const dateStr = new Date(match.played_at).toLocaleDateString('es-AR', { day: '2-digit', month: '2-digit', year: '2-digit' });
              const isWinner = result.position_in_match === 1;
              const pts = Math.round((result.earned_championship_points || 0) + (result.osadia_points || 0));

              return (
                <div key={result.id} className="glass p-16 flex-between" style={{
                  borderRadius: '14px', borderLeft: `4px solid ${isWinner ? 'var(--neon-orange)' : 'var(--glass-border)'}`
                }}>
                  <div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                      <span className="heading" style={{ color: isWinner ? 'var(--neon-orange)' : 'white' }}>{result.position_in_match}º</span>
                      <span className="heading text-small">{dateStr}</span>
                      <span className="badge badge-green">{pts} Pts</span>
                    </div>
                    <div className="text-tiny text-muted" style={{ marginTop: '4px', display: 'flex', gap: '12px' }}>
                      <span style={{ color: 'var(--neon-green)' }}>🎯 {exact} acertadas</span>
                      <span style={{ color: 'var(--neon-orange)' }}>❌ {failed} falladas</span>
                    </div>
                  </div>
                  <div className="text-right">
                    <div className="heading text-small" style={{ color: 'var(--neon-green)' }}>{Math.round(result.accuracy_percent)}%</div>
                    <div className="text-tiny text-muted">{exact}/{result.total_match_rounds} rondas</div>
                  </div>
                </div>
              );
            })
          )}
        </div>
      </div>
    </div>
  );
}

// ── TAB DE RANKING ──────────────────────────────────────────────────
function RankingTab({ members, group, onSelectMember }: { members: GroupMember[], group: Group, onSelectMember: (m: GroupMember) => void }) {
  const sortedByPoints = [...members].sort((a, b) => b.total_championship_points - a.total_championship_points);
  const sortedByEffectiveness = [...members]
    .filter(m => (m.total_matches_played / (group.match_count || 1)) >= (group.min_attendance_pct / 100))
    .sort((a, b) => b.effective_avg_percent - a.effective_avg_percent);
  const sortedByOsadia = [...members].sort((a, b) => b.total_osadia_points - a.total_osadia_points);

  return (
    <div className="flex-between" style={{ alignItems: 'flex-start', gap: '8px' }}>
      <RankingColumn title="PTS" icon="🏆" color="var(--neon-cyan)" members={sortedByPoints} valueKey="total_championship_points" onSelectMember={onSelectMember} />
      <RankingColumn title="EFECT" icon="🎯" color="var(--neon-green)" members={sortedByEffectiveness} valueKey="effective_avg_percent" isPercent onSelectMember={onSelectMember} />
      <RankingColumn title="OSADÍA" icon="⚡" color="var(--neon-orange)" members={sortedByOsadia} valueKey="total_osadia_points" onSelectMember={onSelectMember} />
    </div>
  );
}

function RankingColumn({ title, icon, color, members, valueKey, isPercent, onSelectMember }: { 
  title: string, icon: string, color: string, members: GroupMember[], valueKey: keyof GroupMember, isPercent?: boolean, onSelectMember: (m: GroupMember) => void
}) {
  return (
    <div style={{ flex: 1, minWidth: 0 }}>
      <div className="flex-column flex-center m-b-16" style={{ gap: '4px' }}>
        <span style={{ fontSize: '20px' }}>{icon}</span>
        <span className="heading text-xs" style={{ color }}>{title}</span>
      </div>
      {members.map((m: GroupMember, i: number) => (
        <div key={m.id} className="flex-column flex-center m-b-8" style={{ cursor: 'pointer' }} onClick={() => onSelectMember(m)}>
          <div className="text-tiny heading" style={{ color: i === 0 ? 'var(--neon-orange)' : 'white' }}>
            {getMemberDisplayName(m)}
          </div>
          <div className="text-xs" style={{ color, fontWeight: 'bold' }}>
            {isPercent ? `${Math.round(Number(m[valueKey]))}%` : Math.round(Number(m[valueKey]))}
          </div>
        </div>
      ))}
    </div>
  );
}

// ── TAB DE PARTIDAS ─────────────────────────────────────────────────
function MatchesSection({ matches, members, expandedMatch, setExpandedMatch, createdBy, onSelectMember }: {
  matches: Match[], members: GroupMember[], expandedMatch: string | null, setExpandedMatch: (id: string | null) => void, createdBy?: string, onSelectMember: (m: GroupMember) => void
}) {
  if (matches.length === 0) {
    return <div className="p-24 text-center text-muted">No hay partidas registradas aún.</div>;
  }

  return (
    <div className="flex-column">
      {matches.map((match) => {
        const dateStr = new Date(match.played_at).toLocaleDateString('es-AR', { day: '2-digit', month: '2-digit', year: '2-digit' });
        const isExpanded = expandedMatch === match.id;
        const results = (match.results || [])
          .filter((r: MatchResult) => r.user_id !== createdBy)
          .sort((a: MatchResult, b: MatchResult) => a.position_in_match - b.position_in_match);

        return (
          <div key={match.id} className="glass m-b-16" style={{ borderRadius: '16px', overflow: 'hidden' }}>
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
                <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-end', gap: '2px' }}>
                  {results.slice(0, 3).map((r: MatchResult) => (
                    <div key={r.id} className="text-tiny" style={{ color: r.position_in_match === 1 ? 'var(--neon-orange)' : 'var(--text-secondary)' }}>
                      {r.position_in_match}º {getResultName(r, members)}
                    </div>
                  ))}
                </div>
                <span className="text-muted text-xs">{isExpanded ? '▲' : '▼'}</span>
              </div>
            </div>

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
                    {results.map((r: MatchResult) => {
                      const name = getResultName(r, members);
                      const isWinner = r.position_in_match === 1;
                      const champPts = Math.round(r.earned_championship_points || 0);
                      const osaPts = Math.round(r.osadia_points || 0);
                      const accuracy = Math.round(r.accuracy_percent || 0);

                      const memberObj = members.find(m => m.id === r.guest_member_id || (m.user_id && m.user_id === r.user_id));

                      return (
                        <tr key={r.id} style={{ borderBottom: '1px solid rgba(255,255,255,0.05)', cursor: memberObj ? 'pointer' : 'default' }} onClick={() => memberObj && onSelectMember(memberObj)}>
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

// ── TAB DE ESTADÍSTICAS Y GRÁFICOS INTERACTIVOS ───────────────
const NEON_PALETTE = ['#00e5ff', '#ff6d00', '#00ff94', '#ff007f', '#ffd700', '#9d4edd', '#00f5d4', '#ff5722'];

function StatisticsSection({ members, matches, createdBy, onSelectMember }: { members: GroupMember[], matches: Match[], createdBy?: string, onSelectMember: (m: GroupMember) => void }) {
  const [metric, setMetric] = useState<'points' | 'ranking'>('points');
  const [hiddenIds, setHiddenIds] = useState<string[]>([]);
  const [hoveredPoint, setHoveredPoint] = useState<{ name: string; val: string; x: number; y: number } | null>(null);

  const activeMembers = members.filter(m => m.user_id !== createdBy);
  const sortedMatches = [...matches].sort((a, b) => new Date(a.played_at).getTime() - new Date(b.played_at).getTime());

  if (activeMembers.length === 0 || sortedMatches.length === 0) {
    return <div className="p-24 text-center text-muted">Se necesitan partidas registradas para calcular las estadísticas.</div>;
  }

  // 1. Calcular serie temporal por jugador
  const playerSeries: Record<string, number[]> = {};
  const accumPts: Record<string, number> = {};

  const userToMemberMap: Record<string, string> = {};
  activeMembers.forEach(m => {
    if (m.user_id) userToMemberMap[m.user_id] = m.id;
    userToMemberMap[m.id] = m.id;
    accumPts[m.id] = 0;
    playerSeries[m.id] = [];
  });

  if (metric === 'points') {
    sortedMatches.forEach((match) => {
      (match.results || []).forEach(r => {
        const mId = (r.user_id ? userToMemberMap[r.user_id] : null) || r.guest_member_id;
        if (mId && accumPts[mId] !== undefined) {
          accumPts[mId] += (r.earned_championship_points || 0);
        }
      });
      activeMembers.forEach(m => {
        playerSeries[m.id].push(accumPts[m.id] || 0);
      });
    });
  } else {
    sortedMatches.forEach((match) => {
      (match.results || []).forEach(r => {
        const mId = (r.user_id ? userToMemberMap[r.user_id] : null) || r.guest_member_id;
        if (mId && accumPts[mId] !== undefined) {
          accumPts[mId] += (r.earned_championship_points || 0);
        }
      });
      const currentRanking = [...activeMembers].sort((a, b) => (accumPts[b.id] || 0) - (accumPts[a.id] || 0));
      currentRanking.forEach((m, rank) => {
        playerSeries[m.id].push(rank + 1);
      });
    });
  }

  // Dimensiones SVG
  const svgWidth = 400;
  const svgHeight = 200;
  const padLeft = 35;
  const padRight = 15;
  const padTop = 15;
  const padBottom = 25;
  const chartW = svgWidth - padLeft - padRight;
  const chartH = svgHeight - padTop - padBottom;

  let maxVal = 100;
  if (metric === 'points') {
    let highest = 0;
    Object.values(playerSeries).forEach(series => {
      series.forEach(v => { if (v > highest) highest = v; });
    });
    maxVal = Math.max(highest * 1.15, 20);
  } else {
    maxVal = activeMembers.length;
  }

  const numMatches = sortedMatches.length;

  const toggleHide = (id: string) => {
    if (hiddenIds.includes(id)) {
      setHiddenIds(hiddenIds.filter(i => i !== id));
    } else {
      if (hiddenIds.length < activeMembers.length - 1) {
        setHiddenIds([...hiddenIds, id]);
      }
    }
  };

  return (
    <div className="flex-column m-b-32">
      {/* ── HEADER & CONTROLES ──────────────────────────────────────── */}
      <div className="flex-between m-b-16">
        <h3 className="neon-text-cyan heading text-small">EVOLUCIÓN EN EL TIEMPO</h3>
        <div style={{ display: 'flex', background: 'var(--surface)', borderRadius: '20px', padding: '2px' }}>
          <button
            onClick={() => setMetric('points')}
            style={{
              padding: '6px 12px', borderRadius: '16px', border: 'none',
              background: metric === 'points' ? 'var(--neon-cyan)' : 'transparent',
              color: metric === 'points' ? 'black' : 'var(--text-muted)',
              fontFamily: 'var(--font-rajdhani)', fontWeight: 'bold', fontSize: '11px', cursor: 'pointer'
            }}
          >PUNTOS</button>
          <button
            onClick={() => setMetric('ranking')}
            style={{
              padding: '6px 12px', borderRadius: '16px', border: 'none',
              background: metric === 'ranking' ? 'var(--neon-orange)' : 'transparent',
              color: metric === 'ranking' ? 'black' : 'var(--text-muted)',
              fontFamily: 'var(--font-rajdhani)', fontWeight: 'bold', fontSize: '11px', cursor: 'pointer'
            }}
          >RANKING</button>
        </div>
      </div>

      {/* ── GRÁFICO SVG INTERACTIVO ─────────────────────────────────── */}
      <div className="glass p-24 m-b-16" style={{ position: 'relative', overflow: 'hidden' }}>
        <svg viewBox={`0 0 ${svgWidth} ${svgHeight}`} style={{ width: '100%', height: 'auto', display: 'block' }}>
          {/* Grillas horizontales */}
          {[0, 0.25, 0.5, 0.75, 1].map((pct) => {
            const y = padTop + chartH * (1 - pct);
            const gridVal = metric === 'points' ? Math.round(maxVal * pct) : Math.round(1 + (maxVal - 1) * (1 - pct));
            return (
              <g key={pct}>
                <line x1={padLeft} y1={y} x2={svgWidth - padRight} y2={y} stroke="rgba(255,255,255,0.08)" strokeDasharray="3 3" />
                <text x={padLeft - 6} y={y + 3} fill="var(--text-muted)" fontSize="9" textAnchor="end">
                  {metric === 'ranking' ? `#${gridVal}` : gridVal}
                </text>
              </g>
            );
          })}

          {/* Líneas de jugadores */}
          {activeMembers.map((m, idx) => {
            if (hiddenIds.includes(m.id)) return null;
            const series = playerSeries[m.id] || [];
            const color = NEON_PALETTE[idx % NEON_PALETTE.length];

            const pointsSvg = series.map((val, i) => {
              const x = padLeft + (numMatches > 1 ? (i / (numMatches - 1)) * chartW : chartW / 2);
              let y = padTop + chartH * (1 - (val / maxVal));
              if (metric === 'ranking') {
                const rankPct = (val - 1) / Math.max(maxVal - 1, 1);
                y = padTop + chartH * rankPct;
              }
              return { x, y, val, dateStr: new Date(sortedMatches[i].played_at).toLocaleDateString('es-AR', { day: '2-digit', month: '2-digit' }) };
            });

            const polylinePoints = pointsSvg.map(p => `${p.x},${p.y}`).join(' ');

            return (
              <g key={m.id}>
                <polyline fill="none" stroke={color} strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" points={polylinePoints} />
                {pointsSvg.map((p, i) => (
                  <circle
                    key={i} cx={p.x} cy={p.y} r="3.5" fill={color} stroke="var(--surface)" strokeWidth="1.5"
                    style={{ cursor: 'pointer' }}
                    onClick={() => onSelectMember(m)}
                    onMouseEnter={() => setHoveredPoint({ name: getMemberDisplayName(m), val: metric === 'points' ? `${p.val} pts` : `Puesto #${p.val}`, x: p.x, y: p.y })}
                    onMouseLeave={() => setHoveredPoint(null)}
                  />
                ))}
              </g>
            );
          })}
        </svg>

        {hoveredPoint && (
          <div style={{
            position: 'absolute', top: '12px', right: '12px', background: 'var(--surface-elevated)',
            border: '1px solid var(--neon-cyan)', padding: '6px 12px', borderRadius: '8px',
            fontSize: '11px', fontWeight: 'bold', color: 'white', pointerEvents: 'none'
          }}>
            {hoveredPoint.name}: <span style={{ color: 'var(--neon-cyan)' }}>{hoveredPoint.val}</span>
          </div>
        )}
      </div>

      {/* ── LEYENDA INTERACTIVA DE JUGADORES ────────────────────────── */}
      <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px' }} className="m-b-32">
        {activeMembers.map((m, idx) => {
          const isHidden = hiddenIds.includes(m.id);
          const color = NEON_PALETTE[idx % NEON_PALETTE.length];
          const name = getMemberDisplayName(m);

          return (
            <div
              key={m.id}
              onClick={() => onSelectMember(m)}
              style={{
                display: 'flex', alignItems: 'center', gap: '6px',
                padding: '4px 10px', borderRadius: '12px', cursor: 'pointer',
                background: isHidden ? 'transparent' : `${color}20`,
                border: `1px solid ${isHidden ? 'rgba(255,255,255,0.1)' : color}`,
                opacity: isHidden ? 0.5 : 1, transition: 'all 0.2s'
              }}
            >
              <span style={{ width: '8px', height: '8px', borderRadius: '50%', background: isHidden ? '#555' : color }}></span>
              <span style={{ fontSize: '11px', fontWeight: 'bold', color: isHidden ? 'var(--text-muted)' : 'white', textDecoration: isHidden ? 'line-through' : 'none' }}>
                {name.split(' ')[0]}
              </span>
            </div>
          );
        })}
      </div>

      {/* ── DATOS CURIOSOS & TRIVIA ──────────────────────────────────── */}
      <TriviaSection members={activeMembers} matches={sortedMatches} onSelectMember={onSelectMember} />
    </div>
  );
}

// ── SECCIÓN DE TRIVIA Y DATOS CURIOSOS CON NOMBRES REALES ───────────
function TriviaSection({ members, matches, onSelectMember }: { members: GroupMember[], matches: Match[], onSelectMember: (m: GroupMember) => void }) {
  const memberMap: Record<string, GroupMember> = {};
  members.forEach(m => {
    if (m.user_id) memberMap[m.user_id] = m;
    memberMap[m.id] = m;
  });

  // 1. REY DEL PODIO
  const podiumCounts: Record<string, number> = {};
  for (const m of matches) {
    for (const r of m.results || []) {
      if (r.position_in_match <= 3) {
        const target = (r.user_id ? memberMap[r.user_id] : null) || (r.guest_member_id ? memberMap[r.guest_member_id] : null);
        if (target) {
          podiumCounts[target.id] = (podiumCounts[target.id] || 0) + 1;
        }
      }
    }
  }
  const maxPodiums = Math.max(...Object.values(podiumCounts), 0);
  const podiumKings = members.filter(m => podiumCounts[m.id] === maxPodiums && maxPodiums > 0);

  // 2. EL FRANCOTIRADOR (100% efectividad)
  let bestSniper: { member: GroupMember; rounds: number } | null = null;
  for (const m of matches) {
    for (const r of m.results || []) {
      if ((r.accuracy_percent || 0) >= 99.9) {
        const target = (r.user_id ? memberMap[r.user_id] : null) || (r.guest_member_id ? memberMap[r.guest_member_id] : null);
        if (target) {
          if (!bestSniper || r.total_match_rounds > bestSniper.rounds) {
            bestSniper = { member: target, rounds: r.total_match_rounds };
          }
        }
      }
    }
  }

  // 3. REY DE LA OSADÍA
  const sortedOsadia = [...members].sort((a, b) => b.total_osadia_points - a.total_osadia_points);
  const topOsadia = sortedOsadia.length > 0 && sortedOsadia[0].total_osadia_points > 0 ? sortedOsadia[0] : null;

  // 4. EL MURO DE PIEDRA (Mayor regularidad - menor promedio de posición)
  const playerPositions: Record<string, number[]> = {};
  for (const m of matches) {
    for (const r of m.results || []) {
      const target = (r.user_id ? memberMap[r.user_id] : null) || (r.guest_member_id ? memberMap[r.guest_member_id] : null);
      if (target) {
        if (!playerPositions[target.id]) playerPositions[target.id] = [];
        playerPositions[target.id].push(r.position_in_match);
      }
    }
  }

  let regularPlayer: GroupMember | null = null;
  let minAvgPos = 99.0;
  Object.entries(playerPositions).forEach(([mId, posList]) => {
    if (posList.length >= 2) {
      const avg = posList.reduce((a, b) => a + b, 0) / posList.length;
      if (avg < minAvgPos) {
        minAvgPos = avg;
        regularPlayer = memberMap[mId] || null;
      }
    }
  });

  // 5. EL FAROL ROJO (Más veces en el último puesto)
  const lastCounts: Record<string, number> = {};
  for (const m of matches) {
    const totalPlayersInMatch = (m.results || []).length;
    for (const r of m.results || []) {
      if (r.position_in_match === totalPlayersInMatch && totalPlayersInMatch > 0) {
        const target = (r.user_id ? memberMap[r.user_id] : null) || (r.guest_member_id ? memberMap[r.guest_member_id] : null);
        if (target) {
          lastCounts[target.id] = (lastCounts[target.id] || 0) + 1;
        }
      }
    }
  }
  const maxLast = Math.max(...Object.values(lastCounts), 0);
  const worstPlayers = members.filter(m => lastCounts[m.id] === maxLast && maxLast > 0);

  // 6. ZONA DE DESCENSO (Más veces en los últimos 3 puestos)
  const bottom3Counts: Record<string, number> = {};
  for (const m of matches) {
    const totalPlayersInMatch = (m.results || []).length;
    for (const r of m.results || []) {
      if (r.position_in_match > totalPlayersInMatch - 3 && totalPlayersInMatch >= 3) {
        const target = (r.user_id ? memberMap[r.user_id] : null) || (r.guest_member_id ? memberMap[r.guest_member_id] : null);
        if (target) {
          bottom3Counts[target.id] = (bottom3Counts[target.id] || 0) + 1;
        }
      }
    }
  }
  const maxBottom3 = Math.max(...Object.values(bottom3Counts), 0);
  const bottom3Players = members.filter(m => bottom3Counts[m.id] === maxBottom3 && maxBottom3 > 0);

  return (
    <div className="flex-column">
      <div className="text-center text-xs heading text-muted m-b-16" style={{ letterSpacing: '2px' }}>
        ── RÉCORDS Y DATOS CURIOSOS DE LA LIGA ──
      </div>

      {podiumKings.length > 0 && (
        <TriviaCard
          icon="👑"
          title="EL REY DEL PODIO"
          names={podiumKings.map(getMemberDisplayName).join(', ')}
          subtitle="Más apariciones en el Top 3 de las partidas"
          highlight={`${maxPodiums} podios`}
          color="var(--neon-orange)"
          onClick={() => onSelectMember(podiumKings[0])}
        />
      )}

      {bestSniper && (
        <TriviaCard
          icon="🎯"
          title="EL FRANCOTIRADOR"
          names={getMemberDisplayName(bestSniper.member)}
          subtitle={`100% efectividad exacta en partida de ${bestSniper.rounds} rondas`}
          highlight="100% acierto"
          color="var(--neon-cyan)"
          onClick={() => onSelectMember(bestSniper!.member)}
        />
      )}

      {topOsadia && (
        <TriviaCard
          icon="⚡"
          title="REY DE LA OSADÍA"
          names={getMemberDisplayName(topOsadia)}
          subtitle="Máximo puntaje acumulado apostando y arriesgando bazas"
          highlight={`${Math.round(topOsadia.total_osadia_points)} pts`}
          color="var(--neon-green)"
          onClick={() => onSelectMember(topOsadia)}
        />
      )}

      {regularPlayer && (
        <TriviaCard
          icon="🧱"
          title="EL MURO DE PIEDRA (REGULARIDAD)"
          names={getMemberDisplayName(regularPlayer)}
          subtitle="Promedio de puesto más sólido a lo largo de las fechas disputadas"
          highlight={`Puesto #${minAvgPos.toFixed(1)}`}
          color="#00f5d4"
          onClick={() => onSelectMember(regularPlayer!)}
        />
      )}

      {worstPlayers.length > 0 && (
        <TriviaCard
          icon="🔴"
          title="EL FAROL ROJO"
          names={worstPlayers.map(getMemberDisplayName).join(', ')}
          subtitle="Jugador que más veces terminó en la última posición de una partida"
          highlight={`${maxLast} veces último`}
          color="#ff3366"
          onClick={() => onSelectMember(worstPlayers[0])}
        />
      )}

      {bottom3Players.length > 0 && (
        <TriviaCard
          icon="🔻"
          title="ZONA DE DESCENSO"
          names={bottom3Players.map(getMemberDisplayName).join(', ')}
          subtitle="Jugadores con más apariciones en los últimos 3 puestos"
          highlight={`${maxBottom3} veces en el fondo`}
          color="#ff9900"
          onClick={() => onSelectMember(bottom3Players[0])}
        />
      )}
    </div>
  );
}

function TriviaCard({ icon, title, names, subtitle, highlight, color, onClick }: {
  icon: string; title: string; names: string; subtitle: string; highlight: string; color: string; onClick?: () => void;
}) {
  return (
    <div className="glass m-b-16 p-24 flex-between" style={{ borderLeft: `4px solid ${color}`, borderRadius: '16px', cursor: onClick ? 'pointer' : 'default' }} onClick={onClick}>
      <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
        <span style={{ fontSize: '28px' }}>{icon}</span>
        <div>
          <div className="text-xs heading" style={{ color, letterSpacing: '1px' }}>{title}</div>
          <div className="heading heading-medium" style={{ color: 'white', marginTop: '2px' }}>{names}</div>
          <div className="text-muted text-tiny" style={{ marginTop: '2px' }}>{subtitle}</div>
        </div>
      </div>
      <div className="badge" style={{ background: `${color}25`, color, borderColor: color, fontWeight: 'bold' }}>
        {highlight}
      </div>
    </div>
  );
}

// ── TAB SALÓN DE LA FAMA ────────────────────────────────────────────
function HallOfFameSection({ members, onSelectMember }: { members: GroupMember[], onSelectMember: (m: GroupMember) => void }) {
  const maxPlayed = Math.max(...members.map(m => m.total_matches_played), 0);
  const mostPlayed = members.filter(m => m.total_matches_played === maxPlayed && maxPlayed > 0);

  const maxFailed = Math.max(...members.map(m => m.total_failed_osadia), 0);
  const mostReckless = members.filter(m => m.total_failed_osadia === maxFailed && maxFailed > 0);

  const maxChamullero = Math.max(...members.map(m => m.total_chamullero_score || 0), 0);
  const mostChamullero = members.filter(m => (m.total_chamullero_score || 0) === maxChamullero && maxChamullero > 0);

  return (
    <div className="flex-column">
      <HofTile title="ASISTENCIA PERFECTA" winners={mostPlayed} stat={`${maxPlayed} partidas`} color="var(--neon-cyan)" onSelectMember={onSelectMember} />
      <HofTile title="EL CHARLATÁN" winners={mostReckless} stat={`${maxFailed} fallidas`} color="var(--neon-orange)" onSelectMember={onSelectMember} />
      <HofTile title="EL CHAMULLERO" winners={mostChamullero} stat={`${maxChamullero} bazas`} color="#90a4ae" onSelectMember={onSelectMember} />
    </div>
  );
}

function HofTile({ title, winners, stat, color, onSelectMember }: { title: string, winners: GroupMember[], stat: string, color: string, onSelectMember: (m: GroupMember) => void }) {
  if (winners.length === 0) return null;
  const names = winners.map(getMemberDisplayName).join(', ');

  return (
    <div className="glass card m-b-16" style={{ borderLeft: `4px solid ${color}`, cursor: 'pointer' }} onClick={() => onSelectMember(winners[0])}>
      <div className="text-xs heading m-b-8" style={{ color, letterSpacing: '1px' }}>{title}</div>
      <div className="heading heading-medium m-b-8">{names}</div>
      <div className="text-secondary text-tiny">{stat}</div>
    </div>
  );
}
