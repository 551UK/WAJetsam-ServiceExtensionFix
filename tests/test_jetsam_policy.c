#include "../WAJetsamPolicy.h"

#include <assert.h>
#include <limits.h>
#include <stdio.h>

int main(void) {
    assert(waj_clamp_positive_limit(24) == 40);
    assert(waj_clamp_positive_limit(39) == 40);
    assert(waj_clamp_positive_limit(40) == 40);
    assert(waj_clamp_positive_limit(64) == 64);
    assert(waj_clamp_positive_limit(-1) == -1);
    assert(waj_clamp_positive_limit(0) == 0);
    assert(waj_clamp_positive_limit(INT32_MAX) == INT32_MAX);
    assert(waj_clamp_flags_limit(24) == 40);
    assert(waj_clamp_flags_limit(40) == 40);
    assert(waj_clamp_flags_limit(UINT32_MAX) == UINT32_MAX);
    assert(waj_is_whatsapp_service_path("/private/var/containers/Bundle/Application/ID/WhatsApp.app/PlugIns/ServiceExtension.appex/ServiceExtension"));
    assert(!waj_is_whatsapp_service_path("/var/WhatsApp.app/WhatsApp"));
    assert(!waj_is_whatsapp_service_path("/usr/libexec/accessoryupdaterd"));
    assert(waj_is_whatsapp_service_path("/private/var/containers/Bundle/Application/ID/WhatsApp Business.app/PlugIns/ServiceExtension.appex/ServiceExtension"));
    assert(!waj_is_whatsapp_service_path("/private/var/containers/Bundle/Application/ID/WhatsApp Business.app/WhatsApp"));
    assert(!waj_is_whatsapp_service_path("/private/var/containers/Bundle/Application/ID/WhatsApp Business.app/PlugIns/NotificationExtension.appex/NotificationExtension"));
    assert(!waj_is_whatsapp_service_path("/private/var/containers/Bundle/Application/ID/WhatsApp Business.app/PlugIns/ServiceExtension.appex/ServiceExtensionOther"));
    assert(waj_is_whatsapp_service_path("/private/var/containers/Bundle/Application/ID/WhatsAppBusiness.app/PlugIns/ServiceExtension.appex/ServiceExtension"));
    assert(!waj_is_whatsapp_service_path("/private/var/containers/Bundle/Application/ID/WhatsAppBusiness.app/WhatsApp"));
    assert(!waj_is_whatsapp_service_path("/private/var/containers/Bundle/Application/ID/WhatsAppBusiness.app/PlugIns/NotificationExtension.appex/NotificationExtension"));
    assert(!waj_is_whatsapp_service_path("/private/var/containers/Bundle/Application/ID/WhatsAppBusiness.app/PlugIns/ServiceExtension.appex/ServiceExtensionOther"));
    assert(!waj_is_whatsapp_service_path("/var/Unrelated.app/PlugIns/ServiceExtension.appex/ServiceExtension"));
    assert(!waj_is_whatsapp_service_path(NULL));
    puts("40 MB limit and ServiceExtension targeting checks passed.");
    return 0;
}
