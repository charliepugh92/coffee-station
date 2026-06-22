# Davey's Coffee — Style Bible

> Small-batch · hometown · your pour.

A craft-roastery label, rendered in software. Warm kraft-paper surfaces and
roast-brown ink, with a bold condensed menu-board headline and chalkboard
hand-lettering for accents. Cozy and a little hand-made, never corporate.

This is the source of truth. Tokens live in [`src/style.css`](src/style.css);
every component class below maps to a real surface in the app.

---

## 1. Identity

| | |
|---|---|
| **Essence** | A neighbor's coffee bar, not a chain |
| **Voice** | Warm, plain-spoken, first-person ("your coffee's ready") |
| **Mood** | Slow morning, kraft paper, chalkboard menu, caramel light |
| **Reads as** | A local roaster's order ticket |
| **Never** | Slick, corporate, "experience," ALL CAPS shouting, emoji-heavy |

If a sentence sounds like it could appear at a Starbucks, rewrite it.

---

## 2. Wordmark & favicon

The mark is the **lightning-bolt spark** in [`public/favicon.svg`](public/favicon.svg) — recolored from
its original violet to the roast palette so the icon, the wordmark, and the
primary CTA all live in the same family.

| Lockup | Use |
|---|---|
| **Icon + wordmark** (header) | Default on every page |
| **Wordmark only** | Inline citations, footers |
| **Icon only** (favicon, app icons, QR overlays) | Anywhere the wordmark won't fit |

The wordmark is set in **Anton**, sentence case, never tracked open. The
optional tagline ("small-batch · hometown · your pour") is set in **Caveat**,
caramel, lowercase.

Minimum sizes: icon 24px, wordmark 96px wide. Clear space around the lockup
equals the height of a capital letter in the wordmark.

---

## 3. Color

Six brand roles plus four semantic states. Use the role name (`bg-surface`,
`text-roast`), not the hex.

### Brand roles

| Token | Hex | Use |
|---|---|---|
| `surface` | `#FAF7F2` | Page background — warm kraft paper |
| `card` | `#FFFFFF` | Raised surfaces (order cards, board rows, panels) |
| `sunken` | `#F1EAE0` | Insets, disabled fills, empty-state wells |
| `ink` | `#2A2320` | Primary text, dark utility buttons (camera/photo) |
| `roast` | `#874A2C` | **Primary CTA, links, focus rings, icon badges** |
| `caramel` | `#C9842F` | Stars, taglines, hand-lettered accents, hover lift |
| `muted` | `#8B8178` | Meta text, captions, "for Sam · #3 in line" |
| `border` | `#E9E2D8` | Hairlines on cards and dividers |

### Semantic states

| Token | Hex | Use |
|---|---|---|
| `success` | `#3B6D2E` | "Ready" pill text, confirmations |
| `success-tint` | `#E4EFDD` | "Ready" pill fill |
| `error` | `#B23A2E` | Form errors, destructive confirmations |
| `error-tint` | `#F6E2DE` | Error banner fill |
| `accent-tint` | `#F4E7D6` | "In progress" pill fill, focus ring halo |

### Usage rules

- **One primary per screen.** Roast is the only "click me" color. If a screen
  has two roast buttons, one of them is wrong.
- **Caramel is for delight, not destination.** Stars, the tagline, completed
  ratings — never a CTA.
- **Ink is for type and one utility button:** the camera/file button on the
  host board ("Mark ready 📷"). It contrasts with the roast CTA so a host can
  tell the two apart at a glance during a rush.
- **Text on tinted fills uses the same family.** `text-roast` on `bg-accent-tint`,
  `text-success` on `bg-success-tint`. Never plain stone-500.

### Do not

- Add a third brand color. The palette is closed.
- Use stone/gray for chrome (legacy). Use `border` and `muted`.
- Put roast text on caramel fill (fails AA at body size).

---

## 4. Typography

Three faces. Each has one job. Never mix jobs.

