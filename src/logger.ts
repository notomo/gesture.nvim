import { tmpdir } from "os";
import { join } from "path";
import * as log4js from "log4js";

const BACKUP_FILE_COUNT = 3;
const LOG_FILE_PATH =
  process.env.NVIM_GESTURE_LOG_FILE || join(tmpdir(), "gesture.log");

const level = process.env.NVIM_GESTURE_LOG_LEVEL || "info";

log4js.configure({
  appenders: {
    outputFile: {
      type: "file",
      filename: LOG_FILE_PATH,
      maxLogSize: 1024 * 1024,
      backups: BACKUP_FILE_COUNT,
      layout: {
        type: "pattern",
        pattern: `%d{ISO8601} %p (pid:${process.pid}) [%c] - %m`,
      },
    },
  },
  categories: {
    default: { appenders: ["outputFile"], level },
  },
});

export type Logger = log4js.Logger;

export const getLogger = (name: string): Logger => {
  return log4js.getLogger(name);
};
