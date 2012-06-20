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

module FCSParse

#header constants

  H_VersionStart = 0
  H_VersionEnd = 5
  
  H_OffsetBlockLength = 8
  
  H_TextBlockOffsetStart = 10
  H_TextBlockOffsetEnd = 18
  
  H_DataBlockOffsetStart = 26
  H_DataBlockOffsetEnd = 34
  
  H_AnalysisBlockOffsetStart = 42 
  H_AnalysisBlockOffsetEnd = 50
  
  T_SupplTextStartKeyword = :$BEGINSTEXT
  T_SupplTextEndKeyword = :$ENDSTEXT
  
  T_AnalysisStartKeyword = :$BEGINANALYSIS
  T_AnalysisEndKeyword = :$BEGINANALYSIS
  
  T_DataStartKeyword = :$BEGINDATA
  T_DataEndKeyword = :$ENDDATA
  
  T_ModeKeyword = :$MODE
  
  T_DatatypeKeyword = :$DATATYPE
  
  T_ByteorderKeyword = :$BYTEORD
  T_LittleEndianByteorder = "1,2,3,4"
  
  T_ParameterCountKeyword = :$PAR
  
  T_EventCountKeyword = :$TOT
  
  T_ParameterNameKeywordRegex = /P(\d+)N/
  T_ParameterRangeKeywordRegex = /P(\d+)R/

end