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

module FCSParse
  
  class FCSFile
    
    MetadataExtension = ".meta.txt"
    DataExtension = ".data.csv"
    DataDelimiter = ","
    
    def self.new_from_file(filename)
      
      fcsfile = nil
      
      File.open(filename) do |f|
        fcsfile = self.new(f.read)
      end
      
      fcsfile.filename = filename
      
      fcsfile
      
    end
    
    attr_accessor :filename

    SupportedVersions = ["FCS3.0", "FCS3.1"]

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
    
    def get_metadata_string
      str = ""
      @keywords.keys.map{|e| e.to_s}.sort.each do |k|
        str << k.to_s + " => " + @keywords[k.to_sym].to_s + "\n"
      end
      str
    end
    
    def print_metadata

      puts get_metadata_string
      
    end
    
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
      
    end
    
    def parse
      read_header
      parse_text_segment
      parse_data_segment
      @data = nil
    end

  end
  
  def self.process_file(filename, data_header_row = true)
    
    fcsfile = FCSFile.new_from_file(filename)
    fcsfile.parse
    fcsfile.write_metadata_and_data(data_header_row)
    
  end 
    

end

if __FILE__ == $0 then
  
  FCSParse.process_file(ARGV[0], false)
  
end
