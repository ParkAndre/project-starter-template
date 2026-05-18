# Allikad ja metoodika

Käesolev dokument kirjeldab Claude Code konfiguratsiooni projekteerimise põhimõtteid, iga disainiotsuse taga olevaid allikaid ja tööstuspraktikaid. Konfiguratsioon koosneb peafailist (CLAUDE.md), kolmest automaatselt laetavast juhisfailist (security.md, testing.md, standards.md), kolmest referentsfailist (api-design.md, database.md, issue-creation.md) ja 14 custom skillist (`.claude/skills/<name>/SKILL.md` formaadis — varem `commands/*.md`, migreeritud `SKILL-UPGRADE-GUIDE.md` metoodika järgi).

---

## 1. Sissejuhatus

### 1.1 Eesmärk

Konfiguratsioon on tehnoloogia-agnostiline starterimall, mis pakub Claude Code'ile ühtset arendusvoogu, turva-, testimis- ja kvaliteedistandardeid sõltumata projekti tehnoloogilisest stäkist. Malli saab paigaldada mis tahes projekti ja kohandada konkreetse stäki jaoks.

### 1.2 Metoodika

Konfiguratsiooni projekteerimisel tugineti kolmele uurimissuunale:

1. **Anthropic'u ametlik dokumentatsioon ja kogukonna kogemused** — CLAUDE.md failide parimate praktikate uuring, sh juhiste mahu, sõnastuse ja arhitektuuri mõju LLM-i käitumisele
2. **Tööstusstandartide kaardistamine** — OWASP ASVS 5.0, NIST SP 800-63B, REST API disainijuhised ja WCAG 2.2
3. **AI-spetsiifiliste metoodikate uuring** — TDD AI-assistentidega, git workflow'd AI-arenduses, juhiste jõustamismehhanismid

Kokku kasutati 30 allikat, sealhulgas Anthropic'u ametlikku dokumentatsiooni, turvastandartide spetsifikatsioone, tööstuse uuringuid ja praktikute kogemusraporteid.

---

## 2. Konfiguratsioonifailide arhitektuur

### 2.1 Juhiste maht ja LLM-ide töötlemisvõime

Konfiguratsioonifailide mahu planeerimisel lähtuti LLM-ide piiratud juhiste töötlemisvõimest. Jaroslawicz et al. (2025) demonstreerisid empiiriliselt, et suured keelemudelid suudavad usaldusväärselt järgida ligikaudu 150 diskreetset juhist, kusjuures juhiste järgimise tõenäosus langeb ühtlaselt juhiste arvu kasvades — juhiste kahekordistamine vähendab iga üksiku juhise järgimist ligikaudu poole võrra (viidatud: DEV Community, 2025a). Claude Code'i süsteemne prompt kasutab juba ~50 juhist, jättes kasutaja konfiguratsioonile ~100 kohta (HumanLayer, 2025; ShareUHack, 2026).

