# Spectrum

FreeBSD Copyright (c) 2012 Rubyworks

[Homepage](http://rubyworks.github.com/spectrum) /
[Report Issue](http://github.com/rubyworks/spectrum/issues) /
[Source Code](http://github.com/rubyworks/spectrum)

[![Build Status](https://secure.travis-ci.org/rubyworks/spectrum.png)](http://travis-ci.org/rubyworks/spectrum)


## Description

Spectrum is an RSpec-style BDD framework that runs on top of the [Ruby Test](http://rubyworks.github.com/rubytest),
the Ruby universal test harness. It supports all of RSpec's syntax, with a
few exceptions.


## Instruction

### Writing Specifications

Specifications are written as block of `describe` and `it` definitions.

Here's RSpec classic example:

    describe Order do
      it "sums the prices of its line items" do
        order = Order.new
        order.add_entry(LineItem.new(:item => Item.new(
          :price => Money.new(1.11, :USD)
        )))
        order.add_entry(LineItem.new(:item => Item.new(
          :price => Money.new(2.22, :USD),
          :quantity => 2
        )))
        order.total.should eq(Money.new(5.55, :USD))
      end
    end

Spectrum only handle the specification structure, it does not provide an
assertions system. For that use any of a number of available libraries,
such [Assay-RSpec](http://rubyworks.github.com/assay-rspec) or [AE](http://rubyworks.github.com/ae).
You can require these in a helper script, or in Ruby Test configuration (see below).

### Running Specifications

Running specification is done with the `rubytest` command line utility.

    $ rubytest -Ilib -rae/should spec/*_spec.rb

To make things simpler, create a `.test` configuration file.

    require 'ae/should'

    Test.run :default do |run|
      run.files << 'spec/*_spec.rb'
    end

Then simply use:

    $ rubytest


## Copyrights

Copyright (c) 2012 Rubyworks

Spectrum is distributable according to the terms of the FreeBSD license.

See COPYING.rdoc for details.

