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

##
# Contains all classes and constants for parsing FCS v3.x formatted files.
#
module FCSParse
  
  #
  # Contains constants associated with the fcs file format, such as byte offsets
  # and parameter names.
  # 
  # The first character of each constant name specifies the section of the fcs file
  # to which it is relevant.  (H = header, T = text, etc.)
  # 
  # @author Colin J. Fuller
  #
  
  #byte offsets to the start and end of the version string
  H_VersionStart = 0
  H_VersionEnd = 5
  
  #length of the block specifying the offsets of text, data, analysis sections
  H_OffsetBlockLength = 8
  
  #offsets to the start and end of the text section offset
  H_TextBlockOffsetStart = 10
  H_TextBlockOffsetEnd = 18
  
  #offsets to the start and end of the data section offset
  H_DataBlockOffsetStart = 26
  H_DataBlockOffsetEnd = 34
  
  #offsets to the start and end of the analysis section offset
  H_AnalysisBlockOffsetStart = 42 
  H_AnalysisBlockOffsetEnd = 50
  
  #keyword specifying offset to supplementary text section
  T_SupplTextStartKeyword = :$BEGINSTEXT
  T_SupplTextEndKeyword = :$ENDSTEXT
  
  #keyword specifying offset to analysis section
  T_AnalysisStartKeyword = :$BEGINANALYSIS
  T_AnalysisEndKeyword = :$BEGINANALYSIS
  
  #keyword specifying offset to data section
  T_DataStartKeyword = :$BEGINDATA
  T_DataEndKeyword = :$ENDDATA
  
  #keyword specifying the data mode
  T_ModeKeyword = :$MODE
  
  #keyword specifying the data type (e.g. integer, float, etc)
  T_DatatypeKeyword = :$DATATYPE
  
  #keyword specifying byte order and value when little endian
  T_ByteorderKeyword = :$BYTEORD
  T_LittleEndianByteorder = "1,2,3,4"
  
  #keyword specifying the number of parameters measured per event
  T_ParameterCountKeyword = :$PAR
  
  #keyword specifying total number of events
  T_EventCountKeyword = :$TOT
  
  #regular expressions matching names and ranges of all parameters
  T_ParameterNameKeywordRegex = /P(\d+)N/
  T_ParameterRangeKeywordRegex = /P(\d+)R/

end