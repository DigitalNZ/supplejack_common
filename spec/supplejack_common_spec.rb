# The Supplejack Common code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. 
# See https://github.com/DigitalNZ/supplejack for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack 

require "spec_helper"

describe SupplejackCommon do
  
  describe ".redis" do
    let(:connection) { mock(:redis) }

    before(:each) do
      SupplejackCommon.instance_variable_set("@redis", nil)
    end

    it "initializes a redis client" do
      Redis.should_receive(:new) { connection }
      SupplejackCommon.redis.should eq connection
    end

    it "memoizes the redis connection" do
      Redis.should_receive(:new).once { connection }
      SupplejackCommon.redis
      SupplejackCommon.redis
    end
  end
end