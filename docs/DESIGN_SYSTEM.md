# Design System: [Project Name]

> Define before building the first screen.
> This document is the visual source of truth for the product.
> Code must reflect this system, not the other way around.
>
> Note: this boilerplate is API-only. Fill this in when building a frontend on top.

---

## Design principles

<!-- 3-5 principles that guide every visual decision. Must be specific, not generic.
     "Simple" is not a principle. "One primary action per screen" is. -->

1.
2.
3.

---

## Colors

### Base palette

```
/* Primary */
--color-primary-50:   #        /* use: soft backgrounds */
--color-primary-100:  #        /* use: hover states */
--color-primary-500:  #        /* use: primary action, CTA */
--color-primary-600:  #        /* use: CTA hover */
--color-primary-900:  #        /* use: text on light background */

/* Neutral */
--color-neutral-0:    #ffffff  /* white */
--color-neutral-50:   #        /* page backgrounds */
--color-neutral-100:  #        /* card backgrounds */
--color-neutral-200:  #        /* borders */
--color-neutral-400:  #        /* placeholder text */
--color-neutral-600:  #        /* secondary text */
--color-neutral-900:  #        /* primary text */

/* Semantic */
--color-success:      #        /* confirmations, success */
--color-warning:      #        /* alerts, caution */
--color-error:        #        /* errors, destructive */
--color-info:         #        /* neutral information */
```

### Color usage

| Element | Color | Variable |
|---------|-------|----------|
| Page background | | `--color-neutral-50` |
| Card background | | `--color-neutral-0` |
| Primary text | | `--color-neutral-900` |
| Secondary text | | `--color-neutral-600` |
| CTA / primary action | | `--color-primary-500` |
| Borders | | `--color-neutral-200` |

**Rule:** Never use hex directly in code. Always CSS variables or Tailwind tokens.

---

## Typography

```
/* Fonts */
--font-sans:  '';   /* UI, body text */
--font-mono:  '';   /* code, IDs, technical data */

/* Scale */
--text-xs:    0.75rem   /* 12px — labels, captions */
--text-sm:    0.875rem  /* 14px — secondary text, inputs */
--text-base:  1rem      /* 16px — primary text */
--text-lg:    1.125rem  /* 18px — subtitles */
--text-xl:    1.25rem   /* 20px — section titles */
--text-2xl:   1.5rem    /* 24px — page titles */
--text-3xl:   1.875rem  /* 30px — hero, large headings */

/* Weights */
--font-normal:   400
--font-medium:   500
--font-semibold: 600
--font-bold:     700
```

### Typography hierarchy

| Element | Size | Weight | Color |
|---------|------|--------|-------|
| H1 / Page title | `text-2xl` | `font-bold` | `neutral-900` |
| H2 / Section title | `text-xl` | `font-semibold` | `neutral-900` |
| H3 / Card title | `text-lg` | `font-semibold` | `neutral-900` |
| Body | `text-base` | `font-normal` | `neutral-900` |
| Secondary text | `text-sm` | `font-normal` | `neutral-600` |
| Caption / Label | `text-xs` | `font-medium` | `neutral-600` |

---

## Spacing

```
/* Based on 4px scale */
--space-1:  0.25rem   /*  4px */
--space-2:  0.5rem    /*  8px */
--space-3:  0.75rem   /* 12px */
--space-4:  1rem      /* 16px */
--space-5:  1.25rem   /* 20px */
--space-6:  1.5rem    /* 24px */
--space-8:  2rem      /* 32px */
--space-10: 2.5rem    /* 40px */
--space-12: 3rem      /* 48px */
--space-16: 4rem      /* 64px */
```

**Rule:** Card internal padding: `space-4` or `space-6`. Gap between sections: `space-8` or `space-12`.

---

## Borders and shadows

