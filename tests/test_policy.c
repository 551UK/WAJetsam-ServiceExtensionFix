#include "../policy.h"

#include <assert.h>
#include <limits.h>
#include <stdio.h>

int main(void) {
    assert(wsd_clamp_positive_limit(24) == 40);
    assert(wsd_clamp_positive_limit(39) == 40);
    assert(wsd_clamp_positive_limit(40) == 40);
    assert(wsd_clamp_positive_limit(64) == 64);
    assert(wsd_clamp_positive_limit(-1) == -1);
    assert(wsd_clamp_positive_limit(0) == 0);
    assert(wsd_clamp_positive_limit(INT32_MAX) == INT32_MAX);
    assert(wsd_clamp_flags_limit(24) == 40);
    assert(wsd_clamp_flags_limit(40) == 40);
    assert(wsd_clamp_flags_limit(UINT32_MAX) == UINT32_MAX);
    assert(wsd_is_whatsapp_service_path("/private/var/containers/Bundle/Application/ID/WhatsApp.app/PlugIns/ServiceExtension.appex/ServiceExtension"));
    assert(!wsd_is_whatsapp_service_path("/var/WhatsApp.app/WhatsApp"));
    assert(!wsd_is_whatsapp_service_path("/usr/libexec/accessoryupdaterd"));
    assert(!wsd_is_whatsapp_service_path(NULL));
    puts("40 MB limit and ServiceExtension targeting checks passed.");
    return 0;
}