Anthropic'u ametlik dokumentatsioon soovitab hoida CLAUDE.md alla 200 rea (Anthropic, 2025a). Praktikas hoiavad kogenud kasutajad mahtu veelgi väiksemana: Claude Code'i looja Boris Cherny ~100 rida (~2 500 token'it) (MindwiredAI, 2026), HumanLayer'i meeskond alla 60 rea (HumanLayer, 2025), ning DEV Community (2025c) eksperiment näitas, et 30-realine fokuseeritud fail ületab järjepidevalt 200-realist põhjalikku faili.

Käesoleva konfiguratsiooni automaatselt laetav sisu on kokku ~450 rida (CLAUDE.md + kolm imporditud faili), mis jääb alla 150 diskreetse juhise piiri.

### 2.2 Astmeline laadimisarhitektuur

Konfiguratsioon järgib astmelise laadimise mudelit, mis põhineb DEV Community küpsusmudeli (DEV Community, 2025b) tasemel L3 — mitu faili, jagatud murede kaupa. Küpsusmudel eristab kuut taset:

- **L0**: Juhised puuduvad
- **L1**: Üks CLAUDE.md fail
- **L2**: Konkreetsed piirangud RFC 2119 keelega (MUST, MUST NOT)
- **L3**: Mitu faili, jagatud murede kaupa
- **L4**: Rajapõhine laadimine (reeglid laetakse ainult relevantsete failide puhul)
- **L5**: Hooldatav, vananemise jälgimisega
- **L6**: Adaptiivne dünaamilise laadimisega

Medium (2025b) rõhutab, et kõige levinum viga on "kõige toppida ühte CLAUDE.md faili" — iga sessioon maksab auto-loaded sisu eest token'ites, sõltumata sellest, kas sisu on konkreetses kontekstis relevatne.

### 2.3 Failide jaotamine auto-loaded ja on-demand kategooriatesse

Failide jaotamisel rakendati Anthropic'u litmus-testi: "Iga rea kohta küsi: kas selle eemaldamine põhjustaks Claude'il vigu? Kui ei, eemalda." (Anthropic, 2025a). Selle kriteeriumi alusel:

- **Auto-loaded** (laetakse iga sessioon): turvajuhised (security.md), testimisnõuded (testing.md), koodi puhastusreeglid (standards.md) — need mõjutavad iga koodi muutmise sessiooni ja sisaldavad reegleid, mida Claude ei saa koodist ise tuletada
- **On-demand** (loetakse vajaduse korral): API disain (api-design.md), andmebaas (database.md), issue loomine (issue-creation.md) — need on relevantsed ainult spetsiifilistes kontekstides (API endpoint'ide kirjutamine, migratsioonide loomine, issue'de koostamine)

Projektistruktuuri juhised (kataloogistruktuurid, nimekonventsioonid) puuduvad eraldi failina, kuna Claude tuletab need projekti failisüsteemist ise — Anthropic'u (2025a) litmus-test kinnitab: kui info on koodist tuletatav, ei ole juhistes kordamine vajalik.

---

## 3. Juhiste sõnastamise põhimõtted

### 3.1 Positiivne sõnastus

Kõik juhised on sõnastatud positiivselt — tegutsemisjuhistena, mitte keeldudena. LLM-ide raskused negatsioonidega on dokumenteeritud empiiriliselt: DEV Community (2025c) näitas, et negatiivsed juhised nagu "Do NOT use default exports" aktiveerivad paradoksaalselt kontseptsiooni enda — mudel "mõtleb" default exports'idele rohkem, kui ta seda muidu teeks. Positiivne sõnastus "Use named exports exclusively" annab selge tegutsemisjuhise ilma soovimatut kontseptsiooni aktiveerimata.

Praktiline eksperiment samas allikas näitas, et kümne negatiivse reegli pööramine positiivseks vähendas rikkumisi ligikaudu 50%. Näiteid rakendatud sõnastusest:

| Negatiivne sõnastus | Positiivne sõnastus |
|---|---|
| NEVER store secrets in code | Store all secrets in environment variables |
| NEVER modify database directly in production | Apply all database changes through migration files |
| NEVER trust client-side authorization | Verify authorization server-side on every request |
| NEVER log passwords, tokens, credit cards | Exclude from logs: passwords, tokens, credit cards, PII |
| NEVER use `eval()` or dynamic code execution | Use parameterized APIs for OS commands |

### 3.2 Kriitiliste reeglite ankurdamine

LLM-id pööravad ebaproportsionaalselt rohkem tähelepanu konteksti algusele ja lõpule — seda nimetatakse primacy-recency bias'iks (DEV Community, 2025c). Soovitus on paigutada 3–5 kõige kriitilisemat reeglit faili algusesse JA lõppu, jättes vähem kriitilised reeglid keskele.

CLAUDE.md peafailis on viis kriitilist reeglit esitatud nii faili esimeses sektsioonis ("Critical Rules") kui viimases ("Critical Rules (Repeated)"):
1. Parameetrilised päringud kõigi andmebaasi operatsioonide jaoks
2. Saladused keskkonnamuutujates
3. Feature branch'id squash merge'iga main'i
4. AI-atributsiooni väljajätmine commit'idest
5. Verifitseerimine enne väitmist

### 3.3 Konkreetsus vs abstraktsus

JetBrains (2025) analüüsis AI-agentide juhiste efektiivsust ja leidis, et agendid järgivad konkreetseid, mõõdetavaid reegleid oluliselt paremini kui abstraktseid printsiipe. Trail of Bits (2025) rakendab sama põhimõtet: nende konfiguratsioonis on ranged numbrilised piirangud nagu "funktsioonid ≤100 rida, tsüklomaatiline keerukus ≤8", mitte üldised üleskutsed nagu "kirjuta loetavat koodi".

Anthropic'u enda promptimise juhised (Anthropic, 2025b) täpsustavad: "Eelista üldisi juhiseid ettekirjutavate sammude asemel — juhis nagu 'mõtle põhjalikult' annab sageli parema tulemuse kui käsitsi kirjutatud samm-sammuline plaan." See kehtib üldiste põhimõtete kohta, kuid mehaanilised reeglid (parameetrilised päringud, cookie'de lipud) peavad olema konkreetsed.

