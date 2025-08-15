#!/usr/bin/env ts-node
import { promises as fs } from 'fs';
import path from 'path';
import { glob } from 'glob';
import { parseStringPromise } from 'xml2js';

/**
 * Load requirement mappings from a JSON file. Returns empty object when file
 * cannot be parsed or does not exist.
 */
export async function loadRequirementMapping(mappingPath: string): Promise<Record<string, string>> {
  try {
    const contents = await fs.readFile(mappingPath, 'utf8');
    return JSON.parse(contents) as Record<string, string>;
  } catch (err: any) {
    console.warn(`Unable to read requirement mapping file at ${mappingPath}: ${err.message}`);
    return {};
  }
}

/**
 * Find the requirement identifier for a given test name. Returns undefined if
 * the test name is not present in the mapping.
 */
export function findRequirementId(testName: string, mapping: Record<string, string>): string | undefined {
  for (const [id, name] of Object.entries(mapping)) {
    if (name === testName) {
      return id;
    }
  }
  return undefined;
}

interface SuiteResult {
  name: string;
  tests: number;
  failures: number;
  passed: number;
}

async function parseJUnitFile(file: string): Promise<SuiteResult[]> {
  const xml = await fs.readFile(file, 'utf8');
  const data = await parseStringPromise(xml);
  const suites: any[] = [];
  if (data.testsuite) {
    suites.push(data.testsuite);
  } else if (data.testsuites && Array.isArray(data.testsuites.testsuite)) {
    suites.push(...data.testsuites.testsuite);
  } else if (data.testsuites && data.testsuites.testsuite) {
    suites.push(data.testsuites.testsuite);
  } else if (data.testsuites && data.testsuites.testcase) {
    const cases = Array.isArray(data.testsuites.testcase)
      ? data.testsuites.testcase
      : [data.testsuites.testcase];
    const failures = cases.filter((c: any) => c.failure || c.error).length;
    suites.push({
      $: {
        name: path.basename(file),
        tests: String(cases.length),
        failures: String(failures),
      },
    });
  }
  return suites.map((suite) => {
    const attrs = suite.$ || {};
    const tests = parseInt(attrs.tests ?? '0', 10);
    const failures = parseInt(attrs.failures ?? '0', 10) + parseInt(attrs.errors ?? '0', 10);
    const skipped = parseInt(attrs.skipped ?? attrs.disabled ?? '0', 10);
    const passed = tests - failures - skipped;
    return { name: attrs.name ?? path.basename(file), tests, failures, passed } as SuiteResult;
  });
}

async function appendSummary(results: SuiteResult[]): Promise<void> {
  const summaryPath = process.env.GITHUB_STEP_SUMMARY;
  if (!summaryPath) return;
  let md = '| Test Suite | Passed | Failed |\n| --- | --- | --- |\n';
  for (const r of results) {
    md += `| ${r.name} | ${r.passed} | ${r.failures} |\n`;
  }
  await fs.appendFile(summaryPath, md);
}

async function writeTraceability(results: SuiteResult[], mapping: Record<string, string>): Promise<void> {
  const trace: Record<string, unknown> = {};
  for (const r of results) {
    const req = findRequirementId(r.name, mapping);
    if (req) {
      trace[req] = { test: r.name, passed: r.failures === 0, failed: r.failures, passedTests: r.passed, total: r.tests };
    }
  }
  await fs.mkdir('artifacts', { recursive: true });
  await fs.writeFile(path.join('artifacts', 'traceability.json'), JSON.stringify(trace, null, 2));
}

async function main() {
  const patternsEnv = process.env.TEST_RESULTS_GLOBS;
  if (!patternsEnv) {
    console.warn('TEST_RESULTS_GLOBS not set');
    return;
  }

  const patterns = patternsEnv.split(/\r?\n|[ ,]+/).filter(Boolean);
  const files = new Set<string>();
  for (const pattern of patterns) {
    const matches = await glob(pattern);
    for (const m of matches) {
      files.add(m);
    }
  }

  const results: SuiteResult[] = [];
  for (const file of files) {
    const suites = await parseJUnitFile(file);
    results.push(...suites);
  }

  await appendSummary(results);

  const mappingFile = process.env.REQ_MAPPING_FILE ?? 'requirements.json';
  const mapping = await loadRequirementMapping(path.resolve(mappingFile));
  await writeTraceability(results, mapping);

  if (results.some((r) => r.failures > 0)) {
    process.exitCode = 1;
  }
}

// Only run main when executed directly (not when imported for tests)
if (process.argv[1] && process.argv[1].endsWith('generate-ci-summary.ts')) {
  main();
}
