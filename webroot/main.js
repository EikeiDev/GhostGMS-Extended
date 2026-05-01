'use strict';

// ── Config paths ──────────────────────────────────────────────
const PREFS_PATH = '/data/adb/modules/ghostgms/config/user_prefs';
const CATS_PATH = '/data/adb/modules/ghostgms/config/gms_categories';
const PREFS_BAK = '/data/local/tmp/ghostgms_config/user_prefs';
const CATS_BAK = '/data/local/tmp/ghostgms_config/gms_categories';
const VELOXINE = '/data/adb/modules/ghostgms/veloxine.sh';

// ── Category definitions ──────────────────────────────────────
const CATEGORIES = [
  { id: 'ADS', label: 'Advertising', desc: 'Ad ID & ad services', safety: 'safe' },
  { id: 'TRACKING', label: 'Tracking', desc: 'User activity & measurement', safety: 'safe' },
  { id: 'ANALYTICS', label: 'Analytics', desc: 'Firebase & GMS stats', safety: 'safe' },
  { id: 'REPORTING', label: 'Reporting', desc: 'Bug & crash reports', safety: 'safe' },
  { id: 'FITNESS', label: 'Fitness', desc: 'Google Fit & Health', safety: 'safe' },
  { id: 'DISCOVERY', label: 'Discovery', desc: 'Device & service discovery', safety: 'caution' },
  { id: 'BACKGROUND', label: 'Background', desc: 'Push & check-ins', safety: 'caution' },
  { id: 'UPDATE', label: 'Updates', desc: 'GMS auto-update services', safety: 'caution' },
  { id: 'CAST', label: 'Cast', desc: 'Chromecast & media sharing', safety: 'caution' },
  { id: 'SYNC', label: 'Sync', desc: 'Cloud & account sync', safety: 'caution' },
  { id: 'GEOFENCE', label: 'Geofencing', desc: 'Geofence triggers', safety: 'caution' },
  { id: 'NEARBY', label: 'Nearby Share', desc: 'Quick Share services', safety: 'caution' },
  { id: 'WEAR', label: 'Wear OS', desc: 'Smartwatch connectivity', safety: 'caution' },
  { id: 'LOCATION', label: 'Location', desc: 'Maps & navigation accuracy', safety: 'danger' },
  { id: 'AUTH', label: 'Auth', desc: 'Google Account sign-in', safety: 'danger' },
  { id: 'CLOUD', label: 'Cloud', desc: 'Google Cloud services', safety: 'danger' },
  { id: 'WALLET', label: 'Wallet', desc: 'Google Wallet & NFC', safety: 'danger' },
  { id: 'PAYMENT', label: 'Payments', desc: 'Google Pay transactions', safety: 'danger' },
];

const SAFETY_CLASS = { safe: 's-safe', caution: 's-caution', danger: 's-danger' };

// ── KSU bridge ────────────────────────────────────────────────
async function exec(cmd) {
  try {
    const TIMEOUT = new Promise(r => setTimeout(() => r(null), 8000));
    const res = await Promise.race([window.ksu.exec(cmd), TIMEOUT]);
    if (!res) return '';
    if (typeof res === 'string') return res.trim();
    if (typeof res === 'object') {
      const val = res.out ?? res.stdout ?? res.output ?? res.result;
      return val != null ? String(val).trim() : '';
    }
    return '';
  } catch { return ''; }
}

function toast(msg, duration = 2200) {
  if (window.ksu && typeof window.ksu.toast === 'function') {
    window.ksu.toast(msg);
    return;
  }
  const el = document.getElementById('toast');
  el.textContent = msg;
  el.classList.add('show');
  clearTimeout(el._t);
  el._t = setTimeout(() => el.classList.remove('show'), duration);
}

// ── Config I/O ────────────────────────────────────────────────
function hexToUtf8(hex) {
  let str = '';
  for (let i = 0; i + 1 < hex.length; i += 2)
    str += String.fromCharCode(parseInt(hex.substr(i, 2), 16));
  return str;
}

async function readFileHex(path) {
  const hex = await exec(`od -An -v -tx1 "${path}" 2>/dev/null | tr -d ' \n'`);
  return hex ? hexToUtf8(hex) : '';
}

function parseConfig(text) {
  const map = {};
  if (!text) return map;
  for (const line of text.split('\n')) {
    const m = line.trim().match(/^([^=]+)=(.*)$/);
    if (m) map[m[1].trim()] = m[2].trim();
  }
  return map;
}

async function loadConfig() {
  const [prefsText, catsText] = await Promise.all([
    readFileHex(PREFS_PATH) || readFileHex(PREFS_BAK),
    readFileHex(CATS_PATH)  || readFileHex(CATS_BAK),
  ]);

  const prefs = parseConfig(prefsText);
  const cats  = parseConfig(catsText);

  const allPrefs = ['ENABLE_GHOSTED', 'ENABLE_LOG_DISABLE',
                    'ENABLE_BLUR_DISABLE', 'ENABLE_SERVICES_DISABLE'];

  for (const key of allPrefs) {
    const el = document.getElementById(key);
    if (el) el.checked = (prefs[key] === '1');
  }

  for (const cat of CATEGORIES) {
    const el = document.getElementById('DISABLE_' + cat.id);
    if (el) el.checked = (cats['DISABLE_' + cat.id] === '1');
  }

  updateCatGrid();
  await updateStatus();
}

