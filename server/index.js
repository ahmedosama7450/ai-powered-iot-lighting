import dotenv from "dotenv";
import { GoogleGenerativeAI } from "@google/generative-ai";
import { Server } from "socket.io";
import express from "express";
import { promises as fs } from "fs";
import { createServer } from "http";
import { parse } from "url";
import SerialPort from "serialport";
import { z } from "zod";

var indx = 0;
var Data = [];
var waiting = false;
var sync = false;

function isPromptResultValid(promptResult) {
  const lightingInfoSchema = z.array(
    z.object({
      duration: z
        .object({
          hours: z.number().nonnegative(),
          minutes: z.number().nonnegative(),
          seconds: z.number().nonnegative(),
        })
        .nullable(),
      shouldWaitForMotion: z.boolean().default(false),
      color: z.string().regex(/^#[0-9a-fA-F]{6}$/),
      isOn: z.boolean().default(true),
      color_S: z.string(),
      detected: z.boolean().default(false),
    })
  );

  const parseResult = lightingInfoSchema.safeParse(promptResult);
  return parseResult.success;
}

function refinePromptResult(promptResult, end) {
  const indexOfNull = promptResult.findIndex((item) => item.duration === null);

  if (indexOfNull < 0) {
    return promptResult;
  } else {
    return end
      ? promptResult.slice(0, indexOfNull + 1)
      : promptResult.slice(0, indexOfNull);
  }
}

const Server_get = createServer(async (req, res) => {
  const { pathname, query } = parse(req.url, true);
  if (pathname === "/api" && req.method == "GET") {
    const prompt = query.prompt;
    try {
      var txt = await Get_From_AI(prompt);
      const jsonObject = JSON.parse(txt);
      const isValid = isPromptResultValid(jsonObject);
      if (isValid) {
        var refinedData = refinePromptResult(jsonObject, true);
        Data = refinedData;
        indx = 0;
        const S = JSON.stringify(Data[indx]);
        port.write(S + ";", (err) => {
          if (err) {
            console.error("Error sending data:", err.message);
          } else {
            console.log("Data sent to Arduino:", S);
          }
        });
        waiting = false;
        res.writeHead(200, { "Content-Type": "text/plain" });
        res.end(`Received prompt: ${JSON.stringify(Data)}`);
      } else {
        const error = new Error("Something Wrong happened, Please Try again");
        res.writeHead(500, { "Content-Type": "text/plain" });
        res.end(error.message);
      }
    } catch (err) {
      const error = new Error("server error");
      res.writeHead(500, { "Content-Type": "text/plain" });
      res.end(error.message);
    }
  } else {
    const error = new Error("server error");
    res.writeHead(500, { "Content-Type": "text/plain" });
    res.end(error.message);
  }
});

const port_get = 8000;
Server_get.listen(port_get, () => {
  console.log("server is rumming");
});

dotenv.config();
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const app = express();
const server = createServer(app);
const io = new Server(server);
const config = {
  port: "COM6",
  baudRate: 9600,
};
var port = new SerialPort(config.port, { baudRate: config.baudRate });

const data = await fs.readFile("./test.txt", { encoding: "utf8" });
const model = genAI.getGenerativeModel({
  model: "gemini-pro",
  generationConfig: { temperature: 0 },
});

async function Get_From_AI(pro) {
  const result = await model.generateContent(
    data.replace("<user prompt>", pro)
  );
  const response = await result.response;
  return response.text();
}

port.on("open", () => {
  console.log("Serial port opened.");
});

port.on("data", (data) => {
  if (data == "0") {
    console.log("hellllo");
    if (indx >= Data.length - 1 || sync) {
      console.log("done");
      waiting = true;
    } else {
      indx++;
      const S = JSON.stringify(Data[indx]);
      port.write(S + ";", (err) => {
        if (err) {
          console.error("Error sending data:", err.message);
        } else {
          io.emit("Update", { indx: indx, State: 0 });
        }
      });
    }
  } else {
    Data[indx]["detected"] = true;
    io.emit("Update", { indx: indx, State: 1 });
  }
});

port.on("error", (err) => {
  console.error("Error:", err.message);
});

io.on("connection", function (socket) {
  console.log("user is connectes");
  socket.on("data", async (data) => {
    try {
      var txt = await Get_From_AI(data["Orders"]);
      const jsonObject = JSON.parse(txt);
      const isValid = isPromptResultValid(jsonObject);
      if (isValid) {
        var refinedData = [];
        if (data["indx"] < 0 || data["indx"] == Data.length - 1) {
          refinedData = refinePromptResult(jsonObject, true);
        } else {
          refinedData = refinePromptResult(jsonObject, false);
        }
        if (data["indx"] < 0) {
          Data = refinedData;
          indx = 0;
          const S = JSON.stringify(Data[indx]);
          port.write(S + ";", (err) => {
            if (err) {
              console.error("Error sending data:", err.message);
            } else {
              console.log("Data sent to Arduino:", S);
            }
          });
        } else {
          sync = true;
          if (Data[data["indx"]]["duration"] == null) {
            Data.splice(data["indx"], 1);
            Array.prototype.splice.apply(
              Data,
              [data["indx"], 0].concat(refinedData)
            );
            if (indx == data["indx"]) {
              waiting = true;
              indx--;
            }
          } else {
            Array.prototype.splice.apply(
              Data,
              [data["indx"] + 1, 0].concat(refinedData)
            );
          }
          if (waiting) {
            indx++;
            const S = JSON.stringify(Data[indx]);
            port.write(S + ";", (err) => {
              if (err) {
                console.error("Error sending data:", err.message);
              } else {
                console.log("Data sent to Arduino:", S);
              }
            });
          }
          sync = false;
        }
        waiting = false;
        io.emit("data", { indx: indx, Orders: Data });
      } else {
        io.emit("err", { Err: "Something Wrong happened, Please Try again" });
      }
    } catch (err) {
      io.emit("err", { Err: "Something Wrong happened, Please Try again" });
    }
  });

  socket.on("Update", async (data) => {
    console.log("update");
    if (data["state"] == 0) {
      if (indx > data["indx"]) {
        for (var i = data["indx"]; i <= indx; i++) {
          Data[i]["detected"] = false;
        }
      }
      indx = data["indx"];
      const S = JSON.stringify(Data[indx]);
      port.write(S + ";", (err) => {
        if (err) {
          console.error("Error sending data:", err.message);
        } else {
          io.emit("Update", { indx: indx, State: 0 });
        }
      });
    }
  });
  io.emit("data", { indx: indx, Orders: Data });
});

const port1 = process.env.PORT || 8080;
console.log("8080");
server.listen(port1);
