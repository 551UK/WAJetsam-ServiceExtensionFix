# WAJetsam-ServiceExtensionFix

Keeps WhatsApp’s ServiceExtension stable by raising its memory limit to 40 MB and preventing Watusi’s expiry-check code from terminating the extension.

Watusi’s checkExpiryDate path can intentionally call _exit(0) inside WhatsApp’s ServiceExtension. When that happens, the extension closes cleanly and WhatsApp background message processing can stop, which can leave messages stuck on one tick until the ServiceExtension starts again.

The tweak patches only that specific expiry-worker exit path and lets the worker return normally instead of killing the ServiceExtension.

If you use Choicy, make sure WatusiExpiryFix is allowed for net.whatsapp.WhatsApp.ServiceExtension and is not blocked, otherwise the main fix will not load.

-------------------------------------------------
How this fix came about 
---------------------------------------------------

I spent quite a bit of time tracing a WhatsApp one-tick delivery issue and eventually narrowed it down to WatusiTools’ expiry-check code inside WhatsApp’s ServiceExtension.

The symptom was that a message would sometimes remain on one tick until another message was sent. When the second message was sent, the ServiceExtension would relaunch and both messages would then deliver.

At first I thought the ServiceExtension was being killed by Jetsam because it often disappeared when memory usage was around 24 MB. I raised the actual ServiceExtension memory limit and verified that the real footprint ledger had been increased, but the same problem still occurred.

That ruled out the original memory-limit theory.

I then added tracing around process termination and captured the actual failure.

The important finding was that the ServiceExtension was not crashing and was not being killed by the kernel. It was exiting normally with:

_exit(0)

The process exit was:

exit code 0
no signal
no memory kill reason
memory usage well below the raised limit

So this was a deliberate clean process termination from userspace.

The stack trace led into libWatusiTools.dylib / libWatusiToolsSL.dylib, specifically code associated with the exported symbol:

checkExpiryDate

The binary is obfuscated/stripped, so I cannot say with certainty that the entire surrounding worker is literally the source-level checkExpiryDate function, but the code is clearly associated with that symbol and the failing execution path is in that expiry-check area.

The relevant ARM64 worker contains two matching termination call sites with this pattern:

mov w0, #0
blr x19

The first instruction puts 0 into w0, which is the first integer argument register on ARM64.

During the actual failure, the function pointer in x19 resolved to _exit.

So at runtime those instructions effectively become:

_exit(0);

That immediately terminates WhatsApp’s ServiceExtension.

This explains the delivery behaviour very closely.

The sequence I observed is effectively:

Watusi expiry-check worker runs
→ it reaches the termination path
→ _exit(0) is called
→ WhatsApp ServiceExtension disappears
→ background WhatsApp processing stops
→ message remains on one tick
→ later activity causes iOS/WhatsApp to relaunch ServiceExtension
→ queued work resumes
→ messages deliver

On one captured failure, the ServiceExtension stayed gone for roughly a minute before the next trigger caused it to come back.

I initially made a build-specific patch by using the exact offsets from the WatusiTools binary I was testing.

On that build, the two relevant call sites were:

0xE3F80
0xE4120

and the worker’s normal cleanup/return epilogue was around:

0xE4620

Instead of allowing the two blr x19 instructions to call _exit, I redirect them to the worker’s normal return path.

So conceptually the original code:

mov w0, #0
blr x19

becomes:

mov w0, #0
b normal_return

The normal return block restores the saved registers/frame and returns from the worker normally.

I specifically did not hook _exit globally and make it return.

That would be unsafe because _exit is a noreturn API. Code that calls _exit is allowed to assume execution never comes back. Forcing _exit itself to return could leave the stack/register state in an unexpected condition.

Redirecting only the known Watusi expiry-worker call sites to their own legitimate cleanup path is much safer because execution exits the worker in the way its own code already expects.

After confirming that worked, I changed the patch so it was no longer tied to one WatusiTools UUID or fixed offsets.

The current patch does the following at runtime:

It only runs inside:

net.whatsapp.WhatsApp.ServiceExtension

It resolves:

checkExpiryDate

using dlsym.

It verifies that the resolved symbol belongs to a WatusiTools-family dylib.

It currently accepts names such as:

libWatusiTools.dylib
libWatusiToolsSL.dylib

and other libWatusiTools*.dylib variants.

I had to add that because another phone used libWatusiToolsSL.dylib and showed the exact same _exit(0) behaviour.

It locates the loaded Mach-O __TEXT,__text executable region.
It scans a bounded area around checkExpiryDate for the specific ARM64 pattern:

mov w0, #0
blr x19

It looks for the expected pair of those calls close together.
It then looks for the matching local normal-return epilogue between them.

The epilogue shape I am validating is:

ldp x29, x30, [sp, #0x10]
ldp x20, x19, [sp], #0x20
ret

The patch is only applied if the code shape is unique and unambiguous.

If the WatusiTools version is materially different, it refuses to patch rather than guessing.

It dynamically calculates ARM64 unconditional branch instructions from both termination sites to the discovered return epilogue.
It writes the two branch instructions with MSHookMemory and verifies the writes.

If only one write succeeds, the code attempts to restore the original instruction so it does not leave a partial patch behind.

So the important point is that I am not disabling your entire expiry mechanism and I am not globally suppressing process exits.

I am only preventing the expiry-check worker from terminating WhatsApp’s ServiceExtension.

Everything before that termination path is still allowed to run.

I also found that this is not specific to one WatusiTools build.

One phone was using:

libWatusiTools.dylib

and another was using:

libWatusiToolsSL.dylib

Both reproduced the same basic behaviour: code associated with checkExpiryDate eventually called _exit(0) from the ServiceExtension.

The exact offsets differed, which is why the final version uses signature-based discovery instead of fixed offsets.

I cannot currently tell you exactly which internal condition in the expiry logic causes that branch to be taken because the WatusiTools code is obfuscated and I have not fully reconstructed the expiry state machine.

So I do not want to claim whether it is:

a date comparison
licence state
cached state
failed validation
a timer
some anti-tamper condition
or another internal expiry condition

What I can say with confidence is:

the ServiceExtension is not being killed by Jetsam in the failures I captured
it exits with code 0
_exit(0) is called
the caller is inside WatusiTools
the execution path is associated with checkExpiryDate
preventing those two termination calls from exiting ServiceExtension stops the one-tick issue on the devices I tested

I also kept a small memory-limit adjustment because the stock ServiceExtension limit is fairly low, but the actual one-tick failure I traced was not caused by memory pressure.

The core fix is the expiry-worker patch, not the Jetsam increase.

If you want to fix it properly upstream, I think the best place to look is anywhere the checkExpiryDate worker intentionally resolves/calls an exit function when running inside WhatsApp’s ServiceExtension.

My guess is that terminating the main WhatsApp process may have been the original intended behaviour of that code, but when the same expiry logic is injected into the ServiceExtension, killing that extension interrupts WhatsApp’s background message pipeline and causes the one-tick behaviour.

A cleaner upstream fix would probably be to avoid calling _exit(0) from inside net.whatsapp.WhatsApp.ServiceExtension, or return from the expiry worker normally when the current process is the ServiceExtension.
