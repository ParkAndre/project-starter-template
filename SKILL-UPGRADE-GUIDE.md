# Skill Upgrade Guide — käsiraamat järgmistele skillidele

Selle dokumendi eesmärk: anda AI-le piisav kontekst, et **kõiki ülejäänud skille** sama põhjalikkusega ümber teha, nagu tegime `/review` skilliga. Sisaldab metoodikat, allikaid, otsuseid ja konkreetseid mustreid mida rakendada.

---

## 1. Lähtekoht

**Projektis:** `/Users/andrepark/Sites/claude-config/.claude/commands/` sisaldab vanas `commands/*.md` formaadis slash-komandasid:
- analyze.md, catchup.md, commit.md, e2e.md, fix-issue.md, merge.md, refactor.md, research.md, security-scan.md, tdd.md, update-project.md, update-readme.md, verify.md

**Globaalselt:** `/Users/andrepark/.claude/skills/` sisaldab uut `skills/<name>/SKILL.md` formaati. Praegu seal on ainult `review/` (juba uuendatud).

**Eesmärk:** kõik projektipõhised commands ümber teha **globaalseteks skillideks** (kus mõistlik) + sama läbimõelduse tase mis `/review`-l.

---

## 2. Mida tegime /review-ga (eeskuju)

Võtsin kolm referents-implementatsiooni:
- **henno** — `github.com/henno/.claude/skills/review/SKILL.md` (12.6 KB, 5 spetsialisti)
- **MrKnights1** — `github.com/MrKnights1/claude-config/.claude/skills/review/SKILL.md` (16.5 KB, mature)
- Originaal — `~/.claude/skills/review/SKILL.md` (186 rida, 2 agenti)

Sünteesisin parimad osad + lisasin puudu (test-quality eraldi agent, intent alignment, domain risk patterns, AI-attribution check). Lõpptulemus: **332 rida, 6 paralleelset spetsialisti, auto-execute pärast plan-mode kinnitust**.

Lõplikud failid (mõlemad byte-identsed):
- `/Users/andrepark/.claude/skills/review/SKILL.md` (globaalne)
- `/Users/andrepark/Sites/claude-config/.claude/commands/review.md` (projekti koopia)

---

## 3. Anthropic/community parimad praktikad (uuritud webist)

Need on **universaalsed reeglid** mida kohaldada igale skill failile:

### Pikkus
- **SKILL.md alla 500 rea** (hard cap), ideaalselt 200–300 (orkestraatori puhul)
- Token-kulu jääb sessiooni kontekstis kogu aeg — iga rida on korduv kulu
- Detailne materjal (rubrikud, näited, checklistid) → eraldi `references/*.md` failid skill-kausta sees
- Vanem `commands/*.md` formaat ei toeta references → üks fail, lubatud ~500 rida

