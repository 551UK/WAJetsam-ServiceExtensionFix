# WAJetsam&ServiceExtensionFIx

Minimal WhatsApp ServiceExtension fix for iOS 16 / Dopamine rootless. Made by 551.

## What it does

- Prevents the WatusiTools `checkExpiryDate` worker from deliberately terminating WhatsApp's `ServiceExtension`.
- Keeps positive WhatsApp ServiceExtension Jetsam limits at a minimum of **40 MB**.
- Supports `libWatusiTools.dylib`, `libWatusiToolsSL.dylib`, and compatible WatusiTools image-name variants.
- Includes a Settings page with a WhatsApp-style icon and an **Enable Patch** switch.

The signature patch is the proven guarded runtime patch from WatusiServiceDiag 1.8.0. It is applied only when the expected unique ARM64 worker shape is found.

The Settings switch controls the Watusi exit patch. A change takes effect the next time WhatsApp's ServiceExtension starts. The 40 MB memory floor remains active.

-------------------------------------------------
How this fix came about 
---------------------------------------------------

I’ve been debugging an issue where WhatsApp messages sometimes stay on one tick until another message is sent. It appears to be caused by WatusiTools terminating WhatsApp’s ServiceExtension process.

At first I suspected jetsam because the ServiceExtension often disappeared when memory usage was around 24 MB. I raised the real phys_footprint limit to 40 MB and confirmed through the kernel ledger that the higher limit was actually applied, but the ServiceExtension still terminated.

I then added tracing inside net.whatsapp.WhatsApp.ServiceExtension and captured the failure directly.

During one of the one-tick events, the ServiceExtension exited normally with:

_exit(0)

It was not a crash or jetsam kill. At the time it was only using around 23.7 MB with a verified 40MB memory limit.

The caller stack pointed into libWatusiTools.dylib, in code associated with the exported checkExpiryDate function.

On the WatusiTools build I tested, UUID:

568A2EDE-23FF-307E-91FB-XXXXXXXXXXXX

the failing worker contained two matching termination sites:

0xE3F80
0xE4120

Both had the ARM64 pattern:

mov w0, #0
blr x19

During the actual failure, the function pointer in x19 resolved to _exit, so the ServiceExtension was effectively doing:

_exit(0);

After that, the ServiceExtension stayed dead until WhatsApp/iOS relaunched it. This matches the behaviour where the first message remains on one tick and sending another message causes the ServiceExtension to relaunch and both messages then deliver.

I fixed it by patching only those termination calls inside the ServiceExtension.

Rather than making _exit() return globally, which could be unsafe because _exit is a noreturn function, I redirect the termination calls to the worker’s existing normal ARM64 cleanup/return epilogue.

On my build that epilogue was at:

0xE4620

So effectively:

0xE3F80 -> normal return
0xE4120 -> normal return

The rest of checkExpiryDate continues to execute normally; only the part that deliberately terminates the ServiceExtension is skipped.

I later generalized the fix so it no longer depends on my WatusiTools UUID or hard-coded offsets. It now:

resolves checkExpiryDate from libWatusiTools.dylib/libWatusiToolsSL.dylib
finds the executable __TEXT,__text region
searches around checkExpiryDate for the matching mov w0,#0; blr x19 termination pair
verifies the surrounding code structure
finds the matching normal return epilogue
redirects the two termination calls to that epilogue
refuses to patch anything if the signature is ambiguous or different

The patch is only loaded inside net.whatsapp.WhatsApp.ServiceExtension. It does not patch the main WhatsApp process and does not globally hook _exit.

Since applying this fix, the one-tick issue appears to have stopped on my device.

So the underlying issue appears to be that WatusiTools’ checkExpiryDate-related worker is intentionally terminating WhatsApp’s ServiceExtension with _exit(0), which interrupts background message processing until the extension is launched again.
