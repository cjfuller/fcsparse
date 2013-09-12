#--
# /* ***** BEGIN LICENSE BLOCK *****
#  * 
#  * Copyright (c) 2012 Colin J. Fuller
#  * 
#  * Permission is hereby granted, free of charge, to any person obtaining a copy
#  * of this software and associated documentation files (the Software), to deal
#  * in the Software without restriction, including without limitation the rights
#  * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  * copies of the Software, and to permit persons to whom the Software is
#  * furnished to do so, subject to the following conditions:
#  * 
#  * The above copyright notice and this permission notice shall be included in
#  * all copies or substantial portions of the Software.
#  * 
#  * THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#  * SOFTWARE.
#  * 
#  * ***** END LICENSE BLOCK ***** */
#++

require 'fcsparse/fcsconst'
require 'fcsparse/fcsevent'

##
# Contains all classes and constants for parsing FCS v3.x formatted files.
# 
module FCSParse
  
  ##
  # A class representing an FCS-encoded file.  Has methods to parse the data,
  # manage it, and convert it to human-readable format.
  # 
  # Currently reads FCS v3.x files.  Files must have data encoded in list mode,
  # and data points must be in float or double format (this will change eventually to support
  # all formats in the specification).
  # 
  # Analysis sections of the file are ignored.
  # 
  # Data can be written to delimited text files, and metadata to plain text files,
  # or the objects containing the data can be used by other code to process
  # the data further.
  # 
  # @author Colin J. Fuller
  # 
  class FCSFile
    
    MetadataExtension = ".meta.txt"
    DataExtension = ".data.csv"
    DataDelimiter = FCSEvent::DefaultDelimiter
    SupportedVersions = ["FCS3.0", "FCS3.1"]
        
    attr_accessor :filename, :events
    
    
    ##
    # Generates a new FCSFile object from the specified file.
    # 
    # Calling this will read the entire file into memory but will not parse it.
    # 
    # @param [String] filename  the filename of the FCS-encoded file (with path as required to locate it)
    # @return [FCSFile]   a new FCSFile object initialized with the contents of the file.
    # 
    def self.new_from_file(filename)
      
      fcsfile = nil
      
      File.open(filename) do |f|
        fcsfile = self.new(f.read)
      end
      
      fcsfile.filename = filename
      
      fcsfile
      
    end
    
    ##
    # Generates a new FCSFile from the specified FCS-encoded data string.
    # 
    # @param [String] file_string   a String containing an FCS-encoded dataset.
    def initialize(file_string)
      @data = file_string
      @keywords = Hash.new
    end

    def read_header

      version_string= @data[H_VersionStart..H_VersionEnd]

      unless SupportedVersions.include?(version_string) then
        raise "Unable to read this FCS format: " + version_string
      end
      

      @version = version_string[3..5].to_f
      
      @text_offsets = Array.new
      @data_offsets = Array.new
      @analysis_offsets = Array.new
      
      @text_offsets << @data[H_TextBlockOffsetStart, H_OffsetBlockLength].to_i
      @text_offsets << @data[H_TextBlockOffsetEnd, H_OffsetBlockLength].to_i
      
      @data_offsets << @data[H_DataBlockOffsetStart, H_OffsetBlockLength].to_i
      @data_offsets << @data[H_DataBlockOffsetEnd, H_OffsetBlockLength].to_i
      
      @analysis_offsets << @data[H_AnalysisBlockOffsetStart, H_OffsetBlockLength].to_i
      @analysis_offsets << @data[H_AnalysisBlockOffsetEnd, H_OffsetBlockLength].to_i
            
    end
    
    def parse_text_segment_with_bounds(lower_bound, upper_bound)
      
      token_queue = Array.new
      
      delimiter = @data[lower_bound]
      
      token_start = lower_bound + 1
      
      (lower_bound+1).upto(upper_bound) do |i|
        
        if @data[i] == delimiter and not @data[i-1] == delimiter and not @data[i+1] == delimiter then
          
          token_queue << @data[token_start...i]
          token_start = i+1
          
        end
        
      end
      
      token_queue.each_slice(2) do |kv|
        
        @keywords[kv[0].upcase.to_sym]= kv[1]
        
      end
      
      
    
    end    
    
    def parse_text_segment
      
      parse_text_segment_with_bounds(@text_offsets[0].to_i, @text_offsets[1].to_i)
      
      suppl_text_start = @keywords[T_SupplTextStartKeyword].to_i
      suppl_text_end = @keywords[T_SupplTextEndKeyword].to_i
      
      unless suppl_text_start == 0 and suppl_text_end == 0 then
        parse_text_segment_with_bounds(suppl_text_start, suppl_text_end)
      end
      
      @data_offsets[0] = @keywords[T_DataStartKeyword].to_i
      @data_offsets[1] = @keywords[T_DataEndKeyword].to_i
      
      @analysis_offsets[0] = @keywords[T_AnalysisStartKeyword].to_i
      @analysis_offsets[1] = @keywords[T_AnalysisEndKeyword].to_i
      
      unless @keywords[T_ModeKeyword] == "L" then
        raise "Only list mode is supported for the data block."
      end
      
    end
    
    def parse_data_segment
      
      event_format = construct_event_format_string
      
      event_count = @keywords[T_EventCountKeyword].to_i
      
      bytes_per_event = ((@data_offsets[1] - @data_offsets[0] + 1)*1.0/event_count).to_i
            
      @events = Array.new
            
      0.upto(event_count -1) do |e|
        
        offset = @data_offsets[0] + bytes_per_event*e
        
        event_string = @data[offset, bytes_per_event]
        
        event = FCSEvent.new_with_data_and_format(event_string, event_format, @keywords)
        
        @events << event
                
      end
      
    end
    
    def construct_event_format_string
      
      datatype = @keywords[T_DatatypeKeyword]
      
      is_little_endian = (@keywords[T_ByteorderKeyword] == T_LittleEndianByteorder)
            
      formatchar = case datatype
      
      when 'I'
        
        nil
         
      when 'F'
        
        if is_little_endian then
          
          'e'
          
        else
          
          'g'
          
        end
        
      when 'D'
        
        if is_little_endian then
          
          'E'
          
        else
          
          'G'
          
        end
        
      when 'A'
        
        nil
        
      end
        
      unless formatchar then
        raise "Integer and string data not yet supported."
      end
            
      parameter_count = @keywords[T_ParameterCountKeyword].to_i
            
      formatchar*parameter_count
      
    end
    
    ##
    # Gets the metadata (that is all the information in the text block of the
    # fcs file) as a string, where there is one key, value pair per line, separated
    # by the characters " => "
    # 
    # @return [String]    a String containing all the metadata
    def get_metadata_string
      str = ""
      @keywords.keys.map{|e| e.to_s}.sort.each do |k|
        str << k.to_s + " => " + @keywords[k.to_sym].to_s + "\n"
      end
      str
    end
    
    ##
    # Prints the metadata string returned by {#get_metadata_string}.
    # 
    def print_metadata

      puts get_metadata_string
      
      nil
      
    end
    
    ##
    # Writes the metadata and data from the FCS-formatted file to disk in human
    # readable format.
    # 
    # The metadata is written as a text file (formatted by 
    # {#get_metadata_string}), in the same location as the input FCS file and
    # with the same name except for an extra extension specified in 
    # {FCSFile::MetadataExtension}.
    # 
    # The data, delimited by the data delimiter specified
    # as {FCSFile::DataDelimiter}, one row per event, is written to a text file
    # in the same location as the input FCS file and with the same name except
    # for an extra extension specified in {FCSFile::DataExtension}.
    # 
    # @param [Boolean] write_header_row an optional parameter specifying whether
    # the data file should have a header row with the name of each column's 
    # parameter.  Defaults to true.
    # 
    def write_metadata_and_data(write_header_row = true)
      
      meta_filename = @filename + MetadataExtension
      
      data_filename = @filename + DataExtension
      
      File.open(meta_filename, "w") do |f|
        
        f.write(get_metadata_string)
        
      end
      
      File.open(data_filename, "w") do |f|
        
        if write_header_row then
          f.puts(@events[0].names_to_s_delim(DataDelimiter))
        end
        
        @events.each do |e|
          
          f.puts(e.to_s_delim(DataDelimiter))
        
        end
        
      end
      
      nil
      
    end
    
    ##
    # Parses the raw data loaded in the FCSFile to metadata, events, and parameters.
    # 
    # Erases the raw data from the FCSFile object after parsing is complete.
    # 
    def parse
      read_header
      parse_text_segment
      parse_data_segment
      @data = nil
    end

    private :read_header, :parse_text_segment_with_bounds, :parse_text_segment, :parse_data_segment, :construct_event_format_string

  end
  
  
  ##
  # Processes a specified FCS-formatted file, and writes human-readable output
  # to disk in the format specified by {FCSFile#write_metadata_and_data}.
  # 
  # @param [String] filename  the filename of the FCS-encoded file (with path as required to locate it)
  # @param [Boolean] data_header_row an optional parameter specifying whether
  # the data file should have a header row with the name of each column's 
  # parameter.  Defaults to true.
  # 
  def self.process_file(filename, data_header_row = true)
    
    fcsfile = FCSFile.new_from_file(filename)
    fcsfile.parse
    fcsfile.write_metadata_and_data(data_header_row)
    
    nil
    
  end 
    


end

