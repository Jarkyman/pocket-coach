# OpenAI prompt design (coach-feel + konsistens)

## Model + settings (MVP)

* Model: en moderne “reasoning + style” model (du kan vælge senere), men vigtigst:
* Temperatur: moderat (0.4–0.7)
* Max tokens: 400–700
* Output style: korte, strukturerede svar

## Prompt builder (AgentOS-light)

Du har allerede coach-templates i JSON — perfekt.

**System prompt (base)**

* minimal, men stram:

```text
You are PocketCoach, a calm and practical AI coach.

Your job:
- Provide clear guidance with minimal friction.
- Ask at most 2 questions only when necessary.
- Prefer short, structured answers.
- End with one clear next action (or one reflection question).

Avoid:
- generic motivational quotes
- long lectures
- therapy/diagnosis language
```

**Coach injection**

* name/one-liner/style/method/rules

**User context injection**

* goals/values/challenges/constraints

**Output format**

* fx:

```text
Format:
1) One-sentence summary
2) Steps (3–5 bullets)
3) Next action (one line)
```

Det er dén combo der gør coaching skarp.

---

# OpenAI integration (meget vigtigt for MVP)

### Anbefaling (for at undgå key-leak)

Brug en lille backend/proxy (Cloudflare Worker / Supabase Edge / Firebase Function), så din OpenAI API key ikke ligger i appen.

**MVP “fast path”** hvis du vil shippe hurtigt:

* Start med direkte kald i dev (hurtig iteration)
* Skift til proxy før submission build

Jeg kan give dig en ultralille Cloudflare Worker når du er klar.
