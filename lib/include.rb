require 'rubygems'
require 'bundler'
Bundler.setup(:default, :ci)

require 'csv'
require 'json'
require 'time'

require './lib/paths.rb'
require './lib/test.rb'
require './lib/html.rb'
require './lib/reference.rb'

require './lib/document/document.rb'
require './lib/document/structure.rb'
require './lib/document/punctuation.rb'
require './lib/document/date.rb'
require './lib/document/line.rb'

require './lib/segments/una.rb'
require './lib/segments/unh.rb'
require './lib/segments/unb.rb'
require './lib/segments/uns.rb'
require './lib/segments/unt.rb'
require './lib/segments/unz.rb'
require './lib/segments/bgm.rb'
require './lib/segments/ali.rb'
require './lib/segments/dtm.rb'
require './lib/segments/ftx.rb'
require './lib/segments/rff.rb'
require './lib/segments/nad.rb'
require './lib/segments/tax.rb'
require './lib/segments/lin.rb'
require './lib/segments/pac.rb'
require './lib/segments/qty.rb'
require './lib/segments/imd.rb'
require './lib/segments/pia.rb'
require './lib/segments/mea.rb'
require './lib/segments/pri.rb'
require './lib/segments/gin.rb'
require './lib/segments/cps.rb'
require './lib/segments/pci.rb'
require './lib/segments/loc.rb'
require './lib/segments/inv.rb'
require './lib/segments/cdi.rb'
require './lib/segments/cnt.rb'
require './lib/segments/moa.rb'

require './lib/cli.rb'