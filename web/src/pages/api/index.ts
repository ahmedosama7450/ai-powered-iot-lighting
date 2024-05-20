import type { NextApiRequest, NextApiResponse } from "next";
import { GoogleGenerativeAI } from "@google/generative-ai";
import { promises as fs } from "fs";
import { join } from "path";

async function extractLightingInfo(userPrompt: string) {
  const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY!);
  const model = genAI.getGenerativeModel({
    model: "gemini-pro",
    generationConfig: { temperature: 0 },
  });
  
  const promptFileContent = await fs.readFile(
    join(process.cwd(), 'public', 'prompt.txt'),
    "utf8"
  );
  const prompt = promptFileContent.replace("<user prompt>", userPrompt);

  const result = await model.generateContent(prompt);
  const response = await result.response;
  const text = response.text();

  return text;
}

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse<any>
) {  
  res.status(200).json(JSON.parse(await extractLightingInfo(req.query.prompt as string)));
}
