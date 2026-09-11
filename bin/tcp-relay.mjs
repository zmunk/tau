import net from "node:net";

const listenHost = process.env.LISTEN_HOST ?? "127.0.0.1";
const listenPort = Number(process.env.LISTEN_PORT ?? "47657");

const targetHost = process.env.TARGET_HOST;
const targetPort = Number(process.env.TARGET_PORT);

if (!targetHost) {
  throw new Error("TARGET_HOST is required");
}

if (!Number.isInteger(listenPort) || !Number.isInteger(targetPort)) {
  throw new Error("LISTEN_PORT and TARGET_PORT must be valid integers");
}

const server = net.createServer((client) => {
  const upstream = net.createConnection({
    host: targetHost,
    port: targetPort,
  });

  client.setNoDelay(true);
  upstream.setNoDelay(true);

  client.pipe(upstream);
  upstream.pipe(client);

  const closeBoth = () => {
    client.destroy();
    upstream.destroy();
  };

  client.on("error", (error) => {
    console.error(`[relay] client error: ${error.message}`);
    closeBoth();
  });

  upstream.on("error", (error) => {
    console.error(`[relay] upstream error: ${error.message}`);
    closeBoth();
  });
});

server.on("error", (error) => {
  console.error(`[relay] server error: ${error.message}`);
  process.exit(1);
});

server.listen(listenPort, listenHost, () => {
  console.error(
    `[relay] ${listenHost}:${listenPort}` +
      ` -> ${targetHost}:${targetPort}`,
  );
});

function shutdown() {
  server.close(() => process.exit(0));
}

process.on("SIGINT", shutdown);
process.on("SIGTERM", shutdown);
