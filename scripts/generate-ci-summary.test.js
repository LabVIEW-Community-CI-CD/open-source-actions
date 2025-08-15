import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'fs/promises';
import { fileURLToPath } from 'url';
import path from 'path';
import {
  loadRequirementMapping,
  findRequirementId,
  parseJUnitFile,
  renderActionDoc,
  main,
  copyEvidence,
  generateActionDocs,
} from './generate-ci-summary.ts';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const mappingPath = path.resolve(__dirname, '../requirements.json');

test('loadRequirementMapping reads file and findRequirementId works', async () => {
  const mapping = await loadRequirementMapping(mappingPath);
  assert.equal(findRequirementId('Dispatcher.Tests', mapping), 'REQ-001');
  assert.equal(findRequirementId('Unknown.Tests', mapping), undefined);
});

test('parseJUnitFile parses simple JUnit XML', async () => {
  const xml = `<?xml version="1.0" encoding="UTF-8"?>\n<testsuite name="Sample" tests="3" failures="1">\n  <testcase name="a"/>\n  <testcase name="b"><failure/></testcase>\n  <testcase name="c"/>\n</testsuite>`;
  const junitPath = path.join(__dirname, 'sample-junit.xml');
  await fs.writeFile(junitPath, xml);
  const suites = await parseJUnitFile(junitPath);
  await fs.unlink(junitPath);
  assert.equal(suites.length, 1);
  assert.deepEqual(suites[0], { name: 'Sample', tests: 3, failures: 1, passed: 2 });
});

test('renderActionDoc fills template placeholders', async () => {
  const templatePath = path.resolve(__dirname, '../doc-templates/action-doc-template.md');
  const template = await fs.readFile(templatePath, 'utf8');
  const info = {
    name: 'demo-action',
    synopsis: 'Demo synopsis',
    description: '',
    parameters: [
      { name: 'Req', type: 'string', required: true, description: 'required param' },
      { name: 'Opt', type: 'number', required: false, description: 'optional param' },
    ],
  };
  const md = renderActionDoc(template, info);
  assert.ok(md.includes('demo-action'));
  assert.ok(md.includes('**Req** (`string`): required param'));
  assert.ok(md.includes('**Opt** (`number`): optional param'));
  assert.ok(md.includes('pwsh -File actions/Invoke-OSAction.ps1 -ActionName demo-action'));
  assert.ok(md.includes('action_name: demo-action'));
});

test('main writes artifacts to artifacts directory', async () => {
  const cwd = process.cwd();
  try {
    process.chdir(path.resolve(__dirname, '..'));
    const junitXml = `<?xml version="1.0" encoding="UTF-8"?>\n<testsuite name="Sample" tests="1">\n  <testcase name="Dispatcher.Tests"/>\n</testsuite>`;
    const junitPath = path.join(__dirname, 'ci-junit.xml');
    await fs.writeFile(junitPath, junitXml);
    process.env.TEST_RESULTS_GLOBS = junitPath;
    process.env.DISPATCHER_SCRIPT = path.resolve('actions', 'Invoke-OSAction.ps1');
    await fs.rm('artifacts', { recursive: true, force: true });
    await main();
    await fs.access(path.join('artifacts', 'traceability.json'));
    await fs.access(path.join('artifacts', 'traceability.md'));
    await fs.access(path.join('artifacts', 'action-docs.zip'));
    await fs.unlink(junitPath);
  } finally {
    delete process.env.TEST_RESULTS_GLOBS;
    delete process.env.DISPATCHER_SCRIPT;
    await fs.rm(path.join(process.cwd(), 'artifacts'), { recursive: true, force: true });
    process.chdir(cwd);
  }
});

