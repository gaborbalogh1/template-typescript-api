import express, { Request, Response } from "express";
import helmet from "helmet";
import cors from "cors";
import pino from "pino";
import { z } from "zod";

const log = pino({ level: process.env.LOG_LEVEL ?? "info" });
const app = express();
const PORT = parseInt(process.env.PORT ?? "3000");

app.use(helmet());
app.use(cors());
app.use(express.json());

app.get("/healthz", (_req: Request, res: Response) =>
  res.json({ status: "ok", uptime: process.uptime() }));

app.get("/", (_req: Request, res: Response) =>
  res.json({ service: process.env.SERVICE_NAME ?? "api", version: "1.0.0" }));

// Real Zod validation, not just an import that's never used -- README/
// .idp.yaml both claim "Zod validation" as a feature, so it needs an
// actual validated route, not just the dependency listed.
const EchoSchema = z.object({
  message: z.string().min(1).max(1000),
});

app.post("/echo", (req: Request, res: Response) => {
  const parsed = EchoSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ error: "Invalid request body", details: parsed.error.flatten() });
  }
  res.json({ echoed: parsed.data.message });
});

// Same dual-purpose pattern Forge itself uses (app.js) -- runnable directly
// via `node dist/index.js` (ECS Fargate, local dev) without also starting a
// listener when required as a module by lambda.ts (serverless-http wraps
// the Express app directly; a real listening server is neither needed nor
// wanted inside the Lambda execution environment).
if (require.main === module) {
  app.listen(PORT, () => log.info({ port: PORT }, "Server started"));
}

export default app;