```
/* Border radius */
--radius-sm:   0.25rem   /* small inputs */
--radius-md:   0.375rem  /* inputs, buttons */
--radius-lg:   0.5rem    /* cards */
--radius-xl:   0.75rem   /* modals, panels */
--radius-full: 9999px    /* pills, avatars */

/* Shadows */
--shadow-sm:  0 1px 2px rgb(0 0 0 / 0.05)
--shadow-md:  0 4px 6px rgb(0 0 0 / 0.07)
--shadow-lg:  0 10px 15px rgb(0 0 0 / 0.10)
--shadow-xl:  0 20px 25px rgb(0 0 0 / 0.12)
```

---

## Base components

### Buttons

| Variant | Use | Appearance |
|---------|-----|------------|
| `primary` | Primary action on the screen. Max 1 per view. | Background `primary-500`, white text |
| `secondary` | Secondary action | Border `neutral-200`, white background, `neutral-900` text |
| `ghost` | Tertiary action, links | No background or border, `primary-500` text |
| `destructive` | Delete, irreversible cancel | Background `error`, white text |

**Required states:** `default`, `hover`, `active`, `disabled`, `loading`

```tsx
// Usage example
<Button variant="primary" size="md" loading={isPending}>
  Save changes
</Button>
```

---

### Inputs

**Required states:** `default`, `focus`, `error`, `disabled`

```tsx
<FormField
  label="Email"
  error={errors.email?.message}
  hint="We'll use this email for confirmations"
>
  <Input type="email" {...register('email')} />
</FormField>
```

**Rule:** Every input has a visible label. Never use placeholder as the only label.

---

### Cards

```tsx
// Standard card
<Card>
  <CardHeader>
    <CardTitle>Title</CardTitle>
    <CardDescription>Optional description</CardDescription>
  </CardHeader>
  <CardContent>
    {/* content */}
  </CardContent>
  <CardFooter>
    {/* actions */}
  </CardFooter>
</Card>
```

---

### Loading and empty states

**Rule:** Every screen that loads data must have 3 states defined before implementation:

| State | What to show |
|-------|-------------|
| Loading | Skeleton, not a generic spinner |
| Empty | Illustration + message + action (if applicable) |
| Error | Clear message + retry action |

---

## Layout and grid

```
/* Breakpoints */
sm:  640px
md:  768px
lg:  1024px
xl:  1280px

/* Max content width */
--content-max:  1280px
--content-md:   768px   /* forms, onboarding flows */

/* Sidebar (if applicable) */
--sidebar-width: 240px
```

---

## Icons

**Library:** <!-- e.g.: Lucide, Heroicons, Phosphor -->
**Sizes:** `16px` (inline), `20px` (UI standard), `24px` (emphasis)
**Rule:** No emoji as UI. No icon without accessible label (`aria-label` or visible text).

---

## Animations

```
/* Durations */
--duration-fast:   100ms   /* hover, focus */
--duration-normal: 200ms   /* UI transitions */
--duration-slow:   300ms   /* modals, panels */

/* Easing */
--ease-out: cubic-bezier(0, 0, 0.2, 1)
--ease-in-out: cubic-bezier(0.4, 0, 0.2, 1)
```

**Rule:** Enter animations: `ease-out`. Exit: `ease-in`. Nothing > 300ms for frequent interactions.

---

## Accessibility

- Minimum text/background contrast: **4.5:1** (WCAG AA)
- Every interactive element: visible outline on focus
- Images: always descriptive `alt`
- Forms: `label` associated with every input
- Colors: never the only state indicator (accompany with icon or text)

---

## Implementation

**UI stack:**
<!-- e.g.: Tailwind CSS + shadcn/ui / Tailwind + custom components / CSS Modules -->

**Where components live:**
```
src/components/ui/        # primitives (Button, Input, Card, Modal...)
src/components/           # reusable composites
src/features/*/components # feature-specific components
```

**Rule:** A new component is only created if it will be used in 2+ places. If single-use, inline it in the feature.
