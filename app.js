/* =====================================================
   Compiler Optimization Viewer — app.js
   ===================================================== */

/* ── Topic Metadata ───────────────────────────────── */
const TOPICS = [
  {
    id: 'cse',
    name: 'Common Subexpression Elimination',
    short: 'CSE',
    desc: 'Identifies and eliminates repeated computations of the same expression.',
    gcc: {
      dir: 'gcc/Common_Subexpression_Elimination',
      src: 'example.c',
      asm: { O0: 'example_o0.s', O1: 'example_o1.s', O2: 'example_o2.s', O3: 'example_o3.s' },
      explanation: 'explanation.md',
    },
    llvm: {
      dir: 'llvm/Common_Subexpression_Elimination',
      src: 'example_1_1.c',
      ir: { O0: 'example_O0.ll', O1: 'example_O1.ll', O2: 'example_O2.ll', O3: 'example_O3.ll' },
      explanation: 'explanation.md',
    },
  },
  {
    id: 'cf',
    name: 'Constant Folding',
    short: 'CF',
    desc: 'Evaluates constant expressions at compile time rather than run time.',
    gcc: {
      dir: 'gcc/Constant_Folding',
      src: 'example_1_1.c',
      asm: { O0: 'example_O0.s', O1: 'example_O1.s', O2: 'example_O2.s', O3: 'example_O3.s' },
      explanation: 'explanation.md',
    },
    llvm: {
      dir: 'llvm/Constant_Folding',
      src: null,           // no source in LLVM folder; GCC source is shared
      ir: { O0: 'example_O0.ll', O1: 'example_O1.ll', O2: 'example_O2.ll', O3: 'example_O3.ll' },
      explanation: 'explanation.md',
    },
  },
  {
    id: 'cp',
    name: 'Constant Propagation',
    short: 'CP',
    desc: 'Replaces variable references with their known constant values throughout the code.',
    gcc: {
      dir: 'gcc/Constant_Propagation',
      src: 'example.c',
      asm: { O0: 'example_o0.s', O1: 'example_o1.s', O2: 'example_o2.s', O3: 'example_o3.s' },
      explanation: 'explanation.md',
    },
    llvm: {
      dir: 'llvm/Constant_Propagation',
      src: 'example_1_1.c',
      ir: { O0: 'example_O0.ll', O1: 'example_O1.ll', O2: 'example_O2.ll', O3: 'example_O3.ll' },
      explanation: 'explanation.md',
    },
  },
  {
    id: 'copyp',
    name: 'Copy Propagation',
    short: 'CopyP',
    desc: 'Replaces uses of an assigned variable with its right-hand-side expression.',
    gcc: {
      dir: 'gcc/Copy_Propagation',
      src: 'example.c',
      asm: { O0: 'example_o0.s', O1: 'example_o1.s', O2: 'example_o2.s', O3: 'example_o3.s' },
      explanation: 'explanation.md',
    },
    llvm: {
      dir: 'llvm/Copy_Propagation',
      src: 'example_1_1.c',
      ir: { O0: 'example_O0.ll', O1: 'example_O1.ll', O2: 'example_O2.ll', O3: 'example_O3.ll' },
      explanation: 'explanation.md',
    },
  },
  {
    id: 'dce',
    name: 'Dead Code Elimination',
    short: 'DCE',
    desc: 'Removes code that is computed but whose result is never used.',
    gcc: {
      dir: 'gcc/Dead_Code_Elimination',
      src: 'example.c',
      asm: { O0: 'example_o0.s', O1: 'example_o1.s', O2: 'example_o2.s', O3: 'example_o3.s' },
      explanation: 'explanation.md',
    },
    llvm: {
      dir: 'llvm/Dead_Code_Elimination',
      src: 'example_1_1.c',
      ir: { O0: 'example_O0.ll', O1: 'example_O1.ll', O2: 'example_O2.ll', O3: 'example_O3.ll' },
      explanation: 'explanation.md',
    },
  },
  {
    id: 'fc',
    name: 'Function Cloning',
    short: 'FC',
    desc: 'Duplicates a function to allow specialized optimizations for specific call sites.',
    gcc: {
      dir: 'gcc/Function_Cloning',
      src: 'example.c',
      asm: { O0: 'example_o0.s', O1: 'example_o1.s', O2: 'example_o2.s', O3: 'example_o3.s' },
      explanation: 'explanation.md',
    },
    llvm: {
      dir: 'llvm/Function_Cloning',
      src: 'example_1_1.c',
      ir: { O0: 'example_O0.ll', O1: 'example_O1.ll', O2: 'example_O2.ll', O3: 'example_O3.ll' },
      explanation: 'explanation.md',
    },
  },
  {
    id: 'fi',
    name: 'Function Inlining',
    short: 'FI',
    desc: 'Replaces a function call with the body of the called function.',
    gcc: {
      dir: 'gcc/Function_Inlining',
      src: 'example.c',
      asm: { O0: 'example_o0.s', O1: 'example_o1.s', O2: 'example_o2.s', O3: 'example_o3.s' },
      explanation: 'explanation.md',
    },
    llvm: {
      dir: 'llvm/Function_Inlining',
      src: 'example_1_1.c',
      ir: { O0: 'example_O0.ll', O1: 'example_O1.ll', O2: 'example_O2.ll', O3: 'example_O3.ll' },
      explanation: 'explanation.md',
    },
  },
  {
    id: 'ive',
    name: 'Induction Variable Elimination',
    short: 'IVE',
    desc: 'Removes or replaces induction variables that depend only on the loop counter.',
    gcc: {
      dir: 'gcc/induction_variable_elimination',
      src: 'example.c',
      asm: { O0: 'example_o0.s', O1: 'example_o1.s', O2: 'example_o2.s', O3: 'example_o3.s' },
      explanation: 'explanation.md',
    },
    llvm: {
      dir: 'llvm/Induction_Variable_Elimination',
      src: 'example_1_1.c',
      ir: { O0: 'example_O0.ll', O1: 'example_O1.ll', O2: 'example_O2.ll', O3: 'example_O3.ll' },
      explanation: 'explanation.md',
    },
  },
  {
    id: 'lf',
    name: 'Loop Fusion',
    short: 'LF',
    desc: 'Merges two adjacent loops with the same bounds into a single loop.',
    gcc: {
      dir: 'gcc/Loop_Fusion',
      src: 'example_1_1.c',
      asm: { O0: 'example_O0.s', O1: 'example_O1.s', O2: 'example_O2.s', O3: 'example_O3.s' },
      explanation: 'explanation.md',
    },
    llvm: {
      dir: 'llvm/Loop_Fusion',
      src: 'example_1_1.c',
      ir: { O0: 'example_O0.ll', O1: 'example_O1.ll', O2: 'example_O2.ll', O3: 'example_O3.ll' },
      explanation: 'explanation.md',
    },
  },
  {
    id: 'licm',
    name: 'Loop Invariant Detection & Code Motion',
    short: 'LICM',
    desc: 'Moves computations that do not change within a loop to outside the loop.',
    gcc: {
      dir: 'gcc/Loop_Invariant_Detection_and_Code_Motion',
      src: 'example_1_1.c',
      asm: { O0: 'example_O0.s', O1: 'example_O1.s', O2: 'example_O2.s', O3: 'example_O3.s' },
      explanation: 'explanation.md',
    },
    llvm: {
      dir: 'llvm/Loop_Invariant_Detection_and_Code_Motion',
      src: 'example_1_1.c',
      ir: { O0: 'example_O0.ll', O1: 'example_O1.ll', O2: 'example_O2.ll', O3: 'example_O3.ll' },
      explanation: 'explanation.md',
    },
  },
  {
    id: 'lp',
    name: 'Loop Peeling',
    short: 'LP',
    desc: 'Extracts the first (or last) few iterations of a loop to enable further optimization.',
    gcc: {
      dir: 'gcc/Loop_Peeling',
      src: 'example_1_1.c',
      asm: { O0: 'example_O0.s', O1: 'example_O1.s', O2: 'example_O2.s', O3: 'example_O3.s' },
      explanation: 'explanation.md',
    },
    llvm: {
      dir: 'llvm/Loop_Peeling',
      src: 'example_1_1.c',
      ir: { O0: 'example_O0.ll', O1: 'example_O1.ll', O2: 'example_O2.ll', O3: 'example_O3.ll' },
      explanation: 'explanation.md',
    },
  },
  {
    id: 'sr',
    name: 'Strength Reduction',
    short: 'SR',
    desc: 'Replaces expensive operations (e.g. multiplication) with cheaper ones (e.g. addition).',
    gcc: {
      dir: 'gcc/strength_reduction',
      src: 'example_1_1.c',
      asm: { O0: 'example_O0.s', O1: 'example_O1.s', O2: 'example_O2.s', O3: 'example_O3.s' },
      explanation: 'explanation.md',
    },
    llvm: {
      dir: 'llvm/Strength_Reduction',
      src: 'example_1_1.c',
      ir: { O0: 'example_O0.ll', O1: 'example_O1.ll', O2: 'example_O2.ll', O3: 'example_O3.ll' },
      explanation: 'explanation.md',
    },
  },
  {
    id: 'srl',
    name: 'Strength Reduction in Loops',
    short: 'SRL',
    desc: 'Applies strength reduction specifically to loop induction variables and array indexing.',
    gcc: {
      dir: 'gcc/Strength_Reduction_in_Loops',
      src: 'example_1_1.c',
      asm: { O0: 'example_O0.s', O1: 'example_O1.s', O2: 'example_O2.s', O3: 'example_O3.s' },
      explanation: 'explanation.md',
    },
    llvm: {
      dir: 'llvm/Strength_Reduction_in_Loops',
      src: 'example_1_1.c',
      ir: { O0: 'example_O0.ll', O1: 'example_O1.ll', O2: 'example_O2.ll', O3: 'example_O3.ll' },
      explanation: 'explanation.md',
    },
  },
  {
    id: 'uce',
    name: 'Unreachable Code Elimination',
    short: 'UCE',
    desc: 'Removes branches and code that can never be executed regardless of input.',
    gcc: {
      dir: 'gcc/Unreachable_Code_Elimination',
      src: 'example_1_1.c',
      asm: { O0: 'example_O0.s', O1: 'example_O1.s', O2: 'example_O2.s', O3: 'example_O3.s' },
      explanation: 'explanation.md',
    },
    llvm: {
      dir: 'llvm/Unreachable_Code_Elimination',
      src: 'example_1_1.c',
      ir: { O0: 'example_O0.ll', O1: 'example_O1.ll', O2: 'example_O2.ll', O3: 'example_O3.ll' },
      explanation: 'explanation.md',
    },
  },
];

