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
require_relative './datatypes.rb'
require_relative './paths.rb'
require_relative './errors.rb'
require_relative './reference.rb'
require_relative './curator.rb'
require_relative './dictionary.rb'
require_relative './routines.rb'
require_relative './history.rb'
require_relative './morph.rb'

require_relative './document/date.rb'
require_relative './document/interchange.rb'
require_relative './document/message.rb'
require_relative './document/message_factory.rb'
require_relative './document/segment_factory.rb'
require_relative './document/rule.rb'
require_relative './document/document.rb'
require_relative './document/element.rb'
require_relative './document/composite.rb'
require_relative './document/punctuation.rb'
require_relative './document/tag.rb'
require_relative './document/segment.rb'
require_relative './document/group.rb'
require_relative './document/group_factory.rb'

require_relative './segments/una.rb'
require_relative './segments/unb.rb'
require_relative './segments/unh.rb'
require_relative './segments/unt.rb'
require_relative './segments/doc.rb'
require_relative './segments/dtm.rb'
require_relative './segments/eqd.rb'
require_relative './segments/ftx.rb'
require_relative './segments/gid.rb'
require_relative './segments/gin.rb'
require_relative './segments/loc.rb'
require_relative './segments/mea.rb'
require_relative './segments/nad.rb'
require_relative './segments/rff.rb'
require_relative './segments/pia.rb'

require_relative './messages/baplie.rb'

require_relative './associations.rb'

require_relative './document/segment_map.rb'
require_relative './document/message_map.rb'

require_relative './html/html.rb'
require_relative './html/bayplan.rb'

require_relative './cli.rb'