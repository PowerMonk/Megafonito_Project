# UI audit — active Flutter screens

## Pre-refresh baseline

The running implementation, not the older PDFs, is the baseline. Current navigation is Home, Contacts, Opportunities, Processes, Account; Support is a separate app-bar action. App behavior and mock-service boundaries are described in [Frontend](../as-built/frontend.md) and [Frontend flows](../as-built/frontend-flows.md).

## Existing visual language

The source uses a recognizable black/navy and amber/orange identity, custom SVG marks, pale-gray page backgrounds, white cards, and rounded corners. However, color, elevation, typography, spacing, and shape are set locally in individual screens. The app theme is minimal and doesn't provide a strong design-system source of truth. Several screens use fixed spacing, black AppBars, and ad hoc bright blue/purple accents.

## Screen-level observations

- **Home:** dark AppBar/navigation against a light feed; filter chips, card design, and action buttons use different radius/color/elevation choices. Card metadata can overflow at narrow widths; date is fixed rather than sourced from the notice record. Empty/error/loading states are plain and visually unrelated.
- **Navigation:** legacy `BottomNavigationBar` is used despite Material 3 being the SDK default. Five long-ish labels compete for space on compact devices; custom SVGs require selected/unselected tint coordination.
- **Action menu:** overlay and FAB styling are bespoke; two simultaneously visible action FABs share a `heroTag`, risking a duplicate Hero assertion. Labels/icons need consistent semantics and touch bounds.
- **Contacts:** search/card UI uses hardcoded colors, tight copy-icon constraints and a `shrinkWrap` copy-all target. Long email/location text should wrap cleanly.
- **Opportunities:** asset-derived list is functional, but row/card surfaces and content typography are not shared with the rest of the app. Detail content is example data.
- **Processes and Support:** separate visual styles and placeholder actions; improve hierarchy and tappable tiles without inventing functionality.
- **Account:** information hierarchy, copy actions, schedule placeholder, and sign-out affordance are visually inconsistent with other surfaces; hardcoded source data must remain treated as mock.
- **Composers:** action icons and header styling differ between notice/opportunity/message forms. Dense inline rows and unbounded form fields can be difficult on small screens/large text. The title/link controller defect is behavior, so it should be documented rather than covertly concealed by a visual pass.
- **Login/register/splash:** login is explicitly a development bypass but its development status can be communicated more clearly and with a more deliberate hierarchy. The splash progress is timer simulation, not app loading.

## Accessibility and responsive concerns

Some icon actions depend on visual context for meaning; copying buttons have reduced constraints; hardcoded text styles can work against system text scaling; dense horizontal rows need wrapping/constraints; content max width is not consistently controlled on larger viewports. Visual acceptance should cover semantic labels, contrast, selected/focused/disabled states, keyboard insets, safe areas, and at least 48 logical-pixel target sizes.

## Scope distinction

Visual corrections may make existing metadata legible and layouts robust (such as showing `created_at` instead of a fabricated date). They must not suggest that login, notices, audience targeting, upload, contact delivery, or support forms are backend-backed. Core behavior/security bugs are tracked separately in [Known gaps](../as-built/known-gaps.md).

## Refresh outcome

- A single Material 3 theme now supplies brand colors, typography, component styling, and 48dp icon-button minimums.
- The home shell has a compact NavigationBar and a wide NavigationRail at 600 logical pixels, preserving all five destinations. Support remains an app-bar route.
- Feed cards now show actual `created_at`, use flexible metadata layouts, and style loading/empty/detail states consistently. The create-action menu uses a fade/slide transition, avoids the expensive full-screen blur filter, and has distinct Hero tags.
- The notice composer sits directly on the page surface rather than a floating card; its text fields are transparent and borderless to align with the surrounding recipient/category rows.
- Opportunity cards use smaller square image frames with `BoxFit.contain`, and show a slice of the next card to cue horizontal scrolling.
- Contacts, Opportunities, Processes, Account, Support, login/register/splash, and all three composers now use the shared surface, spacing, typography, and accessible control styles.
- Composer forms and screen content are width-constrained and scrollable; mock auth remains visibly marked as development.
- Focused widget tests cover compact/wide layout, navigation, touch target size, text scaling, keyboard-inset scrolling, and existing interaction callbacks.
