Pry.editor = "subl"

require "rubygems"
require "bundler/setup"

require 'supplejack_common'

def reload!
  files_names = Dir.glob("lib/**/*.rb")
  files_names.delete("lib/supplejack_common/version.rb")
  files_names.each do |name|
    eval(File.read(name))
  end
  return true
end