#ifndef WSD_POLICY_H
#define WSD_POLICY_H

#include <stdbool.h>
#include <stdint.h>
#include <string.h>

#define WSD_TARGET_LIMIT_MB 40

static inline bool wsd_is_whatsapp_service_path(const char *path) {
    if (!path) return false;

    static const char *suffixes[] = {
        "/WhatsApp.app/PlugIns/ServiceExtension.appex/ServiceExtension",
        "/WhatsApp Business.app/PlugIns/ServiceExtension.appex/ServiceExtension",
        "/WhatsAppBusiness.app/PlugIns/ServiceExtension.appex/ServiceExtension",
        "/Watusi.app/PlugIns/ServiceExtension.appex/ServiceExtension"
    };

    size_t length = strlen(path);
    for (size_t i = 0; i < sizeof(suffixes) / sizeof(suffixes[0]); i++) {
        size_t suffix_length = strlen(suffixes[i]);
        if (length >= suffix_length &&
            strcmp(path + length - suffix_length, suffixes[i]) == 0) {
            return true;
        }
    }

    return false;
}

static inline int32_t wsd_clamp_positive_limit(int32_t value) {
    return value > 0 && value < WSD_TARGET_LIMIT_MB ? WSD_TARGET_LIMIT_MB : value;
}

static inline uint32_t wsd_clamp_flags_limit(uint32_t value) {
    return value > 0 && value < WSD_TARGET_LIMIT_MB ? WSD_TARGET_LIMIT_MB : value;
}

#endif