Selle põhimõtte kohaselt on konfiguratsioonist välja jäetud iseenesestmõistetavad juhised nagu "Use clear, descriptive variable and function names" või "Keep functions small and focused" — HumanLayer (2025) rõhutab: "Ära kasuta CLAUDE.md-d linterina — koodi stiilireeglid on token'ite mõttes kallid ja nõuandva iseloomuga ebausaldatavad." Sisalduvad reeglid on mehaanilised ja mõõdetavad (nt "Remove debug `console.log` / `print` statements", "Exclude from logs: passwords, tokens, credit cards, PII").

---

## 4. Jõustamismehhanismid

### 4.1 CLAUDE.md juhiste järgimise tase

CLAUDE.md juhiseid järgitakse ligikaudu 60–80% ajast (Medium, 2025a), mis langeb juhiste mahu kasvades veelgi. See on aktsepteeritav eelistuste (nt koodistiil) jaoks, kuid ebapiisav kriitiliste reeglite (nt "ära push'i otse main'i") jaoks.

### 4.2 Hook'id kui jõustamismehhanism

Claude Code'i hook'id on shell-skriptid, mis käivitatakse töövoo konkreetsetel hetkedel (nt enne tööriista kasutamist, pärast faili kirjutamist). Hook'id töötavad OS-tasemel, mitte LLM-i otsustusprotsessis, tagades 100% jõustamise (DEV Community, 2025d).

DEV Community (2025d) raporteeris konkreetseid tulemusi hook'ide kasutuselevõtust:

| Probleem | Enne hook'e | Pärast hook'e |
|----------|-------------|---------------|
| Sessiooniprotokolli rikkumised | 3 | 0 |
| Koodi kirjutamine ilma loata | 4 | 0 |
| Konteksti kaotamine tihendamisel | kümneid | 0 |

Üks praktik võttis selle kokku: "CLAUDE.md on soovitusnimekiri, mitte leping. Reeglid prompt'ides on palved. Hook'id koodis on seadused." (Medium, 2025a)

Käesolev konfiguratsioon on mallrepo, mistõttu konkreetsed hook'id on esitatud näidetena (`settings.json.example`), mitte jõustatud kujul. Projekti-spetsiifilisel kasutusel on soovituslik liigutada absoluutsed reeglid (AI-atributsiooni keeld, main'i kaitse) hook'idesse.

---

## 5. Arendusvoog

### 5.1 Issue-driven development

Kogu arendusvoog on üles ehitatud GitHub issue'de ümber: kasutajalt küsitakse, kas luua GitHub issue; jaatava vastuse korral algab töö issue'st, viiakse ellu feature branch'il ja liidetakse main'i squash merge'iga. Eitava vastuse korral implementeeritakse muudatused otse praegusel branch'il. See mudel ühtib GitHub'i enda "IssueOps" filosoofiaga, kus automatiseeritud töövood käivitatakse otse issue'dest (GitHub, 2025a). GitHub'i hiljutised täiendused (aprill 2025) — sub-issue'd, issue tüübid ja täiustatud otsing — tugevdavad issue-keskset lähenemist veelgi (GitHub, 2025b).

Issue'd on struktureeritud kasutajaväärtuse põhiselt: feature issue'de pealkirjad järgivad formaati "As a [role] I [action]", kus roll peab olema lõppkasutaja roll (mitte arendaja). Iga issue peab tootma deployable increment'i, kus iga UI element töötab end-to-end — see "no dead UI" reegel on projekt-spetsiifiline kvaliteedistandard, mida Claude ei saaks koodist ise tuletada.

### 5.2 Kakskeelne töövoog (eesti -> inglise)

Konfiguratsioon rakendab kakskeelset töövogu: issue'd koostatakse esmalt eesti keeles, kasutaja vaatab üle ja kinnitab, seejärel tõlgitakse inglise keelde enne GitHub'i laadimist. Ühtegi identset mustrit ei leitud teistest avaldatud töövoojuhistest.

Siiski on aluseks olevad põhimõtted hästi dokumenteeritud:
- Nõuete kogumine emakeeles vähendab kognitiivset koormust kriitilises faasis (üldine lokaliseerimise parim praktika)
- Inglise keelde tõlkimine tagab ühilduvuse AI-tööriistade, väliste kaastöötajate ja laiema ökosüsteemiga
- Ülevaatuspunkt (kasutaja kinnitab eestikeelset mustandit enne tõlkimist) püüab arusaamatused varakult kinni

