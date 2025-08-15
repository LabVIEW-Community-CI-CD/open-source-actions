#!/usr/bin/env -S node --loader ts-node/esm
import { promises as fs } from 'fs';
import path from 'path';
import { glob } from 'glob';
import { parseStringPromise } from 'xml2js';
import yaml from 'js-yaml';

interface TestCase {
  id: string;
  name: string;
  status: 'passed' | 'failed' | 'skipped';
  duration: number;
  requirements: string[];
  owner?: string;
  evidence?: string;
}

interface RequirementGroup {
  id: string;
  description?: string;
  owner?: string;
  tests: TestCase[];
}

interface Totals {
  total: number;
  passed: number;
  failed: number;
  skipped: number;
  duration: number;
}

interface Mapping {
  reqInfo: Record<string, { description?: string; owner?: string }>;
  testMap: Map<string, { id: string; owner?: string }[]>;
}

const COLLATOR = new Intl.Collator('en', { numeric: true, sensitivity: 'base' });

function redact(text: string): string {
  return text.replace(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}/gi, '<redacted>');
}

function normalizeTestId(id: string): string {
  return id.toLowerCase().replace(/::/g, '-').replace(/\s+/g, '-');
}

function parseTags(name: string): { clean: string; reqs: string[]; owner?: string } {
  const reqs: string[] = [];
  let owner: string | undefined;
  name = name.replace(/\[REQ-([^\]]+)\]/gi, (_, id) => {
    reqs.push(`REQ-${id.toUpperCase()}`);
    return '';
  });
  name = name.replace(/\[Owner:([^\]]+)\]/i, (_, o) => {
    owner = o.trim();
    return '';
  });
  return { clean: name.trim(), reqs, owner };
}

async function parseJUnitFile(file: string): Promise<TestCase[]> {
  const xml = await fs.readFile(file, 'utf8');
  const data = await parseStringPromise(xml);
  const cases: TestCase[] = [];
  function walk(node: any) {
    if (!node) return;
    const suites = node.testsuite || node.testsuites;
    if (Array.isArray(suites)) {
      for (const s of suites) walk(s);
    } else if (suites) {
      walk(suites);
    }
    const tcs = node.testcase;
    if (Array.isArray(tcs)) {
      for (const tc of tcs) {
        const attrs = tc.$ || {};
        const { clean, reqs, owner } = parseTags(attrs.name || '');
        const classname = attrs.classname ? `${attrs.classname}::` : '';
        const id = (classname + clean).trim();
        const time = parseFloat(attrs.time || '0');
        const status: TestCase['status'] = tc.skipped
          ? 'skipped'
          : tc.failure || tc.error
          ? 'failed'
          : 'passed';
        cases.push({
          id,
          name: clean,
          status,
          duration: isNaN(time) ? 0 : time,
          requirements: reqs,
          owner,
        });
      }
    }
  }
  walk(data);
  return cases;
}

async function loadRequirementMapping(file: string): Promise<Mapping> {
  const reqInfo: Record<string, { description?: string; owner?: string }> = {};
  const testMap = new Map<string, { id: string; owner?: string }[]>();
  try {
    const text = await fs.readFile(file, 'utf8');
    const data = JSON.parse(text);
    const arr: any[] = Array.isArray(data?.requirements) ? data.requirements : Array.isArray(data) ? data : [];
    for (const r of arr) {
      reqInfo[r.id] = { description: r.description, owner: r.owner };
      for (const t of r.tests || []) {
        const obj = typeof t === 'string' ? { id: t } : t;
        if (!testMap.has(obj.id)) testMap.set(obj.id, []);
        testMap.get(obj.id)!.push({ id: r.id, owner: obj.owner || r.owner });
      }
    }
  } catch {
    /* ignore */
  }
  return { reqInfo, testMap };
}

async function gatherEvidence(dir: string): Promise<Map<string, string>> {
  const map = new Map<string, string>();
  try {
    const files = await glob(`${dir}/**/*`, { nodir: true });
    for (const f of files) {
      map.set(path.basename(f), path.join('artifacts', 'evidence', path.relative(dir, f)));
    }
  } catch {
    /* ignore */
  }
  return map;
}

async function copyEvidence(dir: string) {
  try {
    await fs.access(dir);
    await fs.mkdir('artifacts', { recursive: true });
    await fs.cp(dir, path.join('artifacts', 'evidence'), { recursive: true });
  } catch {
    /* ignore */
  }
}

