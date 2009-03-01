$:.push File.join(File.dirname(__FILE__), '..', 'lib')
require 'activekv'

RACK_ENV = :test unless defined? RACK_ENV

describe "ActiveKV::Base" do
  before do
    ActiveKV::Base.unconfigure!
  end
  
  it "should be inheritable" do
    class InheritanceTest < ActiveKV::Base
    end
  end

  it "should allow a configuration file to be provided" do
    ActiveKV::Base.configure File.join(File.dirname(__FILE__), 'simple-config.yml')
  end
  
  it "should fail to save an object if not configured" do
    class Unconfigured < ActiveKV::Base
    end
    
    u = Unconfigured.new
    begin
      u.save!
      raise "Should not have allowed an instance to be saved when not configured"
    rescue ActiveKV::NotConfiguredError
    end
  end
end

describe "ActiveKV::Base when configured" do
  before do
    ActiveKV::Base.unconfigure!
    ActiveKV::Base.configure File.join(File.dirname(__FILE__), 'simple-config.yml')
  end
  
  it "should fail to save an object if no key is specified" do
    class NoKey < ActiveKV::Base
    end

    u = NoKey.new
    begin
      u.save!
      raise "Should not have allowed an instance to be saved when it does not specify a key"
    rescue ActiveKV::NoKeySpecifiedError
    end
  end

  it "should fail to save an object if key is nil" do
    class WithKey < ActiveKV::Base
      key :name
    end

    u = WithKey.new
    begin
      u.save!
      raise "Should not have allowed an instance to be saved when key value is nil"
    rescue ActiveKV::NilKeyError
    end
  end

  it "should allow an object to be saved if configured and a key is specified" do
    class WithKey < ActiveKV::Base
      key :name
    end

    u = WithKey.new
    u.name = 'TestName'
    u.save!  
  end
  
  it "should not find an object that has not been created" do
    class NotFound < ActiveKV::Base
    end
    
    NotFound.find('missing').should be_nil
  end
  
  it "should find an object that has previously been saved" do
    class Found < ActiveKV::Base
      key :name
    end
    
    f = Found.new
    f.name = 'myname'
    f.save!
    
    Found.find('myname').name.should == 'myname'
  end
end
