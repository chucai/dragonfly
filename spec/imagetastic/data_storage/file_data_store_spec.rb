require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/data_store_spec'

describe Imagetastic::DataStorage::FileDataStore do
  
  before(:each) do
    @data_store = Imagetastic::DataStorage::FileDataStore.new
    
    # Set 'now' to a date in the past
    Time.stub!(:now).and_return Time.mktime(1984,"may",4,14,28,1)
    @file_pattern_prefix_without_root = '1984/05/04/14_28_01'
    @file_pattern_prefix = "#{@data_store.root_path}/#{@file_pattern_prefix_without_root}"
  end
  
  after(:each) do
    # Clean up created files
    FileUtils.rm_rf("#{@data_store.root_path}/1984")
  end
  
  it_should_behave_like 'data_store'
  
  describe "store" do
    
    before(:each) do
      @temp_object = Imagetastic::TempObject.new('goobydoo')
    end
    
    def it_should_write_to_file(storage_path, temp_object)
      FileUtils.should_receive(:cp).with(temp_object.path, storage_path)
    end
    
    it "should store the file in a folder based on date, with default filename" do
      it_should_write_to_file("#{@file_pattern_prefix}_file", @temp_object)
      @data_store.store(@temp_object)
    end

    it "should store the file with a numbered suffix if the filename already exists" do
      FileUtils.mkdir_p(@file_pattern_prefix)
      FileUtils.touch("#{@file_pattern_prefix}_file")
      it_should_write_to_file("#{@file_pattern_prefix}_file_2", @temp_object)
      @data_store.store(@temp_object)
    end
    
    it "should store the file with an incremented number suffix if the filename already exists" do
      FileUtils.mkdir_p(@file_pattern_prefix)
      FileUtils.touch("#{@file_pattern_prefix}_file")
      FileUtils.touch("#{@file_pattern_prefix}_file_2")
      it_should_write_to_file("#{@file_pattern_prefix}_file_3", @temp_object)
      @data_store.store(@temp_object)
    end

    it "should return the filepath without the root of the stored file" do
      @data_store.store(@temp_object).should == "#{@file_pattern_prefix_without_root}_file"
    end
    
    it "should raise an error if it can't create a directory" do
      FileUtils.should_receive(:mkdir_p).and_raise(Errno::EACCES)
      lambda{ @data_store.store(@temp_object) }.should raise_error(Imagetastic::DataStorage::UnableToStore)
    end
    
    it "should raise an error if it can't create a file" do
      FileUtils.should_receive(:cp).and_raise(Errno::EACCES)
      lambda{ @data_store.store(@temp_object) }.should raise_error(Imagetastic::DataStorage::UnableToStore)
    end
    
  end
  
end