/* ── State ────────────────────────────────────────── */
const state = {
  currentTopic: null,
  currentLevel: 'O0',
  currentExpTab: 'gcc',
  // cache of fetched file contents
  cache: {},
  // loaded explanation text
  gccExplanation: '',
  llvmExplanation: '',
};

/* ── DOM Refs ─────────────────────────────────────── */
const $ = id => document.getElementById(id);
const $q = sel => document.querySelector(sel);

/* ── Utility: fetch with cache ───────────────────── */
async function fetchFile(path) {
  if (state.cache[path] !== undefined) return state.cache[path];
  try {
    const res = await fetch(path);
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const text = await res.text();
    state.cache[path] = text;
    return text;
  } catch (e) {
    state.cache[path] = null;
    return null;
  }
}

/* ── Utility: escape HTML ────────────────────────── */
function escHtml(s) {
  return s
    .replace(/&/g,'&amp;')
    .replace(/</g,'&lt;')
    .replace(/>/g,'&gt;');
}

/* ── Utility: highlight code ─────────────────────── */
function highlight(code, lang) {
  if (!code) return '<em style="color:var(--text-dim)">File not found or empty.</em>';
  try {
    const aliases = { 's': 'x86asm', 'll': 'llvm', 'c': 'c' };
    const l = aliases[lang] || lang;
    if (hljs.getLanguage(l)) {
      return hljs.highlight(code, { language: l }).value;
    }
  } catch (_) {}
  return escHtml(code);
}

