# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

require "supplejack_common/oai/base"
require "supplejack_common/oai/paginated_collection"
require "supplejack_common/oai/client/record"

Dir[File.dirname(__FILE__) + '/oai/*.rb'].each {|file| require file }