function buildGroups(tests: TestCase[], mapping: Mapping, evidence: Map<string, string>): RequirementGroup[] {
  const groups = new Map<string, RequirementGroup>();
  for (const test of tests) {
    const mapped = mapping.testMap.get(test.id);
    if (mapped) {
      for (const m of mapped) {
        test.requirements.push(m.id);
        if (!test.owner && m.owner) test.owner = m.owner;
      }
    }
    const key = normalizeTestId(test.id);
    for (const [file, dest] of evidence.entries()) {
      if (file === key || file.startsWith(key + '.')) {
        test.evidence = dest;
        break;
      }
    }
    const reqs = test.requirements.length ? Array.from(new Set(test.requirements)) : ['Unmapped'];
    for (const req of reqs) {
      const info = mapping.reqInfo[req] || {};
      const g = groups.get(req) || { id: req, description: info.description, owner: info.owner, tests: [] };
      g.tests.push(test);
      groups.set(req, g);
    }
  }
  const arr = Array.from(groups.values());
  arr.sort((a, b) => COLLATOR.compare(a.id, b.id));
  const order: Record<TestCase['status'], number> = { failed: 0, passed: 1, skipped: 2 };
  for (const g of arr) {
    g.tests.sort((a, b) => {
      const diff = order[a.status] - order[b.status];
      if (diff !== 0) return diff;
      return a.id.localeCompare(b.id);
    });
  }
  return arr;
}

function computeTotals(tests: TestCase[]): Totals {
  let passed = 0,
    failed = 0,
    skipped = 0,
    duration = 0;
  for (const t of tests) {
    duration += t.duration;
    if (t.status === 'passed') passed++;
    else if (t.status === 'failed') failed++;
    else skipped++;
  }
  return { total: tests.length, passed, failed, skipped, duration };
}

function requirementPassRate(g: RequirementGroup): number {
  const p = g.tests.filter((t) => t.status === 'passed').length;
  const f = g.tests.filter((t) => t.status === 'failed').length;
  return p + f === 0 ? 0 : (p / (p + f)) * 100;
}

function matrixMarkdown(groups: RequirementGroup[], truncate: boolean): string {
  const header =
    '| Requirement | Test ID | Status | Duration (s) | Owner | Evidence |\n| --- | --- | --- | --- | --- | --- |\n';
  let md = '';
  let count = 0;
  for (const g of groups) {
    const rate = requirementPassRate(g).toFixed(0);
    const rows = truncate && count + g.tests.length > 100 ? g.tests.slice(0, 100 - count) : g.tests;
    const openDetails = g.tests.length > 5;
    const title = `${g.id} (${rate}% passed)`;
    if (openDetails) md += `<details><summary>${title}</summary>\n\n${header}`;
    else md += `#### ${title}\n\n${header}`;
    for (const t of rows) {
      const evidenceCell = t.evidence
        ? t.evidence.length <= 60
          ? `[✔️](${t.evidence})`
          : '✔️'
        : '';
      md += `| ${g.id} | ${redact(t.id)} | ${t.status.charAt(0).toUpperCase() + t.status.slice(1)} | ${t.duration.toFixed(
        2
      )} | ${redact(t.owner || '')} | ${evidenceCell} |\n`;
    }
    if (openDetails) md += '\n</details>\n\n';
    else md += '\n';
    count += rows.length;
    if (truncate && count >= 100) break;
  }
  if (truncate && groups.reduce((a, g) => a + g.tests.length, 0) > 100) {
    md += '\n_List truncated; see artifact for full details._\n';
  }
  return md;
}

async function writeStepSummary(content: string) {
  const summaryPath = process.env.GITHUB_STEP_SUMMARY;
  if (summaryPath) {
    await fs.appendFile(summaryPath, content);
  }
}

async function appendError(message: string) {
  await writeStepSummary(`\n\n### Errors\n\n\u0060\u0060\u0060\n${redact(message)}\n\u0060\u0060\u0060\n`);
}

async function writeTraceability(groups: RequirementGroup[], totals: Totals) {
  const json = { summary: totals, requirements: groups };
  await fs.writeFile(path.join('artifacts', 'traceability.json'), redact(JSON.stringify(json, null, 2)));
  const md = '# Test Traceability Matrix\n\n' + matrixMarkdown(groups, false);
  await fs.writeFile(path.join('artifacts', 'traceability.md'), redact(md));
}

interface ActionDocResult {
  md: string;
  json: any;
}