### Frontmatter
- `allowed-tools` on **space-separated string**, mitte array. Näide: `Bash(git:*) Bash(gh:*) Read Glob Grep Agent`
- Lubatud väljad: `name`, `description`, `disable-model-invocation`, `allowed-tools`, `when_to_use`, `argument-hint`, `arguments`, `model`, `effort`, `paths`, `shell`, `hooks`, `context`, `agent`, `user-invocable`, `min_claude_code_version`, `version`
- `description` ~100 sõna, sisaldab konkreetseid trigger-fraase ("Use when user says...")
- `disable-model-invocation: true` kui kasutaja käivitab manuaalselt `/<name>` kaudu (väldib juhuslikku auto-invocation'it)
- Deferred tools (nt `EnterPlanMode`, `ExitPlanMode`, `TaskCreate`) **EI lähe** `allowed-tools` listi — laaditakse jooksva ajaga `ToolSearch` kaudu

### Struktuur
- Body on **imperatiivne**, mitte selgitav. "State what to do rather than narrating how or why."
- Tüüpilised sektsioonid: `Persona`, `Review Standard`/`Standard`, `Process`, `Output Format`, `Rules`
- Process'i sammud nummerdada; iga samm ~5–10 rida

### Alamagentide kasutamine
- Skill kasutab `Agent` tööriista subagentide käivitamiseks
- Mitu agenti paralleelselt → ühes message'is mitu `Agent` tool_use blokki
- `subagent_type: "general-purpose"` on default; alternatiivina luua custom agendid `.claude/agents/`-i (järgmise sammu refactor, mitte praegune)
- Iga agent saab eraldi distinct `description` värväärtuse (et orkestraator ei collapse them as redundant)

### Allikad
- https://code.claude.com/docs/en/skills.md
- https://code.claude.com/docs/en/sub-agents.md
- https://github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md

---

## 4. Sisulised mustrid mida rakendasime (KÕIGE OLULISEM osa)

Need on **üldised review-stiili mustrid** mille võtsin MrKnights1 + henno omadest ja kohandasin. Mõned on kohaldatavad ka muudele skillidele (mitte ainult review'le):

### A. Persona
- Senior developer 30+ aastat (calm, analytical, evidence-driven)
- "Do NOT hunt for problems. Note real issues only when the inspected code supports them. When the code is good, say so."
- Tunda et see on **õigustatud autoriteet**, mitte agressiivne kriitik

### B. Standard (review-tüüpi skilli puhul)
- **File:line nõue iga finding'u kohta** — alati
- **WHY + konkreetne fix** — alati
- **Problem-vs-preference filter:** pidada AINULT kui üks järgnevatest:
  - Konkreetne failure scenario ("with input X, returns Y instead of Z")
  - Dokumenteeritud konventsiooni rikkumine (tsiteeri kust)
  - Mõõdetav puudus (perf number, security CVE class, correctness gap)
- "Could be cleaner", "I'd write it differently", "better practice in general" → **drop**
- **Mitigation discipline (bias toward keeping):** drop AINULT kui saad tsiteerida `file:line` reaalsest mitigatsioonist (type constraint, validation layer mis lükkab tagasi just selle inputi, transaction wrap, guard mis muudab failing path unreachable). EI loe mitigatsiooniks: "framework probably handles it", error-swallowing try/catch, happy-path-only test, mittekattev guard
- **"Every review starts from ZERO"** — keelata viited eelmistele voorudele / "round 2" / "previous fix"

### C. Process — bootstrap pattern
Kõik skillid, mis kasutavad deferred tools:
```
Step 0: ToolSearch query: select:<tool1>,<tool2>,...
Step 0+: invoke <tool> (e.g., EnterPlanMode)
```

### D. Process — diff kogumine (relevant for: review, refactor, security-scan, verify)
Kombineerida kõik mitte-tühjad:
- Feature branch: `git diff <base>...HEAD` + `git diff --cached` + `git diff`
- Base branch: `git diff --cached` + `git diff` + `git diff HEAD^..HEAD`
- Apply `-- <path>` filter kui file scope
- Tühi → exit clean

### E. Process — intent kogumine (relevant for: review, fix-issue, commit, merge)
- `git log <base>..HEAD --format='%H%n%s%n%n%b%n---'` — commit-sõnumid bodydega (intent signal!)
- Parse branch name issue numbri jaoks: regex `^(?:gh-|issue-|fix-|feature/)?([0-9]+)` → `gh issue view <n>`
- Fallback PR check: `gh pr list --head <branch> --json number,title,body 2>/dev/null`
- Kui issue/PR puudub → confidence langeb, aga töö jätkub

### F. Mitu paralleelset spetsialisti (kus loogiliselt sobib)
- 6 agendi paralleelne dispatch ühes message'is
- "Duplication is intentional" — kõik agendid katavad enda domeeni täielikult, kattuvused = confidence signal
- Tag `(flagged by N agents)` finding'u pealkirjas kui N≥2
- **Agendid mitte alati vajalikud** — väikesed/mehaanilised skillid (update-readme, terminal-title-tüüpi) ei vaja agente

### G. Trace boundary (in-scope vs out-of-scope)
- Forward trace: `Grep` callers/consumers/tests, `Read` relevant regions
- Backward trace: config, schema, deps mida muudatus eeldab
- **IN scope:** muudatus ise + traced unchanged kood mille muudatus mõjutab
- **OUT of scope:** pre-existing bugs koodis mida diff ei puudutanud ega trace-ga ei jõudnud

### H. Lazy file fetching
- Ärge lugege faile upfront skill body's
- Agendid + orkestraator lugevad faile **vajadusel** verification'i ajal

### I. Validation pass (orkestraator pärast agendi tulemusi)
1. Re-read iga finding'u referenced rida — kinnita probleem on tegelik
2. Problem-vs-preference filter
3. Mitigation check (bias toward keeping)
4. **Oscillation check** — vaata praegust diffi + recent commits; kui fix tühistaks rea, otsusta teadlikult (mitte vaikimisi auto-apply ega auto-drop)
5. Dedup + confidence tag
6. **Intent alignment** (UUS, puudub henno/MrKnights1-s) — võrdle commit + issue AC + diff → aligned/partial/scope-creep/divergent

### J. Output format (review/analyze tüüpi)
- Scope, Intent, Mode, Confidence (+ põhjus kui langetatud), Findings count
- Findings grupeeritud severity järgi
- Area Coverage tabel (iga ala finding/no issue/n/a; n/a peab olema diff-spetsiifiline põhjus)
- Intent Alignment sektsioon
- Dropped (Already Mitigated) — AINULT kui midagi pilluti, ja iga rida vajab `file:line` tsiteeringut
- Open Questions Or Assumptions
- Verdict

### K. Survival criteria fixide jaoks (relevant for: fix-issue, refactor, auto-execute skillid)
Iga fix kandidaat peab elama üle teise review-vooru:
- Eelista üldist vormi erijuhtumi asemel
- Mitte parameetrid/defaultid mida keegi ei kasuta
- Tsiteeri shared values defining module'ist, mitte inline copy
- Mitte logid/state mis dupleerivad ümbrust
- Värskenda või eemalda aegunud kommentaarid
- Mitte revert hiljutist muudatust (välja arvatud oscillation check otsustas teisiti)

### L. Post-fix self-review (kui skill kirjutab koodi)
Pärast fix'ide rakendamist ÜKS inline pass:
- Identifitseeri fix-delta enda Edit/Write kõnedest
- Rakenda samad survival kriteeriumid muudatustele
- Kommentaarid: kas kirjeldavad kehtivat koodi?
- Cross-file consumers: kas korrektsed?
- Fix kõik mida leiad **kitsalt scoped'ina** — mitte refaktoori "while you're there"
- Out-of-scope findings → surface eraldi sektsioonis kasutajale
- **Üks pass, mitte rekursioon**

### M. AI-attribution check
Globaalselt kohaldatav (kasutaja personaalne reegel kõikidele projektidele):
- Flagida: `Co-Authored-By: Claude...`, `🤖 Generated with Claude Code`, `// Generated by AI`, `# Written by Claude`
- Asukoht: commit messages, PR descriptions, koodikommentaarid

### N. Domain / business-logic risk patterns (smell-based, globaalselt sobiv)
LLM ei tea konkreetseid reegleid, aga oskab tuvastada **mustreid kus äriloogika tüüpiliselt katki läheb**:
- Money/quantity math (precision, rounding, sign)
- Permission/authz check enne mutating actions
- Multi-tenancy isolation (query scoping)
- State machine transitions (illegal blocked?)
- Time/date (timezones, expiry/deadline)
- Idempotency retried operations
- Resource counters (atomic decrement, no negative)
- Implicit invariants (`sum=parts`, `total>=0`, `deadline>now`)
- Ebakindlus → Open Questions, mitte Findings (mitte leiutada reegleid)

---

## 5. Arhitektuurilised otsused (raamistik järgmistele skillidele)

Iga skilli puhul küsida endalt järgmist:

### Q1: Kas skill on **read-only analüüs** või **muudab koodi**?
- Read-only (review, analyze, security-scan, verify): plan-mode pole vajalik; pure analüüs + raport; KEEP IT PURE
- Muudab koodi (fix-issue, refactor, commit, update-readme): plan-mode → user approval → execute → post-fix self-review

### Q2: Kas vajab mitut agenti?
- **JAH:** kui skill katab mitut sõltumatut domeeni (review, analyze sügav) → 3–6 paralleelset spetsialisti
- **EI:** kui skill on mehaaniline ühe-tee tegevus (terminal-title, update-readme, catchup, e2e käivitamine) → otse orkestraatoris
- **VAHEPEAL:** 2 agendi setup (üks "wide", üks "deep") kui domeen ühene, aga tahetakse kattuv confidence (commit, merge)

### Q3: Kas user invokeerib käsitsi (/<name>) või Claude auto-invokeerib?
- Käsitsi: `disable-model-invocation: true`
- Auto: jätta välja; tagada hea `description` triger-fraasidega

### Q4: Kas argument'iga (`/review src/auth` või `/review security`)?
- Kui jah: lisada step "Parse argument" (path scope vs focus keyword vs tühi)

### Q5: Kas vajab git/gh konteksti?
- Diff'i? → step "Gather context" + "Get diff"
- Issue/PR? → step "Issue context"

### Q6: Kuhu skill elab?
- Globaalne (default): `~/.claude/skills/<name>/SKILL.md`
- Projekt-specific (ainult kui REALES projekti kontekstis tähtis): `~/Sites/claude-config/.claude/commands/<name>.md`
- **User soovib praegu: kõik globaalsed.** Projekt-versioone vältida.

---

## 6. Soovituslik järjekord järgmistele skillidele

Eelistus suurim väärtus / madalaim risk esimene:

1. **commit.md** — kõrge sagedusega kasutus; saab kasu intent-aligned commit message generation'ist + AI-attribution check'ist
2. **fix-issue.md** — auto-execute mudel sobib (sarnaselt review'le); test-driven discipline check; intent alignment
3. **refactor.md** — multi-agent split (correctness preservation + maintainability gains); survival criteria fixidele; oscillation check tähtis (refactor võib pingponging'isse jääda)
4. **analyze.md** — multi-agent split sarnaselt review'le, aga focus on understanding/explanation, mitte findings; pure read-only
5. **security-scan.md** — review/security agendi rubriku spetsialiseering; saab OWASP punktid jagada
6. **verify.md** — test execution + result interpretation; intent alignment (oodatav vs tegelik)
7. **tdd.md** — test quality agendi reeglistik; Comment-Out Test mentaalne mudel; AC mapping
8. **merge.md** — branch safety + commit hygiene + conflict resolution discipline; oscillation check rebase'ide jaoks
9. **e2e.md** — test execution skill; lihtsam, vajab vähem refaktorit
10. **update-project.md** — mehaaniline (stash/pull/migrate); lihtsalt formaadi puhastus
11. **update-readme.md** — mehaaniline; lihtsalt formaadi puhastus
12. **research.md** — web/Playwright; vajab ümbervaatamist kas vajab Plan agendi sarnast
13. **catchup.md** — mahuline ülevaade; lihtsalt formaadi puhastus
14. **fix-issue.md** — duplikaat #2-ga ülal, kontrollida

---

## 7. Metoodika (samm-sammult)

Iga skilli puhul:

1. **Loe olemasolev** käsk/skill → tuvasta praegune ulatus ja puudused
2. **Otsi 2–3 referents-implementatsiooni** GitHub'ist (henno, MrKnights1, anthropics/skills, jne)
3. **Võrdle** mustreid: persona, process, validation, output format
4. **Tuvasta lüngad** mida ükski versioon ei kata aga peaks
5. **Tee otsused** Q1–Q6 ülal
6. **Disaini** uus struktuur (kasuta plan mode'i kui mittetriviaalne)
7. **Kirjuta** alla 500 rea, imperatiivne keel, frontmatter õige syntax
8. **Verifitseeri:** wc -l, frontmatter parse, internal references, sektsioonide täielikkus
9. **Test:** käivita reaalsel ülesandel
10. **Iteratsioon:** kui finding-kvaliteet madal, lisa täpsemaid kriteeriume

---

## 8. /review konkreetne transformatsioon (näide)

**Vana (sinu originaal, 186 rida):**
- 2 alamagenti (Correctness+Security / Reliability+Design)
- Pure review, plan-mode
- Hea persona, sirged sammud
- Puudu: issue context, problem-vs-preference, mitigation discipline, oscillation, intent alignment, test quality agent

**Uus (332 rida):**
- **6 paralleelset spetsialisti** (correctness+domain, security, reliability, performance, maintainability, test quality)
- **Bootstrap** sammuga `ToolSearch` deferred tools'i jaoks
- **Argument parsing** (path vs focus keyword)
- **Context kogumine** paralleelselt (base branch detection fail-soft, commit messages bodydega, issue/PR context)
- **Kombineeritud diff** (base...HEAD + staged + unstaged)
- **Lazy file fetching** (mitte upfront)
- **Trace boundary** eksplitsiitne (forward + backward, in/out scope)
- **Mitigation handling** rangelt distsiplineeritud
- **Validation pass:** verify line → problem-vs-preference → mitigation citation → oscillation check → dedup → intent alignment
- **Severity näited** kalibreeringuks
- **Survival criteria** fix-plan'i jaoks
- **Auto-execute** pärast approval (TaskCreate per fix → smallest correct fix → verify)
- **Post-fix self-review** üks inline pass
- **Domain risk patterns** (smell-based, project-agnostic)
- **AI-attribution check** globaalselt
- **Output format** rangelt struktureeritud (Intent Alignment, Dropped section file:line requirement, Verdict)

**Frontmatter:**
```yaml
---
name: review
description: Thoughtful code review with parallel specialist agents. Use when user says "review", "check my code", or similar.
disable-model-invocation: true
allowed-tools: Bash(git:*) Bash(gh:*) Bash(test:*) Read Glob Grep Agent
---
```

---

## 9. Praktilised vihjed AI'le kes seda kasutab

- **ÄRA kopeeri /review struktuuri 1:1** teistele skillidele — iga skill on erinev ülesanne
- **Kasuta principie**, mitte vormingut: problem-vs-preference, mitigation discipline, intent alignment on universaalsed; 6 agendi struktuur EI ole
- **Iga skilli puhul küsi:** mida see skill TEEB? (analyze? mutate? execute?) → see määrab arhitektuuri
- **Vajaduse korral kasuta plan-mode'i** kui muudatus on mitte-triviaalne
- **Tee uurimist webist** kui pole kindel parima praktika osas
- **Failid alla 500 rea**, ideaalselt 200–350
- **Frontmatter validne**, space-separated allowed-tools
- **Imperatiivne keel** body's, mitte selgitav
- **Sünkroniseeri** globaalne + projekti koopia (kui mõlemad eksisteerivad — kontrolli `diff` käsuga)
- **Plan-fail** asub `/Users/andrepark/.claude/plans/<random-name>.md` plan mode'i sessiooni jaoks; orkestraator kirjutab sinna pärast Findings'eid

---

## 10. Failid mis jäid alles dokumenteerimiseks

- `/Users/andrepark/.claude/plans/soft-wobbling-quill.md` — /review täpne disainiplan (vt seal kõik tehtud otsused)
- `/Users/andrepark/.claude/skills/review/SKILL.md` — globaalne /review (332 rida)
- `/Users/andrepark/Sites/claude-config/.claude/commands/review.md` — byte-identne koopia projekti's
- See dokument — metoodika edasiseks tööks

---

**Tähtis lõppmärkus:** user soovib et kõik skillid oleksid **globaalsed**, mitte projekti-spetsiifilised. Vältida `@.claude/*.md` import'e projekti standarditele — kui mingit reeglit on vaja, sõnasta see globaalselt (nagu tegime AI-attribution check'iga). Erandid ainult kui projekt päriselt sisaldab domeenidokumentatsiooni (nt `DOMAIN.md`), mille vastu skill peaks kontrollima.