async function saveConfig() {
  const allPrefs = ['ENABLE_GHOSTED', 'ENABLE_LOG_DISABLE',
    'ENABLE_BLUR_DISABLE', 'ENABLE_SERVICES_DISABLE'];

  await exec(`mkdir -p /data/adb/modules/ghostgms/config /data/local/tmp/ghostgms_config`);

  // Write prefs line by line — avoids quoting issues in ksu.exec
  let cmd = `> "${PREFS_PATH}"`;
  for (const key of allPrefs) {
    const el = document.getElementById(key);
    const val = el && el.checked ? '1' : '0';
    cmd += ` && echo '${key}=${val}' >> "${PREFS_PATH}"`;
  }
  cmd += ` && cp "${PREFS_PATH}" "${PREFS_BAK}"`;
  await exec(cmd);

  // Write categories line by line
  let cCmd = `> "${CATS_PATH}"`;
  for (const cat of CATEGORIES) {
    const el = document.getElementById('DISABLE_' + cat.id);
    const val = el && el.checked ? '1' : '0';
    cCmd += ` && echo 'DISABLE_${cat.id}=${val}' >> "${CATS_PATH}"`;
  }
  cCmd += ` && cp "${CATS_PATH}" "${CATS_BAK}"`;
  await exec(cCmd);
}

// ── Status ────────────────────────────────────────────────────
async function updateStatus() {
  // Counting components in the 'disabledComponents' section of dumpsys
  // We use a more complex grep/sed to target only the GMS package components
  const out = await exec(`dumpsys package com.google.android.gms 2>/dev/null | sed -n '/disabledComponents:/,/^  [a-z]/p' | grep -c "\\."`);
  let count = parseInt(out, 10) || 0;
  
  // Fallback: if sed failed or returned 0, try a broader search for any disabled flag
  if (count === 0) {
    const fallback = await exec(`dumpsys package com.google.android.gms 2>/dev/null | grep -E "enabled=[234]" | wc -l`);
    count = parseInt(fallback, 10) || 0;
  }

  const badge = document.getElementById('status-badge');
  // Only update if we got a valid number
  if (!isNaN(count)) {
    badge.textContent = `${count} services blocked`;
  }
}

// ── UI helpers ────────────────────────────────────────────────
function updateCatGrid() {
  const master = document.getElementById('ENABLE_SERVICES_DISABLE');
  const grid = document.getElementById('cat-grid');
  const label = document.getElementById('cat-label');
  const active = master && master.checked;
  [grid, label].forEach(el => el.classList.toggle('disabled-card', !active));
  grid.querySelectorAll('.cat-card').forEach(c => c.classList.toggle('disabled-card', !active));
}

function buildCatGrid() {
  const grid = document.getElementById('cat-grid');
  grid.innerHTML = '';
  for (const cat of CATEGORIES) {
    const sc = SAFETY_CLASS[cat.safety] || 's-safe';
    const card = document.createElement('div');
    card.className = 'cat-card';
    card.innerHTML = `
      <div class="cat-card-top">
        <span class="cat-name">${cat.label}</span>
        <label class="switch">
          <input type="checkbox" id="DISABLE_${cat.id}">
          <span class="slider"></span>
        </label>
      </div>
      <div class="cat-desc"><span class="safety-dot ${sc}"></span>${cat.desc}</div>`;
    grid.appendChild(card);
  }
}

// ── Apply ─────────────────────────────────────────────────────
async function applyChanges() {
  const btn = document.getElementById('btn-apply');
  btn.disabled = true;
  btn.textContent = 'SAVING…';

  try {
    await saveConfig();
    toast('✓ Config saved');
    btn.textContent = 'APPLYING…';
    await exec(`sh "${VELOXINE}" disable`);
    toast('✓ Changes applied!', 3000);
    await updateStatus();
  } catch (e) {
    toast('✗ Error: ' + e.message);
  } finally {
    btn.disabled = false;
    btn.textContent = 'SAVE & APPLY';
  }
}

// ── Init ──────────────────────────────────────────────────────
function init() {
  buildCatGrid();

  document.getElementById('ENABLE_SERVICES_DISABLE').addEventListener('change', updateCatGrid);
  document.getElementById('btn-apply').addEventListener('click', applyChanges);
  document.getElementById('btn-refresh').addEventListener('click', async () => {
    toast('Reloading…');
    await loadConfig();
  });

  // Safety: hide loader after 12s no matter what
  const safetyTimer = setTimeout(() => {
    document.getElementById('loader').classList.add('hidden');
    document.getElementById('status-badge').textContent = 'No KSU bridge';
  }, 12000);

  // Wait for KSU bridge
  let retries = 0;
  const detect = () => {
    if (window.ksu && typeof window.ksu.exec === 'function') {
      clearTimeout(safetyTimer);
      loadConfig().finally(() => {
        document.getElementById('loader').classList.add('hidden');
      });
    } else if (retries < 30) {
      retries++;
      setTimeout(detect, 200);
    } else {
      clearTimeout(safetyTimer);
      document.getElementById('loader').classList.add('hidden');
      document.getElementById('status-badge').textContent = 'No KSU bridge';
    }
  };
  detect();
}

document.addEventListener('DOMContentLoaded', init);
