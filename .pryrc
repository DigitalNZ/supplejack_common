Pry.editor = "subl"

require "rubygems"
require "bundler/setup"

require 'dnz_harvester'

def reload!
  files_names = Dir.glob("lib/**/*.rb")
  files_names.delete("lib/dnz_harvester/version.rb")
  files_names.each do |name|
    eval(File.read(name))
  end
  return true
end