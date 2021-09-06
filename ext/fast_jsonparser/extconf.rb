require 'mkmf'
$CXXFLAGS += ' $(optflags) $(debugflags) -std=c++1z -Wno-register '


create_makefile 'fast_jsonparser/fast_jsonparser'