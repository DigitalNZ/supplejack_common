Pry.editor = "subl"

require "rubygems"
require "bundler/setup"

require 'harvester_core'

def reload!
  files_names = Dir.glob("lib/**/*.rb")
  files_names.delete("lib/harvester_core/version.rb")
  files_names.each do |name|
    eval(File.read(name))
  end
  return true
end