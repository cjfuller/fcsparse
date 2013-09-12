A simple ruby parser for FCS-formatted flow cytometry data files.  Supports writing of data and metadata to human-readable delimited text files or use as a library for further data analysis in ruby.

Requires a ruby interpreter (e.g. [http://ruby-lang.org](http://ruby-lang.org) with rubygems installed (this is installed by default for recent versions).  Tested only on ruby versions 1.8.7 and 1.9.3.

Currently processes v3.x FCS files only, and is limited at the moment to those with the data section in list mode and with floating point (single- or double-precision) data.

API docs are available at [http://rdoc.info/gems/fcsparse](http://rdoc.info/gems/fcsparse).

To install as a ruby gem, run at the command line:
```
gem install fcsparse
```
(The gem can also be downloaded from [https://rubygems.org/gems/fcsparse](https://rubygems.org/gems/fcsparse).)


To run from the command line, install the gem, and run from the command line:
```
fcsparse /path/to/mydata.fcs
```
where `/path/to/mydata.fcs` is the full path to the file you want to process.

The output is written into two files, each with the same name as the input file, with an extra extension.

The first file, ending in .txt, contains all the metadata contained in the FCS file, which may contain 
information about the experiment as well as information about how to parse the original data file.

The second file, ending in .csv, contains comma-separated columns of numbers that are all the datapoints 
for the file. Each parameter measured is one column and each flow cytometry event is a row. By default, 
a header row is written to the file that contains the name of each parameter.

To process a file into human-readable comma-delimited data from ruby code (`require 'rubygems'` first for ruby 1.8):
```
require 'fcsparse'

FCSParse.process_file(filename, include_header_row)
```
where `filename` is the name (with path) to your FCS-formatted file, and `include_header_row` is an optional 
boolean parameter that specifies whether to write a title for each column in the output file.
