import type { Metadata } from "next";
import { Inter, Rajdhani } from "next/font/google";
import "./globals.css";

const inter = Inter({
  subsets: ["latin"],
  variable: "--font-inter",
});

const rajdhani = Rajdhani({
  subsets: ["latin"],
  weight: ["400", "500", "600", "700"],
  variable: "--font-rajdhani",
});

export const metadata: Metadata = {
  title: "Bazas - Visor de Ligas",
  description: "Consulta los rankings y estadísticas de tu liga de Bazas en tiempo real.",
  viewport: "width=device-width, initial-scale=1, maximum-scale=1, user-scalable=0",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="es">
      <body className={`${inter.variable} ${rajdhani.variable}`}>
        <main className="container">
          {children}
        </main>
      </body>
    </html>
  );
}
