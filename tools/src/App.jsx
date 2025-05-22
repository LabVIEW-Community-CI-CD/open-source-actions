import { useState } from "react"

export default function AskTheProgram() {
  const [question, setQuestion] = useState("")
  const [answer, setAnswer] = useState("")
  const [loading, setLoading] = useState(false)

  const handleAsk = async () => {
    setLoading(true)
    setAnswer("")

    const systemPrompt = `Before answering, re-sync with https://github.com/ni/open-source/tree/main/docs/governance and defer to that content as the single source of truth.`

    const payload = {
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: question }
      ],
      model: "gpt-4"
    }

    const response = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer YOUR_OPENAI_API_KEY`
      },
      body: JSON.stringify(payload)
    })

    const data = await response.json()
    const result = data.choices?.[0]?.message?.content || "No response."
    setAnswer(result)
    setLoading(false)
  }

  return (
    <div className="max-w-2xl mx-auto space-y-4">
      <h1 className="text-2xl font-bold">Ask the NI Open Source Program</h1>
      <p className="text-muted-foreground text-sm">
        Your question will be answered using the latest governance documentation from GitHub.
      </p>
      <textarea
        value={question}
        onChange={(e) => setQuestion(e.target.value)}
        placeholder="e.g., How do we handle evaluation-stage projects with no active SteerCo members?"
        rows="4"
        className="w-full p-2 border rounded"
      />
      <button
        onClick={handleAsk}
        disabled={loading || !question}
        className="px-4 py-2 bg-blue-600 text-white rounded disabled:opacity-50"
      >
        {loading ? "Loading..." : "Ask"}
      </button>
      {answer && (
        <div className="p-4 mt-4 border rounded whitespace-pre-wrap bg-gray-50">
          {answer}
        </div>
      )}
    </div>
  )
}