/* ── Utility: show/hide loading ───────────────────── */
function showLoading() { $('loading-overlay').style.display = 'flex'; }
function hideLoading() { $('loading-overlay').style.display = 'none'; }

/* ── Parse GCC explanation.md → per-level sections ── */
function parseGccExplanation(md) {
  if (!md) return { O0: '', O1: '', O2: '', O3: '', intro: '' };

  // Headers like: ### `-O0` or ### -O0 or ## `-O0`
  const levelPattern = /#{2,4}\s+[`-]*(-O[0-3])[`-]?[^\n]*/gi;
  const matches = [];
  let m;
  while ((m = levelPattern.exec(md)) !== null) {
    matches.push({ level: m[1].replace('-', ''), index: m.index });
  }

  if (matches.length === 0) return { O0: '', O1: '', O2: '', O3: '', intro: md };

  const intro = md.slice(0, matches[0].index).trim();
  const sections = {};
  for (let i = 0; i < matches.length; i++) {
    const start = matches[i].index;
    const end   = i + 1 < matches.length ? matches[i + 1].index : md.length;
    sections[matches[i].level] = md.slice(start, end).trim();
  }
  return { ...sections, intro };
}

/* ── Parse LLVM explanation.md → per-level sections (same format as GCC) ── */
function parseLlvmExplanation(txt) {
  // Reuse the same section parser as GCC — LLVM .md files use identical ### -O0 headers
  return parseGccExplanation(txt);
}