async function generateActionDocs(registryPath: string): Promise<ActionDocResult> {
  const actionYaml = yaml.load(await fs.readFile('action.yml', 'utf8')) as any;
  const inputs = Object.entries(actionYaml.inputs || {}).map(([name, info]: [string, any]) => ({
    name,
    description: info.description || '',
    required: !!info.required,
    default: info.default ?? '',
    type: info.type || 'string',
  }));
  const triggerInput = ['mode', 'command', 'function'].find((n) => inputs.some((i) => i.name === n));
  let registry: any = {};
  try {
    const full = path.resolve(registryPath);
    if (full.endsWith('.ts')) {
      const mod = await import(full);
      registry = mod.default ?? mod;
    } else {
      registry = JSON.parse(await fs.readFile(full, 'utf8'));
    }
  } catch {
    registry = {};
  }

  let md = '### Parameters\n';
  md += '| Name | Description | Required | Default | Type |\n| --- | --- | --- | --- | --- |\n';
  for (const inp of inputs) {
    md += `| ${inp.name} | ${redact(inp.description)} | ${inp.required ? 'Yes' : 'No'} | ${redact(
      String(inp.default)
    )} | ${inp.type} |\n`;
  }
  md += '\n### Dispatchers\n';
  for (const fname of Object.keys(registry).sort((a, b) => a.localeCompare(b))) {
    const info = registry[fname];
    md += `\n#### ${fname}\n`;
    if (info.description) md += `${redact(info.description)}\n\n`;
    md += '| Parameter | Type | Required | Default | Description |\n| --- | --- | --- | --- | --- |\n';
    const params = info.parameters || {};
    for (const pname of Object.keys(params).sort((a, b) => a.localeCompare(b))) {
      const p = params[pname];
      md += `| ${pname} | ${p.type} | ${p.required ? 'Yes' : 'No'} | ${redact(p.default ?? '')} | ${redact(
        p.description || ''
      )} |\n`;
    }
    if (triggerInput) {
      md += '\n```yaml\n- uses: ./\n  with:\n';
      md += `    ${triggerInput}: ${fname}\n`;
      md += '```\n';
    }
  }
  const json = { inputs, functions: registry };
  return { md: redact(md), json };
}

function buildSummary(totals: Totals, groups: RequirementGroup[], actionDocsMd: string): string {
  const passRate =
    totals.passed + totals.failed === 0 ? 0 : (totals.passed / (totals.passed + totals.failed)) * 100;
  const sha = (process.env.GITHUB_SHA || '').slice(0, 7);
  const runId = process.env.GITHUB_RUN_ID || '';
  let md = `## Summary\n\n`;
  md += `- Total: ${totals.total}\n`;
  md += `- Passed: ${totals.passed}\n`;
  md += `- Failed: ${totals.failed}\n`;
  md += `- Skipped: ${totals.skipped}\n`;
  md += `- Pass rate: ${passRate.toFixed(2)}%\n`;
  md += `- Duration: ${totals.duration.toFixed(2)}s\n`;
  md += `- Commit: ${sha}\n`;
  md += `- Run: ${runId}\n\n`;
  md += `## Test Traceability Matrix\n\n`;
  md += matrixMarkdown(groups, true);
  md += `\n## Action Documentation\n\n`;
  md += actionDocsMd;
  return md;
}

async function writeActionDocs(data: ActionDocResult) {
  await fs.writeFile(path.join('artifacts', 'action-docs.json'), redact(JSON.stringify(data.json, null, 2)));
  await fs.writeFile(path.join('artifacts', 'action-docs.md'), data.md);
}

export async function main() {
  const globPattern = process.env.TEST_RESULTS_GLOB || '**/junit*.xml';
  const mappingFile = process.env.REQ_MAPPING_FILE || 'requirements.json';
  const registryFile = process.env.DISPATCHER_REGISTRY || 'dispatchers.json';
  const evidenceDir = process.env.EVIDENCE_DIR || 'test-screenshots';
  try {
    const files = await glob(globPattern);
    if (files.length === 0) throw new Error('No JUnit files found');
    let tests: TestCase[] = [];
    for (const f of files) {
      const arr = await parseJUnitFile(f);
      tests = tests.concat(arr);
    }
    const mapping = await loadRequirementMapping(mappingFile);
    const evidence = await gatherEvidence(evidenceDir);
    await fs.mkdir('artifacts', { recursive: true });
    await copyEvidence(evidenceDir);
    const groups = buildGroups(tests, mapping, evidence);
    const totals = computeTotals(tests);
    const actionDocs = await generateActionDocs(registryFile);
    await writeTraceability(groups, totals);
    await writeActionDocs(actionDocs);
    const summary = buildSummary(totals, groups, actionDocs.md);
    await writeStepSummary(redact(summary));
  } catch (err: any) {
    await appendError(err.message || String(err));
    process.exitCode = 1;
  }
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}
