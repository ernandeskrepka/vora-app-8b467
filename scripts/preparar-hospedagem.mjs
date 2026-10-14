// Preparo do banco no build da hospedagem (Netlify, Render e afins).
//
// Nao existe terminal nessas plataformas, entao o build e quem cria/atualiza
// as tabelas. Regras:
// - sem banco configurado (primeiro deploy, antes de criar o Postgres): avisa
//   e deixa o build seguir, para o site existir e as variaveis entrarem depois;
// - Netlify: as migrations da plataforma criam/atualizam as tabelas;
// - outras hospedagens com banco configurado: roda `prisma db push`;
// - falha de conexao nao derruba o build: o painel mostra o erro na hora do uso.
import { spawnSync } from "node:child_process";

if (
  process.env.NETLIFY === "true" ||
  process.env.NETLIFY_DB_URL ||
  process.env.NETLIFY_DATABASE_URL
) {
  console.log(
    "[vora] Schema gerenciado pelas migrations da Netlify; pulando prisma db push.",
  );
  process.exit(0);
}

const url =
  process.env.DATABASE_URL ||
  process.env.NETLIFY_DB_URL ||
  process.env.NETLIFY_DATABASE_URL;

if (!url) {
  console.warn(
    "[vora] Sem DATABASE_URL/NETLIFY_DB_URL: pulando a criacao das tabelas. " +
      "Crie o banco e rode o deploy de novo.",
  );
  process.exit(0);
}

console.log("[vora] Aplicando o schema no banco (prisma db push)...");
const r = spawnSync(
  "npx",
  ["prisma", "db", "push"],
  { stdio: "inherit", env: { ...process.env, DATABASE_URL: url } },
);

if (r.status !== 0) {
  console.warn(
    "[vora] Nao consegui aplicar o schema agora (status " + r.status + "). " +
      "O build continua; confira o banco e rode o deploy novamente.",
  );
}
process.exit(0);