/* ── Build key differences table ─────────────────── */
function buildDiffTable(gccSections, llvmFullText) {
  const levels = [
    { key: 'O0', label: '-O0', name: 'No Optimization' },
    { key: 'O1', label: '-O1', name: 'Basic' },
    { key: 'O2', label: '-O2', name: 'More Opts' },
    { key: 'O3', label: '-O3', name: 'Aggressive' },
  ];

  const gccSummary = {
    O0: extractFirstBullets(gccSections.O0, 3) || 'No optimizations applied.',
    O1: extractFirstBullets(gccSections.O1, 3) || 'Basic optimizations enabled.',
    O2: extractFirstBullets(gccSections.O2, 3) || 'Additional pass-level optimizations.',
    O3: extractFirstBullets(gccSections.O3, 3) || 'Aggressive optimizations including vectorization.',
  };

  const llvmSec = parseGccExplanation(llvmFullText);
  const llvmSummary = {
    O0: extractFirstBullets(llvmSec.O0, 3) || 'No optimizations; full debug info preserved.',
    O1: extractFirstBullets(llvmSec.O1, 3) || 'Simple optimizations; mem2reg applied.',
    O2: extractFirstBullets(llvmSec.O2, 3) || 'CSE, GVN, LICM applied at IR level.',
    O3: extractFirstBullets(llvmSec.O3, 3) || 'Aggressive inlining, unrolling, auto-vectorization.',
  };

  let html = `
    <table class="diff-table">
      <thead>
        <tr>
          <th class="level-col">Level</th>
          <th><span class="gcc-col">GCC</span> (x86-64 Assembly)</th>
          <th><span class="llvm-col">LLVM/Clang</span> (LLVM IR)</th>
        </tr>
      </thead>
      <tbody>`;

  for (const { key, label, name } of levels) {
    html += `
      <tr>
        <td class="level-col level-${key}">${label}<br><small style="color:var(--text-dim);font-family:var(--font-ui)">${name}</small></td>
        <td class="gcc-col">${gccSummary[key]}</td>
        <td class="llvm-col">${llvmSummary[key]}</td>
      </tr>`;
  }

  html += `</tbody></table>`;
  return html;
}

