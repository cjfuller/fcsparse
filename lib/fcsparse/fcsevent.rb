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

module FCSParse
  
  class FCSParam
    
    def initialize(name, description, value, limit)
      
      @name = name
      @description = description
      @value = value
      @limit = limit
      
    end
    
    attr_accessor :name, :description, :value, :limit
    
  end
  
  class FCSEvent
    
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
    
    
    
    def initialize
      
      @values = Hash.new
      
    end
    
    def [](parameter_name)
      
      @values[parameter_name]
      
    end
    
    def []=(parameter_name, value)
      
      @values[parameter_name]= value
      
    end
    
    def names_to_s_delim(delimiter)
      
      all_param_names = @values.keys.sort
      
      all_param_names.join(delimiter)
      
    end
    
    def to_s_delim(delimiter)
            
      all_param_names = @values.keys.sort
      
      all_param_values = all_param_names.map{|e| @values[e].value}
      
      all_param_values.join(delimiter)
      
    end
    
    def to_s
      
      to_s_delim(",")
      
    end

  end
  
end
