# Google Play Store Listing — BandWise (IELTS Band Score Calculator)

Package: `com.sanket.ieltsbandcalculator`
Last updated: 2026-07-22 · Version 1.0.0

Everything below is copy-paste ready. Character limits are noted so you stay
within Google Play's constraints. Fields are ordered the way Play Console asks
for them.

---

## 1. App name / Title  (max 30 characters)

**Primary choice (27 chars):**
```
IELTS Band Score Calculator
```

Alternatives (all ≤30 chars) if the primary is taken or you want more brand:
```
BandWise: IELTS Band Score      (26)
IELTS Band Calculator & Prep    (28)
BandWise — IELTS Calculator     (27)
```

> ASO note: the exact phrase "IELTS Band Score Calculator" is the single
> highest-intent search term for this app, so keeping it in the title is worth
> more than leading with the brand name while you have no brand recognition yet.

---

## 2. Short description  (max 80 characters)

**Primary (76 chars):**
```
Calculate your IELTS band score & track practice across all four sections.
```

Alternatives:
```
IELTS band calculator: convert raw scores, track bands, see your trend.  (72)
Know your IELTS band. Convert scores, log practice, watch your progress. (72)
```

> ASO note: the short description is indexed by Play. Front-load "IELTS band"
> and use natural keywords ("calculate", "band score", "practice", "sections").

---

## 3. Full description  (max 4000 characters)

```
Know exactly where your IELTS band stands — before test day.

BandWise turns your practice scores into real IELTS band scores in seconds. Enter your Listening and Reading raw scores and get the band instantly from the official conversion tables. Add your Writing and Speaking bands, and BandWise calculates your Overall Band the same way the real exam does — including the official rounding rules. No guesswork, no spreadsheets.

Whether you're aiming for band 6.5 for a visa, band 7 for university, or band 8 to stand out, BandWise shows you the number that matters and how close you are.

━━━━━━━━━━━━━━━━━━━━
WHY BANDWISE
━━━━━━━━━━━━━━━━━━━━

★ Accurate band conversion
Raw score → band for Listening and Reading, using the correct tables for both Academic and General Training. Writing and Speaking are entered directly against the official band descriptors.

★ Overall band, done right
BandWise averages your four sections and applies IELTS's exact half-band rounding rules — so the Overall Band you see is the one you'd actually get.

★ Track every practice session
Log each mock test or practice set. Build a history of your scores instead of losing them on paper.

★ See your progress
A clean trend chart shows your band moving over time, section by section, so you know if your prep is working.

★ Official band descriptors built in
Reference what each band actually means for Writing and Speaking — right inside the app, whenever you need it.

★ Works completely offline
No account, no sign-up, no internet required. Your data stays on your device. Practice on the bus, on a plane, anywhere.

★ Fast, clean, and free
Designed to be quick to use every single day of your prep.

━━━━━━━━━━━━━━━━━━━━
PERFECT FOR
━━━━━━━━━━━━━━━━━━━━

• Students preparing for IELTS Academic (university, study abroad)
• Applicants taking IELTS General Training (work, migration, PR visas)
• Anyone doing mock tests who wants an instant, accurate band
• Teachers and tutors tracking student progress

━━━━━━━━━━━━━━━━━━━━
HOW IT WORKS
━━━━━━━━━━━━━━━━━━━━

1. Pick Academic or General Training.
2. Enter your Listening and Reading raw scores — see the band instantly.
3. Add your Writing and Speaking bands.
4. Get your Overall Band, correctly rounded.
5. Save it to your log and watch your trend improve.

━━━━━━━━━━━━━━━━━━━━

BandWise is an independent study tool. It is not affiliated with, endorsed by, or connected to the IELTS partners (British Council, IDP: IELTS Australia, or Cambridge University Press & Assessment). "IELTS" is a trademark of its respective owners and is used here only to describe the exam this tool helps you prepare for.

Download BandWise and know your band today.
```

> Keep the trademark disclaimer — Google (and the IELTS owners) expect
> third-party prep apps to make clear they are unofficial. This reduces the
> risk of a takedown/suspension.

---

## 4. Keyword strategy (for your reference — Play has no keyword field)

Google Play indexes your **title + short description + full description**, so
the words below should appear naturally in those three fields (they already do
above). Do NOT keyword-stuff — repetition beyond ~3–4x can hurt you.

Primary (high intent):
- ielts band calculator
- ielts band score calculator
- ielts score calculator
- ielts band score

Secondary:
- ielts practice / ielts mock test
- ielts listening band / ielts reading band
- ielts overall band
- ielts academic / ielts general training
- band score converter / raw score to band

Long-tail:
- calculate ielts band from raw score
- ielts band 7 / band 6.5 / band 8
- ielts preparation tracker

---

## 5. Category & tags

- **Category:** Education
- **Tags (pick up to 5 in Play Console):** Education, Test Prep, Study,
  Reference, Productivity
- **Content rating:** Everyone (no objectionable content)

---

## 6. Release notes / "What's new"  (max 500 characters)

For v1.0.0:
```
Welcome to BandWise 1.0!
• Instant IELTS band from Listening & Reading raw scores (Academic + General)
• Enter Writing & Speaking bands, get your Overall Band with correct rounding
• Log your practice and track your band trend over time
• Official band descriptors built in
• 100% offline — no account needed
```

---

## 7. Graphic assets checklist (you still need to create these)

Play Console requires:
- [ ] **App icon** — 512×512 PNG (32-bit, with alpha). Already have the mark;
      export a 512px version.
- [ ] **Feature graphic** — 1024×500 PNG/JPG (shown at top of listing). Use the
      teal→indigo gradient + the ascending-bars mark + tagline "Know your band".
- [x] **Phone screenshots** — DONE. Six ad-free 1080×2160 images in
      `store/screenshots/` (Overall Band, score conversion, band trend,
      practice log, band descriptors, offline/privacy). See that folder's
      README for upload order.
- [ ] (Optional) 7-inch & 10-inch tablet screenshots.
- [ ] (Optional) Promo video (YouTube URL).

---

## 8. Store settings reminders

- [ ] Privacy policy URL (required — even for an offline app that collects
      nothing; you must still state that). Say the app stores data only on the
      device and that ads are served via Google AdMob.
- [ ] Data safety form: declare AdMob (ads use advertising ID). BandWise itself
      stores practice logs locally only.
- [ ] Contact email for the listing.
- [ ] Target audience & content: not directed at children.

---

## TODO before publishing
- [ ] Swap AdMob **test** IDs for real ones in `lib/core/ads/ad_config.dart`
      and set `useTestIds = false` (Android IDs first; iOS IDs still pending).
- [ ] Create the graphic assets above.
- [ ] Write & host a privacy policy; paste the URL into Play Console.
- [ ] Build a signed release (`flutter build appbundle --release`).
