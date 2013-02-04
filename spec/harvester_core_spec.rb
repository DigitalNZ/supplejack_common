require "spec_helper"

describe HarvesterCore do
  
  describe ".redis" do
    let(:connection) { mock(:redis) }

    before(:each) do
      HarvesterCore.instance_variable_set("@redis", nil)
    end

    it "initializes a redis client" do
      Redis.should_receive(:new) { connection }
      HarvesterCore.redis.should eq connection
    end

    it "memoizes the redis connection" do
      Redis.should_receive(:new).once { connection }
      HarvesterCore.redis
      HarvesterCore.redis
    end
  end
end