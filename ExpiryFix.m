// WAJetsam&ServiceExtensionFIx 1.8.0 patch component. Made by 551.
// Same guarded WatusiTools checkExpiryDate patch used by the proven clean build.
// Diagnostic logging is intentionally omitted.

#import <Foundation/Foundation.h>
#import <substrate.h>

#include <dlfcn.h>
#include <mach-o/dyld.h>
#include <mach-o/loader.h>
#include <stdatomic.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#define WEF_SCAN_BEFORE          ((uintptr_t)0x00004000)
#define WEF_SCAN_AFTER           ((uintptr_t)0x00030000)
#define WEF_MAX_CALLS            32
#define WEF_MAX_CLUSTER_DISTANCE ((uintptr_t)0x00001000)

#define WEF_ARM64_MOV_W0_0       ((uint32_t)0x52800000)
#define WEF_ARM64_BLR_X19        ((uint32_t)0xd63f0260)
#define WEF_ARM64_LDP_FP_LR      ((uint32_t)0xa9417bfd)
#define WEF_ARM64_LDP_X20_X19    ((uint32_t)0xa8c24ff4)
#define WEF_ARM64_RET            ((uint32_t)0xd65f03c0)

#define WEF_PREFS_DOMAIN CFSTR("com.551.wajetsamserviceextensionfix")
#define WEF_PREF_ENABLED CFSTR("Enabled")

static atomic_bool wef_installed;
static atomic_bool wef_refused;

typedef struct {
    uintptr_t call1;
    uintptr_t call2;
    uintptr_t epilogue;
} wef_signature_match;

static bool wef_patch_enabled(void) {
    CFPreferencesAppSynchronize(WEF_PREFS_DOMAIN);
    CFPropertyListRef value = CFPreferencesCopyAppValue(WEF_PREF_ENABLED, WEF_PREFS_DOMAIN);
    if (!value) return true;

    bool enabled = true;
    if (CFGetTypeID(value) == CFBooleanGetTypeID()) {
        enabled = CFBooleanGetValue((CFBooleanRef)value);
    } else if (CFGetTypeID(value) == CFNumberGetTypeID()) {
        int number = 1;
        if (CFNumberGetValue((CFNumberRef)value, kCFNumberIntType, &number)) {
            enabled = number != 0;
        }
    }

    CFRelease(value);
    return enabled;
}

static const char *wef_basename(const char *path) {
    if (!path) return NULL;
    const char *slash = strrchr(path, '/');
    return slash ? slash + 1 : path;
}

static bool wef_is_watusi_tools_image_name(const char *name) {
    if (!name) return false;

    static const char prefix[] = "libWatusiTools";
    static const char suffix[] = ".dylib";
    const size_t prefix_len = sizeof(prefix) - 1;
    const size_t suffix_len = sizeof(suffix) - 1;
    const size_t name_len = strlen(name);

    if (name_len < prefix_len + suffix_len) return false;
    if (strncmp(name, prefix, prefix_len) != 0) return false;
    return strcmp(name + name_len - suffix_len, suffix) == 0;
}

static bool wef_is_service_extension(void) {
    char path[4096] = {0};
    uint32_t size = sizeof(path);
    if (_NSGetExecutablePath(path, &size) != 0) return false;
    return strstr(path, "/WhatsApp.app/PlugIns/ServiceExtension.appex/ServiceExtension") != NULL;
}