| Face | Role | Where |
|---|---|---|
| **Anton** (display) | Headlines | Wordmark, view titles, `Your coffee's ready`, order-board station name |
| **Caveat** (accent) | Hand-lettered moments | Tagline, completion-card subtitle, guest comment quotes, "thanks!" toasts |
| **Inter** (body) | Everything else | Body, labels, buttons, inputs, meta, status pills |

### Scale

| Class | Size / weight | Use |
|---|---|---|
| `text-display` | Anton 32/1.0 | Page hero ("Open the bar") |
| `text-heading` | Anton 21/1.1 | View titles, station names |
| `text-card-title` | Anton 20/1.1 | Inside cards ("Your coffee's ready") |
| `text-accent` | Caveat 600 18 | Taglines, hand-written notes |
| `text-body` | Inter 400 16/1.6 | Default prose |
| `text-meta` | Inter 400 13 | "Maya's Corner · for Sam · #3" |
| `text-label` | Inter 600 11/.1em uppercase | Status pills, eyebrows |

### Rules

- **Sentence case everywhere.** Never Title Case, never ALL CAPS — except
  status pills (`PENDING`, `READY`) which earn it by being tiny labels.
- **Anton is bold by construction.** Never set Anton in italics, never apply
  `font-bold` — it's already at its single weight.
- **Caveat is for human moments.** A guest comment ("thank you!!"), the
  tagline, a completion toast. Never UI chrome. Never inputs or labels.
- **Two Inter weights only:** 400 regular and 600 semibold. No 500, no 700.

---

## 5. Layout

| Token | Value | Use |
|---|---|---|
| `radius-sm` | 7px | Status pills, small chips |
| `radius-md` | 10px | Inputs, secondary buttons |
| `radius-lg` | 14px | Cards, primary buttons, panels |
| `radius-pill` | 9999px | Avatars, icon badges |

Spacing follows Tailwind's default 4px scale. Reach for `gap-3` / `p-4` /
`p-6` first; deviate only when a component genuinely needs it.

Borders are always **0.5px** (use `border` + custom width) when shown — never
1px chrome. The kraft-paper aesthetic depends on hairlines, not boxes.

The page max-widths in use today are correct and stay:

- Forms (`OrderForm`, `AuthView`): `max-w-sm` / `max-w-lg`
- Reading surfaces (`HomeView`): `max-w-2xl`
- Host board (`OrderBoardView`): `max-w-3xl`

---

## 6. Components

Every spec below maps to a real Vue component. Tailwind classes use the new
brand tokens; the migration column shows what to replace from today's code.

### 6.1 App shell — [`App.vue`](src/App.vue)

```html
<div class="min-h-screen bg-surface text-ink">
  <header class="flex items-center justify-between border-b border-border px-6 py-4">
    <RouterLink to="/" class="flex items-center gap-3">
      <img src="/favicon.svg" class="h-8 w-8" alt="" />
      <span class="font-display text-2xl leading-none">Davey's Coffee</span>
    </RouterLink>
    <nav class="flex items-center gap-5 text-sm text-muted">
      <RouterLink class="hover:text-ink" to="/my-orders">Your orders</RouterLink>
      ...
    </nav>
  </header>
  <main class="p-6">
    <RouterView />
  </main>
</div>
```

Migration: `bg-stone-50` → `bg-surface`, `text-stone-900` → `text-ink`,
`border-stone-200` → `border-border`, `text-stone-600` → `text-muted`.

### 6.2 Primary button

```html
<button class="rounded-lg bg-roast px-4 py-2 text-base font-semibold text-surface
               hover:bg-roast/90 active:scale-[.99] disabled:opacity-45">
  Place order
</button>
```

- Full-width inside forms (`w-full`), inline elsewhere.
- Disabled is opacity-45, not gray — the brown stays brown.

### 6.3 Utility button (camera / dark actions)

```html
<button class="rounded-lg bg-ink px-3 py-2 text-sm font-semibold text-surface
               inline-flex items-center gap-2">
  Mark ready
  <i class="ti ti-camera" />
</button>
```

