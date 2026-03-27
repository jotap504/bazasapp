const SUPABASE_URL = 'https://qqvlqwschyrvtksvpwdf.supabase.co';
const ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFxdmxxd3NjaHlydnRrc3Zwd2RmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM2NzI3NzYsImV4cCI6MjA4OTI0ODc3Nn0.SoLMXK1eoqHQJIk7yZWh5ahaDb7KXAJUGz_o5kFQJTA';

// RELLENA ESTO CON DATOS REALES PARA PROBAR
const TEST_IMAGE_URL = 'https://qqvlqwschyrvtksvpwdf.supabase.co/storage/v1/object/sign/scoresheets/tabla1.jpg?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV9mMTJiMzM1OS1kYTQxLTQxZmUtYTNmMi04YzVmOWRmZDhiNDkiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJzY29yZXNoZWV0cy90YWJsYTEuanBnIiwiaWF0IjoxNzczODQ5MzMzLCJleHAiOjE3NzQ0NTQxMzN9.XY9ypJVQ7T29u-Xsi7dInCKbydMqTA0X8jbZ7NHtevg';
const TEST_PLAYER_NAMES = ['Jugador A', 'Jugador B', 'Jugador C'];
const GROUP_ID = 'a05d82eb-8b7f-441d-9e14-553500ef9d6a'; // Puedes sacarlo de la tabla 'groups' en el Dashboard de Supabase

async function test() {
  console.log('--- Descubriendo Modelos Disponibles ---');
  try {
    const listRes = await fetch(`https://generativelanguage.googleapis.com/v1beta/models?key=AIzaSyCXsXwTPF5q6nN5uCsp-TyOa1oKF6NoBig`);
    const listData = await listRes.json();
    console.log('Modelos disponibles:', listData.models?.map(m => m.name).join(', ') || 'Niguno encontrado');
  } catch (e) {
    console.error('Error al listar modelos:', e);
  }

  console.log('\n--- Probando Edge Function process-scoresheet ---');

  try {
    const response = await fetch(`${SUPABASE_URL}/functions/v1/process-scoresheet`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${ANON_KEY}`,
      },
      body: JSON.stringify({
        image_url: TEST_IMAGE_URL,
        player_names: TEST_PLAYER_NAMES,
        group_id: GROUP_ID
      })
    });

    const data = await response.json();
    console.log('Status:', response.status);
    console.log('Response:', JSON.stringify(data, null, 2));

    if (!response.ok) {
      console.error('ERROR detectado en la respuesta.');
    } else {
      console.log('¡ÉXITO! La IA respondió correctamente.');
    }
  } catch (error) {
    console.error('Error al contactar con la función:', error);
  }
}

test();