Alternatiivsetest lähenemistest leiti: kakskeelsed issue body'd (originaal + tõlge samas issue's), GitHub'i spec-kit lokaliseerimise preset'id, ja otsene ingliskeelne kirjutamine AI-tõlke toega (GitHub, 2025c). Käesolev lähenemine on põhjendatud meeskondadele, kus eesti keel on peamine töökeel.

---

## 6. Versioonihaldus ja commit-konventsioonid

### 6.1 Kaheastmeline commit-workflow

Konfiguratsioon eristab kahte commit-töövoogu: lihtsad kirjeldavad sõnumid branch'il töötades ja formaalsed Conventional Commits squash merge'imisel main'i. See lähenemine ühtib Addy Osmani (2026) soovitusega käsitleda commit'e AI-arenduses kui "save point'e mängus" — branch'il commit'itakse sageli ja väikestes tükkides, main'i jõuab üks puhas squash commit.

### 6.2 Squash merge muster

Squash merge workflow (branch -> töö -> squash merge main'i -> branch'i kustutamine) on laialdaselt tunnustatud muster. Osmani (2026) soovitab üligranulaarseid commit'e taastepunktidena ja ühte puhast commit'i main'i.

Ranger (2025) tõstatab olulise tähelepaneku: AI-genereeritud kood peaks läbima rangemad kontrollid kui inimkirjutatud kood. See tähendab, et otse main'i push'imine pärast squash merge'i võib vajada tulevikus PR-ülevaatuse lisamist.

### 6.3 AI-atributsiooni poliitika

Konfiguratsioon jätab "Co-Authored-By: Claude" commit'idest välja. See on teadlik valik, mis erineb mõnest kogukonna praktikast, kuid on kehtiv meeskondadele, kes eelistavad puhast commit-ajalugu ilma AI-märgenditeta.

---

## 7. Turvanõuded

### 7.1 OWASP ASVS raamistik

Turvajuhised põhinevad OWASP Application Security Verification Standard (ASVS) versioonil 5.0.0, mis avaldati Global AppSec EU konverentsil Barcelonas mais 2025 (OWASP, 2025). ASVS on de facto standard veebirakenduste turvalisuse kontrollimiseks.

ASVS 5.0 on läbinud olulise ümbertöötluse võrreldes v4-ga (SoftwareMill, 2025):
- 286-st v4 nõudest jäid muutmata ainult 11
- 109 nõuet (38%) eemaldati, deduplitseeriti või liideti
- L1 (esimese taseme) nõuded vähenesid 128-lt (46%) 70-le (20%), et soodustada kasutuselevõttu
- Arhitektuuripeatükk (V1) eemaldati täielikult — verifitseeritavad nõuded jaotati relevantsete peatükkide vahel
- Lisandusid uued peatükid: OAuth/OIDC (V10), WebRTC (V17), iseseisvad token'id (V9), veebi frontend'i turvalisus (V3)

OpenSSF (2025) pakub täiendavalt turva-keskse juhendi AI koodi-assistentide instruktsioonide kirjutamiseks, rõhutades, et turvajuhised peavad olema konkreetsed ja sisaldama nii positiivseid kui negatiivseid näiteid.

### 7.2 Sisendvalideerimine ja süstimisvastased meetmed

SQL-süstimise vastu kasutatakse parameetriliste päringute nõuet, mis on OWASP Top 10 kõige kriitilisem soovitus (OWASP, 2025). Konfiguratsioon sisaldab konkreetset koodinäidet (BAD vs GOOD), kuna Osmani (2026) ja Sabrina.dev (2025) kinnitavad, et konkreetsed koodinäited töötavad LLM-ide puhul paremini kui abstraktsed reeglid — mudel jäljendab nähtud mustrit usaldusväärsemalt kui kirjalikku juhist.

XSS, käsu-süstimine, template injection, XXE ja deserialiseerimise ohud on kaetud kokkuvõtlikult, viidates OWASP ASVS asjakohastele peatükkidele.

### 7.3 Autentimine ja paroolipoliitika

Paroolipoliitika (minimaalselt 8 tähemärki, soovitavalt 15+) ühtib ASVS 5.0 nõudega, mis langetas miinimumi 12-lt 8-le vastavalt NIST SP 800-63B versioonile 4 (SoftwareMill, 2025). ASVS 5.0 eemaldas eraldi soola nõuded, kuna kaasaegsed algoritmid (Argon2, bcrypt) haldavad soola sisemiselt.

