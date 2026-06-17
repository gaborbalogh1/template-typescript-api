import express, { Request, Response } from "express";
import helmet from "helmet";
import cors from "cors";
import pino from "pino";

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

app.listen(PORT, () => log.info({ port: PORT }, "Server started"));
export default app;
