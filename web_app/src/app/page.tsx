'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';

export default function Home() {
  const [inviteCode, setInviteCode] = useState('');
  const router = useRouter();

  const handleJoin = (e: React.FormEvent) => {
    e.preventDefault();
    if (inviteCode.trim()) {
      router.push(`/${inviteCode.trim().toUpperCase()}`);
    }
  };

  return (
    <div className="full-viewport flex-column flex-center p-24">
      <div className="glass card p-24 text-center" style={{ width: '100%', maxWidth: '400px', padding: '40px 24px' }}>
        <h1 className="neon-text-cyan heading m-b-8" style={{ fontSize: '42px' }}>BAZAS</h1>
        <p className="text-secondary m-b-32 text-small" style={{ letterSpacing: '2px' }}>VISOR DE LIGAS</p>
        
        <form onSubmit={handleJoin}>
          <div className="m-b-24">
            <label className="text-muted text-xs heading m-b-8" style={{ display: 'block', textAlign: 'left', letterSpacing: '1px' }}>
              CÓDIGO DE INVITACIÓN
            </label>
            <input
              type="text"
              className="input-main"
              value={inviteCode}
              onChange={(e) => setInviteCode(e.target.value)}
              placeholder="EJ: BAZ-123"
            />
          </div>
          
          <button type="submit" className="button-hero glass">
            VER LIGA
          </button>
        </form>
      </div>

      <p className="fixed-bottom text-center text-muted text-xs">
        ACCESO DE SÓLO LECTURA
      </p>
    </div>
  );
}
