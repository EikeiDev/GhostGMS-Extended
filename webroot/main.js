const categories = [
{ id: 'ADS', label: 'Block Advertising', desc: 'Google Ad services', safety: 'safe' },
{ id: 'TRACKING', label: 'Block Tracking', desc: 'User activity tracking', safety: 'safe' },
{ id: 'ANALYTICS', label: 'Block Analytics', desc: 'Firebase & GMS Analytics', safety: 'safe' },
{ id: 'REPORTING', label: 'Block Reporting', desc: 'Bug & Crash reports', safety: 'safe' },
{ id: 'FITNESS', label: 'Block Fitness', desc: 'Google Fit & Health', safety: 'safe' },
{ id: 'DISCOVERY', label: 'Block Discovery', desc: 'Google Device Discovery', safety: 'safe' },
{ id: 'BACKGROUND', label: 'Block Background', desc: 'Push notifications & Check-ins', safety: 'caution' },
{ id: 'UPDATE', label: 'Block Updates', desc: 'GMS auto-update services', safety: 'caution' },
{ id: 'GEOFENCE', label: 'Block Geofencing', desc: 'Geofence-based triggers', safety: 'caution' },
{ id: 'NEARBY', label: 'Block Nearby Share', desc: 'Quick Share services', safety: 'caution' },
{ id: 'CAST', label: 'Block Cast', desc: 'Chromecast & Media sharing', safety: 'caution' },
{ id: 'SYNC', label: 'Block Sync', desc: 'Cloud & Account sync', safety: 'caution' },
{ id: 'WEAR', label: 'Block Wear OS', desc: 'Smartwatch connectivity', safety: 'caution' },
{ id: 'LOCATION', label: 'Block Location', desc: 'Navigation & Maps accuracy', safety: 'warning' },
{ id: 'AUTH', label: 'Block Auth', desc: 'Google Account sign-in', safety: 'warning' },
{ id: 'CLOUD', label: 'Block Cloud', desc: 'Google Cloud services', safety: 'warning' },
{ id: 'WALLET', label: 'Block Wallet', desc: 'Google Wallet & NFC', safety: 'warning' },
{ id: 'PAYMENT', label: 'Block Payment', desc: 'Google Pay transactions', safety: 'warning' }
];
const MOD_PATH = '/data/adb/modules/ghostgms/config/user_prefs';
const PERSIST_PATH = '/data/adb/ghostgms/user_prefs';
const VELOXINE_PATH = '/data/adb/modules/ghostgms/veloxine.sh';
let currentPrefs = {};
function hexToUtf8(hex) {
let str = '';
for (let i = 0; i < hex.length; i += 2) {
str += String.fromCharCode(parseInt(hex.substr(i, 2), 16));
}
return str;
}
async function runCommand(cmd) {
try {
const res = await window.ksu.exec(cmd);
if (typeof res === 'string') return res;
if (res && typeof res === 'object') return res.stdout || res.output || '';
return '';
} catch (e) { return ''; }
}
function updateUIVisibility() {
const master = document.getElementById('ENABLE_SERVICES_DISABLE');
const catGrid = document.getElementById('service-grid');
const catTitle = document.getElementById('cat-title');
const state = master && !master.checked;
if (catGrid) catGrid.classList.toggle('disabled-section', state);
if (catTitle) catTitle.classList.toggle('disabled-section', state);
}
async function loadPrefs() {
try {
const hexCmd = `od -An -v -tx1 ${MOD_PATH} | tr -d ' \\n'`;
let hex = await runCommand(hexCmd);
if (!hex || hex.length < 10) hex = await runCommand(`od -An -v -tx1 ${PERSIST_PATH} | tr -d ' \\n'`);
if (hex) {
const content = hexToUtf8(hex);
const lines = content.split('\n');
lines.forEach(line => {
const match = line.match(/^([^=]+)=(.*)$/);
if (match) {
const key = match[1].trim();
const val = parseInt(match[2].trim());
if (!isNaN(val)) {
currentPrefs[key] = val.toString();
const el = document.getElementById(key);
if (el) el.checked = (val === 0);
}
}
});
updateUIVisibility();
}
} catch (e) { console.error(e); }
finally { document.getElementById('loader').classList.add('hidden'); }
}
async function savePrefs() {
const btn = document.getElementById('save-btn');
const oldText = btn.innerText;
btn.innerText = "SAVING...";
btn.disabled = true;
let content = '';
const fields = ['ENABLE_LOG_DISABLE', 'ENABLE_SYS_PROPS', 'ENABLE_BLUR_DISABLE', 'ENABLE_SERVICES_DISABLE'];
fields.forEach(key => {
const el = document.getElementById(key);
content += `${key}=${el && el.checked ? '0' : '1'}\n`;
});
categories.forEach(cat => {
const el = document.getElementById(`DISABLE_${cat.id}`);
content += `DISABLE_${cat.id}=${el && el.checked ? '0' : '1'}\n`;
});
try {
await runCommand(`mkdir -p /data/adb/ghostgms`);
await runCommand(`echo "${content}" > ${PERSIST_PATH}`);
await runCommand(`echo "${content}" > ${MOD_PATH}`);
window.ksu.toast("Configuration Saved!");
await runCommand(`sh ${VELOXINE_PATH} boot`);
window.ksu.toast("GhostGMS: Changes Applied!");
loadPrefs();
} catch (e) { window.ksu.toast("Save Error: " + e.message); }
finally { btn.innerText = oldText; btn.disabled = false; }
}
function initUI() {
const grid = document.getElementById('service-grid');
categories.forEach(cat => {
const card = document.createElement('div');
card.className = 'card';
card.innerHTML = `<div class="card-info"><span class="card-label ${cat.safety}">${cat.label}</span><span class="card-desc">${cat.desc}</span></div><label class="switch"><input type="checkbox" id="DISABLE_${cat.id}"><span class="slider"></span></label>`;
grid.appendChild(card);
});
document.getElementById('save-btn').addEventListener('click', savePrefs);
document.getElementById('ENABLE_SERVICES_DISABLE').addEventListener('change', updateUIVisibility);
let retries = 0;
const detect = () => {
if (window.ksu && window.ksu.exec) { loadPrefs(); }
else if (retries < 20) { retries++; setTimeout(detect, 200); }
else { document.getElementById('loader').classList.add('hidden'); }
};
detect();
}
document.addEventListener('DOMContentLoaded', initUI);
