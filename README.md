# WAJetsam&ServiceExtensionFIx

Minimal WhatsApp ServiceExtension fix for iOS 16 / Dopamine rootless. Made by 551.

## What it does

- Prevents the WatusiTools `checkExpiryDate` worker from deliberately terminating WhatsApp's `ServiceExtension`.
- Keeps positive WhatsApp ServiceExtension Jetsam limits at a minimum of **40 MB**.
- Supports `libWatusiTools.dylib`, `libWatusiToolsSL.dylib`, and compatible WatusiTools image-name variants.
- Includes a Settings page with a WhatsApp-style icon and an **Enable Patch** switch.

The signature patch is the proven guarded runtime patch from WatusiServiceDiag 1.8.0. It is applied only when the expected unique ARM64 worker shape is found.

The package contains no trace dylib, observer daemon, report/status/collector tools or diagnostic file logging.

The Settings switch controls the Watusi exit patch. A change takes effect the next time WhatsApp's ServiceExtension starts. The 40 MB memory floor remains active.
