MVP screens (minimal but complete) 

Welcome / Onboarding (Very important its good, so people find the app interesting) 
“What do you want help with?” (chips) 
“Add your values” (optional) 
"Choose a topic or Pre defend Agent" 

Coach Library 
Prebuilt coaches (download = save locally) 
Coach cards: name, one-liner, style 

Coach Details 
“Start chat” 
“Preview what this coach is like” 

Personal Context 
Goals, values, constraints (3–5 fields) 
Toggle: “Use this context for all coaches” 

Chat 
Message list + quick prompts (“Plan my day”, “I’m stuck”, “Give me the hard truth”) 

Create Coach (PRO)
Name, tone, purpose, rules Share / Import 

Coach (PRO-lite) 
Export coach as code / link; import from code 

Paywall (RevenueCat) 

Settings 
Manage subscription / restore purchases / Light/Dark theme / Notifications / ect.


1) Design principles
Vibe: Better Creating / calm / premium / minimal
 Layout: big type, lots of whitespace, soft cards, subtle motion
 Animations: short, purposeful (150–350ms), mostly fade/slide/scale, hero transitions
 Themes: full light + dark with the same semantic tokens
Motion rules (so it never feels “gimmicky”)
Screen transitions: fade + slight slide (8–16px)


Cards: micro-scale on tap (0.98) + haptic


Chat: message bubbles animate in (fade + slide up 6px)


Paywall: springy card entrance + subtle shimmer on primary CTA



2) Screen-by-screen wireframe (MVP)
A) Welcome / Onboarding (3–4 screens)
Screen A1 — Welcome
Big title: PocketCoach


Subtitle: “Minimalist AI coaching for focus, clarity, and better decisions.”


Primary button: Get started


Secondary: “Restore” (tiny, in corner) (optional)


Background: soft gradient + subtle noise texture


Animation ideas
Logo/title fades in + slight scale (0.98 → 1.0)


CTA button slides up



Screen A2 — “What do you want help with?”
Title: “What do you want help with right now?”


Chip grid (multi-select):


Productivity, Focus, Life clarity, Habits, Business, Creativity, Confidence, Decisions, Systems


Primary: Continue


Secondary: Skip


Animation
Chips appear with staggered fade (50ms delay each)



Screen A3 — “Start your way”
3 cards:
Pick a coach (recommended)


Pick a topic (fast start)


Create your own coach (Pro) (shows lock icon)


Animation
Cards slide in with stagger


Tapping a card uses hero-ish expansion into next screen



Screen A4 — Values (optional)
Title: “What matters most to you?”


Small helper: “Add this now or later — it improves coaching.”


Fields (multiline, minimal):


Goals


Values


Challenges


Toggle: “Use this context for all coaches” (default ON)


Primary: Continue


Secondary: Skip


Animation
Field focus highlights smoothly



B) Main: Coach Library (Home)
Top:
Greeting: “Good evening” / “Welcome back”


Search (optional MVP: filter chips)


Section: Curated coaches


Coach cards (vertical list):


Name


one-liner


style tags


“Saved” indicator if downloaded


Bottom nav (optional, but clean):
Home


Chat (last used)


Library


Settings
 (Or keep it simple with just Home + Settings; your call—MVP can be 3 tabs.)


Animation
Coach cards: subtle parallax on scroll


Tap: hero transition into details



C) Coach Details
Large coach name


One-liner


“What this coach helps with” bullets


Buttons:


Start chat


Preview style (opens modal with example response)


“Download” / “Remove” toggle


Preview Modal
“Ask: ‘Help me plan tomorrow’”


Shows sample structured answer


Animation
Hero title from card → details


Modal slides up with blur background



D) Personal Context (Settings sub-screen + “before chat” shortcut)
Goals, Values, Challenges, Constraints


Toggle “Use for all coaches”


Save


Animation
Save button morphs to checkmark



E) Chat
Top bar:
Coach avatar + name

small “Context on/off” indicator

overflow menu: “Edit context”, “Share coach”, “Switch coach”

Body:
Messages
Quick prompts row (scrollable):
“Plan my day”
“I’m stuck”
“Give me the hard truth”
“Help me decide”
“Reflect with me”
Composer: input + send
optional microphone later
Paywall trigger
On 6th message/day (free), show paywall sheet
Animation
Each assistant message animates in (fade + slide)
Quick prompts bounce subtly on first view



F) Create Coach (Pro)
Fields:
Name
Style preset (calm/direct/motivational/tough-love)
Purpose
Rules (multiline)
Test coach (sends a sample prompt)
Save
If free user: show paywall
Animation
Style preset chips animate selection
Save → confetti micro burst (tiny)


G) Share / Import (Pro-lite)
Export
Generates a share code (base64 JSON) + share button

Copy to clipboard
Import
Paste code
Preview coach card
If free user: paywall
Animation
Export code appears with typewriter effect (optional)



H) Paywall (RevenueCat)
Title: “Unlock PocketCoach Pro”
Benefit bullets:
Unlimited coaching sessions
Create your own coaches
Share & import coaches
Multiple context profiles
Plans: Monthly / Yearly (Yearly highlighted)
Primary CTA: Start free trial (if you enable trial) or Continue
Restore purchases
Small disclaimer
Animation
Paywall card slides up with spring
CTA has subtle shimmer



I) Settings
Manage subscription
Restore purchases
Theme: System / Light / Dark
Notifications (future toggle)
Edit personal context
About



3) Navigation + routes (Flutter)

Suggested routes:
/onboarding/welcome
/onboarding/topics
/onboarding/start
/onboarding/context
/home (tabs)
/coach/:id
/chat/:coachId
/context
/create-coach
/share-import
/paywall
/settings

Tabs (recommended):
Home (Library)
Chat (last coach)
Settings
Keep it minimal.