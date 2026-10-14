import { spawnSync } from "node:child_process";
import { describe, expect, it } from "vitest";

const script = new URL("../../scripts/preparar-hospedagem.mjs", import.meta.url);

function executar(variables: Record<string, string>) {
  const environment = { ...process.env };
  for (const name of [
    "NETLIFY",
    "DATABASE_URL",
    "NETLIFY_DB_URL",
    "NETLIFY_DATABASE_URL",
  ]) {
    delete environment[name];
  }
  return spawnSync(process.execPath, [script.pathname], {
    env: { ...environment, ...variables },
    encoding: "utf8",
    timeout: 5000,
  });
}

describe("preparo do banco na hospedagem", () => {
  it.each<Record<string, string>>([
    { NETLIFY: "true" },
    { NETLIFY: "true", DATABASE_URL: "postgresql://invalid.invalid/test" },
    { NETLIFY_DB_URL: "postgresql://invalid.invalid/test" },
    { NETLIFY_DATABASE_URL: "postgresql://invalid.invalid/test" },
  ])("deixa a Netlify aplicar as migrations (%j)", (variables) => {
    const result = executar(variables);
    expect(result.error).toBeUndefined();
    expect(result.status).toBe(0);
    expect(result.stdout).toContain("Schema gerenciado pelas migrations da Netlify");
    expect(result.stdout).not.toContain("Aplicando o schema no banco");
    expect(result.stderr).toBe("");
  });

  it("continua permitindo um deploy sem banco em outras hospedagens", () => {
    const result = executar({});
    expect(result.error).toBeUndefined();
    expect(result.status).toBe(0);
    expect(result.stderr).toContain("pulando a criacao das tabelas");
    expect(result.stdout).toBe("");
  });
});
