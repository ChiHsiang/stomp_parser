#!/usr/bin/env ruby

require "mkmf"

$CFLAGS << " -O3"

should_build = true
should_build &&= have_header "ruby.h"
should_build &&= defined?(RUBY_ENGINE) && %w[ruby rbx].include?(RUBY_ENGINE)

if should_build
  create_makefile("stomp_parser/stomp/c_parser")
else
  dummy_makefile(".")
end
