# WAJetsam&ServiceExtensionFIx

Minimal WhatsApp ServiceExtension fix for iOS 16 / Dopamine rootless. Made by 551.

## What it does

- Prevents the WatusiTools `checkExpiryDate` worker from deliberately terminating WhatsApp's `ServiceExtension`.
- Keeps positive WhatsApp ServiceExtension Jetsam limits at a minimum of **40 MB**.
- Supports `libWatusiTools.dylib`, `libWatusiToolsSL.dylib`, and compatible WatusiTools image-name variants.
- Includes a Settings page with a WhatsApp-style icon and an **Enable Patch** switch.

The runtime patch is the same guarded signature-based fix proven in WatusiServiceDiag 1.8.0. It is only applied when the expected unique ARM64 worker shape is found.

This clean package contains no trace dylib, observer daemon, report/status/collector tools or diagnostic file logging.

The Settings switch controls the Watusi exit patch. A change takes effect the next time WhatsApp's ServiceExtension starts. The 40 MB memory floor remains active.