/* Extract first N bullet points / key sentences from a markdown section */
function extractFirstBullets(md, n) {
  if (!md) return '';
  // Get lines with - or * bullets or bold text
  const bullets = md.split('\n')
    .filter(l => /^[-*]\s/.test(l.trim()) || /\*\*/.test(l))
    .slice(0, n)
    .map(l => l.replace(/^[-*]\s/, '').replace(/\*\*/g, '').trim())
    .filter(Boolean);
  if (bullets.length) return bullets.map(b => `• ${b}`).join('<br>');
  // Fallback: first 2 non-empty lines after the header
  const lines = md.split('\n').filter(l => l.trim() && !/^#+/.test(l.trim())).slice(0, 2);
  return lines.map(l => l.replace(/\*\*/g, '').trim()).join(' ');
}

/* Try to extract LLVM-specific notes for a given level from the plain-text explanation */
function extractLLVMLevel(txt, level) {
  if (!txt) return '';
  const re = new RegExp(`-${level}[^\\n]*\\n([\\s\\S]*?)(?=\\n-O|={10}|\\z)`, 'i');
  const m  = txt.match(re);
  if (m && m[1]) {
    return m[1].split('\n').filter(Boolean).slice(0, 3).join(' ').trim();
  }
  return '';
}

/* ── Sidebar: render nav items ───────────────────── */
function renderSidebar() {
  const nav = $('sidebar-nav');
  nav.innerHTML = TOPICS.map((t, i) => `
    <div class="nav-item" data-id="${t.id}" title="${t.desc}">
      <span class="nav-num">${String(i + 1).padStart(2, '0')}</span>
      <span>${t.name}</span>
    </div>
  `).join('');

  $('topic-count').textContent = TOPICS.length;

  nav.querySelectorAll('.nav-item').forEach(el => {
    el.addEventListener('click', () => loadTopic(el.dataset.id));
  });
}

/* ── Welcome grid: render cards ──────────────────── */
function renderWelcomeGrid() {
  $('welcome-grid').innerHTML = TOPICS.map((t, i) => `
    <div class="welcome-card" data-id="${t.id}">
      <div class="welcome-card-num">${String(i + 1).padStart(2, '0')} · ${t.short}</div>
      <div class="welcome-card-name">${t.name}</div>
    </div>
  `).join('');

  $('welcome-grid').querySelectorAll('.welcome-card').forEach(el => {
    el.addEventListener('click', () => loadTopic(el.dataset.id));
  });
}

/* ── Search ──────────────────────────────────────── */
function initSearch() {
  $('search-input').addEventListener('input', e => {
    const q = e.target.value.toLowerCase();
    document.querySelectorAll('.nav-item').forEach(el => {
      const match = el.textContent.toLowerCase().includes(q);
      el.classList.toggle('hidden', !match);
    });
  });
}

/* ── Load topic ───────────────────────────────────── */
async function loadTopic(id) {
  const topic = TOPICS.find(t => t.id === id);
  if (!topic) return;

  state.currentTopic = topic;
  state.currentLevel = 'O0';
  state.currentExpTab = 'gcc';
  state.gccExplanation  = '';
  state.llvmExplanation = '';

  // Update sidebar active
  document.querySelectorAll('.nav-item').forEach(el => {
    el.classList.toggle('active', el.dataset.id === id);
  });

  // Switch views
  $('welcome').style.display    = 'none';
  $('topic-view').style.display = 'block';

  // Set header
  $('topic-title').textContent = topic.name;
  $('topic-desc').textContent  = topic.desc;

  showLoading();

  // Determine source file paths
  const gccSrcPath  = `${topic.gcc.dir}/${topic.gcc.src}`;
  const llvmSrcPath = topic.llvm.src ? `${topic.llvm.dir}/${topic.llvm.src}` : null;

  // Build source tabs
  const srcFiles = $('source-files');
  if (topic.llvm.src && topic.llvm.src !== topic.gcc.src) {
    srcFiles.innerHTML = `
      <span class="src-tab active" data-src="gcc">${topic.gcc.src} (GCC)</span>
      <span class="src-tab" data-src="llvm">${topic.llvm.src} (LLVM)</span>
    `;
    srcFiles.querySelectorAll('.src-tab').forEach(tab => {
      tab.addEventListener('click', async () => {
        srcFiles.querySelectorAll('.src-tab').forEach(t => t.classList.remove('active'));
        tab.classList.add('active');
        const path = tab.dataset.src === 'gcc' ? gccSrcPath : llvmSrcPath;
        const code = await fetchFile(path);
        renderCode('source-code-inner', code, 'c');
      });
    });
  } else {
    srcFiles.innerHTML = `<span class="src-tab active">${topic.gcc.src}</span>`;
  }

  // Fetch source + explanations in parallel
  const [gccSrc, llvmExplTxt, gccExplTxt] = await Promise.all([
    fetchFile(gccSrcPath),
    topic.llvm.explanation ? fetchFile(`${topic.llvm.dir}/${topic.llvm.explanation}`) : Promise.resolve(''),
    topic.gcc.explanation  ? fetchFile(`${topic.gcc.dir}/${topic.gcc.explanation}`)  : Promise.resolve(''),
  ]);

  state.gccExplanation  = gccExplTxt  || '';
  state.llvmExplanation = llvmExplTxt || '';

  renderCode('source-code-inner', gccSrc, 'c');

  hideLoading();

  // Load first level
  await loadLevel('O0');

  // Reset opt tabs
  document.querySelectorAll('.opt-tab').forEach(btn => {
    btn.classList.toggle('active', btn.dataset.level === 'O0');
  });

  // Show gcc explanation by default
  renderExplanation('gcc');
}

/* ── Load optimization level ─────────────────────── */
async function loadLevel(level) {
  if (!state.currentTopic) return;
  state.currentLevel = level;
  const topic = state.currentTopic;

  showLoading();

  const gccFile  = topic.gcc.asm[level];
  const llvmFile = topic.llvm.ir[level];
  const gccPath  = `${topic.gcc.dir}/${gccFile}`;
  const llvmPath = `${topic.llvm.dir}/${llvmFile}`;

  const [gccCode, llvmCode] = await Promise.all([
    fetchFile(gccPath),
    fetchFile(llvmPath),
  ]);

  $('gcc-file-tag').textContent  = gccFile;
  $('llvm-file-tag').textContent = llvmFile;

  renderCode('gcc-code',  gccCode,  's');
  renderCode('llvm-code', llvmCode, 'll');

  hideLoading();

  // Refresh explanation panel for the new level
  renderExplanation(state.currentExpTab);
}

/* ── Render code into an element ─────────────────── */
function renderCode(elemId, code, lang) {
  const el = $(elemId);
  // Clear any previous hljs state so it can re-highlight
  delete el.dataset.highlighted;
  if (code === null) {
    el.innerHTML = '<em style="color:var(--text-dim)">⚠ File not found or empty.</em>';
    return;
  }
  el.innerHTML = highlight(code, lang);
}

/* ── Render explanation panel ─────────────────────── */
function renderExplanation(tab) {
  state.currentExpTab = tab;

  document.querySelectorAll('.exp-tab').forEach(btn => {
    btn.classList.toggle('active', btn.dataset.exp === tab);
  });

  const level      = state.currentLevel;
  const gccSec     = parseGccExplanation(state.gccExplanation);
  const expContent = $('exp-content');

  if (tab === 'gcc') {
    // Show per-level section from explanation.md
    const section = gccSec[level] || gccSec.intro || '';
    if (!section) {
      expContent.innerHTML = '<em style="color:var(--text-dim)">No GCC explanation available.</em>';
    } else {
      expContent.innerHTML = `
        <div class="notice">
          <span class="notice-icon">⚙</span>
          <span>GCC explanation for optimization level <strong>${level}</strong> – ${state.currentTopic?.name}</span>
        </div>
        ${typeof marked !== 'undefined' ? marked.parse(section) : `<pre>${escHtml(section)}</pre>`}
      `;
    }
  } else if (tab === 'llvm') {
    // Show per-level LLVM explanation (same markdown format as GCC)
    const llvmSec = parseLlvmExplanation(state.llvmExplanation);
    const section = llvmSec[level] || llvmSec.intro || '';
    if (!section) {
      expContent.innerHTML = '<em style="color:var(--text-dim)">No LLVM explanation available.</em>';
    } else {
      expContent.innerHTML = `
        <div class="notice">
          <span class="notice-icon">◈</span>
          <span>LLVM/Clang explanation for optimization level <strong>${level}</strong> – ${state.currentTopic?.name}</span>
        </div>
        ${typeof marked !== 'undefined' ? marked.parse(section) : `<pre>${escHtml(section)}</pre>`}
      `;
    }
  } else if (tab === 'diff') {
    expContent.innerHTML = `
      <div class="notice">
        <span class="notice-icon">⚖</span>
        <span>Key differences between GCC and LLVM/Clang across all optimization levels for <strong>${state.currentTopic?.name}</strong></span>
      </div>
      ${buildDiffTable(gccSec, state.llvmExplanation)}
      <div style="margin-top:16px;font-size:12px;color:var(--text-dim)">
        * GCC emits x86-64 assembly; LLVM emits architecture-independent IR before further lowering.<br>
        * GCC optimizations are controlled by a single <code>-On</code> flag; LLVM uses LLVM IR passes independently.<br>
        * At <strong>-O1+</strong>, GCC performs CSE and constant folding together; LLVM separates these as individual IR passes.
      </div>
    `;
  }
}

/* ── Back button ─────────────────────────────────── */
function goBack() {
  $('welcome').style.display    = 'block';
  $('topic-view').style.display = 'none';
  state.currentTopic = null;
  document.querySelectorAll('.nav-item').forEach(el => el.classList.remove('active'));
}

/* ── Copy to clipboard ───────────────────────────── */
function copyCode(elemId, btnId) {
  const text = $(elemId)?.textContent || '';
  navigator.clipboard.writeText(text).then(() => {
    const btn = $(btnId);
    const orig = btn.textContent;
    btn.textContent = '✓ Copied';
    setTimeout(() => { btn.textContent = orig; }, 1500);
  });
}

/* ── Collapsible panel toggle ────────────────────── */
function initCollapsible(toggleId, bodyId, arrowId) {
  $(toggleId).addEventListener('click', e => {
    // Don't close if clicking inside nested tabs
    if (e.target.closest('.exp-tabs, .src-tab, .opt-tabs')) return;
    const body  = $(bodyId);
    const arrow = $(arrowId);
    const open  = !body.classList.contains('collapsed');
    body.classList.toggle('collapsed', open);
    arrow.classList.toggle('collapsed', open);
  });
}

/* ── Init ────────────────────────────────────────── */
function init() {
  renderSidebar();
  renderWelcomeGrid();
  initSearch();

  // Collapsible panels
  initCollapsible('source-toggle', 'source-body', 'source-arrow');
  initCollapsible('explanation-toggle', 'exp-body', 'exp-arrow');

  // Opt-level tab buttons
  document.querySelectorAll('.opt-tab').forEach(btn => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('.opt-tab').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      loadLevel(btn.dataset.level);
    });
  });

  // Explanation tab buttons
  document.querySelectorAll('.exp-tab').forEach(btn => {
    btn.addEventListener('click', e => {
      e.stopPropagation();
      renderExplanation(btn.dataset.exp);
    });
  });

  // Copy buttons
  $('gcc-copy-btn').addEventListener('click',  () => copyCode('gcc-code',  'gcc-copy-btn'));
  $('llvm-copy-btn').addEventListener('click', () => copyCode('llvm-code', 'llvm-copy-btn'));

  // Back button
  $('back-btn').addEventListener('click', goBack);

  // Configure marked.js
  if (typeof marked !== 'undefined') {
    marked.setOptions({ breaks: true, gfm: true });
  }

  // Keyboard: Escape → back
  document.addEventListener('keydown', e => {
    if (e.key === 'Escape' && state.currentTopic) goBack();
  });
}

document.addEventListener('DOMContentLoaded', init);
