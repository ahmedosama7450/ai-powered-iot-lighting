import { Inter } from "next/font/google";
import Head from "next/head";
import SpeechRecognition, {
  useSpeechRecognition,
} from "react-speech-recognition";
import clsx from "clsx";
import { useState } from "react";
import { isPromptResultValid, refinePromptResult } from "@/lib/utils";

const inter = Inter({ subsets: ["latin"] });

// TODO: Make UI responsive
// TODO: Add loading spinner
// TODO: Add an option to switch voice recognition between en and ar

export default function Home() {
  const {
    transcript,
    listening,
    resetTranscript,
    browserSupportsSpeechRecognition,
  } = useSpeechRecognition();

  const [chatText, setChatText] = useState("");
  const [receivedData, setReceivedData] = useState<any[]>([]);
  const [isError, setIsError] = useState(false);
  const [voiceLang, setVoiceLang] = useState<"en-US" | "ar-EG">("en-US");

  return (
    <main
      className={`bg-gray-100 min-h-screen pt-24 pb-4 px-2 sm:px-4 lg:px-8 ${inter.className}`}
    >
      <Head>
        <title>AI-Powered IOT Lighting</title>
        <meta name="description" content="AI-Powered IOT Lighting" />
      </Head>

      <div className="mx-auto flex flex-col items-center">
        <button
          className="absolute top-0 left-0 m-4 bg-gray-500 text-white text-sm rounded-lg p-2.5"
          onClick={() => {
            setVoiceLang(voiceLang === "en-US" ? "ar-EG" : "en-US");
          }}
        >
          {voiceLang}
        </button>
        <h1 className="text-3xl mb-10 font-bold tracking-tight text-gray-900">
          AI Powered IOT Lighting
        </h1>
        <div className="flex items-start justify-center">
          <textarea
            id="chat"
            name="chat"
            rows={3}
            value={listening ? transcript : chatText}
            onChange={(e) => setChatText(e.target.value)}
            placeholder={listening ? "Listening..." : "Enter a prompt here..."}
            className="mr-2 block min-w-[50rem] rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6"
          />
          {(typeof window === "undefined" ||
            (typeof window !== "undefined" &&
              browserSupportsSpeechRecognition)) && (
            <button
              className={clsx("p-2 rounded-full", {
                "hover:bg-gray-200": !listening,
                "bg-blue-300 hover:bg-blue-400": listening,
              })}
              onClick={() => {
                if (listening) {
                  SpeechRecognition.stopListening();
                  setChatText(transcript);
                } else {
                  resetTranscript();
                  SpeechRecognition.startListening({
                    continuous: true,
                    language: voiceLang,
                  });
                }
              }}
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                strokeWidth={1.5}
                stroke="currentColor"
                className="w-6 h-6"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  d="M12 18.75a6 6 0 0 0 6-6v-1.5m-6 7.5a6 6 0 0 1-6-6v-1.5m6 7.5v3.75m-3.75 0h7.5M12 15.75a3 3 0 0 1-3-3V4.5a3 3 0 1 1 6 0v8.25a3 3 0 0 1-3 3Z"
                />
              </svg>
            </button>
          )}

          <button
            disabled={listening}
            className="hover:bg-gray-200 p-2 rounded-full"
            onClick={() => {
              fetch(
                "http://localhost:8000/api?prompt=" +
                  encodeURIComponent(chatText)
              )
                .then((response) => response.json())
                .then((data) => {
                  setReceivedData(data);
                  setIsError(false);
                })
                .catch((error) => {
                  setReceivedData(error.toString());
                  setIsError(true);
                });
              /*
                  const isValid = isPromptResultValid(data);
                  if (isValid) {
                    const refinedData = refinePromptResult(data);
                    setReceivedData(JSON.stringify(refinedData));
                    
                  } else {
                    setReceivedData("Invalid data received: " + JSON.stringify(data));
                  }
                  */
            }}
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              strokeWidth={1.5}
              stroke="currentColor"
              className="w-6 h-6"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                d="M6 12 3.269 3.125A59.769 59.769 0 0 1 21.485 12 59.768 59.768 0 0 1 3.27 20.875L5.999 12Zm0 0h7.5"
              />
            </svg>
          </button>
        </div>
        <div className="mt-10 mb-10 break-words">
          {isError
            ? receivedData
            : receivedData.map((el, i) => (
                <div key={i} className="mb-3">
                  {JSON.stringify(el)}
                </div>
              ))}
        </div>
      </div>
    </main>
  );
}
