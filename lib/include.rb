require 'rubygems'

unless ENV['OCRA_EXECUTABLE']
    require 'bundler'
    Bundler.setup(:default, :ci)
end

require 'csv'
require 'json'
require 'time'
require 'io/wait'

require 'colorize'

#require_relative './test.rb'

require_relative './generics.rb'
require_relative './paths.rb'
require_relative './errors.rb'
require_relative './dictionary.rb'
require_relative './debug.rb'
require_relative './history.rb'

require_relative './html/html.rb'
require_relative './html/bayplan.rb'

require_relative './routines/routines.rb'
require_relative './routines/collection.rb'
require_relative './routines/info.rb'
require_relative './routines/parse.rb'
require_relative './routines/structure.rb'
require_relative './routines/timeline.rb'

require_relative './datatypes/datatypes.rb'
require_relative './datatypes/iso_6346.rb'

require_relative './edifact/date.rb'
require_relative './edifact/interchange.rb'
require_relative './edifact/message.rb'
require_relative './edifact/message_factory.rb'
require_relative './edifact/segment_factory.rb'
require_relative './edifact/rule.rb'
require_relative './edifact/document.rb'
require_relative './edifact/element.rb'
require_relative './edifact/composite.rb'
require_relative './edifact/punctuation.rb'
require_relative './edifact/tag.rb'
require_relative './edifact/segment.rb'
require_relative './edifact/group.rb'
require_relative './edifact/group_factory.rb'
require_relative './edifact/curator.rb'
require_relative './edifact/morph.rb'

require_relative './edifact/segments/uci.rb'
require_relative './edifact/segments/ucm.rb'
require_relative './edifact/segments/ucs.rb'
require_relative './edifact/segments/una.rb'
require_relative './edifact/segments/unb.rb'
require_relative './edifact/segments/unh.rb'
require_relative './edifact/segments/unt.rb'

require_relative './edifact/segments/ali.rb'
require_relative './edifact/segments/cps.rb'
require_relative './edifact/segments/doc.rb'
require_relative './edifact/segments/dtm.rb'
require_relative './edifact/segments/eqd.rb'
require_relative './edifact/segments/erc.rb'
require_relative './edifact/segments/ftx.rb'
require_relative './edifact/segments/gid.rb'
require_relative './edifact/segments/gin.rb'
require_relative './edifact/segments/imd.rb'
require_relative './edifact/segments/lin.rb'
require_relative './edifact/segments/loc.rb'
require_relative './edifact/segments/mea.rb'
require_relative './edifact/segments/nad.rb'
require_relative './edifact/segments/pac.rb'
require_relative './edifact/segments/pai.rb'
require_relative './edifact/segments/pci.rb'
require_relative './edifact/segments/pia.rb'
require_relative './edifact/segments/qty.rb'
require_relative './edifact/segments/rff.rb'
# UNICORN
require_relative './edifact/segments/mcr.rb'
require_relative './edifact/segments/rdq.rb'

require_relative './edifact/messages/aperak.rb'
require_relative './edifact/messages/baplie.rb'
require_relative './edifact/messages/contrl.rb'
require_relative './edifact/messages/desadv.rb'

require_relative './edifact/associations.rb'

require_relative './edifact/segment_map.rb'
require_relative './edifact/message_map.rb'

require_relative './forms/form.rb'

require_relative './cli.rb' unless WITHOUT_CLI