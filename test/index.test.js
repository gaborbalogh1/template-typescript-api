const test = require("node:test");
const assert = require("node:assert");
const http = require("node:http");
const app = require("../dist/index").default;

function request(server, path, opts = {}) {
  return new Promise((resolve, reject) => {
    const { port } = server.address();
    const req = http.request(
      { host: "127.0.0.1", port, path, method: opts.method || "GET", headers: opts.headers },
      res => {
        let body = "";
        res.on("data", chunk => (body += chunk));
        res.on("end", () => resolve({ status: res.statusCode, body: JSON.parse(body) }));
      }
    );
    req.on("error", reject);
    if (opts.body) req.write(opts.body);
    req.end();
  });
}

test("GET /healthz returns ok", async () => {
  const server = app.listen(0);
  try {
    const res = await request(server, "/healthz");
    assert.strictEqual(res.status, 200);
    assert.strictEqual(res.body.status, "ok");
  } finally {
    server.close();
  }
});

test("POST /echo validates the body with Zod", async () => {
  const server = app.listen(0);
  try {
    const ok = await request(server, "/echo", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ message: "hi" }),
    });
    assert.strictEqual(ok.status, 200);
    assert.strictEqual(ok.body.echoed, "hi");

    const bad = await request(server, "/echo", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ message: "" }),
    });
    assert.strictEqual(bad.status, 400);
  } finally {
    server.close();
  }
});
