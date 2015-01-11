%module libxml2

%{
  #include <libxml2/libxml/tree.h>
  #include <stdio.h>
%}

%include </usr/include/libxml2/libxml/xmlexports.h>
%include </usr/include/libxml2/libxml/xmlversion.h>
%include </usr/include/libxml2/libxml/tree.h>
