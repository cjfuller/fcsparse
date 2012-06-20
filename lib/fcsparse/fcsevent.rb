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

##
# Contains all classes and constants for parsing FCS v3.x formatted files.
#
module FCSParse
  
  ##
  # Class representing a single parameter and its value in a single event.
  # 
  # @author Colin J. Fuller
  # 
  class FCSParam
    
    ##
    # Create a new parameter with specified information
    # 
    # @param name   the name of the parameter
    # @param description  a longer description of the parameter
    # @param value  the value of the parameter
    # @param limit  the maximum value that the parameter can take
    # 
    def initialize(name, description, value, limit)
      
      @name = name
      @description = description
      @value = value
      @limit = limit
      
    end
    
    attr_accessor :name, :description, :value, :limit
    
  end
  
  
  ##
  # Class representing a single FCS-encoded event.
  # 
  # @author Colin J. Fuller
  # 
  class FCSEvent
    
    #default delimiter for printing output
    DefaultDelimiter = ","
    
    private_class_method :new
    
    def initialize
      
      @values = Hash.new
      
    end
    
    
    ##
    # Creates a new FCSEvent from the specified information.
    # 
    # @param [String] event_data_string   the raw data corresponding to the
    #         entire event from the fcs file
    # @param [String] event_format_string a string suitable for use with String#unpack
    #         that can decode the raw data.
    # @param [Hash] parameter_info_hash   a hash containing at minimum the parameters
    #         from the text section specifying the names and ranges of the parameters
    #         keys should be the parameter names from the fcs file format converted
    #         to symbols ($ included), and values should be a string corresponding
    #         to the value of the parameter from the fcs file.
    # @return [FCSEvent] an FCSEvent that has been created by parsing the raw data.
    # 
    def self.new_with_data_and_format(event_data_string, event_format_string, parameter_info_hash)
    
      data_points = event_data_string.unpack(event_format_string)
      
      parameter_names = Hash.new
      parameter_limits = Hash.new
      
      parameter_info_hash.each_key do |k|
        
        matchobj = k.to_s.match(T_ParameterNameKeywordRegex)
        
        
        if matchobj then
          
          parameter_names[matchobj[1].to_i] = parameter_info_hash[k]
          
        end
          

        matchobj = k.to_s.match(T_ParameterRangeKeywordRegex)
        
        if matchobj then
          
          parameter_limits[matchobj[1].to_i] = parameter_info_hash[k]

        end
    
      end
      
      ordered_indices = parameter_names.keys.sort
            
      event = new      
      
      data_points.each_with_index do |e, i|
      
        param = FCSParam.new(parameter_names[ordered_indices[i]], nil, e, parameter_limits[ordered_indices[i]])
        
        event[param.name] = param
        
      end
      
      event
              
    end    
    
    ##
    # Gets a named parameter associated with the event.
    # 
    # @param [String] parameter_name  the name of the parameter to retrieve; this should be 
    #                 exactly the name specified for the parameter in the text
    #                 section of the fcs file
    # @return [FCSParam]  an FCSParam object that holds the information about the named parameter.
    # 
    def [](parameter_name)
      
      @values[parameter_name]
      
    end
    
    ##
    # Sets a named parameter associated with the event.
    # @param [String] parameter_name  the name of the parameter to retrieve; this should be 
    #                 exactly the name specified for the parameter in the text
    #                 section of the fcs file
    # @param [FCSParam] value   an FCSParam object that holds the information about the named parameter.
    # 
    def []=(parameter_name, value)
      
      @values[parameter_name]= value
      
    end
    
    ##
    # Gets the names of the parameters associated with this event in alphabetical
    # order as a string, delimited by the supplied delimiter.
    # 
    # @param [String] delimiter a String containing the desired delimiter.
    # @return [String]  a String containing delimited alphabetized parameter names.
    # 
    def names_to_s_delim(delimiter)
      
      all_param_names = @values.keys.sort
      
      all_param_names.join(delimiter)
      
    end
    
    ##
    # Gets the values of the parameters associated with this event ordered 
    # alphabetically by the parameter names (i.e. in the same order as when calling
    # {#names_to_s_delim}), delimited by the supplied delimiter.
    # 
    # @param [String]delimiter a String containing the desired delimiter.
    # @return [String]  a String containing delimited ordered parameter values.
    #
    def to_s_delim(delimiter)
            
      all_param_names = @values.keys.sort
      
      all_param_values = all_param_names.map{|e| @values[e].value}
      
      all_param_values.join(delimiter)
      
    end
    
    ##
    # Converts the event to a string representation.  This is the same as calling
    # {#to_s_delim} with the delimiter set to {FCSEvent::DefaultDelimiter}.
    # 
    # @return [String]  a String containing delimited ordered parameter values.
    #
    def to_s
      
      to_s_delim(DefaultDelimiter)
      
    end

  end
  
end