Täiendavad autentimisreeglid — ühtlased veateated ("Invalid credentials"), ühtlased vastamise ajad kasutajate loendamise takistamiseks, ja rate limiting'u piirangud — põhinevad OWASP ASVS peatükil V2 (OWASP, 2025).

### 7.4 OAuth/OIDC

OAuth/OIDC sektsiooni aluseks on ASVS 5.0 peatükk V10.4, mis sisaldab 16 OAuth Authorization Server'i nõuet (OWASP, 2025; SoftwareMill, 2025). Konfiguratsioon katab neist olulisemad: redirect URI valideerimine allowlist'i vastu, PKCE kasutamine avalike klientide jaoks (SPA-d, mobiilirakendused), ID token'i claim'ide (`iss`, `aud`, `exp`, `nonce`) valideerimine ja turvaline token'ite salvestamine (httpOnly cookies, mitte localStorage).

### 7.5 Sessioonihaldus

Sessioonihaldusnõuded — sessiooni ID regenereerimine pärast sisselogimist, >=128-bitise entroopiaga token'id, tegevusetuse ja absoluutne aegumine, täielik invalideerimine väljalogimisel — põhinevad OWASP ASVS peatükil V3 (OWASP, 2025). Cookie'de turvalipud (`httpOnly`, `secure`, `sameSite`) on sama peatüki konkreetsed nõuded.

### 7.6 JWT ja API võtmed

JWT turvajuhised järgivad OWASP ASVS peatükki V9 (iseseisvad token'id). Peamised nõuded — `alg` päise valideerimine, `none` algoritmi keelamine, lühike aegumisaeg (<=15 min access token'id), server-side refresh token'ite rotatsioon — on tööstuse standardpraktika.