static bool wef_text_bounds(const void *base, uintptr_t *out_start, uintptr_t *out_end) {
    if (!base || !out_start || !out_end) return false;

    const struct mach_header_64 *header = (const struct mach_header_64 *)base;
    if (header->magic != MH_MAGIC_64 || header->sizeofcmds > 1024 * 1024) return false;

    const uint8_t *cursor = (const uint8_t *)(header + 1);
    const uint8_t *end = cursor + header->sizeofcmds;
    const struct segment_command_64 *text_segment = NULL;
    const struct section_64 *text_section = NULL;

    for (uint32_t i = 0;
         i < header->ncmds && cursor + sizeof(struct load_command) <= end;
         i++) {
        const struct load_command *command = (const struct load_command *)cursor;
        if (command->cmdsize < sizeof(*command) ||
            command->cmdsize > (size_t)(end - cursor)) {
            return false;
        }

        if (command->cmd == LC_SEGMENT_64 &&
            command->cmdsize >= sizeof(struct segment_command_64)) {
            const struct segment_command_64 *segment =
                (const struct segment_command_64 *)cursor;
            size_t sections_bytes =
                (size_t)segment->nsects * sizeof(struct section_64);

            if (sections_bytes <= command->cmdsize - sizeof(*segment) &&
                strncmp(segment->segname, "__TEXT", sizeof(segment->segname)) == 0) {
                const struct section_64 *sections =
                    (const struct section_64 *)(segment + 1);

                for (uint32_t s = 0; s < segment->nsects; s++) {
                    if (strncmp(sections[s].sectname, "__text",
                                sizeof(sections[s].sectname)) == 0 &&
                        strncmp(sections[s].segname, "__TEXT",
                                sizeof(sections[s].segname)) == 0) {
                        text_segment = segment;
                        text_section = &sections[s];
                        break;
                    }
                }
            }
        }

        if (text_segment && text_section) break;
        cursor += command->cmdsize;
    }

    if (!text_segment || !text_section || text_section->size < 16) return false;

    uintptr_t slide = (uintptr_t)base - (uintptr_t)text_segment->vmaddr;
    uintptr_t start = slide + (uintptr_t)text_section->addr;
    uintptr_t finish = start + (uintptr_t)text_section->size;
    if (finish <= start) return false;

    *out_start = start;
    *out_end = finish;
    return true;
}

static uint32_t wef_read32(uintptr_t address) {
    uint32_t value = 0;
    memcpy(&value, (const void *)address, sizeof(value));
    return value;
}

static bool wef_is_return_epilogue(uintptr_t address, uintptr_t text_end) {
    if (address > text_end || text_end - address < 12) return false;

    return wef_read32(address) == WEF_ARM64_LDP_FP_LR &&
           wef_read32(address + 4) == WEF_ARM64_LDP_X20_X19 &&
           wef_read32(address + 8) == WEF_ARM64_RET;
}

static bool wef_find_signature(uintptr_t symbol_addr,
                               uintptr_t text_start,
                               uintptr_t text_end,
                               wef_signature_match *out_match,
                               size_t *out_call_count,
                               size_t *out_cluster_count) {
    if (!out_match || symbol_addr < text_start || symbol_addr >= text_end) return false;

    uintptr_t scan_start =
        symbol_addr > WEF_SCAN_BEFORE ? symbol_addr - WEF_SCAN_BEFORE : text_start;
    if (scan_start < text_start) scan_start = text_start;
    scan_start &= ~(uintptr_t)3;

    uintptr_t scan_end = text_end;
    if (symbol_addr <= UINTPTR_MAX - WEF_SCAN_AFTER) {
        uintptr_t wanted = symbol_addr + WEF_SCAN_AFTER;
        if (wanted < scan_end) scan_end = wanted;
    }
    scan_end &= ~(uintptr_t)3;

    uintptr_t calls[WEF_MAX_CALLS] = {0};
    size_t call_count = 0;

    for (uintptr_t pc = scan_start + 4; pc + 4 <= scan_end; pc += 4) {
        if (wef_read32(pc - 4) == WEF_ARM64_MOV_W0_0 &&
            wef_read32(pc) == WEF_ARM64_BLR_X19) {
            if (call_count >= WEF_MAX_CALLS) {
                if (out_call_count) *out_call_count = call_count + 1;
                if (out_cluster_count) *out_cluster_count = 0;
                return false;
            }
            calls[call_count++] = pc;
        }
    }

    size_t cluster_count = 0;
    wef_signature_match selected = {0};

    for (size_t i = 0; i < call_count; i++) {
        for (size_t j = i + 1; j < call_count; j++) {
            uintptr_t call1 = calls[i];
            uintptr_t call2 = calls[j];

            if (call2 <= call1 ||
                call2 - call1 > WEF_MAX_CLUSTER_DISTANCE) {
                break;
            }

            size_t epilogue_count = 0;
            uintptr_t epilogue = 0;

            for (uintptr_t pc = call1 + 4; pc + 12 <= call2; pc += 4) {
                if (wef_is_return_epilogue(pc, text_end)) {
                    epilogue_count++;
                    epilogue = pc;
                    if (epilogue_count > 1) break;
                }
            }

            if (epilogue_count == 1) {
                cluster_count++;
                selected.call1 = call1;
                selected.call2 = call2;
                selected.epilogue = epilogue;
            }
        }
    }

    if (out_call_count) *out_call_count = call_count;
    if (out_cluster_count) *out_cluster_count = cluster_count;
    if (cluster_count != 1) return false;

    *out_match = selected;
    return true;
}