test('traceability markdown includes pass and fail results', async () => {
  const cwd = process.cwd();
  const dispatcher = path.join(__dirname, 'empty-dispatcher.ps1');
  const junitPath = path.join(__dirname, 'ci-multi.xml');
  try {
    process.chdir(path.resolve(__dirname, '..'));
    await fs.writeFile(dispatcher, "$Registry = [ordered]@{}");
    const junitXml =
      `<?xml version="1.0" encoding="UTF-8"?>\n` +
      `<testsuites>` +
      `<testsuite name="Dispatcher.Tests" tests="1" failures="0"><testcase name="Dispatcher.Tests"/></testsuite>` +
      `<testsuite name="Dispatcher.DryRun.Tests" tests="1" failures="1"><testcase name="Dispatcher.DryRun.Tests"><failure/></testcase></testsuite>` +
      `</testsuites>`;
    await fs.writeFile(junitPath, junitXml);
    process.env.TEST_RESULTS_GLOBS = junitPath;
    process.env.DISPATCHER_SCRIPT = dispatcher;
    await fs.rm('artifacts', { recursive: true, force: true });
    await main();
    const md = await fs.readFile(path.join('artifacts', 'traceability.md'), 'utf8');
    assert.match(md, /REQ-001.*Pass/);
    assert.match(md, /REQ-002.*Fail/);
  } finally {
    delete process.env.TEST_RESULTS_GLOBS;
    delete process.env.DISPATCHER_SCRIPT;
    await fs.rm(path.join(process.cwd(), 'artifacts'), { recursive: true, force: true });
    await fs.rm(junitPath, { force: true });
    await fs.rm(dispatcher, { force: true });
    process.chdir(cwd);
    process.exitCode = 0;
  }
});

test('copyEvidence copies files when EVIDENCE_DIR is set', async () => {
  const cwd = process.cwd();
  const evidenceDir = path.join(__dirname, 'evidence-src');
  const srcFile = path.join(evidenceDir, 'sample.txt');
  try {
    process.chdir(path.resolve(__dirname, '..'));
    await fs.rm('artifacts', { recursive: true, force: true });
    await fs.mkdir(evidenceDir, { recursive: true });
    await fs.writeFile(srcFile, 'hello');
    process.env.EVIDENCE_DIR = evidenceDir;
    await copyEvidence();
    const copied = await fs.readFile(path.join('artifacts', 'evidence', 'sample.txt'), 'utf8');
    assert.equal(copied, 'hello');
  } finally {
    delete process.env.EVIDENCE_DIR;
    await fs.rm(path.join(process.cwd(), 'artifacts'), { recursive: true, force: true });
    await fs.rm(evidenceDir, { recursive: true, force: true });
    process.chdir(cwd);
  }
});

test('generateActionDocs respects DISPATCHER_SCRIPT', async () => {
  const cwd = process.cwd();
  const pathEnv = process.env.PATH;
  let tmp;
  let binDir;
  try {
    tmp = await fs.mkdtemp(path.join(__dirname, 'docs-test-'));
    process.chdir(tmp);
    // Copy template
    await fs.mkdir(path.join('doc-templates'), { recursive: true });
    await fs.copyFile(
      path.resolve(__dirname, '../doc-templates/action-doc-template.md'),
      path.join('doc-templates', 'action-doc-template.md')
    );
    // Create fake actions
    await fs.mkdir(path.join('scripts', 'allowed-action'), { recursive: true });
    await fs.writeFile(path.join('scripts', 'allowed-action', 'AllowedAction.ps1'), '#');
    await fs.mkdir(path.join('scripts', 'other-action'), { recursive: true });
    await fs.writeFile(path.join('scripts', 'other-action', 'OtherAction.ps1'), '#');
    // Dispatcher allows only allowed-action
    const dispatcher = path.join(tmp, 'dispatcher.ps1');
    await fs.writeFile(dispatcher, "$Registry = [ordered]@{'allowed-action' = @{}}" );
    process.env.DISPATCHER_SCRIPT = dispatcher;
    // Fake pwsh
    binDir = await fs.mkdtemp(path.join(__dirname, 'fake-pwsh-'));
    const pwshPath = path.join(binDir, 'pwsh');
    await fs.writeFile(
      pwshPath,
      "#!/bin/sh\necho '{\"Synopsis\":\"s\",\"Description\":{\"Text\":\"d\"},\"Parameters\":{\"Parameter\":[]}}'"
    );
    await fs.chmod(pwshPath, 0o755);
    process.env.PATH = `${binDir}:${pathEnv}`;
    await fs.rm('artifacts', { recursive: true, force: true });
    await generateActionDocs();
    const files = await fs.readdir(path.join('artifacts', 'action-docs'));
    assert.deepEqual(files, ['allowed-action.md']);
  } finally {
    if (binDir) await fs.rm(binDir, { recursive: true, force: true });
    if (tmp) await fs.rm(tmp, { recursive: true, force: true });
    delete process.env.DISPATCHER_SCRIPT;
    process.env.PATH = pathEnv;
    process.chdir(cwd);
  }
});
