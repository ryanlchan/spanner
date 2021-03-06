require 'spec_helper'

describe Spanner do
  
  it "should return nil for empty strings & nil" do
    Spanner.parse('').should be_nil
    Spanner.parse(nil).should be_nil
  end

  it "should assume seconds" do
    Spanner.parse('1').should == 1
    Spanner.parse(1).should == 1
  end

  #simple
  { '.5s' => 0.5, '1s' => 1, '1.5s' => 1.5, '1m' => 60, '1.5m' => 90, '1d' => 86400, '1.7233312d' => 148895.81568, '1M' => Spanner.days_in_month(Time.new.year, Time.new.month) * 24 * 60 * 60 }.each do |input, output|
    it "should parse #{input} and return #{output}" do
      Spanner.parse(input).should == output
    end
  end

  #complex
  { '1m23s' => 83, '3h20min' => 3600*3+20*60 }.each do |input, output|
    it "should parse #{input} and return #{output}" do
      Spanner.parse(input).should == output
    end
  end
  
  #singular
  { '1 day' => 3600*24, '5 day' => 3600*24*5, '1 hour' => 3600 }.each do |input, output|
    it "should parse #{input} and return #{output}" do
      Spanner.parse(input).should == output
    end
  end
  
  it "should let you set the length of a month" do
    Spanner.parse("4 months", :length_of_month => 1234).should == 4936
  end
  
  it "should accept time as from option" do
    now = Time.new
    Spanner.parse('23s', :from => now).should == now.to_i + 23
  end

  it "should accept special :now as from option" do
    Spanner.parse('23s', :from => :now).should == Time.new.to_i + 23
  end
end

describe Spanner, "format" do
  { 3600*24 => '1 day', 3600*24*5 => '5 days', 3620 => '1 hour 20 seconds',
    175814631 => '5 years 6 months 3 weeks 1 day 16 hours 20 minutes 1 second',
    nil => "", "abc" => "" }.each do |input, output|
    it "should format #{input} as #{output}" do
      Spanner.format(input).should == output
    end
  end
  
  it "should be possible to restrict the biggest unit" do
    Spanner.format(3600*24*50).should == "1 month 2 weeks 5 days"
    Spanner.format(3600*24*50, :biggest_unit => :days).should == "50 days"
  end
  
  it "should default to no restriction if invalid biggest unit is supplied" do
    Spanner.format(3600*24*14, :biggest_unit => "LALA").should == "2 weeks"
  end
end