static uint32_t wef_make_b(uintptr_t from, uintptr_t to, bool *ok) {
    intptr_t delta = (intptr_t)to - (intptr_t)from;
    if ((delta & 3) != 0) {
        *ok = false;
        return 0;
    }

    intptr_t words = delta >> 2;
    if (words < -(1 << 25) || words >= (1 << 25)) {
        *ok = false;
        return 0;
    }

    *ok = true;
    return 0x14000000u | ((uint32_t)words & 0x03ffffffu);
}

static bool wef_try_install(void) {
    if (atomic_load(&wef_installed)) return true;
    if (atomic_load(&wef_refused)) return false;

    void *symbol = dlsym(RTLD_DEFAULT, "checkExpiryDate");
    if (!symbol) return false;

    Dl_info image = {0};
    if (dladdr(symbol, &image) == 0 || !image.dli_fname || !image.dli_fbase) {
        atomic_store(&wef_refused, true);
        return false;
    }

    const char *image_name = wef_basename(image.dli_fname);
    if (!wef_is_watusi_tools_image_name(image_name)) {
        atomic_store(&wef_refused, true);
        return false;
    }

    uintptr_t text_start = 0;
    uintptr_t text_end = 0;
    if (!wef_text_bounds(image.dli_fbase, &text_start, &text_end)) {
        atomic_store(&wef_refused, true);
        return false;
    }

    uintptr_t symbol_addr = (uintptr_t)symbol;
    wef_signature_match match = {0};
    size_t call_count = 0;
    size_t cluster_count = 0;

    if (!wef_find_signature(symbol_addr,
                            text_start,
                            text_end,
                            &match,
                            &call_count,
                            &cluster_count)) {
        atomic_store(&wef_refused, true);
        return false;
    }

    bool ok1 = false;
    bool ok2 = false;
    uint32_t branch1 = wef_make_b(match.call1, match.epilogue, &ok1);
    uint32_t branch2 = wef_make_b(match.call2, match.epilogue, &ok2);

    if (!ok1 || !ok2) {
        atomic_store(&wef_refused, true);
        return false;
    }

    MSHookMemory((void *)match.call1, &branch1, sizeof(branch1));
    MSHookMemory((void *)match.call2, &branch2, sizeof(branch2));

    uint32_t actual1 = wef_read32(match.call1);
    uint32_t actual2 = wef_read32(match.call2);
    bool installed = actual1 == branch1 && actual2 == branch2;

    if (!installed) {
        uint32_t original = WEF_ARM64_BLR_X19;
        if (actual1 == branch1) {
            MSHookMemory((void *)match.call1, &original, sizeof(original));
        }
        if (actual2 == branch2) {
            MSHookMemory((void *)match.call2, &original, sizeof(original));
        }
    }

    atomic_store(&wef_installed, installed);
    if (!installed) atomic_store(&wef_refused, true);
    return installed;
}

static void wef_image_added(const struct mach_header *mh, intptr_t slide) {
    (void)mh;
    (void)slide;

    if (!atomic_load(&wef_installed) &&
        !atomic_load(&wef_refused)) {
        (void)wef_try_install();
    }
}

__attribute__((constructor)) static void wef_start(void) {
    if (!wef_is_service_extension()) return;
    if (!wef_patch_enabled()) return;

    atomic_init(&wef_installed, false);
    atomic_init(&wef_refused, false);

    (void)wef_try_install();

    if (!atomic_load(&wef_installed) &&
        !atomic_load(&wef_refused)) {
        _dyld_register_func_for_add_image(wef_image_added);
    }
}
