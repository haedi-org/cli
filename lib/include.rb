require 'rubygems'
require 'bundler'
Bundler.setup(:default, :ci)

require 'csv'
require 'json'
require 'time'
require 'io/wait'

require 'colorize'

#require_relative './test.rb'

require_relative './datatypes.rb'
require_relative './paths.rb'
require_relative './errors.rb'
require_relative './html.rb'
require_relative './reference.rb'
require_relative './curator.rb'
require_relative './dictionary.rb'

require_relative './document/document.rb'
require_relative './document/element.rb'
require_relative './document/composite.rb'
require_relative './document/punctuation.rb'
require_relative './document/date.rb'
require_relative './document/tag.rb'
require_relative './document/segment.rb'

require_relative './segments/una.rb'
require_relative './segments/unh.rb'
require_relative './segments/dtm.rb'

require_relative './document/segment_map.rb'