API võtmete haldamine (SHA-256 räsimine, ühekordne näitamine loomisel, scope'imine, aegumiskuupäevad, rate limiting võtme kaupa) tugineb turvauuringute firma Trail of Bits (2025) konfiguratsioonile, mis rõhutab supply chain'i turvalisust ja konkreetseid mehaanilisi reegleid.

### 7.7 HTTP turvapäised ja CORS

Turvapäiste loend (HSTS, X-Frame-Options, X-Content-Type-Options, CSP, Referrer-Policy) ja CORS-i wildcard'i keeld tootmiskeskkonnas põhinevad OWASP ASVS peatükil V14 (OWASP, 2025). Päised on esitatud kokkuvõtliku loeteluna, mitte serveri-spetsiifiliste näidetena, kuna Claude genereerib serveri-spetsiifilise konfiguratsiooni (Apache, Nginx, Express) konteksti põhjal.

### 7.8 Krüptograafia

Lubatud algoritmide loend (AES-GCM, SHA-256+, bcrypt/Argon2, TLS 1.2+) ja välistatud algoritmid (MD5, SHA-1, ECB, Math.random()) põhinevad OWASP ASVS peatükil V11 (OWASP, 2025). ASVS 5.0 lisas nõude 11.1.4 (L3 tasemel) post-quantum krüptograafia migratsiooni planeerimiseks — see on mainimisväärne tulevikutrend, kuid L3 nõudena pole praegu konfiguratsioonifailis kajastatud.

### 7.9 Rate limiting

Rate limiting'u piirangud (login 5/15min, password reset 3/15min, registreerimine 5/h, autenditud API 100/min, avalik API 20/min) põhinevad OWASP ASVS soovitustel ja tööstuse standardpraktikatel. `429 Too Many Requests` vastus `Retry-After` päisega on HTTP spetsifikatsiooni (RFC 6585) nõue.

### 7.10 Vigade käsitlemine ja logimine

Üldiste veateadete nõue ("Invalid credentials", mitte "Password incorrect") on OWASP ASVS peatüki V7 konkreetne nõue kasutajate loendamise takistamiseks (OWASP, 2025). Struktureeritud logimise (JSON) nõue ja tundlike andmete logimisest välistamise reegel on samast peatükist.

---

## 8. Testimine

### 8.1 TDD efektiivsus AI-assistentidega

Konfiguratsioon jõustab testipõhise arenduse (TDD) red-green-refactor tsükli. Simon Willison (2025) nimetab red/green TDD-d üheks kolmest igapäevasest agentsest mustrist, kirjeldades seda kui "meeldivalt kokkuvõtlikku viisi saada paremaid tulemusi koodiga töötavast agendist". Builder.io (2025) kinnitab, et AI elimineerib TDD suurima hõõrdepunkti — boilerplate testide kirjutamise —, muutes ajaloolise nõrkuse kiirendiks.

Nimble Approach (2025) selgitab, miks TDD ja AI on eriti hea kombinatsioon: test annab AI-le täpse spetsifikatsiooni soovitud käitumisest, ja AI suudab GREEN faasi (minimaalse koodi kirjutamise testi läbimiseks) sageli sekunditega lõpule viia.

### 8.2 Ühe konteksti TDD pitfall

Alexop.dev (2025) tuvastas olulise probleemi: kui üks LLM-i kontekst näeb nii testi kirjutamise kui implementatsiooni faasi, "petab" mudel ~80% ajast — kirjutab testi, mis arvestab juba tulevase implementatsiooniga, või jätab testi üldse vahele ja liigub otse implementatsiooni juurde. Lahendusena pakkusid nad multi-agent isolatsiooni: eraldi subagendid RED, GREEN ja REFACTOR faaside jaoks, igaüks isoleeritud kontekstis. See tõstis usaldusväärsuse ~20%-lt ~84%-le.

Käesolev konfiguratsioon kasutab vastumeetmena "Comment-Out Test" valideerimist: pärast implementatsiooni asendatakse kood katkise stubiga ja kontrollitakse, kas test ikka ebaõnnestub. See on kerge alternatiiv multi-agent isolatsioonile, mis ei nõua infrastruktuuri lisaseadistust.

### 8.3 Triviaalsete muudatuste erand

Konfiguratsioon teeb erandi triviaalsete muudatuste (üherealised parandused, konfiguratsiooni muudatused, kirjavead) jaoks, mis ei nõua täielikku RED-GREEN-REFACTOR tseremooniat. See tugineb Anthropic'u (2025a) soovitusele: "Kui muudatust saab kirjeldada ühe lausega, jäta plaan vahele." TDD nõue kehtib täielikult kõigi sisuliste muudatuste jaoks.

### 8.4 Testide valideerimine

"Comment-Out Test" meetod — implementatsiooni asendamine katkise stubiga, et kontrollida testi tegelikkust — on tõhus kaitse võltstestide vastu. Assertion'ite kvaliteedinäited (fake test vs real test) on esitatud konkreetsete koodinäidetena, kuna need töötavad LLM-idele efektiivsemalt kui abstraktsed reeglid (Osmani, 2026).

### 8.5 Katvuse lävendid ja testide jaotus

Katvuse lävendid (80% uue koodi jaoks, 90%+ kriitiliste radade jaoks) ja testide jaotus (70% unit, 20% integration, 10% E2E) on tööstuse standardpraktikad. Konfiguratsioon rõhutab, et katvus ei ole eesmärk omaette — "60% katvus tõeliste testidega on parem kui 100% katvus võltstestidega" (Sabrina.dev, 2025).

---

## 9. API disain

### 9.1 RESTful konventsioonid

RESTful konventsioonid (PATCH eelistamine PUT-ile osaliseks uuendamiseks, mitmuse nimisõnad endpoint'ides, korrektsed HTTP staatuskoodid, ühtne vastuse formaat) on jätkuvalt aktuaalsed (Postman, 2025; Medium, 2026). REST domineerib endiselt — 83% ettevõtetest kasutab seda (MyAppAPI, 2025).

### 9.2 Contract-first / OpenAPI lähenemine

Konfiguratsioon nõuab API lepingute (OpenAPI/Swagger) defineerimist enne implementatsiooni. Üle 80% organisatsioonidest rakendab mingil tasemel API-first lähenemist (MyAppAPI, 2025), kus OpenAPI spetsifikatsioon on de facto standard. API-first tähendab, et spetsifikatsioon toimib ühtse tõeallikana nii frontend'i kui backend'i jaoks.

Programming Helper (2026) kirjeldab API-first trendi laiemat konteksti: AI-natiivsed API-d peavad üha enam teenindama nii inimesi kui AI-agente, ja selge OpenAPI spetsifikatsioon toimib lepinguna mõlema jaoks.

### 9.3 Vahemälu (Caching)

Konfiguratsioon sisaldab caching-juhiseid: ETag ja If-None-Match tingimuslikud päringud, Cache-Control päised sisutüübi järgi, 304 Not Modified vastused. Need tuginevad REST API parimate praktikate kogumikele (Postman, 2025; Medium, 2026). HTTP/2 ja HTTP/3 kasutuselevõtt on jõudnud 83%-ni ettevõtetest, muutes ETag'id ja Cache-Control päised hädavajalikuks oleku järjepidevuse tagamisel (MyAppAPI, 2025).

### 9.4 Idempotentsus

Idempotency key muster (POST/PATCH päringute jaoks `Idempotency-Key` päise vastuvõtmine turvaliseks kordamiseks, server-side salvestamine, aegumisega) on standardpraktika, mis pärineb Stripe'i API disainist ja on dokumenteeritud Postman (2025) parimate praktikate hulgas.

### 9.5 Versioneerimine

Versioonimisstrateegia (URL path soovitusena, `Sunset` päisega deprekeermine, `v1`-st alustamine) on jätkuvalt soovituslik lähenemine (Postman, 2025).

---

## 10. Andmebaasi juhised

### 10.1 Migratsioonid

Migratsioonide haldamine järgib üldtunnustatud praktikaid: kõik skeemi muudatused migratsioonifailide kaudu, olemasolevad migratsioonid on immutaablid (muudatuste jaoks luuakse uus migratsioon), iga migratsioon sisaldab nii üles- kui allamineku loogikat. Ohtlike operatsioonide loend (NOT NULL veergude lisamine, veergude kustutamine, veergude ümbernimetamine) dokumenteerib levinud antimustreid, mis võivad tootmiskeskkonnas andmekadu põhjustada.

### 10.2 Päringute optimeerimine

Parameetriliste päringute nõue on nii turva- (SQL-süstimise vastane, vt sektsioon 7.2) kui jõudlusnõue. N+1 päringute vältimine (JOINs või eager loading), connection pooling ja EXPLAIN kasutamine on tööstuse standardpraktikad, mis tagavad andmebaasi jõudluse skaleerumisel.

---

## 11. Koodi kvaliteet

### 11.1 Koodi puhastusreeglid

Konfiguratsioon sisaldab viit mehaanilist koodi puhastusreeglit: kasutamata importide/muutujate/funktsioonide eemaldamine, kommenteeritud koodi kustutamine, debug-väljundite eemaldamine, surnud koodiradade eemaldamine ja linteri käivitamine. Need on konkreetsed, mõõdetavad reeglid, mida Claude saab järjepidevalt rakendada (JetBrains, 2025).

### 11.2 Ligipääsetavus (WCAG)

Ligipääsetavusnõuded põhinevad Web Content Accessibility Guidelines (WCAG) 2.1 AA tasemel: semantiline HTML, klaviatuuril ligipääsetavus, ARIA sildid, värvikontrasti nõuded (4.5:1 normaalse teksti, 3:1 suure teksti jaoks), info edastamine lisaks värvile ka teksti/ikoonide kaudu, piltidel alt-tekst, vormide ligipääsetavus.

### 11.3 Logimine

Logimisstandard on kokkuvõtlik: turvasündmuste logimine, struktureeritud JSON-formaat koos ajatempli, taseme, päringu ID ja kontekstiga, ning tundlike andmete (paroolid, token'id, krediitkaardinumbrid, isikuandmed) välistamine logidest.

---

## 12. Issue loomine

### 12.1 Kasutajaväärtuse põhine struktureerimine

Issue'd on struktureeritud lõppkasutaja perspektiivist: feature issue'de pealkirjad järgivad formaati "As a [role] I [action]", kus roll on alati lõppkasutaja (user, customer, admin), mitte tehniline roll (developer, engineer). See tagab, et iga issue esindab reaalset kasutajaväärtust.

### 12.2 Deploy-safe increments

"No dead UI" reegel nõuab, et iga issue toodaks deployable increment'i: iga nupp töötab, iga vorm saadab andmeid, iga leht laadib ilma vigadeta. Kui funktsionaalsus ei ole veel valmis, ei lisata ka UI elementi. See on projekt-spetsiifiline kvaliteedistandard, mida Claude ei saaks koodist ise tuletada.

### 12.3 Issue malli struktuur

Issue mall sisaldab: eesmärk (miks), kasutajalugu, vastuvõtukriteeriumid (mõõdetavad tulemused), testimisootused (testi tüüp ja kavatsus), andmebaasi muudatused (kui kohaldub) ja sõltuvused. Vastuvõtukriteeriumid on sõnastatud jälgitava käitumisena, mitte implementatsiooni detailidena — "WHAT, not HOW" põhimõte.

---

## Viited

- Alexop.dev. (2025). Forcing Claude Code to TDD: An Agentic Red-Green-Refactor Loop. https://alexop.dev/posts/custom-tdd-workflow-claude-code-vue/
- Anthropic. (2025a). Best Practices for Claude Code. https://code.claude.com/docs/en/best-practices
- Anthropic. (2025b). Claude Prompting Best Practices. https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices
- Builder.io. (2025). Test-Driven Development with AI. https://www.builder.io/blog/test-driven-development-ai
- DEV Community. (2025a). I Wrote 200 Lines of Rules for Claude Code -- It Ignored Them All. https://dev.to/minatoplanb/i-wrote-200-lines-of-rules-for-claude-code-it-ignored-them-all-4639
- DEV Community. (2025b). CLAUDE.md Best Practices: From Basic to Adaptive. https://dev.to/cleverhoods/claudemd-best-practices-from-basic-to-adaptive-9lm
- DEV Community. (2025c). 5 Patterns That Make Claude Code Actually Follow Your Rules. https://dev.to/docat0209/5-patterns-that-make-claude-code-actually-follow-your-rules-44dh
- DEV Community. (2025d). I Wrote 500 Lines of Rules for Claude Code -- Here's How I Made It Actually Follow Them. https://dev.to/mikeadolan/i-wrote-500-lines-of-rules-for-claude-code-heres-how-i-made-it-actually-follow-them-3c8
- GitHub. (2025a). IssueOps: Automate CI/CD and More with GitHub Issues and Actions. https://github.blog/engineering/issueops-automate-ci-cd-and-more-with-github-issues-and-actions/
- GitHub. (2025b). Introducing Sub-Issues: Enhancing Issue Management on GitHub. https://github.blog/engineering/architecture-optimization/introducing-sub-issues-enhancing-issue-management-on-github/
- GitHub. (2025c). spec-kit. https://github.com/github/spec-kit
- HumanLayer. (2025). Writing a Good CLAUDE.md. https://www.humanlayer.dev/blog/writing-a-good-claude-md
- JetBrains. (2025). Coding Guidelines for Your AI Agents. https://blog.jetbrains.com/idea/2025/05/coding-guidelines-for-your-ai-agents/
- Medium. (2025a). Your CLAUDE.md Is a Suggestion -- Hooks Make It Law. https://medium.com/codetodeploy/your-claude-md-is-a-suggestion-hooks-make-it-law-0124c5783b68
- Medium. (2025b). Claude Code Rules: Stop Stuffing Everything into One CLAUDE.md. https://medium.com/@richardhightower/claude-code-rules-stop-stuffing-everything-into-one-claude-md-0b3732bca433
- Medium. (2026). REST API Design in 2026: What's Changed, What Still Works. https://medium.com/@md.mohiuddin/rest-api-design-in-2026-whats-changed-what-still-works-8f2f09e925e2
- MindwiredAI. (2026). Claude Code Creator Workflow: Boris Cherny's 100-Line CLAUDE.md. https://mindwiredai.com/2026/03/25/claude-code-creator-workflow-claudemd/
- MyAppAPI. (2025). API Design Best Practices 2025. https://myappapi.com/blog/api-design-best-practices-2025
- Nimble Approach. (2025). How to Use TDD for Better AI Coding Outputs. https://nimbleapproach.com/blog/how-to-use-test-driven-development-for-better-ai-coding-outputs/
- OpenSSF. (2025). Security-Focused Guide for AI Code Assistant Instructions. https://best.openssf.org/Security-Focused-Guide-for-AI-Code-Assistant-Instructions.html
- Osmani, A. (2026). My LLM Coding Workflow Going Into 2026. https://addyosmani.com/blog/ai-coding-workflow/
- OWASP. (2025). Application Security Verification Standard v5.0.0. https://owasp.org/www-project-application-security-verification-standard/
- Postman. (2025). REST API Best Practices. https://blog.postman.com/rest-api-best-practices/
- Programming Helper. (2026). API-First Development 2026. https://www.programming-helper.com/tech/api-first-development-2026-rest-openapi-developer-experience-python
- Ranger. (2025). Version Control Best Practices for AI Code. https://www.ranger.net/post/version-control-best-practices-ai-code
- Sabrina.dev. (2025). The Ultimate AI Coding Guide for Developers. https://www.sabrina.dev/p/ultimate-ai-coding-guide-claude-code
- ShareUHack. (2026). Claude Code CLAUDE.md Setup Guide 2026. https://www.shareuhack.com/en/posts/claude-code-claude-md-setup-guide-2026
- SoftwareMill. (2025). What's New in ASVS 5.0. https://softwaremill.com/whats-new-in-asvs-5-0/
- Trail of Bits. (2025). Claude Code Config. https://github.com/trailofbits/claude-code-config
- Willison, S. (2025). Agentic Engineering Patterns. https://simonwillison.net/guides/agentic-engineering-patterns/
