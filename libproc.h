#ifndef WAJETSAM_LIBPROC_COMPAT_H
#define WAJETSAM_LIBPROC_COMPAT_H

#include <stdint.h>
#include <sys/resource.h>

#ifdef __cplusplus
extern "C" {
#endif

int proc_pidpath(int pid, void *buffer, uint32_t buffersize);
int proc_pid_rusage(int pid, int flavor, rusage_info_t *buffer);
int proc_listallpids(void *buffer, int buffersize);

#ifdef __cplusplus
}
#endif

#endif
