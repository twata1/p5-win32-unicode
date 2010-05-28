#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include <windows.h>

MODULE = Win32::Unicode::Dir    PACKAGE  = Win32::Unicode::Dir

PROTOTYPES: DISABLE

SV*
get_current_directory()
    CODE:
        WCHAR cur[MAX_PATH];
        
        GetCurrentDirectoryW(sizeof(cur), cur);
        RETVAL = newSVpv(cur, wcslen(cur) * 2);
    OUTPUT:
        RETVAL

int
set_current_directory(SV* dir)
    CODE:
        STRLEN len;
        const WCHAR* chdir = SvPV_const(dir, len);
        
        RETVAL = SetCurrentDirectoryW(chdir);
    OUTPUT:
        RETVAL

int
remove_directory(SV* dir)
    CODE:
        STRLEN len;
        const WCHAR* rmdir = SvPV_const(dir, len);
        
        RETVAL = RemoveDirectoryW(rmdir);
    OUTPUT:
        RETVAL

void
find_first_file(SV* self, SV* dir)
    CODE:
        WIN32_FIND_DATAW file_info;
        STRLEN len;
        const WCHAR* opendir = SvPV_const(dir, len);
        
        HANDLE handle = FindFirstFileW(opendir, &file_info);
        
        HV* h = (HV*)SvRV(self);
        hv_stores(h, "handle", newSViv(handle));
        hv_stores(h, "first", newSVpv(file_info.cFileName, wcslen(file_info.cFileName) * 2));
        
SV*
find_next_file(SV* self)
    CODE:
        WIN32_FIND_DATAW file_info;
        
        HV* h = (HV*)SvRV(self);
        HANDLE handle = SvIV(*hv_fetchs(h, "handle", strlen("handle")));
        
        if(FindNextFileW(handle, &file_info) == 0) {
            XSRETURN_EMPTY;
        }
        
        RETVAL = newSVpv(file_info.cFileName, wcslen(file_info.cFileName) * 2);
    OUTPUT:
        RETVAL

int
find_close(SV* self)
    CODE:
        HV* h = (HV*)SvRV(self);
        HANDLE handle = SvIV(*hv_fetchs(h, "handle", strlen("handle")));
        RETVAL = FindClose(handle);
    OUTPUT:
        RETVAL