Reserved for the host-board "Mark ready 📷" file picker and any other
destructive-adjacent utility. Visually distinct from `bg-roast` so a host can
tell apart "start the next order" from "capture the photo" mid-rush.

### 6.4 Text input

```html
<input class="w-full rounded-md border-[0.5px] border-border bg-card
              px-3 py-2 text-base text-ink placeholder:text-muted
              focus:border-roast focus:ring-4 focus:ring-accent-tint
              focus:outline-none" />
```

Focus ring is `accent-tint` (4px halo), border becomes `roast`. Never `ring-blue-500`.

### 6.5 Order-status pill

A 4-state badge driven by the order's `status`:

| State | Class |
|---|---|
| `PENDING` | `bg-sunken text-muted` |
| `IN_PROGRESS` | `bg-accent-tint text-roast` |
| `READY` | `bg-success-tint text-success` |
| `PICKED_UP` | `bg-[#ECE7DF] text-muted` |

All share: `rounded-sm px-2 py-1 text-[11px] font-semibold uppercase
tracking-[.08em]`. This is the **only** place in the app that uses ALL CAPS.

### 6.6 Star rating — [`OrderFeedback.vue`](src/components/order/OrderFeedback.vue)

Active stars: `text-caramel` (was `text-amber-400`). Inactive: `text-[#DCD3C8]`
(was `text-stone-300`). Star glyph: Tabler `ti-star`, sized 22px in the
feedback widget, 18px on summary cards.

### 6.7 Guest status card — [`OrderStatus.vue`](src/components/order/OrderStatus.vue)

```html
<div class="rounded-lg border-[0.5px] border-border bg-card p-6 text-center">
  <span class="mx-auto mb-2 flex h-11 w-11 items-center justify-center
               rounded-full bg-accent-tint text-roast">
    <i class="ti ti-coffee text-[22px]" />
  </span>
  <p class="font-display text-card-title">Your coffee's ready</p>
  <p class="mt-1 font-accent text-base text-muted">
    Maya's Corner · for Sam
  </p>
  <!-- photo + stars + feedback -->
</div>
```

The icon badge tints with `accent-tint`. The headline is Anton, the subtitle
slips into Caveat for warmth. Stars and feedback follow §6.6.

### 6.8 Host board row — [`OrderBoardView.vue`](src/views/OrderBoardView.vue)

```html
<div class="flex items-start justify-between rounded-lg border-[0.5px]
            border-border bg-card p-4">
  <div>
    <div class="text-base font-semibold text-ink">
      {{ guestName }}
      <span class="ml-1 text-xs font-normal text-muted">#{{ queue }}</span>
    </div>
    <div class="mt-0.5 text-sm text-muted">{{ summary }}</div>
    <div class="mt-1 font-accent text-base text-muted">"{{ note }}"</div>
  </div>
  <div class="flex flex-col items-end gap-2">
    <span class="rounded-sm bg-accent-tint px-2 py-1 text-[11px]
                 font-semibold uppercase tracking-[.08em] text-roast">
      In progress
    </span>
    <!-- advance button (utility or primary) -->
  </div>
</div>
```

Guest notes and comments are rendered in **Caveat** — they are the human
voice on a screen full of UI.

### 6.9 Empty / closed states

A friendly sentence on `bg-sunken`, with a coffee icon if there's room.
Never a generic "No data" — always something neighborly:

- "This station is closed right now — check back later."
- "No orders yet."
- "This coffee link isn't valid."

---

## 7. Iconography

Use the **Tabler outline** set (already documented in the visualize widget
guidance; pull via `@tabler/icons` if we adopt them as a webfont — open
decision). Outline only — never filled glyphs. Sized to match the
adjacent text's cap height: 16px next to body text, 22px in icon badges.

Hero glyphs we'll reach for repeatedly: `ti-coffee`, `ti-camera`, `ti-star`,
`ti-clock`, `ti-qrcode`, `ti-share-2`, `ti-chevron-down`.

The single coffee emoji (☕) in today's closed-station copy may stay — it's a
deliberate human flourish, not chrome — but no other emoji in UI.

---

## 8. States & motion

