#!/usr/bin/env ruby

class SequenceGrid
  attr_writer :file_name, :seq1, :seq2, :match_value, :mismatch_penalty, :gap_penalty, :debug_on
  
  def initialize(file_name, seq1, seq2, match_value, mismatch_penalty, gap_penalty, debug_on = false)
    @file_name = file_name
    @col_length = seq1.length + 1
    @row_length = seq2.length + 1
    @seq1 = seq1
    @seq2 = seq2
    @match_value = match_value
    @mismatch_penalty = mismatch_penalty
    @gap_penalty = gap_penalty
    @debug_on = debug_on
    @grid = []
    @trace_grid = []
    fill_first_col_and_row_with_zeroes
  end
  
  def fill_first_col_and_row_with_zeroes
  	@row_length.times do
  	  @grid << []
  	  @trace_grid << []
  	end
  	@col_length.times do # add all 0s to 0th row of grid
  	  @grid[0] << 0
  	  @trace_grid[0] << 0
  	end
  	i = 1
  	(@row_length - 1).times do
  	  @grid[i] << 0
  	  @trace_grid[i] << 0
  	  (@col_length - 1).times do
  	    @grid[i] << '?'
  	    @trace_grid[i] << '?'
      end
      i = i + 1
  	end
  end

  def show_grid
    print "       #{@seq1.join('   ')}\n" # print seq1
    print "   ", @grid[0].join('   '), "\n" # print 0th row
    i = 1
    while i < @row_length
      print @seq2[i-1], ' '; 
      @grid[i].each do |elem|
        if elem.is_a?(Fixnum) && elem > -1
          print "+#{elem}  "
        else
          print "#{elem}  "
        end     
      end
      print "\n"
      i = i + 1
    end
    print "\n"
  end
  
  def show_trace_grid
    print "     #{@seq1.join('  ')}\n" # print seq1
    print "  ", @trace_grid[0].join('  '), "\n" # print 0th row
    i = 1
    while i < @row_length
      print @seq2[i-1], ' '; 
      @trace_grid[i].each {|elem| print "#{elem}  "}
      print "\n"
      i = i + 1
    end
    print "\n"
  end
  
  def grid_value(row_pos, col_pos)
    max_vals = []
    if @seq2[row_pos - 1] == @seq1[col_pos - 1]
      diag = @match_value + @grid[row_pos - 1][col_pos - 1]
    else 
      diag = @mismatch_penalty + @grid[row_pos - 1][col_pos - 1]
    end
    left = @gap_penalty + @grid[row_pos][col_pos - 1]
    up = @gap_penalty + @grid[row_pos - 1][col_pos]
    if diag > left && diag > up
      @trace_grid[row_pos][col_pos] = 'D'
      return diag
    elsif left > diag && left > up
      @trace_grid[row_pos][col_pos] = 'L'
      return left
    elsif up > diag && up > left
      @trace_grid[row_pos][col_pos] = 'U'
      return up
    elsif diag == left || diag == up
      @trace_grid[row_pos][col_pos] = 'D'
      return diag
    elsif left == up
      @trace_grid[row_pos][col_pos] = 'L'
      return left
    end
  end
  
  def fill_in_grid
    col_pos = 1
    while col_pos < @col_length
      row_pos = 1 
      while row_pos < @row_length
        @grid[row_pos][col_pos] = grid_value(row_pos, col_pos)
        row_pos = row_pos + 1
      end
      col_pos = col_pos + 1
    end
    show_grid if @debug_on
    show_trace_grid if @debug_on
  end
  
  def gather_trace
    trace = []
    row_pos = @row_length - 1
    col_pos = @col_length - 1
    done = false
    while !done
      cur_val = @trace_grid[row_pos][col_pos]
      trace << cur_val
      if cur_val == 'D'
        row_pos = row_pos - 1
        col_pos = col_pos - 1
      elsif cur_val == 'L'
        col_pos = col_pos - 1
      elsif cur_val == 'U'
        row_pos = row_pos - 1
      end
      if (row_pos == 0) && (col_pos == 0)
        done = true
      end
    end
    trace
  end
  
  def calculate_solution
    new_seq1 = []
    new_seq2 = []
    trace = gather_trace
    puts trace.join(' ') if @debug_on
    seq1_pos = @seq1.length - 1
    seq2_pos = @seq2.length - 1
    trace.each do |mark|
      if mark == 'D'
        new_seq1 << @seq1[seq1_pos]
        seq1_pos = seq1_pos - 1
        new_seq2 << @seq2[seq2_pos]
        seq2_pos = seq2_pos - 1
      elsif mark == 'L'
        new_seq1 << @seq1[seq1_pos]
        seq1_pos = seq1_pos - 1
        new_seq2 << '-' 
      elsif mark == 'U'
        new_seq1 << '-'
        new_seq2 << @seq2[seq2_pos]
        seq2_pos = seq2_pos - 1
      end
    end
    new_seq1.reverse!
    new_seq2.reverse!
    puts "Solution for #{@file_name}: "
    puts new_seq1.join(' ')
    puts new_seq2.join(' ')
  end
  
end # SequenceGrid

if ARGV.length < 4
  puts "usage: p4 <file> <match_value> <mismatch_penalty> <gap_penalty>"
  exit
end

in_file_name = ARGV[0]
match_value = ARGV[1].to_i
mismatch_penalty = ARGV[2].to_i
gap_penalty = ARGV[3].to_i
in_file = File.new(in_file_name, 'r')
if !in_file
  puts "Error reading file #{in_file_name}" 
  exit
end

seqs = []
lines = in_file.readlines

lines.each do |line|
  seqs << line.chomp.gsub(/ /,'').scan(/./) if !(line =~ /#/) && (line =~ /[GATC]+/) # remove newlines, whitespace, and covert to char array
end

seqs.sort! { |a, b| b.length <=> a.length }
if (seqs.length != 2) 
  puts "Error parsing file"
  exit
end

seq1, seq2 = seqs
debug_on = true if ARGV.include?('-d')
seq_grid = SequenceGrid.new(in_file_name, seq1, seq2, match_value, mismatch_penalty, gap_penalty, debug_on || false)
seq_grid.fill_in_grid
seq_grid.calculate_solution







