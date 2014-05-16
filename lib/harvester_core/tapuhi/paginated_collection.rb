# The Supplejack code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack_core 

# encoding: ISO-8859-1

module HarvesterCore
  module Tapuhi
    class PaginatedCollection
      include Enumerable

      attr_reader :klass, :file_paths, :limit

      def initialize(klass, file_paths, limit=nil)
        @klass      = klass
        @file_paths = file_paths
        @limit      = limit.to_i
      end

      def each(&block)
        count = 0
        
        file_paths.each do |file_path|
          File.open(file_path, 'r:iso-8859-1') do |file|
            while not file.eof?
              run_length_bytes = klass.get_run_length_bytes
              record_length = file.read(run_length_bytes).to_i
              record_contents = file.read(record_length - run_length_bytes)

              record = klass.new(record_contents)
              record.set_attribute_values

              if record.rejected?
                next
              else
                count += 1
                yield(record)
              end
              
              break if count == limit
            end
          end
          break if count == limit
        end
      end

    end
  end
end