| State | Treatment |
|---|---|
| **Hover** (button) | `hover:bg-roast/90` — a small darkening, no lift, no shadow |
| **Hover** (link) | `text-muted` → `text-ink` |
| **Focus** | 4px `ring-accent-tint`, border becomes `roast` |
| **Active** | `active:scale-[.99]` — a tiny press, no color change |
| **Disabled** | `opacity-45` — the color stays, the affordance dims |
| **Loading** | "Loading the menu…" / "…" — never a spinner; copy carries the brand |
| **Live (new order arrived)** | A 200ms `bg-accent-tint` flash on the row, then settle |

No drop shadows. No glassmorphism. No gradients. The kraft-paper aesthetic is
flat by design.

---

## 9. Voice & copy

Write the way you'd talk to a regular at the bar.

| Don't | Do |
|---|---|
| "Your order is ready for pickup." | "Your coffee's ready." |
| "Submit" | "Place order" |
| "Account required" | "Need an account? Sign up" |
| "Error: Field required" | "What should I call you?" |
| "Session terminated" | "The station's closed for now." |

- **First person, present tense.** The app speaks as the bar.
- **Lowercase for warmth.** Buttons and headings get a leading capital;
  taglines and Caveat moments stay lowercase.
- **Em-dashes welcome.** A neighborly aside is a feature, not a bug.
- **Numbers are read aloud.** "#3 in line", not "Position: 3".

---

## 10. Imagery

Two image surfaces today:

1. **Menu / preset photos** (host-uploaded). Round to `rounded-lg`, never
   crop weirdly — `object-cover` with a 4:3 box.
2. **Completion photos** (the host's "your drink, ready" snapshot). Same
   `rounded-lg`, capped at `max-h-56` inside the status card. These are the
   single most delightful surface in the app — never compress, never overlay.

No stock photography ever. If we don't have a real photo, we use copy and the
icon badge.

---

## 11. Accessibility floor

- **Contrast.** Every text/background pair is verified at AA (4.5:1 body,
  3:1 large). Roast on surface = 7.3:1 ✓. Muted on surface = 4.6:1 ✓. Caramel
  is bright by design — **never** use it for body text on surface (3.0:1, fails).
- **Focus is always visible.** The 4px accent-tint ring is the contract.
- **Status pills carry the word**, not just the color. A red-green colorblind
  guest still reads "READY".
- **Touch targets ≥ 44px.** Star buttons in the rating row are intentionally
  oversized (22px glyph + padding) for thumb use on phones.
- **Icons announce themselves.** Decorative icons get `aria-hidden`;
  icon-only buttons get `aria-label`.

---

## 12. Anti-patterns

Things that *will* drift us off-brand if no one stops them:

- A blue link. Links are roast.
- A second primary button on a screen.
- Caramel body text.
- Adding emoji to buttons or labels (the ☕ in the closed-state copy is the
  exception, not the precedent).
- Title Case headings.
- Drop shadows on cards. We are paper, not iOS.
- A `text-gray-*` or `bg-stone-*` class in a new component. The tokens
  replaced them — use them.

---

## 13. Migration cheat-sheet

For the existing components, swap these classes wholesale:

| Today | Bible |
|---|---|
| `bg-stone-50` | `bg-surface` |
| `bg-stone-100` | `bg-sunken` |
| `bg-stone-700` / `bg-stone-800` | `bg-roast` (CTA) **or** `bg-ink` (utility) |
| `text-stone-900` | `text-ink` |
| `text-stone-600` / `text-stone-500` | `text-muted` |
| `text-stone-400` | `text-muted` (let opacity carry the dim) |
| `border-stone-200` / `border-stone-300` | `border-border` (with `border-[0.5px]`) |
| `text-amber-400` / `text-amber-600` | `text-caramel` |
| `text-red-600` | `text-error` |
| `text-green-600` | `text-success` |
| `font-semibold` on headings | `font-display` (Anton) |
| `tracking-tight` on wordmark | (drop — Anton is already condensed) |

Run the swap one view at a time; commit per view. The bible is the rubric.
