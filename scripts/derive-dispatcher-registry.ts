import { promises as fs } from 'fs';
import { glob } from 'glob';
import path from 'path';

interface ParameterInfo {
  type: 'string' | 'boolean' | 'number';
  required: boolean;
  default: string;
  description: string;
}

interface FunctionInfo {
  description: string;
  parameters: Record<string, ParameterInfo>;
}

function parseHelp(help: string): { description: string; paramDescriptions: Record<string, string> } {
  const paramDescriptions: Record<string, string> = {};
  let description = '';
  if (help) {
    const synMatch = help.match(/\.SYNOPSIS\s+([^]*?)(?=\n\.[A-Z]|\n#>)/i);
    const descMatch = help.match(/\.DESCRIPTION\s+([^]*?)(?=\n\.[A-Z]|\n#>)/i);
    description = (synMatch?.[1] || descMatch?.[1] || '').trim();
    const paramRegex = /\.PARAMETER\s+([^\n]+)\s+([^]*?)(?=\n\.[A-Z]|\n#>)/gi;
    let pm: RegExpExecArray | null;
    while ((pm = paramRegex.exec(help))) {
      paramDescriptions[pm[1].trim()] = pm[2].trim();
    }
  }
  return { description, paramDescriptions };
}

function parseParams(body: string, paramDescriptions: Record<string, string>): Record<string, ParameterInfo> {
  const params: Record<string, ParameterInfo> = {};
  const m = body.match(/param\s*\(([\s\S]*?)\)/i);
  if (!m) return params;
  const block = m[1];
  const entries = block.split(/[\r\n]+/).map((l) => l.trim()).filter(Boolean);
  for (let line of entries) {
    line = line.replace(/^[,]|[,]$/g, '').trim();
    const nameMatch = line.match(/\$([A-Za-z0-9_]+)/);
    if (!nameMatch) continue;
    const name = nameMatch[1];
    const type: ParameterInfo['type'] = /\[switch\]/i.test(line)
      ? 'boolean'
      : /\[int\]/i.test(line) || /\[double\]/i.test(line)
      ? 'number'
      : 'string';
    const required =
      /\[Parameter[^\]]*Mandatory\s*=\s*\$?true/i.test(line) || /\[Parameter\(Mandatory\)\]/i.test(line);
    let def = '';
    const eq = line.indexOf('=');
    if (eq !== -1) {
      def = line
        .slice(eq + 1)
        .split(',')[0]
        .trim()
        .replace(/^['"]|['"]$/g, '');
    }
    const description = paramDescriptions[name] || '';
    params[name] = { type, required, default: def, description };
  }
  return params;
}

async function parseFile(file: string): Promise<Record<string, FunctionInfo>> {
  const content = await fs.readFile(file, 'utf8');
  const result: Record<string, FunctionInfo> = {};
  const lines = content.split(/\r?\n/);
  for (let i = 0; i < lines.length; i++) {
    const fnMatch = lines[i].match(/^function\s+([A-Za-z0-9_]+)/);
    if (!fnMatch) continue;
    const name = fnMatch[1];

    let help = '';
    for (let j = i - 1; j >= 0; j--) {
      if (lines[j].trim().endsWith('#>')) {
        let start = j;
        while (start >= 0 && !lines[start].includes('<#')) start--;
        if (start >= 0) help = lines.slice(start, j + 1).join('\n');
        break;
      }
      if (lines[j].trim() !== '') break;
    }

    let brace = 0;
    let started = false;
    const bodyLines: string[] = [];
    for (let k = i; k < lines.length; k++) {
      const line = lines[k];
      if (line.includes('{')) {
        brace += (line.match(/\{/g) || []).length;
        started = true;
      }
      if (started) bodyLines.push(line);
      if (line.includes('}')) {
        brace -= (line.match(/\}/g) || []).length;
        if (started && brace === 0) {
          i = k;
          break;
        }
      }
    }
    const body = bodyLines.join('\n');
    const { description, paramDescriptions } = parseHelp(help);
    const parameters = parseParams(body, paramDescriptions);
    result[name] = { description, parameters };
  }
  return result;
}

async function main() {
  const files = await glob('actions/**/*.ps1');
  const aggregate: Record<string, FunctionInfo> = {};
  for (const file of files) {
    const parsed = await parseFile(file);
    Object.assign(aggregate, parsed);
  }
  const sorted: Record<string, FunctionInfo> = {};
  for (const fn of Object.keys(aggregate).sort((a, b) => a.localeCompare(b))) {
    const params = aggregate[fn].parameters;
    const sortedParams: Record<string, ParameterInfo> = {};
    for (const p of Object.keys(params).sort((a, b) => a.localeCompare(b))) {
      sortedParams[p] = params[p];
    }
    sorted[fn] = { description: aggregate[fn].description, parameters: sortedParams };
  }
  await fs.writeFile(path.resolve('dispatchers.json'), JSON.stringify(sorted, null, 2));
}

main().catch((err) => {
  console.error(err);
  process.exitCode = 1;
});
