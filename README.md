# BandWise

An **offline-first exam score simulator & prep tracker**, IELTS-first and
architected so more exams (CELPIP, PTE, TOEFL…) drop in as self-contained
modules without rewriting the core.

Three pillars:

1. **Score Simulator** — dial in module bands or a raw score and see the result
   live, using the exam's official scoring formula.
2. **Rubric Reference** — official band descriptors for Writing, Speaking and the
   Overall Band, as scannable collapsible cards.
3. **Practice Log** — log real attempts and review progress via list/search,
   a calendar heatmap, and trend graphs. 100% on-device.

---

## Running it

```bash
flutter pub get
flutter run
```

The generated Drift code (`*.g.dart`) is committed. If you change the DB schema,
regenerate it with `./tool/codegen.sh` (see the note under *Dependencies* for why
it isn't a plain `build_runner` call).

Tests (the trust-critical scoring/rounding/conversion logic):

```bash
flutter test
```

> **Ads note:** the app ships with Google's official **test** AdMob IDs, so it
> runs out of the box with no AdMob account. See [Monetization](#monetization).

---

## Architecture

Feature-first, layered (presentation / domain / data), with the **core kept
exam-agnostic**.

```
lib/
  main.dart                 # bootstrap: prefs, ad init, ProviderScope
  app.dart                  # MaterialApp + theming
  core/
    exam/
      exam_module.dart      # ExamModule plugin contract (the extensibility seam)
      exam_registry.dart    # list of installed exams + selection providers
    ads/                    # AdConfig (test IDs), AdService, AdaptiveBanner
    theme/                  # light + dark Material 3 theme, band colours
  features/
    home/                   # bottom-nav shell (Simulate · Rubrics · Log · Settings)
    settings/               # theme, exam type, daily reward perk (shared_preferences)
    exams/
      ielts/                # the first ExamModule implementation
        domain/             # PURE DART — models, scoring, rubric models (unit-tested)
        data/               # asset loader (rootBundle JSON -> domain)
        presentation/       # simulator (Mode A/B) + rubrics + Riverpod providers
    log/                    # exam-AGNOSTIC practice log
      data/                 # Drift database, filters, providers
      presentation/         # list/search, editor, calendar heatmap, trend charts
assets/
  data/ielts/               # versioned conversion tables (JSON)
  rubrics/ielts/            # versioned rubric text (JSON)
test/ielts/                 # scoring/rounding/conversion unit tests
```

**State management:** [Riverpod](https://riverpod.dev). Chosen over Bloc for
lower ceremony on the live-updating simulator (providers recompute the Overall
Band as a slider drags — no "Calculate" button).

**Why the domain layer has no Flutter imports:** the scoring logic is the app's
trust anchor, so `ielts_models.dart` / `ielts_scoring.dart` are pure Dart and
tested in isolation. Only the thin `data/` loader touches `rootBundle`.

### Data accuracy & the rounding rule

- **Conversion tables are indicative and versioned.** IELTS does **not** publish
  a single fixed raw→band table; boundaries vary slightly between test versions.
  The shipped tables come from official Cambridge practice-test materials and are
  clearly labelled "indicative" in-app, with a `version` + `source` in each JSON
  file so they can be updated without an app rebuild.
- **Overall Band rounding follows the official convention**, not the product
  brief. The brief listed averages like `.375`/`.875` as rounding *down*; the
  official rule rounds the average to the **nearest half band with ties going
  up**, so `6.375 → 6.5` and `6.875 → 7.0`. Rounding those down would
  under-report a candidate's band by half a point, so the code implements the
  official rule (`(avg*2).round()/2`) and the app shows a one-line explanation of
  each rounding. See `lib/features/exams/ielts/domain/ielts_scoring.dart` and the
  exhaustive tests in `test/ielts/ielts_scoring_test.dart`.

---

## Dependencies (and why each earns its place)

| Package | Why |
|---|---|
| `flutter_riverpod` | State management; live simulator + reactive log streams. |
| `drift` + `sqlite3_flutter_libs` + `path_provider` + `path` | Typed SQLite for the log. The search / date-range / score-range filters and calendar aggregation map naturally to SQL — cleaner than hand-rolled NoSQL queries. |
| `fl_chart` | Custom-painter charts: the conversion chart (highlighted marker) and progress trends. Lightweight, no native deps. |
| `google_mobile_ads` | Banner + app-open + rewarded ads (see below). |
| `intl` | Date formatting for the log/calendar. |
| `shared_preferences` | Tiny key-value settings (theme, exam variant, daily perk). Drift would be overkill for these. |

Dev-only: `build_runner` + `drift_dev` for Drift codegen.

> **Codegen quirk — `sqlite3` build hook.** `sqlite3 ≥3.3` ships a Dart 3.10
> native *build hook* that breaks `build_runner`'s AOT snapshot of its codegen
> script, but drift 2.34 needs `sqlite3` 3.x at runtime — so we can't pin it
> down permanently. Regenerate Drift code with **`./tool/codegen.sh`**, which
> temporarily overrides `sqlite3` to the last hook-free version (2.9.4) for the
> generation step only, then restores the normal deps. The generated `.g.dart`
> is version-independent and committed, so you only need this when the DB schema
> changes. Revisit once `build_runner` supports build hooks.

Riverpod codegen was intentionally **not** added — its `build` constraint
conflicts with `drift_dev`, and manual providers keep the graph simple.

---

## Monetization

Configured in `lib/core/ads/ad_config.dart`. All IDs are Google's **official test
IDs**; flip `useTestIds = false` and fill in real unit IDs (plus the app IDs in
`AndroidManifest.xml` / `Info.plist`) before release.

- **Banner** — persistent, bottom of the shell, in its own row so it never covers
  controls. Renders nothing until an ad loads (no broken box).
- **App-open** — shown once on cold launch, non-blocking.
- **Rewarded** — user-initiated, **once per day**. Reward = **Focus Mode**: hides
  banners for the rest of the day.
- **No interstitials.** By design, no full-screen ad can appear during a scoring
  interaction — the only full-screen ads are the cold-launch app-open ad and the
  user-tapped rewarded ad.

---

## Adding a new exam module

The core (log, calendar, trends, settings, shell) never references IELTS. To add
an exam:

1. **Implement `ExamModule`** (`lib/core/exam/exam_module.dart`): `id`,
   `displayName`, `variants`, `moduleOptions`, `scoreScale`, and
   `buildSimulatorPage` / `buildRubricsPage`.
2. **Add your data** as versioned JSON assets (conversion tables / rubrics) and a
   loader in your module's `data/` layer. Keep scoring logic in a **pure-Dart
   `domain/`** file and unit-test it.
3. **Register it** in `exam_registry.dart`:
   ```dart
   return const [ IeltsModule(), CelpipModule() ];
   ```
   The shell's exam switcher, the log's module/variant dropdowns, and the graphs
   pick it up automatically via `moduleOptions` / `scoreScale`.

> ⚠️ CELPIP uses a different scale (1–12 per skill) and different modules — it
> needs its own research + scoring rules. `ScoreScale` and the opaque
> `examId/variantId/moduleId` strings on log entries already accommodate this;
> don't assume IELTS band-averaging generalizes.

---

## Privacy

No account, no cloud sync, no personal analytics. All log data lives in a local
SQLite database on the device. The only network use is the ad SDK.

---

## Status / what's next

- ✅ Exam-plugin core, IELTS scoring engine (fully tested), versioned JSON data,
  Simulator (Mode A + B) with live charts, Rubric Reference, Practice Log
  (CRUD + search/filter + calendar heatmap + trend graphs), ads scaffold,
  light/dark themes.
- ✅ App icon (iOS + Android adaptive) and native splash. Sources are generated
  by `tool/gen_branding.py` into `assets/branding/`; regenerate the platform
  assets with `dart run flutter_launcher_icons` and
  `dart run flutter_native_splash:create`.
- ⏭️ Tablet-optimised master/detail layouts, widget/integration tests, CELPIP module.

### Branding

BandWise's mark is four ascending rounded bars (rising band scores) with a single
highlighted marker dot on the tallest — echoing the "your score on the conversion
chart" idea — on a teal→indigo gradient. Edit `tool/gen_branding.py` to tweak.
