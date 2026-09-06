// WAJetsam&ServiceExtensionFIx 1.8.0
// Made by 551
// Minimal runningboardd component: keep WhatsApp ServiceExtension
// positive Jetsam limits at a minimum of 40 MB. No logging/diagnostics.

#import <Foundation/Foundation.h>
#import <substrate.h>

#include <errno.h>
#include <libproc.h>
#include <mach-o/dyld.h>
#include <stdbool.h>
#include <stdint.h>
#include <string.h>

#include "policy.h"

#define PROC_PIDPATHINFO_MAXSIZE 4096

#define MEMORYSTATUS_CMD_SET_JETSAM_HIGH_WATER_MARK 5
#define MEMORYSTATUS_CMD_SET_JETSAM_TASK_LIMIT      6
#define MEMORYSTATUS_CMD_SET_MEMLIMIT_PROPERTIES    7

typedef struct memorystatus_memlimit_properties {
    int32_t  memlimit_active;
    uint32_t memlimit_active_attr;
    int32_t  memlimit_inactive;
    uint32_t memlimit_inactive_attr;
} memorystatus_memlimit_properties_t;

extern int memorystatus_control(uint32_t command,
                                int32_t pid,
                                uint32_t flags,
                                void *buffer,
                                size_t buffersize);

static int (*orig_memorystatus_control)(uint32_t, int32_t, uint32_t, void *, size_t);

static const char *wsd_basename(const char *path) {
    if (!path) return NULL;
    const char *slash = strrchr(path, '/');
    return slash ? slash + 1 : path;
}

static bool wsd_current_executable_is(const char *name) {
    char path[PROC_PIDPATHINFO_MAXSIZE] = {0};
    uint32_t size = sizeof(path);
    if (_NSGetExecutablePath(path, &size) != 0) return false;
    const char *base = wsd_basename(path);
    return base && strcmp(base, name) == 0;
}

static bool wsd_target_pid(int32_t pid) {
    if (pid < 2) return false;
    char path[PROC_PIDPATHINFO_MAXSIZE] = {0};
    int n = proc_pidpath(pid, path, PROC_PIDPATHINFO_MAXSIZE);
    return n > 0 && wsd_is_whatsapp_service_path(path);
}

static int wsd_hooked_memorystatus_control(uint32_t command,
                                           int32_t pid,
                                           uint32_t flags,
                                           void *buffer,
                                           size_t buffersize) {
    bool set_cmd = command == MEMORYSTATUS_CMD_SET_JETSAM_HIGH_WATER_MARK ||
                   command == MEMORYSTATUS_CMD_SET_JETSAM_TASK_LIMIT ||
                   command == MEMORYSTATUS_CMD_SET_MEMLIMIT_PROPERTIES;

    if (!set_cmd || !orig_memorystatus_control) {
        return orig_memorystatus_control
            ? orig_memorystatus_control(command, pid, flags, buffer, buffersize)
            : -1;
    }

    if (command == MEMORYSTATUS_CMD_SET_MEMLIMIT_PROPERTIES &&
        (!buffer || buffersize != sizeof(memorystatus_memlimit_properties_t))) {
        return orig_memorystatus_control(command, pid, flags, buffer, buffersize);
    }

    int incoming_errno = errno;
    if (!wsd_target_pid(pid)) {
        errno = incoming_errno;
        return orig_memorystatus_control(command, pid, flags, buffer, buffersize);
    }

    uint32_t new_flags = flags;
    memorystatus_memlimit_properties_t modified;
    void *new_buffer = buffer;

    if (command == MEMORYSTATUS_CMD_SET_MEMLIMIT_PROPERTIES) {
        modified = *(memorystatus_memlimit_properties_t *)buffer;
        modified.memlimit_active = wsd_clamp_positive_limit(modified.memlimit_active);
        modified.memlimit_inactive = wsd_clamp_positive_limit(modified.memlimit_inactive);
        new_buffer = &modified;
    } else {
        new_flags = wsd_clamp_flags_limit(flags);
    }

    errno = incoming_errno;
    return orig_memorystatus_control(command, pid, new_flags, new_buffer, buffersize);
}

%ctor {
    @autoreleasepool {
        if (!wsd_current_executable_is("runningboardd")) return;

        MSHookFunction((void *)memorystatus_control,
                       (void *)wsd_hooked_memorystatus_control,
                       (void **)&orig_memorystatus_control);
    }
}
