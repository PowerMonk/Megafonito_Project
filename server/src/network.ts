import { networkInterfaces } from 'node:os';

import QRCode from 'qrcode';

import { APP_NAME, DEFAULT_PORT } from './config';
import { DEMO_ACCOUNTS } from './seed';

export interface LanAddress {
  address: string;
  interfaceName: string;
}

export interface LanUrl {
  url: string;
  address: string;
  label: string;
  primary: boolean;
  qrSvg: string;
}

function isPrivate(address: string): boolean {
  if (/^10\./.test(address)) return true;
  if (/^192\.168\./.test(address)) return true;
  if (/^172\.(1[6-9]|2\d|3[01])\./.test(address)) return true;
  return false;
}

function isVirtual(address: string, interfaceName: string): boolean {
  if (
    /virtualbox|vmware|hyper-?v|vethernet|wsl|docker|loopback|tap|tun|npcap|virtual/i.test(
      interfaceName,
    )
  ) {
    return true;
  }
  // Default host-only / container adapters that commonly appear on dev laptops.
  if (address === '192.168.56.1') return true;
  if (/^192\.168\.99\./.test(address)) return true;
  if (/^172\.17\./.test(address)) return true;
  return false;
}

function rank(entry: LanAddress): number {
  const { address, interfaceName } = entry;
  if (interfaceName === 'LAN_IP') return -1;
  if (address === '192.168.137.1') return 0;
  if (isVirtual(address, interfaceName)) return 80;
  if (/wi-?fi|wlan|wireless/i.test(interfaceName)) return 1;
  if (/ethernet|eth/i.test(interfaceName)) return 2;
  if (/^192\.168\./.test(address)) return 3;
  if (/^10\./.test(address)) return 4;
  if (/^172\.(1[6-9]|2\d|3[01])\./.test(address)) return 5;
  if (address === '127.0.0.1') return 99;
  return 50;
}

function labelFor(address: string, interfaceName: string): string {
  if (interfaceName === 'LAN_IP') return 'LAN_IP (manual)';
  if (address === '192.168.137.1') return 'Hotspot de Windows';
  if (address === '127.0.0.1') return 'Solo este equipo';
  if (isVirtual(address, interfaceName)) return 'Adaptador virtual';
  if (/wi-?fi|wlan|wireless/i.test(interfaceName)) return 'Wi-Fi';
  if (/ethernet|eth/i.test(interfaceName)) return 'Ethernet';
  return isPrivate(address) ? 'Red local' : interfaceName;
}

export function listLanAddresses(): LanAddress[] {
  const addresses: LanAddress[] = [];
  const interfaces = networkInterfaces();

  for (const [interfaceName, entries] of Object.entries(interfaces)) {
    for (const entry of entries ?? []) {
      const isIpv4 = entry.family === 'IPv4' || String(entry.family) === '4';
      if (!isIpv4 || entry.internal) continue;
      addresses.push({ address: entry.address, interfaceName });
    }
  }

  const seen = new Set<string>();
  const unique = addresses.filter((entry) => {
    if (seen.has(entry.address)) return false;
    seen.add(entry.address);
    return true;
  });

  const override = process.env.LAN_IP?.trim();
  if (override && !seen.has(override)) {
    unique.unshift({ address: override, interfaceName: 'LAN_IP' });
  }

  return unique.sort((a, b) => rank(a) - rank(b));
}

export async function qrSvgDataUrl(text: string): Promise<string> {
  const svg = await QRCode.toString(text, {
    type: 'svg',
    margin: 1,
    width: 300,
    errorCorrectionLevel: 'M',
    color: { dark: '#14213D', light: '#FFFFFF' },
  });
  return `data:image/svg+xml;base64,${Buffer.from(svg).toString('base64')}`;
}

export async function buildLanUrls(
  port: number = DEFAULT_PORT,
): Promise<LanUrl[]> {
  let addresses = listLanAddresses();
  if (addresses.length === 0) {
    addresses = [{ address: '127.0.0.1', interfaceName: 'localhost' }];
  }

  const urls: LanUrl[] = [];
  for (const entry of addresses) {
    const url = `http://${entry.address}:${port}`;
    urls.push({
      url,
      address: entry.address,
      label: labelFor(entry.address, entry.interfaceName),
      primary: urls.length === 0,
      qrSvg: await qrSvgDataUrl(url),
    });
  }
  return urls;
}

export async function printStartupBanner(
  urls: LanUrl[],
  dbPath: string,
): Promise<void> {
  const primary = urls[0];
  console.log('');
  console.log('  MEGAFONITO · servidor de demostración');
  console.log('  ────────────────────────────────────');
  console.log(`  Base de datos: ${dbPath}`);
  console.log(`  App:           ${APP_NAME}`);
  console.log('');

  for (const entry of urls) {
    const marker = entry.primary ? '→' : ' ';
    console.log(`  ${marker} ${entry.url.padEnd(32)} ${entry.label}`);
  }

  console.log('');
  console.log('  Cuentas demo:');
  for (const account of DEMO_ACCOUNTS) {
    const role = account.role === 'admin' ? 'admin' : 'alumno';
    console.log(
      `   · ${account.username.padEnd(9)} / ${account.password.padEnd(8)}  ${role}  ${account.label}`,
    );
  }

  if (primary) {
    const landingPort = new URL(primary.url).port;
    console.log('');
    console.log(`  Landing local (QR grande): http://localhost:${landingPort}`);
    console.log('');
    console.log('  Escanea este QR desde la app (Inicio de sesión → Conectar):');
    console.log('');
    const terminalQr = await QRCode.toString(primary.url, {
      type: 'terminal',
      small: true,
      errorCorrectionLevel: 'M',
    });
    console.log(terminalQr);
    console.log('  Si el QR no conecta, escribe la URL manualmente en la app.');
    console.log('');
  }
}
