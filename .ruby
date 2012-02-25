---
source:
- Profile
authors:
- name: Trans
  email: transfire@gmail.com
copyrights:
- holder: Rubyworks
  year: '2012'
  license: BSD-2-Clause
requirements:
- name: rubytest
- name: detroit
  groups:
  - build
  development: true
- name: reap
  groups:
  - build
  development: true
- name: ae
  groups:
  - test
  development: true
dependencies: []
alternatives: []
conflicts: []
repositories:
- uri: git://github.com/proutils/spectra.git
  scm: git
  name: upstream
resources:
  home: http://rubyworks.github.com/spectra
  code: http://github.com/rubyworks/spectra
  mail: http://groups.google.com/groups/rubyworks-mailinglist
extra: {}
load_path:
- lib
revision: 0
name: spectra
title: Spectra
version: 0.1.0
summary: RSpec-like BDD on RubyTest
created: '2012-02-22'
description: Spectra is a BDD framework built on RubyTest designed to emulate RSpec
  in most respects.
organization: RubyWorks
date: '2012-02-23'