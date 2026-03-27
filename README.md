# Bazas — La Podrida F1 Championship 🏎️🃏

![App Logo](app_logo_crash_cards)

**Bazas** es una aplicación móvil desarrollada en Flutter y Supabase diseñada para digitalizar, trackear y rankear partidas del juego de cartas "La Podrida" (Oh Hell). La aplicación utiliza Inteligencia Artificial (DeepSeek Vision) para leer planillas de puntaje manuscritas y automatizar el cálculo de campeonatos con un sistema de puntuación inspirado en la Fórmula 1.

## 🏁 Sistema de Puntuación (Matemática del Juego)

La aplicación no solo suma puntos, sino que evalúa el desempeño técnico de cada jugador:

### 1. Puntos de Campeonato (Estilo F1)

Al finalizar cada partida, se asignan puntos según la posición:

- **1º Puesto**: 25 pts
- **2º Puesto**: 18 pts
- **3º Puesto**: 15 pts
- ... (siguiendo el estándar oficial de la FIA)

### 2. Bonus de Osadía (Audacity)

Se premia a los jugadores que toman riesgos. Si un jugador pide **más de 1 baza** y acierta exactamente esa cantidad, suma:

- `bazas_ganadas * multiplicador_osadia`
- El multiplicador es configurable por cada liga (Default x2).

### 3. Bonus de Efectividad

Se premia la precisión. Por cada ronda donde el jugador acertó exactamente lo que pidió, suma un bono fijo (configurable).

---

## 🛠️ Stack Tecnológico

- **Frontend**: Flutter (Dart) + Riverpod (State Management)
- **Backend**: Supabase (PostgreSQL, Auth, Storage)
- **AI OCR**: DeepSeek Vision API vía Supabase Edge Functions
- **Navegación**: GoRouter
- **Estética**: Custom Dark Theme (F1 Edition) + Google Fonts (Rajdhani & Inter)

---

## 🚀 Guía de Instalación para Desarrolladores

### Requisitos Previos

- Flutter SDK (3.19+)
- Supabase CLI
- Una cuenta en DeepSeek (para la API Key de visión)

### Configuración del Env

1. Clonar el repositorio.
2. Crear un archivo `.env` con tus credenciales de Supabase:

   ```env
   SUPABASE_URL=tu_url
   SUPABASE_ANON_KEY=tu_anon_key
   ```

3. Correr la generación de modelos:

   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

### Despliegue de la Edge Function

```bash
supabase functions deploy process-scoresheet
supabase secrets set DEEPSEEK_API_KEY=tu_key_aqui
```

---

## 📱 Capturas del Proceso de Escaneo

El flujo de digitalización consta de 4 fases:

1. **Captura**: Encuadre de la planilla física.
2. **Procesamiento**: Análisis por IA en la nube.
3. **Verificación**: Corrección manual de posibles errores de lectura (resaltados por la IA).
4. **Impacto**: Actualización del ranking global en tiempo real.

---

## 👨‍💻 Autor

Desarrollado como Tech Lead Senior para el proyecto **Bazas**.
Estética de alta gama, visualización de datos avanzada y automatización por IA.
